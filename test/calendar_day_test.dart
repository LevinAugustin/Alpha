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
        borderWidth: 2,
      );
    }
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
  }
  final text = tester.widget<Text>(
    find.descendant(of: cell, matching: find.byType(Text)),
  );
  expect(calendarContrast(text.style!.color!, fill), greaterThanOrEqualTo(4.5));
}
