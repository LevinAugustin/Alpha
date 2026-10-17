import 'package:drift/drift.dart' hide Column;
import 'package:flexify/alpha/alpha_prefs.dart';
import 'package:flexify/database/database.dart';
import 'package:flexify/settings/alpha_settings_page.dart';
import 'package:flexify/workout/muscle_atlas_page.dart';
import 'package:flexify/l10n/l10n.dart';
import 'package:flexify/main.dart';
import 'package:flexify/platform_page_route.dart';
import 'package:flexify/profile/local_profiles.dart';
import 'package:flexify/shell/training_stats.dart';
import 'package:flexify/theme/alpha_theme.dart';
import 'package:flexify/update/app_update.dart';
import 'package:flexify/workout/gym_workout_page.dart';
import 'package:flexify/workout/muscle_map.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  late Future<_Dashboard> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_Dashboard>(
      future: _future,
      builder: (context, snapshot) {
        final data = snapshot.data;
        if (data == null)
          return const Center(child: CircularProgressIndicator());
        final l10n = context.l10n;
        final palette = AlphaTheme.of(context);
        final stored = context.select<Setting, String?>(
          (settings) => settings.profileName,
        );
        final storedName = stored?.trim() ?? '';
        final name = storedName.isEmpty ? data.profileName : storedName;
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          children: [
            _Hero(
              data: data,
              name: name,
              palette: palette,
              onGoal: () async {
                final saved = await editWeeklyGoal(context);
                if (!saved || !mounted) return;
                setState(() => _future = _load());
              },
            ),
            ValueListenableBuilder(
              valueListenable: pendingAppUpdate,
              builder: (context, release, _) {
                if (release == null) return const SizedBox.shrink();
                return Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () => downloadAndInstallUpdate(release),
                    child: Text(l10n.installUpdate),
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _Mini(
                    icon: Icons.local_fire_department,
                    text: l10n.dayStreak(data.dayStreak),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _Mini(
                    icon: Icons.calendar_view_week,
                    text: l10n.weekStreak(data.weekStreak),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  l10n.thisWeek,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                Text(
                  l10n.weekGoalProgress(data.trainedDays.length, data.weekGoal),
                  style: TextStyle(color: palette.muted),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _WeekStrip(days: data.weekDays, trained: data.trainedDays),
            if (data.heat.isNotEmpty) ...[
              const SizedBox(height: 12),
              _MuscleCard(
                heat: data.heat,
                female: palette.id == 'pink',
                onOpen: () {
                  Navigator.of(context).push(
                    FlexPageRoute(
                      builder: (context) => const MuscleAtlasPage(),
                    ),
                  );
                },
              ),
            ],
            if (data.lifts.isNotEmpty) ...[
              const SizedBox(height: 12),
              _ProgressCard(lifts: data.lifts),
            ],
          ],
        );
      },
    );
  }
}

class _Dashboard {
  const _Dashboard({
    required this.dayStreak,
    required this.weekStreak,
    required this.weekDays,
    required this.trainedDays,
    required this.profileName,
    required this.nextPlan,
    required this.weekGoal,
    required this.doneThisWeek,
    required this.heat,
    required this.lifts,
    required this.quote,
  });

  final int dayStreak;
  final int weekStreak;
  final List<DateTime> weekDays;
  final Set<DateTime> trainedDays;
  final String profileName;
  final Plan? nextPlan;
  final int weekGoal;
  final int doneThisWeek;
  final Map<String, double> heat;
  final List<_LiftPoint> lifts;
  final String quote;
}

class _LiftPoint {
  const _LiftPoint({
    required this.name,
    required this.delta,
    required this.latest,
    required this.points,
  });

  final String name;
  final double delta;
  final double latest;
  final List<double> points;
}

Future<_Dashboard> _load() async {
  await alphaPrefs.load();
  final now = DateTime.now();
  final sets = await (db.select(db.exerciseSets).join([
    innerJoin(
      db.exercises,
      db.exercises.id.equalsExp(db.exerciseSets.exerciseId),
    ),
  ])).get();
  final trained = <DateTime>{};
  final bestByExercise = <int, _Lift>{};
  final dailyBest = <int, Map<DateTime, double>>{};
  final heat = <String, double>{};
  final weekStart = mondayOf(now);

  for (final row in sets) {
    final set = row.readTable(db.exerciseSets);
    final exercise = row.readTable(db.exercises);
    if ((set.notes ?? '').contains('warmup')) continue;
    final day = dateOnly(set.timestamp);
    trained.add(day);
    final reps = set.reps ?? 0;
    final load = set.loadKg ?? 0;
    if (!day.isBefore(weekStart)) {
      final region = regionForGroup(exercise.muscle);
      if (region != null) {
        heat[region] = (heat[region] ?? 0) + load * reps;
      }
      if (exercise.muscle == 'Arme') {
        heat['triceps'] = (heat['triceps'] ?? 0) + load * reps * 0.5;
        heat['biceps'] = (heat['biceps'] ?? 0) + load * reps * 0.5;
      }
      if (exercise.muscle == 'Beine') {
        heat['hams'] = (heat['hams'] ?? 0) + load * reps * 0.4;
        heat['glutes'] = (heat['glutes'] ?? 0) + load * reps * 0.3;
      }
    }
    final estimate = estimatedOneRepMax(load, reps);
    if (estimate <= 0) continue;
    final current = bestByExercise[exercise.id];
    if (current == null || estimate > current.best) {
      bestByExercise[exercise.id] = _Lift(
        id: exercise.id,
        name: exercise.name,
        germanName: exercise.germanName,
        best: estimate,
      );
    }
    final perDay = dailyBest.putIfAbsent(exercise.id, () => {});
    final previous = perDay[day] ?? 0;
    if (load > previous) perDay[day] = load;
  }

  if (heat.isNotEmpty) {
    final maxHeat = heat.values.reduce((a, b) => a > b ? a : b);
    if (maxHeat > 0) {
      for (final key in heat.keys.toList()) {
        heat[key] = heat[key]! / maxHeat;
      }
    }
  }

  final weekDays = List.generate(
    7,
    (index) => weekStart.add(Duration(days: index)),
  );
  final doneThisWeek = weekDays.where(trained.contains).length;
  final plans = await (db.select(
    db.plans,
  )..orderBy([(row) => OrderingTerm.asc(row.sequence)])).get();
  final next = plans.isEmpty ? null : plans[doneThisWeek % plans.length];
  final registryName = await _profileName();
  final goal = alphaPrefs.weeklyGoalManual
      ? alphaPrefs.weeklyGoal
      : _automaticGoal(trained, now);
  final lifts = _topLifts(bestByExercise, dailyBest);
  return _Dashboard(
    dayStreak: trainingDayStreak(trained, now),
    weekStreak: trainingWeekStreak(trained, now),
    weekDays: weekDays,
    trainedDays: trained,
    profileName: registryName,
    nextPlan: next,
    weekGoal: goal <= 0 ? 5 : goal,
    doneThisWeek: doneThisWeek,
    heat: heat,
    lifts: lifts,
    quote: _quote(next, doneThisWeek, goal <= 0 ? 5 : goal),
  );
}

Future<String> _profileName() async {
  try {
    final registry = await loadProfileRegistry();
    final name = registry.active.name.trim();
    if (name.isNotEmpty) return name;
  } catch (_) {}
  return 'Levin';
}

int _automaticGoal(Set<DateTime> trained, DateTime now) {
  final counts = <DateTime, int>{};
  for (final day in trained) {
    final week = mondayOf(day);
    counts[week] = (counts[week] ?? 0) + 1;
  }
  if (counts.isEmpty) return 5;
  final recent = counts.values.toList()..sort();
  return recent[recent.length ~/ 2].clamp(1, 7);
}

String _quote(Plan? plan, int done, int goal) {
  final title = '${plan?.title ?? ''} ${plan?.days ?? ''}'.toLowerCase();
  if (title.contains('pull') || title.contains('rücken')) return 'pull';
  if (title.contains('bein') || title.contains('leg')) return 'legs';
  if (title.contains('push') || title.contains('brust')) return 'push';
  if (done >= goal) return 'done';
  if (done > 0) return 'progress';
  return 'remain';
}

List<_LiftPoint> _topLifts(
  Map<int, _Lift> best,
  Map<int, Map<DateTime, double>> daily,
) {
  final ranked = best.values.toList()..sort((a, b) => b.best.compareTo(a.best));
  final points = <_LiftPoint>[];
  for (final lift in ranked.take(3)) {
    final series = daily[lift.id];
    if (series == null || series.length < 2) continue;
    final days = series.keys.toList()..sort();
    final recent = days.length > 8 ? days.sublist(days.length - 8) : days;
    final values = [for (final day in recent) series[day]!];
    points.add(
      _LiftPoint(
        name: lift.germanName?.isNotEmpty == true
            ? lift.germanName!
            : lift.name,
        delta: values.last - values.first,
        latest: values.last,
        points: values,
      ),
    );
  }
  return points;
}

class _Lift {
  const _Lift({
    required this.id,
    required this.name,
    required this.germanName,
    required this.best,
  });

  final int id;
  final String name;
  final String? germanName;
  final double best;
}

class _Hero extends StatelessWidget {
  const _Hero({
    required this.data,
    required this.name,
    required this.palette,
    required this.onGoal,
  });

  final _Dashboard data;
  final String name;
  final AlphaPalette palette;
  final VoidCallback onGoal;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final quote = switch (data.quote) {
      'pull' => l10n.quotePullDay,
      'push' => l10n.quotePushDay,
      'legs' => l10n.quoteLegDay,
      'progress' => l10n.quoteKeepGoing(data.doneThisWeek, data.weekGoal),
      'done' => l10n.quoteKeepGoing(data.doneThisWeek, data.weekGoal),
      _ => l10n.quoteRemaining(data.weekGoal - data.doneThisWeek),
    };
    final plan = data.nextPlan;
    final planName = plan == null
        ? l10n.tabTraining
        : ((plan.title ?? '').trim().isEmpty ? plan.days : plan.title!.trim());
    return Container(
      height: 302,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: palette.border),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.alphaBlend(
              palette.accent.withValues(alpha: 0.28),
              palette.card,
            ),
            palette.card,
            palette.background,
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: 20,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    palette.accent.withValues(alpha: 0.45),
                    palette.accent.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            right: -30,
            bottom: 20,
            child: Image.asset(
              palette.figureAsset,
              height: palette.id == 'pink' ? 280 : 250,
              fit: BoxFit.contain,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.helloName(name).split(',').first,
                  style: const TextStyle(
                    fontFamily: 'Bebas Neue',
                    fontSize: 42,
                    height: 0.9,
                  ),
                ),
                Text(
                  name,
                  style: TextStyle(
                    fontFamily: 'Bebas Neue',
                    fontSize: 42,
                    height: 0.9,
                    color: palette.accent,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    GestureDetector(
                      onTap: onGoal,
                      child: _Ring(
                        done: data.doneThisWeek,
                        goal: data.weekGoal,
                        palette: palette,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.weekGoal,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  quote,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: palette.buttonGradient == null
                          ? palette.accent
                          : null,
                      gradient: palette.buttonGradient,
                    ),
                    child: TextButton(
                      onPressed: plan == null
                          ? null
                          : () {
                              Navigator.of(context).push(
                                FlexPageRoute(
                                  builder: (context) =>
                                      GymWorkoutPage(plan: plan),
                                ),
                              );
                            },
                      child: Text(
                        l10n.startWorkoutNamed(planName),
                        style: TextStyle(
                          fontFamily: 'Bebas Neue',
                          fontSize: 22,
                          color: palette.onAccent,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Ring extends StatelessWidget {
  const _Ring({required this.done, required this.goal, required this.palette});

  final int done;
  final int goal;
  final AlphaPalette palette;

  @override
  Widget build(BuildContext context) {
    final progress = goal == 0 ? 0.0 : (done / goal).clamp(0, 1).toDouble();
    return SizedBox(
      width: 56,
      height: 56,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: progress,
            strokeWidth: 6,
            backgroundColor: palette.accent.withValues(alpha: 0.16),
            color: palette.accent,
          ),
          Text(
            '$done/$goal',
            style: const TextStyle(fontFamily: 'Bebas Neue', fontSize: 16),
          ),
        ],
      ),
    );
  }
}

class _Mini extends StatelessWidget {
  const _Mini({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final palette = AlphaTheme.of(context);
    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: palette.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: palette.accent, size: 22),
          const SizedBox(width: 6),
          Expanded(
            child: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}

class _WeekStrip extends StatelessWidget {
  const _WeekStrip({required this.days, required this.trained});

  final List<DateTime> days;
  final Set<DateTime> trained;

  @override
  Widget build(BuildContext context) {
    final palette = AlphaTheme.of(context);
    final today = dateOnly(DateTime.now());
    return Row(
      children: [
        for (final day in days)
          Expanded(
            child: Column(
              children: [
                Text(
                  MaterialLocalizations.of(context).narrowWeekdays[day.weekday %
                      7],
                  style: TextStyle(
                    color: day == today ? palette.accent : palette.muted,
                    fontWeight: day == today
                        ? FontWeight.w700
                        : FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 34,
                  height: 34,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: trained.contains(day)
                        ? palette.accent
                        : palette.card,
                    border: day == today
                        ? Border.all(color: palette.accent, width: 2)
                        : Border.all(color: palette.border),
                  ),
                  child: Text(
                    '${day.day}',
                    style: TextStyle(
                      color: trained.contains(day)
                          ? palette.onAccent
                          : palette.text,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _MuscleCard extends StatelessWidget {
  const _MuscleCard({
    required this.heat,
    required this.female,
    required this.onOpen,
  });

  final Map<String, double> heat;
  final bool female;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final palette = AlphaTheme.of(context);
    final chips = [
      for (final entry in heat.entries)
        if (entry.value > 0) muscleLabel(context.l10n, entry.key),
    ];
    return Material(
      color: palette.card,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: palette.border),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(context.l10n.musclesThisWeek),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: [
                        for (final chip in chips.take(6))
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: palette.accent.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: palette.accent.withValues(alpha: 0.35),
                              ),
                            ),
                            child: Text(
                              chip,
                              style: TextStyle(
                                color: palette.accent,
                                fontSize: 11,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              MuscleMap(heat: heat, compact: true, female: female),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({required this.lifts});

  final List<_LiftPoint> lifts;

  @override
  Widget build(BuildContext context) {
    final palette = AlphaTheme.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(context.l10n.progressHeading),
              const Spacer(),
              Text(
                context.l10n.lastEightWeeks,
                style: TextStyle(color: palette.muted, fontSize: 12),
              ),
            ],
          ),
          for (final lift in lifts)
            SizedBox(
              height: 36,
              child: Row(
                children: [
                  Expanded(flex: 3, child: Text(lift.name, maxLines: 1)),
                  Expanded(
                    flex: 2,
                    child: CustomPaint(
                      painter: _LinePainter(lift.points, palette.accent),
                    ),
                  ),
                  Text('${lift.latest.toStringAsFixed(0)} kg'),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _LinePainter extends CustomPainter {
  _LinePainter(this.values, this.color);

  final List<double> values;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;
    final minV = values.reduce((a, b) => a < b ? a : b);
    final maxV = values.reduce((a, b) => a > b ? a : b);
    final span = (maxV - minV).abs() < 0.01 ? 1.0 : maxV - minV;
    final path = Path();
    for (var index = 0; index < values.length; index++) {
      final dx = size.width * index / (values.length - 1);
      final dy =
          size.height - ((values[index] - minV) / span) * (size.height - 4) - 2;
      if (index == 0) {
        path.moveTo(dx, dy);
      } else {
        path.lineTo(dx, dy);
      }
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant _LinePainter oldDelegate) => true;
}
