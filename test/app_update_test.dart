import 'dart:async';
import 'dart:io';

import 'package:flexify/shell/calendar_page.dart';
import 'package:flexify/theme/alpha_theme.dart';
import 'package:flexify/update/app_update.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(() {
    pendingAppUpdate.value = null;
    updateCheckFailed.value = false;
    updateCheckCompleted.value = false;
  });

  test('the startup check retries once before it reports failure', () async {
    var calls = 0;
    final ok = await checkForAppUpdate(
      retry: true,
      retryDelay: Duration.zero,
      loadRelease: () async {
        calls += 1;
        expect(updateCheckFailed.value, isFalse);
        if (calls == 1) throw const HandshakeException('handshake');
        return const AppRelease(
          version: '0.0.1',
          apkUrl: 'https://example.test/alpha.apk?sig=secret',
        );
      },
      loadPackage: () async => (version: '9.9.9', buildNumber: '1'),
    );
    expect(ok, isTrue);
    expect(calls, 2);
    expect(updateCheckFailed.value, isFalse);
  });

  test('a second failed check is shown as a failed search', () async {
    var calls = 0;
    final ok = await checkForAppUpdate(
      retry: true,
      retryDelay: Duration.zero,
      loadRelease: () async {
        calls += 1;
        expect(updateCheckFailed.value, isFalse);
        throw const HandshakeException('handshake');
      },
      loadPackage: () async => (version: '9.9.9', buildNumber: '1'),
    );
    expect(ok, isFalse);
    expect(calls, 2);
    expect(updateCheckFailed.value, isTrue);
    expect(updateCheckCompleted.value, isTrue);
  });

  test('download failures stay short and omit signed urls', () {
    final http = describeUpdateFailure(const UpdateCheckException('HTTP 403'));
    expect(http.problem, UpdateProblem.http);
    expect(http.statusCode, 403);
    expect(http.isDownload, isTrue);

    final empty = describeUpdateFailure(const UpdateCheckException('empty'));
    expect(empty.problem, UpdateProblem.empty);
    expect(empty.isDownload, isTrue);

    final size = describeUpdateFailure(
      const UpdateCheckException('size 4 != 10'),
    );
    expect(size.problem, UpdateProblem.size);

    final timeout = describeUpdateFailure(
      TimeoutException('https://example.test/alpha.apk?sig=secret'),
    );
    expect(timeout.problem, UpdateProblem.timeout);
    expect(timeout.details.contains('http'), isFalse);
    expect(timeout.details.contains('sig='), isFalse);

    final network = describeUpdateFailure(
      const HandshakeException('handshake'),
    );
    expect(network.problem, UpdateProblem.network);
    expect(network.isDownload, isTrue);

    final install = describeUpdateFailure(
      PlatformException(code: 'install_failed', message: 'no activity'),
    );
    expect(install.problem, UpdateProblem.install);
    expect(install.isDownload, isFalse);

    final permission = describeUpdateFailure(
      const UpdateCheckException('needs_permission'),
    );
    expect(permission.isDownload, isFalse);
  });

  test('the progress fill contrasts with the track in every theme', () {
    for (final palette in const [
      AlphaPalette.tiefschwarz,
      AlphaPalette.eisblau,
      AlphaPalette.pink,
    ]) {
      final colors = updateProgressColors(palette);
      expect(
        calendarContrast(colors.fill, colors.track),
        greaterThanOrEqualTo(3),
      );
    }
  });

  test('newer release compares the name and the normalized build', () {
    expect(
      isNewerRelease(
        latest: '2.5.2',
        currentVersion: '2.5.1',
        currentBuild: '45303',
      ),
      isTrue,
    );
    expect(
      isNewerRelease(
        latest: 'v2.5.1',
        currentVersion: '2.5.2',
        currentBuild: '45403',
      ),
      isFalse,
    );
    expect(
      isNewerRelease(
        latest: '2.5.2',
        currentVersion: '2.5.2',
        currentBuild: '45303',
      ),
      isFalse,
    );
    expect(
      isNewerRelease(
        latest: '2.5.2+454',
        currentVersion: '2.5.2',
        currentBuild: '453',
      ),
      isTrue,
    );
    expect(
      isNewerRelease(
        latest: '2.5.2+454',
        currentVersion: '2.5.2',
        currentBuild: '45303',
      ),
      isTrue,
    );
    expect(
      isNewerRelease(
        latest: '2.5.2+454',
        currentVersion: '2.5.2',
        currentBuild: '45403',
      ),
      isFalse,
    );
    expect(
      isNewerRelease(
        latest: '2.5.2+45403',
        currentVersion: '2.5.2',
        currentBuild: '454',
      ),
      isFalse,
    );
    expect(
      isNewerRelease(
        latest: '2.5.2+45403',
        currentVersion: '2.5.2',
        currentBuild: '45303',
      ),
      isTrue,
    );
    expect(normalizeBuildNumber(45403), 454);
    expect(normalizeBuildNumber(45302), 453);
    expect(normalizeBuildNumber(45201), 452);
    expect(normalizeBuildNumber(454), 454);
  });

  test('release parsing reports HTTP errors and prefers alpha.apk', () {
    expect(
      () => parseGithubRelease(statusCode: 403, body: '{"message":"no"}'),
      throwsA(
        isA<UpdateCheckException>().having(
          (error) => error.message,
          'message',
          contains('403'),
        ),
      ),
    );
    expect(
      () => parseGithubRelease(statusCode: 200, body: 'not-json'),
      throwsA(isA<UpdateCheckException>()),
    );
    expect(
      () => parseGithubRelease(
        statusCode: 200,
        body: '{"tag_name":"v2.5.2","assets":[]}',
      ),
      throwsA(
        isA<UpdateCheckException>().having(
          (error) => error.message,
          'message',
          'no apk',
        ),
      ),
    );

    final release = parseGithubRelease(
      statusCode: 200,
      body: '''
{
  "tag_name": "v2.5.2",
  "assets": [
    {
      "name": "other.apk",
      "browser_download_url": "https://example.test/other.apk",
      "size": 10
    },
    {
      "name": "alpha.apk",
      "browser_download_url": "https://example.test/alpha.apk",
      "size": 75000000
    }
  ]
}
''',
    );
    expect(release.version, '2.5.2');
    expect(release.apkUrl, 'https://example.test/alpha.apk');
    expect(release.sizeBytes, 75000000);
  });

  test(
    'downloaded bytes must be a successful non-empty file of the right size',
    () {
      expect(
        () =>
            validateDownloadedApk(statusCode: 404, bytes: 4, expectedBytes: 4),
        throwsA(
          isA<UpdateCheckException>().having(
            (error) => error.message,
            'message',
            contains('404'),
          ),
        ),
      );
      expect(
        () =>
            validateDownloadedApk(statusCode: 200, bytes: 0, expectedBytes: 4),
        throwsA(
          isA<UpdateCheckException>().having(
            (error) => error.message,
            'message',
            'empty',
          ),
        ),
      );
      expect(
        () =>
            validateDownloadedApk(statusCode: 200, bytes: 3, expectedBytes: 4),
        throwsA(isA<UpdateCheckException>()),
      );
      validateDownloadedApk(statusCode: 200, bytes: 4, expectedBytes: 4);
    },
  );

  test('download lock rejects a second tap until it is released', () {
    final lock = UpdateDownloadLock();
    expect(lock.tryAcquire(), isTrue);
    expect(lock.held, isTrue);
    expect(lock.tryAcquire(), isFalse);
    lock.release();
    expect(lock.held, isFalse);
    expect(lock.tryAcquire(), isTrue);
    lock.release();
  });

  test('old update APKs are removed and other cache files stay', () {
    final directory = Directory.systemTemp.createTempSync('alpha-update');
    addTearDown(() => directory.deleteSync(recursive: true));
    File('${directory.path}/alpha-update-old.apk').writeAsStringSync('old');
    File('${directory.path}/alpha-update-keep.apk').writeAsStringSync('keep');
    File('${directory.path}/notes.txt').writeAsStringSync('notes');

    expect(
      deleteStaleUpdateApks(directory, keepName: 'alpha-update-keep.apk'),
      1,
    );
    expect(
      File('${directory.path}/alpha-update-old.apk').existsSync(),
      isFalse,
    );
    expect(
      File('${directory.path}/alpha-update-keep.apk').existsSync(),
      isTrue,
    );
    expect(File('${directory.path}/notes.txt').readAsStringSync(), 'notes');
    expect(updateApkName('2.5.2+454', 7), 'alpha-update-2.5.2+454-7.apk');
  });

  test('install results and the settings subtitle stay explicit', () {
    expect(parseInstallResult('started'), InstallApkResult.started);
    expect(parseInstallResult(true), InstallApkResult.started);
    expect(parseInstallResult(false), InstallApkResult.background);
    expect(parseInstallResult(null), InstallApkResult.background);
    expect(
      parseInstallResult('needs_permission'),
      InstallApkResult.needsPermission,
    );

    expect(
      updateStatusLabel(
        failed: true,
        completed: true,
        release: null,
        failedLabel: 'Updatesuche fehlgeschlagen',
        availableLabel: 'Version 2.5.2 verfügbar',
        currentLabel: 'Du bist aktuell',
        idleLabel: 'Nach Updates suchen',
      ),
      'Updatesuche fehlgeschlagen',
    );
    expect(
      updateStatusLabel(
        failed: false,
        completed: true,
        release: const AppRelease(version: '2.5.2', apkUrl: 'https://example'),
        failedLabel: 'Updatesuche fehlgeschlagen',
        availableLabel: 'Version 2.5.2 verfügbar',
        currentLabel: 'Du bist aktuell',
        idleLabel: 'Nach Updates suchen',
      ),
      'Version 2.5.2 verfügbar',
    );
    expect(
      updateStatusLabel(
        failed: false,
        completed: true,
        release: null,
        failedLabel: 'Updatesuche fehlgeschlagen',
        availableLabel: 'Version 2.5.2 verfügbar',
        currentLabel: 'Du bist aktuell',
        idleLabel: 'Nach Updates suchen',
      ),
      'Du bist aktuell',
    );
    expect(formatUpdateMegabytes(5 * 1024 * 1024), '5.0');
  });

  test(
    'download fails on HTTP errors, empty files, and the wrong size',
    () async {
      final forbidden = await _serve((request) {
        request.response.statusCode = 403;
        request.response.write('no');
        return request.response.close();
      });
      final empty = await _serve((request) => request.response.close());
      final short = await _serve((request) {
        request.response.write('abcd');
        return request.response.close();
      });
      final stalled = await _serve((request) async {
        request.response.contentLength = 8;
        request.response.write('x');
        await request.response.flush();
      });
      final directory = Directory.systemTemp.createTempSync('alpha-download');
      addTearDown(() async {
        await forbidden.close(force: true);
        await empty.close(force: true);
        await short.close(force: true);
        await stalled.close(force: true);
        if (directory.existsSync()) directory.deleteSync(recursive: true);
      });
      File(
        '${directory.path}/alpha-update-stale.apk',
      ).writeAsStringSync('stale');
      File('${directory.path}/keep.txt').writeAsStringSync('keep');

      await expectLater(
        downloadUpdateApk(
          AppRelease(version: '2.5.2', apkUrl: forbidden.url, sizeBytes: 2),
          directory,
        ),
        throwsA(
          isA<UpdateCheckException>().having(
            (error) => error.message,
            'message',
            contains('403'),
          ),
        ),
      );
      await expectLater(
        downloadUpdateApk(
          AppRelease(version: '2.5.2', apkUrl: empty.url, sizeBytes: 2),
          directory,
        ),
        throwsA(
          isA<UpdateCheckException>().having(
            (error) => error.message,
            'message',
            'empty',
          ),
        ),
      );
      await expectLater(
        downloadUpdateApk(
          AppRelease(version: '2.5.2', apkUrl: short.url, sizeBytes: 10),
          directory,
        ),
        throwsA(
          isA<UpdateCheckException>().having(
            (error) => error.message,
            'message',
            contains('!='),
          ),
        ),
      );
      await expectLater(
        downloadUpdateApk(
          AppRelease(version: '2.5.2', apkUrl: stalled.url, sizeBytes: 8),
          directory,
          connectTimeout: const Duration(milliseconds: 200),
          idleTimeout: const Duration(milliseconds: 200),
        ),
        throwsA(isA<TimeoutException>()),
      );

      expect(
        File('${directory.path}/alpha-update-stale.apk').existsSync(),
        isFalse,
      );
      expect(File('${directory.path}/keep.txt').readAsStringSync(), 'keep');
      expect(
        directory.listSync().where((entity) => entity.path.endsWith('.apk')),
        isEmpty,
      );

      final good = await _serve((request) {
        request.response.add([1, 2, 3, 4]);
        return request.response.close();
      });
      addTearDown(() => good.close(force: true));
      final file = await downloadUpdateApk(
        AppRelease(version: '2.5.2+454', apkUrl: good.url, sizeBytes: 4),
        directory,
      );
      expect(file.existsSync(), isTrue);
      expect(file.lengthSync(), 4);
      expect(file.path, contains('alpha-update-2.5.2+454-'));
    },
  );
}

class _Server {
  _Server(this.server);

  final HttpServer server;

  String get url => 'http://${server.address.host}:${server.port}/alpha.apk';

  Future<void> close({bool force = false}) => server.close(force: force);
}

Future<_Server> _serve(
  Future<void> Function(HttpRequest request) handle,
) async {
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
  server.listen((request) {
    unawaited(handle(request));
  });
  return _Server(server);
}
