import 'dart:math' as math;

import 'package:drift/drift.dart' hide Column;
import 'package:flexify/database/database.dart';
import 'package:flexify/exercise_labels.dart';
import 'package:flexify/l10n/l10n.dart';
import 'package:flexify/main.dart';
import 'package:flexify/shell/training_stats.dart';
import 'package:flexify/theme/alpha_theme.dart';
import 'package:flutter/material.dart';

const calendarLightLabel = Color(0xFFFFFFFF);
const calendarDarkLabel = Color(0xFF0D0D0D);

double calendarContrast(Color foreground, Color background) {
  final lighter = math.max(
    foreground.computeLuminance(),
    background.computeLuminance(),
  );
  final darker = math.min(
    foreground.computeLuminance(),
    background.computeLuminance(),
  );
  return (lighter + 0.05) / (darker + 0.05);
}

Color calendarDayLabelColor(Color background) {
  final light = calendarContrast(calendarLightLabel, background);
  final dark = calendarContrast(calendarDarkLabel, background);
  return light >= dark ? calendarLightLabel : calendarDarkLabel;
}

String calendarDayKey(DateTime day) =>
    'calendar-day-${day.year}-${day.month}-${day.day}';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late DateTime _month;
  DateTime? _selected;

  @override
  void initState() {
    super.initState();
    final now = dateOnly(DateTime.now());
    _month = DateTime(now.year, now.month);
    _selected = now;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.calendarTitle)),
      body: StreamBuilder<List<TypedResult>>(
        stream: (db.select(db.exerciseSets).join([
          innerJoin(
            db.exercises,
            db.exercises.id.equalsExp(db.exerciseSets.exerciseId),
          ),
          leftOuterJoin(
            db.workouts,
            db.workouts.id.equalsExp(db.exerciseSets.workoutId),
          ),
        ])).watch(),
        builder: (context, snapshot) {
          final rows = snapshot.data ?? const <TypedResult>[];
          final trained = <DateTime>{};
          for (final row in rows) {
            final set = row.readTable(db.exerciseSets);
            final workout = row.readTableOrNull(db.workouts);
            trained.add(workoutDay(workout?.startedAt ?? set.timestamp));
          }
          final today = DateTime.now();
          final selected = _selected;
          final dayRows = selected == null
              ? const <TypedResult>[]
              : rows.where((row) {
                  final set = row.readTable(db.exerciseSets);
                  final workout = row.readTableOrNull(db.workouts);
                  return workoutDay(workout?.startedAt ?? set.timestamp) ==
                      selected;
                }).toList();
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(context.l10n.dayStreak(trainingDayStreak(trained, today))),
              Text(context.l10n.weekStreak(trainingWeekStreak(trained, today))),
              const SizedBox(height: 12),
              Row(
                children: [
                  IconButton(
                    onPressed: () => setState(() {
                      _month = DateTime(_month.year, _month.month - 1);
                    }),
                    icon: const Icon(Icons.chevron_left),
                  ),
                  Expanded(
                    child: Text(
                      MaterialLocalizations.of(context).formatMonthYear(_month),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  IconButton(
                    onPressed: () => setState(() {
                      _month = DateTime(_month.year, _month.month + 1);
                    }),
                    icon: const Icon(Icons.chevron_right),
                  ),
                ],
              ),
              _MonthGrid(
                month: _month,
                trained: trained,
                selected: selected,
                onSelect: (day) => setState(() => _selected = day),
              ),
              const SizedBox(height: 16),
              Text(
                selected == null
                    ? context.l10n.noTrainingThisDay
                    : MaterialLocalizations.of(
                        context,
                      ).formatFullDate(selected),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              if (dayRows.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(context.l10n.noTrainingThisDay),
                )
              else
                for (final row in dayRows)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      localizedExerciseName(
                        context,
                        row.readTable(db.exercises).name,
                        german: row.readTable(db.exercises).germanName,
                      ),
                    ),
                    subtitle: Text(_detail(row.readTable(db.exerciseSets))),
                  ),
            ],
          );
        },
      ),
    );
  }

  String _detail(ExerciseSet set) {
    final reps = set.reps == null ? '-' : set.reps!.toStringAsFixed(0);
    final load = set.loadKg == null
        ? '-'
        : '${set.loadKg!.toStringAsFixed(1)} kg';
    return '$load × $reps';
  }
}

class _MonthGrid extends StatelessWidget {
  const _MonthGrid({
    required this.month,
    required this.trained,
    required this.selected,
    required this.onSelect,
  });

  final DateTime month;
  final Set<DateTime> trained;
  final DateTime? selected;
  final ValueChanged<DateTime> onSelect;

  @override
  Widget build(BuildContext context) {
    final first = DateTime(month.year, month.month);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final leading = first.weekday - 1;
    final cells = leading + daysInMonth;
    final palette = AlphaTheme.of(context);
    final today = dateOnly(DateTime.now());
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
      ),
      itemCount: cells,
      itemBuilder: (context, index) {
        if (index < leading) return const SizedBox.shrink();
        final day = DateTime(month.year, month.month, index - leading + 1);
        final isTrained = trained.contains(day);
        final isToday = day == today;
        final isSelected = selected == day;
        final fill = isTrained ? palette.accent : Colors.transparent;
        final label = isTrained ? calendarDayLabelColor(fill) : palette.text;
        final ring = isToday
            ? (isTrained ? label : palette.accent)
            : (isSelected ? palette.border : null);
        return InkWell(
          onTap: () => onSelect(day),
          child: Container(
            key: Key(calendarDayKey(day)),
            margin: const EdgeInsets.all(2),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: fill,
              borderRadius: BorderRadius.circular(8),
              border: ring == null
                  ? null
                  : Border.all(color: ring, width: isToday ? 2 : 1),
            ),
            child: Text(
              '${day.day}',
              style: TextStyle(color: label, fontWeight: FontWeight.w700),
            ),
          ),
        );
      },
    );
  }
}
