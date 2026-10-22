import 'package:drift/drift.dart' hide isNull, isNotNull, Column;
import 'package:flexify/alpha/live_workout.dart';
import 'package:flexify/database/database.dart';
import 'package:flexify/database/exercise_de_catalog.dart';
import 'package:flexify/exercises/exercise_detail_page.dart';
import 'package:flexify/plan/plan_names.dart';
import 'package:flexify/shell/exercises_page.dart';
import 'package:flexify/shell/start_page.dart';
import 'package:flexify/workout/gym_workout_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/test_app.dart';

void main() {
  tearDown(() {
    catalogEnglishById.clear();
    liveWorkout.value = null;
  });

  test('english catalog fields override the fixed labels', () {
    final labels = parseCatalogEnglishLabels('''
[
  {"id": "latziehen", "kategorie": "Beine", "geraet": "Kabelzug"},
  {
    "id": "kniebeuge",
    "kategorie_en": "Lower body",
    "geraet_en": "Cable stack",
    "position_en": "Standing tall"
  }
]
''');
    expect(labels.containsKey('latziehen'), isFalse);
    expect(labels['kniebeuge']?.category, 'Lower body');
    expect(labels['kniebeuge']?.equipment, 'Cable stack');
    expect(labels['kniebeuge']?.position, 'Standing tall');
  });

  testWidgets('weekday names follow the locale and stay stored', (
    tester,
  ) async {
    final harness = await FlexifyTestHarness.create();
    addTearDown(harness.database.close);
    final plan = await (harness.database.select(
      harness.database.plans,
    )..where((row) => row.id.equals(2))).getSingle();
    expect(plan.title, 'Mittwoch');

    await harness.pump(
      tester,
      GymWorkoutPage(plan: plan),
      locale: const Locale('en'),
      surfaceSize: const Size(400, 900),
    );
    await tester.pump();
    expect(find.text('Wednesday'), findsWidgets);
    expect(find.text('Mittwoch'), findsNothing);
    final stored = await (harness.database.select(
      harness.database.plans,
    )..where((row) => row.id.equals(2))).getSingle();
    expect(stored.title, 'Mittwoch');

    liveWorkout.value = null;
    await harness.pump(
      tester,
      const StartPage(),
      locale: const Locale('en'),
      surfaceSize: const Size(400, 900),
    );
    await tester.pumpAndSettle();
    expect(
      find.text('Start workout · Monday', skipOffstage: false),
      findsOneWidget,
    );
    expect(find.textContaining('Montag'), findsNothing);
    expect(find.textContaining('Mittwoch'), findsNothing);

    await harness.pump(
      tester,
      Builder(
        builder: (context) => Text(
          localizedPlanTitle(
            locale: Localizations.localeOf(context).toLanguageTag(),
            title: 'Mittwoch',
          ),
        ),
      ),
      locale: const Locale('de'),
    );
    await tester.pump();
    expect(find.text('Mittwoch'), findsOneWidget);
  });

  testWidgets('exercise list and detail use english labels', (tester) async {
    final harness = await FlexifyTestHarness.create();
    addTearDown(harness.database.close);
    catalogEnglishById['zz-override'] = const CatalogEnglishText(
      category: 'Lower body',
    );
    await harness.database.exercises.insertOne(
      ExercisesCompanion.insert(
        name: 'zz-cable-row',
        kind: 'strength',
        displayUnit: 'kg',
        germanName: const Value('Kabelrudern'),
        englishName: const Value('Cable Row'),
        categoryName: const Value('Beine'),
        equipment: const Value('Kabelzug'),
      ),
    );
    await harness.database.exercises.insertOne(
      ExercisesCompanion.insert(
        name: 'zz-cardio-bike',
        kind: 'cardio',
        displayUnit: 'min',
        germanName: const Value('Radfahren'),
        englishName: const Value('Bike'),
        categoryName: const Value('Cardio'),
        equipment: const Value('Cardiogerät'),
      ),
    );
    final detailId = await harness.database.exercises.insertOne(
      ExercisesCompanion.insert(
        name: 'zz-lat',
        kind: 'strength',
        displayUnit: 'kg',
        germanName: const Value('Latziehen'),
        englishName: const Value('Lat Pulldown'),
        categoryName: const Value('Beine'),
        equipment: const Value('Kabelzug'),
        position: const Value('stehend'),
        griff: const Value('obergriff'),
        familie: const Value('zz-family'),
        catalogId: const Value('zz-lat'),
      ),
    );
    await harness.database.exercises.insertOne(
      ExercisesCompanion.insert(
        name: 'zz-lat-close',
        kind: 'strength',
        displayUnit: 'kg',
        germanName: const Value('Enges Latziehen'),
        englishName: const Value('Close Lat Pulldown'),
        categoryName: const Value('Beine'),
        familie: const Value('zz-family'),
        catalogId: const Value('zz-lat-close'),
      ),
    );
    await harness.database.exercises.insertOne(
      ExercisesCompanion.insert(
        name: 'zz-override-row',
        kind: 'strength',
        displayUnit: 'kg',
        germanName: const Value('Override'),
        englishName: const Value('Override Row'),
        categoryName: const Value('Beine'),
        equipment: const Value('Kabelzug'),
        catalogId: const Value('zz-override'),
      ),
    );

    await harness.pump(
      tester,
      const Scaffold(body: ExercisesPage()),
      locale: const Locale('en'),
      surfaceSize: const Size(400, 900),
    );
    await tester.pump();
    await tester.enterText(find.byType(TextField), 'zz-cable');
    await tester.pump();
    expect(find.text('Legs · Cable'), findsOneWidget);
    expect(find.text('Beine · Kabelzug'), findsNothing);

    await tester.enterText(find.byType(TextField), 'zz-cardio');
    await tester.pump();
    expect(find.text('Cardio · Cardio machine'), findsOneWidget);
    expect(find.text('Cardiogerät'), findsNothing);

    await tester.enterText(find.byType(TextField), 'zz-override');
    await tester.pump();
    expect(find.text('Lower body · Cable'), findsOneWidget);

    final detail =
        await (harness.database.exercises.select()
              ..where((row) => row.id.equals(detailId)))
            .getSingle();
    await harness.pump(
      tester,
      ExerciseDetailPage(exercise: detail),
      locale: const Locale('en'),
      surfaceSize: const Size(400, 900),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Equipment: Cable'), findsOneWidget);
    expect(find.text('Position: Standing'), findsOneWidget);
    expect(find.text('Grip: Overhand'), findsOneWidget);
    expect(find.text('Close Lat Pulldown · Legs'), findsOneWidget);
    expect(find.textContaining('Beine'), findsNothing);
    expect(find.textContaining('Kabelzug'), findsNothing);
    expect(find.textContaining('stehend'), findsNothing);

    await harness.pump(
      tester,
      const Scaffold(body: ExercisesPage()),
      locale: const Locale('de'),
      surfaceSize: const Size(400, 900),
    );
    await tester.pump();
    await tester.enterText(find.byType(TextField), 'zz-override');
    await tester.pump();
    expect(find.text('Beine · Kabelzug'), findsOneWidget);
    expect(find.text('Lower body · Cable'), findsNothing);
  });
}
