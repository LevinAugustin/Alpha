import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flexify/l10n/l10n.dart';
import 'package:flexify/logging.dart';
import 'package:flexify/main.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

const githubReleasesUrl =
    'https://api.github.com/repos/LevinAugustin/Alpha/releases/latest';

const updateConnectTimeout = Duration(seconds: 20);
const updateIdleTimeout = Duration(seconds: 30);

class AppRelease {
  const AppRelease({
    required this.version,
    required this.apkUrl,
    this.sizeBytes,
  });

  final String version;
  final String apkUrl;
  final int? sizeBytes;
}

class UpdateCheckException implements Exception {
  const UpdateCheckException(this.message);

  final String message;

  @override
  String toString() => message;
}

enum InstallApkResult { started, background, needsPermission }

class UpdateDownloadLock {
  bool _held = false;

  bool get held => _held;

  bool tryAcquire() {
    if (_held) return false;
    _held = true;
    return true;
  }

  void release() {
    _held = false;
  }
}

final updateDownloadLock = UpdateDownloadLock();
final pendingAppUpdate = ValueNotifier<AppRelease?>(null);
final updateCheckFailed = ValueNotifier<bool>(false);
final updateCheckCompleted = ValueNotifier<bool>(false);
final pendingInstallPath = ValueNotifier<String?>(null);

class VersionParts {
  const VersionParts(this.numbers, this.build);

  final List<int> numbers;
  final int? build;
}

VersionParts parseVersion(String raw) {
  final cleaned = raw.trim().replaceFirst(RegExp(r'^v'), '');
  final pieces = cleaned.split('+');
  final numbers = pieces.first
      .split('.')
      .where((part) => part.isNotEmpty)
      .map((part) => int.tryParse(part) ?? 0)
      .toList();
  final build = pieces.length > 1
      ? int.tryParse(pieces[1].split(RegExp(r'[^0-9]')).first)
      : null;
  return VersionParts(numbers, build);
}

int normalizeBuildNumber(int value) {
  final suffix = value % 100;
  if (value >= 100 && suffix >= 1 && suffix <= 3) return value ~/ 100;
  return value;
}

bool isNewerRelease({
  required String latest,
  required String currentVersion,
  required String currentBuild,
}) {
  final next = parseVersion(latest);
  final now = parseVersion(currentVersion);
  final length = next.numbers.length > now.numbers.length
      ? next.numbers.length
      : now.numbers.length;
  for (var index = 0; index < length; index++) {
    final published = index < next.numbers.length ? next.numbers[index] : 0;
    final installed = index < now.numbers.length ? now.numbers[index] : 0;
    if (published != installed) return published > installed;
  }
  if (next.build == null) return false;
  final currentRaw = int.tryParse(currentBuild.trim()) ?? now.build ?? 0;
  return normalizeBuildNumber(next.build!) > normalizeBuildNumber(currentRaw);
}

AppRelease parseGithubRelease({required int statusCode, required String body}) {
  if (statusCode != 200) {
    throw UpdateCheckException('HTTP $statusCode');
  }
  final Map<String, dynamic> json;
  try {
    final decoded = jsonDecode(body);
    if (decoded is! Map) throw const FormatException('release');
    json = Map<String, dynamic>.from(decoded);
  } catch (_) {
    throw const UpdateCheckException('HTTP 200');
  }
  final tag = (json['tag_name'] as String?) ?? '';
  final assets = json['assets'] as List<dynamic>? ?? const [];
  String? apkUrl;
  int? sizeBytes;
  for (final asset in assets) {
    if (asset is! Map) continue;
    final row = Map<String, dynamic>.from(asset);
    final name = (row['name'] as String?) ?? '';
    if (!name.endsWith('.apk')) continue;
    final url = row['browser_download_url'] as String?;
    if (url == null || url.isEmpty) continue;
    final size = row['size'];
    apkUrl = url;
    sizeBytes = size is int ? size : (size is num ? size.toInt() : null);
    if (name == 'alpha.apk') break;
  }
  if (apkUrl == null || tag.trim().isEmpty) {
    throw const UpdateCheckException('no apk');
  }
  return AppRelease(
    version: tag.replaceFirst(RegExp(r'^v'), ''),
    apkUrl: apkUrl,
    sizeBytes: sizeBytes,
  );
}

void validateDownloadedApk({
  required int statusCode,
  required int bytes,
  int? expectedBytes,
}) {
  if (statusCode != 200) {
    throw UpdateCheckException('HTTP $statusCode');
  }
  if (bytes <= 0) {
    throw const UpdateCheckException('empty');
  }
  if (expectedBytes != null && expectedBytes > 0 && bytes != expectedBytes) {
    throw UpdateCheckException('size $bytes != $expectedBytes');
  }
}

InstallApkResult parseInstallResult(Object? value) {
  return switch (value) {
    'started' || true => InstallApkResult.started,
    'needs_permission' => InstallApkResult.needsPermission,
    _ => InstallApkResult.background,
  };
}

String formatUpdateMegabytes(int bytes) {
  return (bytes / (1024 * 1024)).toStringAsFixed(1);
}

String updateApkName(String version, int stamp) {
  final safe = version.replaceAll(RegExp(r'[^A-Za-z0-9._+-]+'), '_');
  return 'alpha-update-$safe-$stamp.apk';
}

int deleteStaleUpdateApks(Directory directory, {String? keepName}) {
  if (!directory.existsSync()) return 0;
  var removed = 0;
  for (final entity in directory.listSync()) {
    if (entity is! File) continue;
    final name = entity.path.split(Platform.pathSeparator).last;
    if (!name.startsWith('alpha-update') || !name.endsWith('.apk')) continue;
    if (keepName != null && name == keepName) continue;
    entity.deleteSync();
    removed++;
  }
  return removed;
}

Future<bool> checkForAppUpdate() async {
  try {
    final latest = await _latestRelease();
    final info = await PackageInfo.fromPlatform();
    updateCheckFailed.value = false;
    updateCheckCompleted.value = true;
    if (!isNewerRelease(
      latest: latest.version,
      currentVersion: info.version,
      currentBuild: info.buildNumber,
    )) {
      pendingAppUpdate.value = null;
      return true;
    }
    pendingAppUpdate.value = latest;
    return true;
  } catch (error, stack) {
    talker.handle(error, stack, 'Update check failed');
    updateCheckFailed.value = true;
    updateCheckCompleted.value = true;
    return false;
  }
}

Future<AppRelease> _latestRelease() async {
  final client = HttpClient();
  try {
    final request = await client
        .getUrl(Uri.parse(githubReleasesUrl))
        .timeout(updateConnectTimeout);
    request.headers.set(HttpHeaders.userAgentHeader, 'Alpha');
    request.headers.set(
      HttpHeaders.acceptHeader,
      'application/vnd.github+json',
    );
    final response = await request.close().timeout(updateConnectTimeout);
    final body = await response
        .transform(utf8.decoder)
        .join()
        .timeout(updateConnectTimeout);
    return parseGithubRelease(statusCode: response.statusCode, body: body);
  } finally {
    client.close(force: true);
  }
}

UpdateInstaller? _updateInstaller;

void ensureUpdateInstaller() {
  _updateInstaller ??= UpdateInstaller();
}

class UpdateInstaller with WidgetsBindingObserver {
  UpdateInstaller() {
    WidgetsBinding.instance.addObserver(this);
  }

  AppRelease? _resumeRelease;
  var _waitingForPermission = false;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed || !_waitingForPermission) return;
    final release = _resumeRelease;
    _waitingForPermission = false;
    _resumeRelease = null;
    if (release == null) {
      updateDownloadLock.release();
      return;
    }
    unawaited(_continueAfterPermission(release));
  }

  Future<void> _continueAfterPermission(AppRelease release) async {
    final context = navigatorKey.currentContext;
    try {
      if (!await canInstallPackages()) {
        if (context != null && context.mounted) {
          await showUpdateFailure(
            context,
            const UpdateCheckException('needs_permission'),
            release.apkUrl,
          );
        }
        return;
      }
      if (context == null || !context.mounted) return;
      await _downloadAndInstall(context, release);
    } catch (error) {
      final current = navigatorKey.currentContext;
      if (current != null && current.mounted) {
        await showUpdateFailure(current, error, release.apkUrl);
      }
    } finally {
      updateDownloadLock.release();
    }
  }
}

Future<void> installAppUpdate(BuildContext context, AppRelease release) async {
  ensureUpdateInstaller();
  if (!updateDownloadLock.tryAcquire()) return;
  var releaseLock = true;
  try {
    if (!await canInstallPackages()) {
      if (!context.mounted) return;
      final open = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(context.l10n.installPermissionTitle),
          content: Text(context.l10n.installPermissionBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(context.l10n.actionCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(context.l10n.openInstallSettings),
            ),
          ],
        ),
      );
      if (open != true) return;
      _updateInstaller!._waitingForPermission = true;
      _updateInstaller!._resumeRelease = release;
      releaseLock = false;
      try {
        await _openInstallPermission();
      } catch (error) {
        _updateInstaller!._waitingForPermission = false;
        _updateInstaller!._resumeRelease = null;
        releaseLock = true;
        rethrow;
      }
      return;
    }
    if (!context.mounted) return;
    await _downloadAndInstall(context, release);
  } finally {
    if (releaseLock) updateDownloadLock.release();
  }
}

Future<void> installDownloadedUpdate(BuildContext context) async {
  final path = pendingInstallPath.value;
  if (path == null || path.isEmpty) return;
  final result = await _invokeInstall(path);
  if (result == InstallApkResult.started) {
    pendingInstallPath.value = null;
    return;
  }
  if (result == InstallApkResult.needsPermission) {
    throw const UpdateCheckException('needs_permission');
  }
  if (!context.mounted) return;
  ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(context.l10n.tapToInstall)));
}

Future<void> _downloadAndInstall(
  BuildContext context,
  AppRelease release,
) async {
  final progress = ValueNotifier<(int, int?)>((0, release.sizeBytes));
  var dialogOpen = false;
  NavigatorState? dialogNavigator;
  if (context.mounted) {
    dialogOpen = true;
    dialogNavigator = Navigator.of(context, rootNavigator: true);
    unawaited(
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        useRootNavigator: true,
        builder: (context) {
          return ValueListenableBuilder<(int, int?)>(
            valueListenable: progress,
            builder: (context, value, _) {
              final total = value.$2;
              final fraction = total == null || total <= 0
                  ? null
                  : (value.$1 / total).clamp(0.0, 1.0);
              return AlertDialog(
                title: Text(context.l10n.downloadingUpdate),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    LinearProgressIndicator(value: fraction),
                    const SizedBox(height: 12),
                    Text(
                      context.l10n.updateDownloadProgress(
                        formatUpdateMegabytes(value.$1),
                        formatUpdateMegabytes(total ?? 0),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
    await WidgetsBinding.instance.endOfFrame;
  }
  File? file;
  try {
    final directory = await getTemporaryDirectory();
    file = await downloadUpdateApk(
      release,
      directory,
      onProgress: (received, total) => progress.value = (received, total),
    );
  } finally {
    if (dialogOpen && dialogNavigator != null && dialogNavigator.mounted) {
      dialogNavigator.pop();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      progress.dispose();
    });
  }
  if (!context.mounted) return;
  await _finishInstall(context, release, file);
}

Future<File> downloadUpdateApk(
  AppRelease release,
  Directory directory, {
  void Function(int received, int? total)? onProgress,
  HttpClient? client,
  Duration connectTimeout = updateConnectTimeout,
  Duration idleTimeout = updateIdleTimeout,
}) async {
  final name = updateApkName(
    release.version,
    DateTime.now().microsecondsSinceEpoch,
  );
  deleteStaleUpdateApks(directory);
  final file = File('${directory.path}${Platform.pathSeparator}$name');
  final http = client ?? HttpClient();
  final ownsClient = client == null;
  try {
    final request = await http
        .getUrl(Uri.parse(release.apkUrl))
        .timeout(connectTimeout);
    request.headers.set(HttpHeaders.userAgentHeader, 'Alpha');
    final response = await request.close().timeout(connectTimeout);
    if (response.statusCode != 200) {
      await response.drain<void>();
      throw UpdateCheckException('HTTP ${response.statusCode}');
    }
    final expected = response.contentLength > 0
        ? response.contentLength
        : release.sizeBytes;
    final sink = file.openWrite();
    var received = 0;
    var closed = false;
    Future<void> closeSink() async {
      if (closed) return;
      closed = true;
      await sink.close();
    }

    try {
      await for (final chunk in response.timeout(idleTimeout)) {
        received += chunk.length;
        sink.add(chunk);
        onProgress?.call(received, expected);
      }
      await closeSink();
    } catch (error) {
      await closeSink();
      if (file.existsSync()) file.deleteSync();
      rethrow;
    }
    try {
      validateDownloadedApk(
        statusCode: response.statusCode,
        bytes: received,
        expectedBytes: expected,
      );
      final publishedSize = release.sizeBytes;
      if (publishedSize != null &&
          publishedSize > 0 &&
          received != publishedSize) {
        throw UpdateCheckException('size $received != $publishedSize');
      }
    } catch (error) {
      if (file.existsSync()) file.deleteSync();
      rethrow;
    }
    return file;
  } finally {
    if (ownsClient) http.close(force: true);
  }
}

Future<void> _finishInstall(
  BuildContext context,
  AppRelease release,
  File file,
) async {
  final result = await _invokeInstall(file.path);
  switch (result) {
    case InstallApkResult.started:
      pendingInstallPath.value = null;
    case InstallApkResult.needsPermission:
      throw const UpdateCheckException('needs_permission');
    case InstallApkResult.background:
      pendingInstallPath.value = file.path;
      if (!context.mounted) return;
      await _showInstallNotification(context.l10n.tapToInstall);
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.tapToInstall)));
  }
}

Future<bool> canInstallPackages() async {
  if (kIsWeb || !Platform.isAndroid) return true;
  try {
    final allowed = await androidChannel.invokeMethod<bool>(
      'canInstallPackages',
    );
    return allowed ?? false;
  } on MissingPluginException {
    return false;
  }
}

Future<void> _openInstallPermission() async {
  if (kIsWeb || !Platform.isAndroid) return;
  await androidChannel.invokeMethod<void>('openInstallPermission');
}

Future<InstallApkResult> _invokeInstall(String path) async {
  if (kIsWeb || !Platform.isAndroid) return InstallApkResult.started;
  final value = await androidChannel.invokeMethod<Object>('installApk', {
    'path': path,
  });
  return parseInstallResult(value);
}

Future<void> _showInstallNotification(String title) async {
  if (kIsWeb || !Platform.isAndroid) return;
  try {
    await androidChannel.invokeMethod<void>('showInstallNotification', {
      'title': title,
    });
  } catch (error, stack) {
    talker.handle(error, stack, 'Update notification failed');
  }
}

Future<void> showUpdateFailure(
  BuildContext context,
  Object error,
  String apkUrl,
) {
  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(context.l10n.updateInstallFailed),
      content: Text('$error'),
      actions: [
        if (apkUrl.isNotEmpty)
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              launchUrlString(apkUrl, mode: LaunchMode.externalApplication);
            },
            child: Text(context.l10n.downloadInBrowser),
          ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(context.l10n.actionClose),
        ),
      ],
    ),
  );
}

String updateStatusLabel({
  required bool failed,
  required bool completed,
  required AppRelease? release,
  required String failedLabel,
  required String availableLabel,
  required String currentLabel,
  required String idleLabel,
}) {
  if (release != null) return availableLabel;
  if (failed) return failedLabel;
  if (completed) return currentLabel;
  return idleLabel;
}
