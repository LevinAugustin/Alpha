import 'dart:io';

import 'package:drift/drift.dart' hide Column, isNull, isNotNull;
import 'package:flexify/database/database.dart';
import 'package:flexify/home_page.dart';
import 'package:flexify/main.dart';
import 'package:flexify/profile/local_profiles.dart';
import 'package:flexify/storage/app_storage_native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import 'support/test_app.dart';

void main() {
  late Directory support;

  setUp(() {
    support = Directory.systemTemp.createTempSync('alpha-onboarding-');
    profileSupportDirectoryOverride = support;
  });

  tearDown(() async {
    profileSupportDirectoryOverride = null;
    if (support.existsSync()) support.deleteSync(recursive: true);
  });

  test('a fresh install asks who you are', () async {
    final registry = await loadProfileRegistry();
    expect(registry.onboarded, isFalse);
    expect(registry.profiles, isEmpty);
    expect(await installNeedsOnboarding(), isTrue);

    final database = AppDatabase.forPath(
      p.join(support.path, databaseFileName),
    );
    addTearDown(database.close);
    final again = await loadProfileRegistry();
    expect(again.onboarded, isFalse);
  });

  test('finishing onboarding activates the named profile', () async {
    final database = AppDatabase.forPath(
      p.join(support.path, databaseFileName),
    );
    addTearDown(database.close);
    db = database;
    await loadProfileRegistry();

    await completeOnboarding(name: 'Mia', bodyWeight: 70, unit: 'lb');

    final registry = await loadProfileRegistry();
    expect(registry.onboarded, isTrue);
    expect(registry.active.name, 'Mia');
    expect(registry.activeId, defaultProfileId);
    expect(await installNeedsOnboarding(), isFalse);
    final setting = await database.settings.select().getSingle();
    expect(setting.profileName, 'Mia');
    expect(setting.strengthUnit, 'lb');
    final weight = await database.bodyWeights.select().getSingle();
    expect(weight.weightKg, closeTo(70 * 0.45359237, 0.001));
  });

  test('an update over 2.4.0 keeps the existing profile', () async {
    final database = AppDatabase.forPath(
      p.join(support.path, databaseFileName),
    );
    await database.settings.update().write(
      const SettingsCompanion(profileName: Value('Sam')),
    );
    await database.close();
    File(p.join(support.path, profileRegistryName)).writeAsStringSync('''
{"active":"default","profiles":[{"id":"default","name":"Sam","file":"flexify.sqlite"}]}
''');

    final registry = await loadProfileRegistry();
    expect(registry.onboarded, isTrue);
    expect(registry.active.name, 'Sam');
    expect(await installNeedsOnboarding(), isFalse);
  });

  test('a 2.4.0 database without the registry file is adopted', () async {
    final database = AppDatabase.forPath(
      p.join(support.path, databaseFileName),
    );
    await database.settings.update().write(
      const SettingsCompanion(profileName: Value('Noah')),
    );
    await database.close();

    final registry = await loadProfileRegistry();
    expect(registry.onboarded, isTrue);
    expect(registry.active.name, 'Noah');
    expect(await installNeedsOnboarding(), isFalse);

    final opened = AppDatabase.forPath(p.join(support.path, databaseFileName));
    addTearDown(opened.close);
    final setting = await opened.settings.select().getSingle();
    expect(setting.profileName, 'Noah');
  });

  test(
    'a 2.4.0 database without a stored name still skips onboarding',
    () async {
      final database = AppDatabase.forPath(
        p.join(support.path, databaseFileName),
      );
      await database.settings.select().getSingle();
      await database.close();

      final registry = await loadProfileRegistry();
      expect(registry.onboarded, isTrue);
      expect(registry.active.name, 'Levin');
      expect(await installNeedsOnboarding(), isFalse);
    },
  );

  testWidgets('home without a profile offers to create one', (tester) async {
    final harness = await FlexifyTestHarness.create();
    addTearDown(harness.database.close);
    await loadProfileRegistry();

    await harness.pump(
      tester,
      const HomePage(),
      locale: const Locale('de'),
      surfaceSize: const Size(400, 900),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Willkommen bei Alpha'), findsOneWidget);
    expect(find.text('Profil erstellen'), findsWidgets);
    expect(find.textContaining('Training starten'), findsOneWidget);
    expect(find.text('Diese Woche'), findsOneWidget);
    expect(find.textContaining('Tage in Folge'), findsWidgets);
    expect(find.byIcon(Icons.lock_outline), findsOneWidget);
    expect(find.text('ALPHA'), findsNothing);

    await tester.tap(find.byKey(const Key('create-profile')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('language-de')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('language-continue')));
    await tester.pumpAndSettle();

    expect(
      tester
          .widget<TextButton>(find.byKey(const Key('onboarding-save')))
          .onPressed,
      isNull,
    );

    await tester.enterText(find.byKey(const Key('onboarding-name')), 'Mia');
    await tester.enterText(find.byKey(const Key('onboarding-weight')), '80');
    await tester.tap(find.byKey(const Key('onboarding-unit-kg')));
    await tester.pump();
    expect(
      tester
          .widget<TextButton>(find.byKey(const Key('onboarding-save')))
          .onPressed,
      isNotNull,
    );

    await tester.tap(find.byKey(const Key('onboarding-save')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    final setting = await harness.database.settings.select().getSingle();
    expect(setting.profileName, 'Mia');
    expect(setting.strengthUnit, 'kg');
    expect(setting.localeOverride, 'de');
    final weight = await harness.database.bodyWeights.select().getSingle();
    expect(weight.weightKg, closeTo(80, 0.001));

    expect(find.text('Hallo'), findsWidgets);
    expect(find.text('Mia'), findsWidgets);
    expect(find.text('Willkommen bei Alpha'), findsNothing);
    expect(find.text('Diese Woche'), findsOneWidget);
    expect(find.textContaining('Tage in Folge'), findsWidgets);
    expect(find.text('ALPHA'), findsNothing);
  });
}
