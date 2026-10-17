import 'package:drift/drift.dart' hide Column;
import 'package:flexify/l10n/l10n.dart';
import 'package:flexify/main.dart';
import 'package:flexify/shell/training_stats.dart';
import 'package:flexify/theme/alpha_theme.dart';
import 'package:flexify/workout/muscle_map.dart';
import 'package:flutter/material.dart';

enum MusclePeriod { week, month, session }

class MuscleAtlasPage extends StatefulWidget {
  const MuscleAtlasPage({super.key});

  @override
  State<MuscleAtlasPage> createState() => _MuscleAtlasPageState();
}

class _MuscleAtlasPageState extends State<MuscleAtlasPage> {
  MusclePeriod _period = MusclePeriod.week;
  late Future<Map<String, double>> _heat = loadMuscleHeat(_period);

  void _select(MusclePeriod period) {
    setState(() {
      _period = period;
      _heat = loadMuscleHeat(period);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final female = AlphaTheme.of(context).id == 'pink';
    return Scaffold(
      appBar: AppBar(title: Text(l10n.muscleMapTitle)),
      body: FutureBuilder<Map<String, double>>(
        future: _heat,
        builder: (context, snapshot) {
          final heat = snapshot.data ?? const <String, double>{};
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(
                    label: Text(l10n.periodWeek),
                    selected: _period == MusclePeriod.week,
                    onSelected: (_) => _select(MusclePeriod.week),
                  ),
                  ChoiceChip(
                    label: Text(l10n.periodMonth),
                    selected: _period == MusclePeriod.month,
                    onSelected: (_) => _select(MusclePeriod.month),
                  ),
                  ChoiceChip(
                    label: Text(l10n.periodSession),
                    selected: _period == MusclePeriod.session,
                    onSelected: (_) => _select(MusclePeriod.session),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              MuscleMap(
                heat: heat,
                female: female,
                onTap: (region) {
                  final score = ((heat[region] ?? 0) * 100).round();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${muscleLabel(l10n, region)} · $score%'),
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(l10n.frontView, textAlign: TextAlign.center),
                  ),
                  Expanded(
                    child: Text(l10n.backView, textAlign: TextAlign.center),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

Future<Map<String, double>> loadMuscleHeat(MusclePeriod period) async {
  final now = DateTime.now();
  DateTime? since;
  int? workoutId;
  if (period == MusclePeriod.week) {
    since = mondayOf(now);
  } else if (period == MusclePeriod.month) {
    since = DateTime(now.year, now.month);
  } else {
    final latest =
        await (db.select(db.workouts)
              ..orderBy([(row) => OrderingTerm.desc(row.startedAt)])
              ..limit(1))
            .getSingleOrNull();
    workoutId = latest?.id;
    if (workoutId == null) return const {};
  }

  final rows = await (db.select(db.exerciseSets).join([
    innerJoin(
      db.exercises,
      db.exercises.id.equalsExp(db.exerciseSets.exerciseId),
    ),
  ])).get();
  final heat = <String, double>{};
  for (final row in rows) {
    final set = row.readTable(db.exerciseSets);
    final exercise = row.readTable(db.exercises);
    if ((set.notes ?? '').contains('warmup')) continue;
    if (workoutId != null && set.workoutId != workoutId) continue;
    if (since != null && set.timestamp.isBefore(since)) continue;
    final load = (set.loadKg ?? 0) * (set.reps ?? 0);
    if (load <= 0) continue;
    final region = regionForGroup(exercise.muscle);
    if (region != null) heat[region] = (heat[region] ?? 0) + load;
    if (exercise.muscle == 'Arme') {
      heat['triceps'] = (heat['triceps'] ?? 0) + load * 0.5;
      heat['biceps'] = (heat['biceps'] ?? 0) + load * 0.5;
    }
    if (exercise.muscle == 'Beine') {
      heat['hams'] = (heat['hams'] ?? 0) + load * 0.4;
      heat['glutes'] = (heat['glutes'] ?? 0) + load * 0.3;
      heat['calves'] = (heat['calves'] ?? 0) + load * 0.15;
    }
    if (exercise.muscle == 'Rücken') {
      heat['traps'] = (heat['traps'] ?? 0) + load * 0.35;
    }
  }
  if (heat.isEmpty) return heat;
  final maxHeat = heat.values.reduce((a, b) => a > b ? a : b);
  if (maxHeat <= 0) return heat;
  for (final key in heat.keys.toList()) {
    heat[key] = heat[key]! / maxHeat;
  }
  return heat;
}
