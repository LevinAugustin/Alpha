import 'package:drift/drift.dart' hide Column;
import 'package:flexify/alpha/alpha_prefs.dart';
import 'package:flexify/alpha/live_workout.dart';
import 'package:flexify/database/database.dart';
import 'package:flexify/settings/alpha_settings_page.dart';
import 'package:flexify/shell/create_profile_dialog.dart';
import 'package:flexify/workout/muscle_atlas_page.dart';
import 'package:flexify/l10n/l10n.dart';
import 'package:flexify/main.dart';
import 'package:flexify/plan/plan_names.dart';
import 'package:flexify/platform_page_route.dart';
import 'package:flexify/profile/local_profiles.dart';
import 'package:flexify/shell/training_stats.dart';
import 'package:flexify/theme/alpha_theme.dart';
import 'package:flexify/update/app_update.dart';
import 'package:flexify/workout/gym_workout_page.dart';
import 'package:flexify/workout/muscle_map.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StartPage extends StatefulWidget {
  const StartPage({super.key, this.active});

  final ValueListenable<bool>? active;

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  late Future<_Dashboard> _future;
  _Dashboard? _shown;
  LiveWorkout? _live;
  String? _knownProfile;
  var _profileReady = false;

  @override
  void initState() {
    super.initState();
    _live = liveWorkout.value;
    _future = _load();
    liveWorkout.addListener(_onLive);
    widget.active?.addListener(_onActive);
  }

  @override
  void didUpdateWidget(StartPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.active == widget.active) return;
    oldWidget.active?.removeListener(_onActive);
    widget.active?.addListener(_onActive);
  }

  @override
  void dispose() {
    liveWorkout.removeListener(_onLive);
    widget.active?.removeListener(_onActive);
    super.dispose();
  }

  void _onLive() {
    final next = liveWorkout.value;
    final ended = _live != null && next == null;
    _live = next;
    if (!mounted) return;
    if (ended) {
      _reload();
    } else {
      setState(() {});
    }
  }

  void _onActive() {
    if (widget.active?.value == true) _reload();
  }

  void _reload() {
    if (!mounted) return;
    final next = _load();
    setState(() {
      _future = next;
    });
  }

  Future<void> _createProfile() async {
    final saved = await showCreateProfileDialog(context);
    if (!saved || !mounted) return;
    _reload();
  }

  Future<void> _openPlan(Plan plan) async {
    await Navigator.of(
      context,
    ).push(FlexPageRoute(builder: (context) => GymWorkoutPage(plan: plan)));
    _reload();
  }

  Future<void> _startOrResume(Plan? next) async {
    final live = liveWorkout.value;
    if (live != null) {
      final plan = await (db.select(
        db.plans,
      )..where((row) => row.id.equals(live.planId))).getSingleOrNull();
      if (plan == null || !mounted) return;
      await _openPlan(plan);
      return;
    }
    if (next == null) return;
    await _openPlan(next);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_Dashboard>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.data != null) _shown = snapshot.data;
        final data = _shown;
        if (data == null)
          return const Center(child: CircularProgressIndicator());
        final l10n = context.l10n;
        final palette = AlphaTheme.of(context);
        final stored = context.select<Setting, String?>(
          (settings) => settings.profileName,
        );
        if (!_profileReady) {
          _knownProfile = stored;
          _profileReady = true;
        } else if (stored != _knownProfile) {
          _knownProfile = stored;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _reload();
          });
        }
        final storedName = stored?.trim() ?? '';
        final name = storedName.isEmpty ? data.profileName : storedName;
        if (name.isEmpty) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            children: [
              _GuestHero(palette: palette, onCreate: _createProfile),
              const SizedBox(height: 12),
              _LockedHome(
                data: data,
                palette: palette,
                onUnlock: _createProfile,
              ),
            ],
          );
        }
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
                _reload();
              },
              onStart: liveWorkout.value == null && data.nextPlan == null
                  ? null
                  : () => _startOrResume(data.nextPlan),
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
                  child: HomeStatTile(
                    icon: Icons.local_fire_department,
                    text: l10n.dayStreak(data.dayStreak),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: HomeStatTile(
                    icon: Icons.calendar_view_week,
                    text: l10n.weekStreak(data.weekStreak),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.thisWeek,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.weekGoalProgress(data.doneThisWeek, data.weekGoal),
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
  final workouts = await db.select(db.workouts).get();
  final startedByWorkout = {
    for (final workout in workouts) workout.id: workout.startedAt,
  };

  for (final row in sets) {
    final set = row.readTable(db.exerciseSets);
    final exercise = row.readTable(db.exercises);
    if ((set.notes ?? '').contains('warmup')) continue;
    final started = set.workoutId == null
        ? null
        : startedByWorkout[set.workoutId!];
    final day = workoutDay(started ?? set.timestamp);
    trained.add(day);
    final reps = set.reps ?? 0;
    final load = set.loadKg ?? 0;
    if (!day.isBefore(weekStart)) {
      contributeMuscleHeat(
        heat,
        load: load * reps,
        group: exercise.muscle,
        primaryMuscles: exercise.primaryMuscles,
        secondaryMuscles: exercise.secondaryMuscles,
      );
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
  final next = await suggestedNextPlan(now);
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

Future<int> finishedWorkoutsThisWeek(DateTime now) async {
  final start = mondayOf(now);
  final end = start.add(const Duration(days: 7));
  final rows =
      await (db.select(db.workouts)..where(
            (row) =>
                row.endedAt.isNotNull() &
                row.startedAt.isBiggerOrEqualValue(start) &
                row.startedAt.isSmallerThanValue(end),
          ))
          .get();
  return rows.length;
}

Future<Plan?> suggestedNextPlan(DateTime now) async {
  final plans =
      await (db.select(db.plans)..orderBy([
            (row) => OrderingTerm.asc(row.sequence),
            (row) => OrderingTerm.asc(row.id),
          ]))
          .get();
  if (plans.isEmpty) return null;
  final completed =
      await (db.select(db.workouts)
            ..where((row) => row.endedAt.isNotNull())
            ..orderBy([
              (row) => OrderingTerm.asc(row.startedAt),
              (row) => OrderingTerm.asc(row.id),
            ]))
          .get();
  final done = completed
      .where((row) => !row.startedAt.toLocal().isAfter(now.toLocal()))
      .toList();
  final lastIndex = done.isEmpty
      ? null
      : plans.indexWhere((plan) => plan.id == done.last.planId);
  return plans[nextPlanIndex(
    lastPlanIndex: lastIndex != null && lastIndex >= 0 ? lastIndex : null,
    completedCount: done.length,
    planCount: plans.length,
  )];
}

Future<String> _profileName() async {
  try {
    final registry = await loadProfileRegistry();
    final name = registry.active.name.trim();
    if (name.isNotEmpty) return name;
  } catch (_) {}
  return '';
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
  final title = (plan?.title ?? '').toLowerCase();
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

class _GuestHero extends StatelessWidget {
  const _GuestHero({required this.palette, required this.onCreate});

  final AlphaPalette palette;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Stack(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 128, 8),
                child: Text(
                  l10n.welcomeToAlpha,
                  style: TextStyle(
                    fontFamily: 'Bebas Neue',
                    fontSize: 40,
                    height: 0.9,
                    color: palette.accent,
                  ),
                ),
              ),
              Positioned(
                right: 4,
                top: 8,
                width: 112,
                height: 96,
                child: Image.asset(
                  palette.figureAsset,
                  fit: BoxFit.contain,
                  alignment: Alignment.centerRight,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 14),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 52),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: palette.buttonGradient == null ? palette.accent : null,
                  gradient: palette.buttonGradient,
                ),
                child: TextButton(
                  key: const Key('create-profile'),
                  onPressed: onCreate,
                  child: Text(
                    l10n.createProfileButton,
                    style: TextStyle(
                      fontFamily: 'Bebas Neue',
                      fontSize: 22,
                      color: palette.onAccent,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LockedHome extends StatelessWidget {
  const _LockedHome({
    required this.data,
    required this.palette,
    required this.onUnlock,
  });

  final _Dashboard data;
  final AlphaPalette palette;
  final VoidCallback onUnlock;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final plan = data.nextPlan;
    final planName = plan == null
        ? l10n.tabTraining
        : planDisplayName(
            title: plan.title,
            sequence: plan.sequence,
            id: plan.id,
          );
    return Stack(
      children: [
        Opacity(
          opacity: 0.45,
          child: IgnorePointer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: HomeStatTile(
                        icon: Icons.local_fire_department,
                        text: l10n.dayStreak(data.dayStreak),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: HomeStatTile(
                        icon: Icons.calendar_view_week,
                        text: l10n.weekStreak(data.weekStreak),
                      ),
                    ),
                    const SizedBox(width: 28),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.thisWeek,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.weekGoalProgress(data.doneThisWeek, data.weekGoal),
                      style: TextStyle(color: palette.muted),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _WeekStrip(days: data.weekDays, trained: data.trainedDays),
                const SizedBox(height: 12),
                ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 52),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: palette.accent,
                    ),
                    child: Center(
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
        ),
        Positioned(
          right: 0,
          top: 0,
          child: Icon(Icons.lock_outline, color: palette.accent),
        ),
        Positioned.fill(
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(key: const Key('locked-home'), onTap: onUnlock),
          ),
        ),
      ],
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({
    required this.data,
    required this.name,
    required this.palette,
    required this.onGoal,
    required this.onStart,
  });

  final _Dashboard data;
  final String name;
  final AlphaPalette palette;
  final VoidCallback onGoal;
  final VoidCallback? onStart;

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
        : planDisplayName(
            title: plan.title,
            sequence: plan.sequence,
            id: plan.id,
          );
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Stack(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 128, 8),
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
                    if (name.isNotEmpty)
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
                        Expanded(
                          child: Text(
                            l10n.weekGoal,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      quote,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              Positioned(
                right: 4,
                bottom: 0,
                width: 112,
                height: 150,
                child: Image.asset(
                  palette.figureAsset,
                  fit: BoxFit.contain,
                  alignment: Alignment.bottomRight,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 14),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 52),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: palette.buttonGradient == null ? palette.accent : null,
                  gradient: palette.buttonGradient,
                ),
                child: TextButton(
                  key: const Key('start-workout'),
                  onPressed: onStart,
                  child: ValueListenableBuilder<LiveWorkout?>(
                    valueListenable: liveWorkout,
                    builder: (context, session, _) {
                      return Text(
                        session == null
                            ? l10n.startWorkoutNamed(planName)
                            : l10n.resumeWorkout,
                        style: TextStyle(
                          fontFamily: 'Bebas Neue',
                          fontSize: 22,
                          color: palette.onAccent,
                        ),
                      );
                    },
                  ),
                ),
              ),
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
          FittedBox(
            child: Text(
              '$done/$goal',
              style: const TextStyle(fontFamily: 'Bebas Neue', fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}

class HomeStatTile extends StatelessWidget {
  const HomeStatTile({super.key, required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final palette = AlphaTheme.of(context);
    return Container(
      constraints: const BoxConstraints(minHeight: 46),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(text, maxLines: 1),
            ),
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
