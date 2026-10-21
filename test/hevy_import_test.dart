import 'dart:io';

import 'package:flexify/database/database.dart';
import 'package:flexify/database/exercise_set_repository.dart';
import 'package:flexify/import/hevy_apply.dart';
import 'package:flexify/import/hevy_import.dart';
import 'package:flexify/main.dart';
import 'package:flutter_test/flutter_test.dart';

import 'mock_tests.dart';
import 'support/fixtures.dart';

void main() {
  test('Hevy CSV preview counts templates and sets', () {
    const csv = '''
title,start_time,end_time,exercise_title,set_type,weight_kg,reps
Tag 5: Pull B Schmal/Neutral,2026-10-01 18:00:00,2026-10-01 19:00:00,Lat Pulldown,normal,60,10
Tag 5: Pull B Schmal/Neutral,2026-10-01 18:00:00,2026-10-01 19:00:00,Lat Pulldown,warmup,30,12
Tag 3: Beine,2026-10-03 18:00:00,2026-10-03 19:10:00,Beinstrecker,normal,50,8
Tag 2: Pull A Breit/Obergriff,2026-10-06 18:00:00,2026-10-06 19:00:00,Barbell Row,normal,70,6
''';
    final preview = parseWorkoutCsv(csv);
    expect(preview, isNotNull);
    expect(preview!.workoutCount, 3);
    expect(preview.exerciseCount, 3);
    expect(preview.templates.map((row) => row.title), [
      'Tag 5: Pull B Schmal/Neutral',
      'Tag 3: Beine',
      'Tag 2: Pull A Breit/Obergriff',
    ]);
    final pull = preview.templates.first;
    expect(pull.setCounts['Lat Pulldown'], 2);
    expect(pull.lastWeights['Lat Pulldown'], 60);
    expect(preview.sets.firstWhere((set) => set.kg == 30).warmup, isTrue);
    expect(
      preview.first,
      DateTime.parse('2026-10-01 18:00:00'.replaceAll(' ', 'T')),
    );
  });

  test('Hevy equipment maps onto the gear list', () {
    expect(hevyEquipmentGear('barbell'), 'Langhantel');
    expect(hevyEquipmentGear('Dumbbell'), 'Kurzhantel');
    expect(hevyEquipmentGear('ez_bar'), 'SZ-Stange');
    expect(hevyEquipmentGear('cable'), 'Kabelzug');
    expect(hevyEquipmentGear('machine'), 'Maschine');
    expect(hevyEquipmentGear('smith machine'), 'Multipresse');
    expect(hevyEquipmentGear('bodyweight'), 'Körpergewicht');
    expect(hevyEquipmentGear('kettlebell'), 'Kettlebell');
    expect(hevyEquipmentGear('resistance_band'), 'Widerstandsband');
    expect(hevyEquipmentGear('cardio'), 'Cardiogerät');
    expect(hevyEquipmentGear('plate'), 'Hantelscheibe');
    expect(hevyEquipmentGear('Scheibe'), 'Hantelscheibe');
    expect(hevyEquipmentGear('weight_plate'), 'Hantelscheibe');
    expect(hevyEquipmentGear('ab wheel'), 'Bauchroller');
    expect(hevyEquipmentGear('ab_wheel'), 'Bauchroller');
    expect(hevyEquipmentGear('Ab-Wheel'), 'Bauchroller');
    expect(hevyEquipmentGear('battle rope'), 'Battle Rope');
    expect(hevyEquipmentGear('sled'), 'Schlitten');
    expect(hevyEquipmentGear('jump rope'), 'Springseil');
    expect(hevyEquipmentGear('other'), isNull);
    expect(hevyEquipmentGear(''), isNull);

    const csv = '''
title,start_time,exercise_title,equipment,weight_kg,reps
Tag,2026-10-01 18:00:00,Plate Pinch,plate,20,10
Tag,2026-10-01 18:00:00,Ab Wheel,ab wheel,0,8
''';
    final preview = parseWorkoutCsv(csv);
    expect(preview!.sets.map((set) => set.equipment), ['plate', 'ab wheel']);
    expect(preview.sets.map((set) => hevyEquipmentGear(set.equipment)), [
      'Hantelscheibe',
      'Bauchroller',
    ]);
  });

  test('measurement CSV reads date and weight', () {
    const csv = 'datum,gewicht\n01.10.2026,82.5\n';
    final points = parseMeasurementCsv(csv);
    expect(points, hasLength(1));
    expect(points.single.kg, 82.5);
    expect(points.single.at, DateTime(2026, 10, 1));
  });

  test('dates accept German, English, ISO and numeric forms', () {
    expect(
      parseImportDate('17 Okt. 2026, 13:20'),
      DateTime(2026, 10, 17, 13, 20),
    );
    expect(parseImportDate('25 Mai 2026, 00:00'), DateTime(2026, 5, 25));
    expect(parseImportDate('4 Aug. 2026, 07:30'), DateTime(2026, 8, 4, 7, 30));
    expect(parseImportDate('5 Sept. 2026, 12:00'), DateTime(2026, 9, 5, 12));
    expect(parseImportDate('8 Dez. 2026, 19:00'), DateTime(2026, 12, 8, 19));
    expect(parseImportDate('9 Mrz. 2026, 11:15'), DateTime(2026, 3, 9, 11, 15));
    expect(
      parseImportDate('10 März 2026, 11:15'),
      DateTime(2026, 3, 10, 11, 15),
    );
    expect(parseImportDate('1. Juni 2026, 8:05'), DateTime(2026, 6, 1, 8, 5));
    expect(parseImportDate('3 Juli 2026, 18:05'), DateTime(2026, 7, 3, 18, 5));
    expect(
      parseImportDate('17 Oct. 2026, 13:20'),
      DateTime(2026, 10, 17, 13, 20),
    );
    expect(
      parseImportDate('17 October 2026, 13:20'),
      DateTime(2026, 10, 17, 13, 20),
    );
    expect(parseImportDate('2 June 2026, 18:00'), DateTime(2026, 6, 2, 18));
    expect(
      parseImportDate('17.10.2026, 13:20'),
      DateTime(2026, 10, 17, 13, 20),
    );
    expect(parseImportDate('17/10/2026'), DateTime(2026, 10, 17));
    expect(
      parseImportDate('2026-10-17 13:20:00'),
      DateTime(2026, 10, 17, 13, 20),
    );
    expect(
      parseImportDate('2026-10-17T13:20:00'),
      DateTime(2026, 10, 17, 13, 20),
    );
    expect(parseImportDate('kein datum'), isNull);
    expect(parseImportDate(''), isNull);
  });

  test('a row with an unreadable date is an error', () {
    const csv = '''
title,start_time,end_time,exercise_title,weight_kg,reps
Training,not-a-date,not-a-date,Curl,20,10
Training,"17 Okt. 2026, 13:20","17 Okt. 2026, 14:00",Curl,22,8
''';
    final preview = parseWorkoutCsv(csv);
    expect(preview, isNotNull);
    expect(preview!.errors, hasLength(1));
    expect(preview.errors.single.value, 'not-a-date');
    expect(preview.sets, hasLength(1));
    expect(preview.sets.single.started, DateTime(2026, 10, 17, 13, 20));
    expect(preview.sets.single.started == DateTime.now(), isFalse);
  });

  test('templates use the newest session and the fixture groups workouts', () {
    final raw = File('test/fixtures/hevy_workouts.csv').readAsStringSync();
    final preview = parseWorkoutCsv(raw);
    expect(preview, isNotNull);
    expect(preview!.workoutCount, 11);
    expect(preview.sets, hasLength(16));
    expect(preview.errors, hasLength(1));
    final trainingA = preview.templates.firstWhere(
      (row) => row.title == 'Training A',
    );
    expect(trainingA.setCounts['Kabelzug-Curl'], 3);
    expect(trainingA.lastWeights['Kabelzug-Curl'], 28);
    expect(trainingA.setCounts.containsKey('Rudern'), isFalse);
    expect(preview.templates, hasLength(10));
  });

  test('German measurement dates are imported', () {
    const csv =
        '"date","weight_kg"\n"25 Mai 2026, 00:00",78\n"not a date",80\n';
    final points = parseMeasurementCsv(csv);
    expect(points, hasLength(1));
    expect(points.single.at, DateTime(2026, 5, 25));
    expect(points.single.kg, 78);
  });

  test('parsing 1766 rows stays grouped and fast', () {
    final buffer = StringBuffer(
      'title,start_time,end_time,exercise_title,set_type,weight_kg,reps\n',
    );
    const workouts = 90;
    const total = 1766;
    final base = total ~/ workouts;
    final extra = total % workouts;
    for (var workout = 0; workout < workouts; workout++) {
      final sets = base + (workout < extra ? 1 : 0);
      final title = 'Training ${workout + 1}';
      final minute = (workout % 60).toString().padLeft(2, '0');
      final start =
          '${(workout % 28) + 1} Okt. 2026, ${8 + (workout % 10)}:$minute';
      for (var set = 0; set < sets; set++) {
        buffer.writeln('"$title","$start","$start","Curl","normal",20,10');
      }
    }
    final started = DateTime.now();
    final preview = parseWorkoutCsv(buffer.toString());
    final elapsed = DateTime.now().difference(started);
    expect(preview, isNotNull);
    expect(preview!.sets, hasLength(1766));
    expect(preview.workoutCount, 90);
    expect(preview.errors, isEmpty);
    expect(elapsed.inSeconds, lessThan(5));
  });

  test('applying 1766 sets stays inside one fast transaction', () async {
    await mockTests();
    final database = testDb();
    addTearDown(database.close);
    db = database;
    final exerciseId = await database
        .into(database.exercises)
        .insert(
          ExercisesCompanion.insert(
            name: 'Curl',
            kind: 'strength',
            displayUnit: 'kg',
          ),
        );
    final exercise = await (database.select(
      database.exercises,
    )..where((row) => row.id.equals(exerciseId))).getSingle();
    const workouts = 90;
    const total = 1766;
    final base = total ~/ workouts;
    final extra = total % workouts;
    final sets = <ImportedSet>[];
    final templates = <ImportedTemplate>[];
    for (var workout = 0; workout < workouts; workout++) {
      final count = base + (workout < extra ? 1 : 0);
      final title = 'Training ${workout + 1}';
      final startedAt = DateTime(2026, 1, (workout % 28) + 1, 8, workout % 60);
      templates.add(
        ImportedTemplate(
          title: title,
          exercises: const ['Curl'],
          setCounts: {'Curl': count},
          lastWeights: const {'Curl': 20},
        ),
      );
      for (var set = 0; set < count; set++) {
        sets.add(
          ImportedSet(
            workoutTitle: title,
            started: startedAt,
            ended: startedAt,
            exercise: 'Curl',
            kg: 20,
            reps: 10,
            warmup: false,
          ),
        );
      }
    }
    final started = DateTime.now();
    await applyWorkoutImport(
      database: database,
      sets: sets,
      templates: templates,
      match: (name) => name == exercise.name ? exercise : null,
      existingPlanCount: 3,
      existingTitles: {'Montag', 'Mittwoch', 'Freitag'},
    );
    final elapsed = DateTime.now().difference(started);
    expect(await database.select(database.exerciseSets).get(), hasLength(1766));
    expect(await database.select(database.plans).get(), hasLength(7));
    expect(elapsed.inSeconds, lessThan(5));
  });

  test('imported Hevy sets are the best-set baseline', () async {
    await mockTests();
    final database = testDb();
    addTearDown(database.close);
    final exerciseId = await database
        .into(database.exercises)
        .insert(
          ExercisesCompanion.insert(
            name: 'Curl',
            kind: 'strength',
            displayUnit: 'kg',
          ),
        );
    final exercise = await (database.select(
      database.exercises,
    )..where((row) => row.id.equals(exerciseId))).getSingle();
    final heavyDay = DateTime(2024, 3, 1, 18);
    final lightDay = DateTime(2024, 6, 1, 18);
    await applyWorkoutImport(
      database: database,
      sets: [
        ImportedSet(
          workoutTitle: 'Pull',
          started: heavyDay,
          ended: heavyDay,
          exercise: 'Curl',
          kg: 100,
          reps: 5,
          warmup: false,
        ),
        ImportedSet(
          workoutTitle: 'Pull',
          started: lightDay,
          ended: lightDay,
          exercise: 'Curl',
          kg: 70,
          reps: 12,
          warmup: false,
        ),
      ],
      templates: [
        ImportedTemplate(
          title: 'Pull',
          exercises: const ['Curl'],
          setCounts: const {'Curl': 1},
          lastWeights: const {'Curl': 70},
        ),
      ],
      match: (name) => name == exercise.name ? exercise : null,
      existingPlanCount: 0,
      existingTitles: {},
    );
    final stored = await (database.select(
      database.exerciseSets,
    )..where((row) => row.exerciseId.equals(exercise.id))).get();
    expect(stored.map((row) => row.loadKg).toList()..sort(), [70, 100]);
    expect(stored.every((row) => row.notes == ''), isTrue);

    final under = await insertExerciseSetFixture(
      database,
      'Curl',
      weight: 80,
      reps: 8,
      created: DateTime(2025, 1, 1),
    );
    expect(await isBestExerciseSet(database, under), isFalse);
    final tie = await insertExerciseSetFixture(
      database,
      'Curl',
      weight: 100,
      reps: 5,
      created: DateTime(2025, 1, 2),
    );
    expect(await isBestExerciseSet(database, tie), isFalse);
    final moreReps = await insertExerciseSetFixture(
      database,
      'Curl',
      weight: 100,
      reps: 6,
      created: DateTime(2025, 1, 3),
    );
    expect(await isBestExerciseSet(database, moreReps), isTrue);
    final heavier = await insertExerciseSetFixture(
      database,
      'Curl',
      weight: 110,
      reps: 3,
      created: DateTime(2025, 1, 4),
    );
    expect(await isBestExerciseSet(database, heavier), isTrue);
  });
}
