import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flexify/database/database.dart';
import 'package:flexify/import_data.dart';
import 'package:flexify/l10n/generated/app_localizations.dart';
import 'package:flexify/main.dart';
import 'package:flexify/storage/app_storage_native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

import 'mock_tests.dart';

class _SupportPaths extends FakePathProviderPlatform {
  _SupportPaths(super.documentsPath);

  @override
  Future<String?> getTemporaryPath() async => documentsPath;

  @override
  Future<String?> getApplicationCachePath() async => documentsPath;
}

void main() {
  test(
    'a 2.4.0 zip backup migrates workouts, sets, profile and custom exercises',
    () async {
      await mockTests();
      final root = await Directory.systemTemp.createTemp('alpha-v72-import-');
      addTearDown(() async {
        try {
          await db.close();
        } catch (_) {}
        if (root.existsSync()) root.deleteSync(recursive: true);
      });
      PathProviderPlatform.instance = _SupportPaths(root.path);

      final live = AppDatabase.forPath(p.join(root.path, databaseFileName));
      await live.customSelect('SELECT 1').get();
      await live.close();
      db = AppDatabase.persistent();
      await db.customSelect('SELECT 1').get();

      await importFlexifyBackupFile(
        File('test/fixtures/flexify-backup_240.zip'),
        lookupAppLocalizations(const Locale('en')),
      );

      final settings = await db.settings.select().getSingle();
      expect(settings.profileName, 'Levin');
      expect(settings.themeId, 'eisblau');
      expect(await db.workouts.select().get(), hasLength(2));
      expect(await db.exerciseSets.select().get(), hasLength(4));
      final custom = await (db.select(
        db.exercises,
      )..where((row) => row.name.equals('Landmine Press Eigen'))).getSingle();
      expect(custom.name, 'Landmine Press Eigen');
      final weight = await db.bodyWeights.select().getSingle();
      expect(weight.weightKg, closeTo(81.5, 0.001));
      final version = await db.customSelect('PRAGMA user_version').getSingle();
      expect(version.data.values.single, 80);
    },
  );
}
