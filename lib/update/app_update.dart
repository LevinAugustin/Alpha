import 'dart:convert';
import 'dart:io';

import 'package:flexify/logging.dart';
import 'package:flexify/main.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';

const githubReleasesUrl =
    'https://api.github.com/repos/LevinAugustin/Alpha/releases/latest';

class AppRelease {
  const AppRelease({required this.version, required this.apkUrl});

  final String version;
  final String apkUrl;
}

final pendingAppUpdate = ValueNotifier<AppRelease?>(null);

Future<bool> checkForAppUpdate() async {
  try {
    final latest = await _latestRelease();
    if (latest == null) return true;
    final current = (await PackageInfo.fromPlatform()).version;
    if (!_isNewer(latest.version, current)) {
      pendingAppUpdate.value = null;
      return true;
    }
    pendingAppUpdate.value = latest;
    return true;
  } catch (error, stack) {
    talker.handle(error, stack, 'Update check failed');
    return false;
  }
}

Future<AppRelease?> _latestRelease() async {
  final client = HttpClient();
  try {
    final request = await client
        .getUrl(Uri.parse(githubReleasesUrl))
        .timeout(const Duration(seconds: 8));
    request.headers.set(HttpHeaders.userAgentHeader, 'Alpha');
    request.headers.set(
      HttpHeaders.acceptHeader,
      'application/vnd.github+json',
    );
    final response = await request.close().timeout(const Duration(seconds: 8));
    if (response.statusCode != 200) return null;
    final body = await response.transform(utf8.decoder).join();
    final json = jsonDecode(body) as Map<String, dynamic>;
    final tag = (json['tag_name'] as String?) ?? '';
    final assets = json['assets'] as List<dynamic>? ?? const [];
    String? apkUrl;
    for (final asset in assets) {
      final row = Map<String, dynamic>.from(asset as Map);
      final name = (row['name'] as String?) ?? '';
      if (name.endsWith('.apk')) {
        apkUrl = row['browser_download_url'] as String?;
        break;
      }
    }
    if (apkUrl == null || tag.isEmpty) return null;
    return AppRelease(
      version: tag.replaceFirst(RegExp(r'^v'), ''),
      apkUrl: apkUrl,
    );
  } finally {
    client.close(force: true);
  }
}

bool _isNewer(String latest, String current) {
  final next = _parts(latest);
  final now = _parts(current);
  final length = next.length > now.length ? next.length : now.length;
  for (var index = 0; index < length; index++) {
    final a = index < next.length ? next[index] : 0;
    final b = index < now.length ? now[index] : 0;
    if (a != b) return a > b;
  }
  return false;
}

List<int> _parts(String version) {
  return version
      .split('+')
      .first
      .split('.')
      .map((part) => int.tryParse(part) ?? 0)
      .toList();
}

Future<void> downloadAndInstallUpdate(AppRelease release) async {
  final client = HttpClient();
  final directory = await getTemporaryDirectory();
  final file = File('${directory.path}/alpha-update.apk');
  try {
    final request = await client.getUrl(Uri.parse(release.apkUrl));
    request.headers.set(HttpHeaders.userAgentHeader, 'Alpha');
    final response = await request.close();
    if (response.statusCode != 200) {
      throw HttpException('Download failed (${response.statusCode})');
    }
    final sink = file.openWrite();
    await response.pipe(sink);
  } finally {
    client.close(force: true);
  }
  if (kIsWeb || !Platform.isAndroid) return;
  await androidChannel.invokeMethod<void>('installApk', {'path': file.path});
}
