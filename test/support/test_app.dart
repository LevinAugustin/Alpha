import 'package:drift/drift.dart';
import 'package:flexify/alpha/alpha_prefs.dart';
import 'package:flexify/database/database.dart';
import 'package:flexify/profile/local_profiles.dart';
import 'package:flexify/l10n/generated/app_localizations.dart';
import 'package:flexify/main.dart';
import 'package:flexify/timer/timer_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../mock_tests.dart';

class FlexifyTestHarness {
  FlexifyTestHarness._({required this.database, required this.timerState});

  final AppDatabase database;
  final TimerState timerState;

  static Future<FlexifyTestHarness> create({TimerState? timerState}) async {
    await mockTests();
    final database = testDb();
    db = database;
    if (alphaPrefs.gyms.isEmpty) {
      alphaPrefs.gyms = [
        GymPlace(
          id: 'default',
          name: 'Studio',
          createdAt: DateTime.utc(2020, 1, 1),
        ),
      ];
      alphaPrefs.activeGymId = 'default';
    }
    if (timerState == null) {
      alphaPrefs.restEndsAt = null;
      alphaPrefs.restTotalMs = null;
      alphaPrefs.restTitle = '';
      alphaPrefs.restTarget = 'timer';
      await alphaPrefs.save();
    }

    return FlexifyTestHarness._(
      database: database,
      timerState: timerState ?? TimerState(),
    );
  }

  Future<void> pump(
    WidgetTester tester,
    Widget home, {
    TimerState? timerState,
    Size? surfaceSize,
    Locale? locale,
    TextScaler? textScaler,
  }) async {
    if (surfaceSize != null) {
      await tester.binding.setSurfaceSize(surfaceSize);
      addTearDown(() => tester.binding.setSurfaceSize(null));
    }

    await ensureWidgetTestProfile();
    final setting = await (database.settings.select()..limit(1)).getSingle();
    final effectiveTimerState = timerState ?? this.timerState;

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          StreamProvider<Setting>(
            initialData: setting,
            create: (_) => database.watchSettings(),
          ),
          ChangeNotifierProvider.value(value: effectiveTimerState),
        ],
        child: MaterialApp(
          scaffoldMessengerKey: rootScaffoldMessenger,
          locale: locale ?? const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          builder: textScaler == null
              ? null
              : (context, child) => MediaQuery(
                  data: MediaQuery.of(context).copyWith(textScaler: textScaler),
                  child: child!,
                ),
          home: home,
        ),
      ),
    );
  }
}
