import 'package:drift/drift.dart' hide Column, isNull, isNotNull;
import 'package:flexify/database/database.dart';
import 'package:flexify/shell/calendar_page.dart';
import 'package:flexify/shell/training_stats.dart';
import 'package:flexify/theme/alpha_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/test_app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('workout days fill the accent cell in every theme', (
    tester,
  ) async {
    final harness = await FlexifyTestHarness.create();
    addTearDown(harness.database.close);
    final exercise = await (harness.database.exercises.select()..limit(1))
        .getSingle();
    final today = dateOnly(DateTime.now());
    final other = DateTime(today.year, today.month, today.day == 1 ? 2 : 1);
    await harness.database.exerciseSets.insertOne(
      ExerciseSetsCompanion.insert(
        exerciseId: exercise.id,
        timestamp: today,
        reps: const Value(8),
        loadKg: const Value(40),
      ),
    );
    await harness.database.exerciseSets.insertOne(
      ExerciseSetsCompanion.insert(
        exerciseId: exercise.id,
        timestamp: other,
        reps: const Value(8),
        loadKg: const Value(40),
      ),
    );

    for (final palette in const [
      AlphaPalette.tiefschwarz,
      AlphaPalette.eisblau,
      AlphaPalette.pink,
    ]) {
      await harness.pump(
        tester,
        Theme(data: alphaThemeData(palette), child: const CalendarPage()),
        surfaceSize: const Size(400, 900),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CircleAvatar), findsNothing);
      _expectWorkoutDay(
        tester,
        day: other,
        fill: palette.accent,
        borderWidth: null,
      );
      _expectWorkoutDay(
        tester,
        day: today,
        fill: palette.accent,
        borderWidth: 3,
      );
    }
  });

  testWidgets('workouts mark the day they started', (tester) async {
    final harness = await FlexifyTestHarness.create();
    addTearDown(harness.database.close);
    final exercise = await (harness.database.exercises.select()..limit(1))
        .getSingle();
    final month = dateOnly(DateTime.now());
    final days = [
      DateTime(month.year, month.month, 1),
      DateTime(month.year, month.month, 3),
      DateTime(month.year, month.month, 6),
    ];
    final plans = await (harness.database.select(
      harness.database.plans,
    )..orderBy([(row) => OrderingTerm.asc(row.id)])).get();
    final spill = DateTime(month.year, month.month, 2, 0, 10);
    final overnight = await harness.database.workouts.insertOne(
      WorkoutsCompanion.insert(
        planId: Value(plans[0].id),
        startedAt: DateTime(days[0].year, days[0].month, days[0].day, 23, 50),
        endedAt: Value(DateTime(spill.year, spill.month, spill.day, 0, 30)),
      ),
    );
    await harness.database.exerciseSets.insertOne(
      ExerciseSetsCompanion.insert(
        exerciseId: exercise.id,
        workoutId: Value(overnight),
        timestamp: spill,
        reps: const Value(8),
        loadKg: const Value(40),
      ),
    );
    for (final day in days.skip(1)) {
      final workoutId = await harness.database.workouts.insertOne(
        WorkoutsCompanion.insert(
          planId: Value(plans[days.indexOf(day)].id),
          startedAt: DateTime(day.year, day.month, day.day, 18),
          endedAt: Value(DateTime(day.year, day.month, day.day, 19)),
        ),
      );
      await harness.database.exerciseSets.insertOne(
        ExerciseSetsCompanion.insert(
          exerciseId: exercise.id,
          workoutId: Value(workoutId),
          timestamp: DateTime(day.year, day.month, day.day, 18, 30),
          reps: const Value(8),
          loadKg: const Value(40),
        ),
      );
    }

    await harness.pump(
      tester,
      Theme(
        data: alphaThemeData(AlphaPalette.tiefschwarz),
        child: const CalendarPage(),
      ),
      surfaceSize: const Size(400, 900),
    );
    await tester.pumpAndSettle();

    for (final day in days) {
      _expectFill(tester, day, AlphaPalette.tiefschwarz.accent);
    }
    _expectFill(tester, dateOnly(spill), Colors.transparent);
    expect(days.map((day) => day.weekday).toSet(), hasLength(3));
  });
}

void _expectWorkoutDay(
  WidgetTester tester, {
  required DateTime day,
  required Color fill,
  required double? borderWidth,
}) {
  final cell = find.byKey(Key(calendarDayKey(day)));
  final box = tester.widget<Container>(cell);
  final decoration = box.decoration! as BoxDecoration;
  expect(decoration.color, fill);
  if (borderWidth == null) {
    expect(decoration.border, isNull);
  } else {
    final border = decoration.border! as Border;
    expect(border.top.width, borderWidth);
    expect(border.bottom.width, borderWidth);
    if (borderWidth == 3) {
      expect(calendarContrast(border.top.color, fill), greaterThanOrEqualTo(3));
      expect(
        border.top.color,
        isNot(
          AlphaPalette.byId(
            fill == AlphaPalette.eisblau.accent
                ? 'eisblau'
                : fill == AlphaPalette.pink.accent
                ? 'pink'
                : 'tiefschwarz',
          ).background,
        ),
      );
      expect(
        border.top.color,
        calendarTodayBorder(
          AlphaPalette.byId(
            fill == AlphaPalette.eisblau.accent
                ? 'eisblau'
                : fill == AlphaPalette.pink.accent
                ? 'pink'
                : 'tiefschwarz',
          ),
          trained: true,
        ),
      );
    }
  }
  final text = tester.widget<Text>(
    find.descendant(of: cell, matching: find.byType(Text)),
  );
  expect(calendarContrast(text.style!.color!, fill), greaterThanOrEqualTo(4.5));
}

void _expectFill(WidgetTester tester, DateTime day, Color fill) {
  final box = tester.widget<Container>(find.byKey(Key(calendarDayKey(day))));
  final decoration = box.decoration! as BoxDecoration;
  expect(decoration.color, fill);
}
