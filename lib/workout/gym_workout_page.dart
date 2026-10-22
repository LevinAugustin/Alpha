import 'dart:async';
import 'dart:io';

import 'package:drift/drift.dart' hide Column;
import 'package:flexify/alpha/alpha_prefs.dart';
import 'package:flexify/alpha/gym_start_sheet.dart';
import 'package:flexify/alpha/live_workout.dart';
import 'package:flexify/alpha/plates.dart';
import 'package:flexify/alpha/set_notes.dart';
import 'package:flexify/alpha/unilateral_sets.dart';
import 'package:flexify/coach/api_key_store.dart';
import 'package:flexify/coach/coach_client.dart';
import 'package:flexify/database/database.dart';
import 'package:flexify/database/exercise_set_repository.dart';
import 'package:flexify/exercises/exercise_detail_page.dart';
import 'package:flexify/exercises/exercise_picker.dart';
import 'package:flexify/exercises/exercise_image.dart';
import 'package:flexify/exercise_labels.dart';
import 'package:flexify/feedback/feedback_page.dart';
import 'package:flexify/l10n/generated/app_localizations.dart';
import 'package:flexify/l10n/l10n.dart';
import 'package:flexify/logging.dart';
import 'package:flexify/main.dart';
import 'package:flexify/plan/plan_names.dart';
import 'package:flexify/platform_page_route.dart';
import 'package:flexify/theme/alpha_theme.dart';
import 'package:flexify/timer/timer_state.dart';
import 'package:flexify/workout/plate_calculator_page.dart';
import 'package:flexify/workout/set_table.dart';
import 'package:flexify/workout/workout_sort_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class GymWorkoutPage extends StatefulWidget {
  const GymWorkoutPage({super.key, required this.plan});

  final Plan plan;

  @override
  State<GymWorkoutPage> createState() => _GymWorkoutPageState();
}

class _SidePair {
  const _SidePair({this.left, this.right});

  final ExerciseSet? left;
  final ExerciseSet? right;
}

class _SetRow {
  _SetRow({required this.kg, required this.reps, required this.previous});

  final TextEditingController kg;
  final TextEditingController reps;
  String previous;
  bool done = false;
  bool warmup = false;
  bool bothSides = false;
  int? setId;
  int? rightSetId;
  double? legacyRightReps;

  void dispose() {
    kg.dispose();
    reps.dispose();
  }
}

class _ExerciseBlock {
  _ExerciseBlock({
    required this.exercise,
    required this.restSeconds,
    required this.sets,
  });

  Exercise exercise;
  int restSeconds;
  int? repMin;
  int? repMax;
  String note = '';
  final List<_SetRow> sets;

  void dispose() {
    for (final set in sets) {
      set.dispose();
    }
  }
}

class _PendingExercise {
  _PendingExercise({
    required this.block,
    required this.index,
    this.replacement,
    required this.swapped,
  });

  final _ExerciseBlock block;
  final int index;
  final _ExerciseBlock? replacement;
  final bool swapped;
}

class _GymWorkoutPageState extends State<GymWorkoutPage> {
  final List<_ExerciseBlock> _blocks = [];
  final Map<int, int?> _planRest = {};
  Workout? _workout;
  Timer? _clock;
  var _ready = false;
  var _busy = false;
  _PendingExercise? _pendingExercise;
  var _undoingExercise = false;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
    final testing = WidgetsBinding.instance.runtimeType.toString().contains(
      'Test',
    );
    if (!testing) {
      _clock = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() {});
      });
    }
  }

  @override
  void dispose() {
    _clock?.cancel();
    if (!Platform.environment.containsKey('FLUTTER_TEST')) {
      unawaited(WakelockPlus.disable().catchError((Object _) {}));
    }
    for (final block in _blocks) {
      block.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    if (!Platform.environment.containsKey('FLUTTER_TEST')) {
      unawaited(WakelockPlus.enable().catchError((Object _) {}));
    }
    try {
      await alphaPrefs.load();
    } catch (error, stack) {
      debugPrint('Gym prefs unavailable: $error\n$stack');
    }
    final existing =
        await (db.select(db.workouts)..where(
              (row) => row.planId.equals(widget.plan.id) & row.endedAt.isNull(),
            ))
            .getSingleOrNull();
    if (mounted && existing == null) {
      final ready = await _ensureStudio();
      if (!mounted) return;
      if (!ready) {
        if (Navigator.of(context).canPop()) Navigator.of(context).pop();
        return;
      }
    }
    final settings = await (db.settings.select()..limit(1)).getSingle();
    final workout = await _activeWorkout(existing);
    final planRows =
        await (db.select(db.planExercises).join([
              innerJoin(
                db.exercises,
                db.exercises.id.equalsExp(db.planExercises.exerciseId),
              ),
            ])..where(
              db.planExercises.planId.equals(widget.plan.id) &
                  db.planExercises.enabled.equals(true),
            ))
            .get();
    planRows.sort(
      (a, b) => a
          .readTable(db.planExercises)
          .sequence
          .compareTo(b.readTable(db.planExercises).sequence),
    );
    final logged = await (db.select(
      db.exerciseSets,
    )..where((row) => row.workoutId.equals(workout.id))).get();
    final byExercise = <int, TypedResult>{
      for (final row in planRows) row.readTable(db.exercises).id: row,
    };
    final savedOrder = _parseOrder(workout.exerciseOrder);
    final order = savedOrder ?? byExercise.keys.toList();
    if (savedOrder == null) {
      await _writeOrder(workout.id, order);
    }
    final blocks = <_ExerciseBlock>[];
    for (final exerciseId in order) {
      final row = byExercise[exerciseId];
      final exercise =
          row?.readTable(db.exercises) ??
          await (db.select(
            db.exercises,
          )..where((item) => item.id.equals(exerciseId))).getSingleOrNull();
      if (exercise == null) continue;
      final planExercise = row?.readTable(db.planExercises);
      _planRest[exercise.id] = planExercise?.restMs;
      blocks.add(
        await _blockFor(
          exercise,
          workout.id,
          planExercise?.maxSets ?? settings.maxSets,
          _restMs(exercise, planExercise?.restMs, settings.timerDuration),
          logged.where((set) => set.exerciseId == exercise.id).toList(),
          repMin: planExercise?.repMin,
          repMax: planExercise?.repMax,
        ),
      );
    }
    if (!mounted) return;
    setState(() {
      _workout = workout;
      _blocks
        ..clear()
        ..addAll(blocks);
      _ready = true;
    });
    _publishLive();
  }

  Future<bool> _ensureStudio() async {
    if (alphaPrefs.gyms.isEmpty) {
      final name = await showFirstStudioDialog(context);
      if (!mounted) return false;
      final trimmed = name?.trim() ?? '';
      if (trimmed.isEmpty) return false;
      final gym = GymPlace(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: trimmed,
        createdAt: DateTime.now(),
      );
      alphaPrefs.gyms = [gym];
      alphaPrefs.activeGymId = gym.id;
      await alphaPrefs.save();
      return true;
    }
    if (alphaPrefs.gyms.length == 1) {
      final only = alphaPrefs.gyms.single.id;
      if (alphaPrefs.activeGymId != only) {
        alphaPrefs.activeGymId = only;
        await alphaPrefs.save();
      }
      return true;
    }
    final choice = await showGymStartSheet(context);
    if (!mounted || choice == null || choice.gymId == null) return false;
    alphaPrefs.activeGymId = choice.gymId!;
    await alphaPrefs.save();
    return true;
  }

  void _publishLive() {
    if (_workout == null) return;
    final title = planTitleOf(
      context,
      title: widget.plan.title,
      sequence: widget.plan.sequence,
      id: widget.plan.id,
    );
    final current = _blocks.cast<_ExerciseBlock?>().firstWhere(
      (block) => block!.sets.any((set) => !set.done),
      orElse: () => _blocks.isEmpty ? null : _blocks.first,
    );
    final name = current == null
        ? title
        : localizedExerciseName(
            context,
            current.exercise.name,
            german: current.exercise.germanName,
            english: current.exercise.englishName,
          );
    liveWorkout.value = LiveWorkout(
      planId: widget.plan.id,
      workoutId: _workout!.id,
      title: title,
      exercise: name,
    );
  }

  List<int>? _parseOrder(String? raw) {
    if (raw == null) return null;
    if (raw.trim().isEmpty) return const [];
    return raw
        .split(',')
        .map((part) => int.tryParse(part.trim()))
        .whereType<int>()
        .toList();
  }

  Future<void> _writeOrder(int workoutId, List<int> ids) async {
    await (db.update(db.workouts)..where((row) => row.id.equals(workoutId)))
        .write(WorkoutsCompanion(exerciseOrder: Value(ids.join(','))));
  }

  Future<void> _persistOrder() async {
    final workout = _workout;
    if (workout == null) return;
    await _writeOrder(
      workout.id,
      _blocks.map((block) => block.exercise.id).toList(),
    );
  }

  Future<Workout> _activeWorkout(Workout? existing) async {
    if (existing != null) return existing;
    final id = await db.workouts.insertOne(
      WorkoutsCompanion.insert(
        planId: Value(widget.plan.id),
        startedAt: DateTime.now(),
      ),
    );
    return (db.select(
      db.workouts,
    )..where((row) => row.id.equals(id))).getSingle();
  }

  Future<_ExerciseBlock> _blockFor(
    Exercise exercise,
    int workoutId,
    int targetSets,
    int restMs,
    List<ExerciseSet> current, {
    int? repMin,
    int? repMax,
  }) async {
    final logged = [...current]
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    final previous = await _previousSets(exercise.id, workoutId);
    final rows = <_SetRow>[];
    if (exercise.einseitig) {
      final loggedPairs = _sidePairs(logged);
      final previousPairs = _sidePairs(previous);
      final count = [
        targetSets,
        previousPairs.length,
        loggedPairs.length,
        1,
      ].reduce((a, b) => a > b ? a : b);
      for (var index = 0; index < count; index++) {
        final saved = index < loggedPairs.length ? loggedPairs[index] : null;
        final earlier = index < previousPairs.length
            ? previousPairs[index]
            : null;
        final source =
            saved?.left ?? saved?.right ?? earlier?.left ?? earlier?.right;
        final row = _SetRow(
          kg: TextEditingController(
            text: _prefill(exercise.id, source?.loadKg, index),
          ),
          reps: TextEditingController(text: _repsForPair(saved, earlier)),
          previous: _pairPrevious(earlier),
        );
        row.bothSides = _countsBothSides(saved);
        row.legacyRightReps = _legacyRightReps(saved);
        row.warmup = notesAreWarmup((saved?.left ?? saved?.right)?.notes);
        if (saved != null) {
          row.done = true;
          row.setId = saved.left?.id;
          row.rightSetId = saved.right?.id;
        }
        rows.add(row);
      }
    } else {
      final count = [
        targetSets,
        previous.length,
        logged.length,
        1,
      ].reduce((a, b) => a > b ? a : b);
      for (var index = 0; index < count; index++) {
        final earlier = index < previous.length ? previous[index] : null;
        final saved = index < logged.length ? logged[index] : null;
        final source = saved ?? earlier;
        final row = _SetRow(
          kg: TextEditingController(
            text: _prefill(exercise.id, source?.loadKg, index),
          ),
          reps: TextEditingController(text: _number(source?.reps)),
          previous: _previousLabel(earlier),
        );
        row.warmup = notesAreWarmup(saved?.notes);
        if (saved != null) {
          row.done = true;
          row.setId = saved.id;
        }
        rows.add(row);
      }
    }
    final block = _ExerciseBlock(
      exercise: exercise,
      restSeconds: nearestRest((restMs / 1000).round()),
      sets: rows,
    );
    block.repMin = repMin;
    block.repMax = repMax;
    return block;
  }

  String _repsForPair(_SidePair? saved, _SidePair? earlier) {
    if (saved != null) {
      final left = saved.left?.reps;
      final right = saved.right?.reps;
      if (left != null && right != null && left != right) {
        return '${_number(left)}/${_number(right)}';
      }
      return _number(left ?? right);
    }
    final left = earlier?.left?.reps;
    final right = earlier?.right?.reps;
    if (left != null && right != null && left != right) return '';
    return _number(left ?? right);
  }

  double? _legacyRightReps(_SidePair? saved) {
    final left = saved?.left?.reps;
    final right = saved?.right?.reps;
    if (left == null || right == null || left == right) return null;
    return right;
  }

  double _plainReps(String text) {
    var best = 0.0;
    for (final part in text.split('/')) {
      final value = double.tryParse(part.trim().replaceAll(',', '.')) ?? 0;
      if (value > best) best = value;
    }
    return best;
  }

  bool _countsBothSides(_SidePair? saved) {
    if (saved == null) return false;
    final left = saved.left;
    final right = saved.right;
    if (left != null && right != null) return left.reps == right.reps;
    if (right != null) return false;
    final side = left?.side;
    return side == null || side.isEmpty;
  }

  List<_SidePair> _sidePairs(List<ExerciseSet> sets) {
    final pairs = <_SidePair>[];
    final open = <int, ExerciseSet>{};
    for (final set in sets) {
      final side = set.side;
      if (side != 'links' && side != 'rechts') {
        pairs.add(_SidePair(left: set));
        continue;
      }
      final stamp = set.timestamp.millisecondsSinceEpoch ~/ 1000;
      final other = open.remove(stamp);
      if (other == null || other.side == side) {
        if (other != null) pairs.add(_combineSides(other, null));
        open[stamp] = set;
        continue;
      }
      pairs.add(_combineSides(other, set));
    }
    for (final set in open.values) {
      pairs.add(_combineSides(set, null));
    }
    return pairs;
  }

  _SidePair _combineSides(ExerciseSet first, ExerciseSet? second) {
    ExerciseSet? left;
    ExerciseSet? right;
    void take(ExerciseSet set) {
      if (set.side == 'rechts') {
        right ??= set;
      } else {
        left ??= set;
      }
    }

    take(first);
    if (second != null) take(second);
    return _SidePair(left: left, right: right);
  }

  String _pairPrevious(_SidePair? pair) {
    if (pair == null || (pair.left == null && pair.right == null)) return '—';
    final load = pair.left?.loadKg ?? pair.right?.loadKg;
    final reps = pairedRepsLabel(pair.left?.reps, pair.right?.reps, _number);
    if (_number(load).isEmpty && reps.isEmpty) return '—';
    return '${_number(load)} kg × $reps';
  }

  String _prefill(int exerciseId, double? logged, int index) {
    if (logged != null) return _number(logged);
    if (index != 0) return '';
    final next = alphaPrefs.nextWeight['$exerciseId'];
    return next == null ? '' : _number(next);
  }

  Future<List<ExerciseSet>> _previousSets(int exerciseId, int workoutId) async {
    final history =
        await (db.select(db.exerciseSets)
              ..where(
                (row) =>
                    row.exerciseId.equals(exerciseId) &
                    row.workoutId.isNotValue(workoutId),
              )
              ..orderBy([(row) => OrderingTerm.desc(row.timestamp)])
              ..limit(80))
            .get();
    final home = firstStudio(alphaPrefs.gyms)?.id;
    final gymHistory = history
        .where(
          (set) => sameGym(set.notes, alphaPrefs.activeGymId, firstGymId: home),
        )
        .toList();
    if (gymHistory.isEmpty) return const [];
    final workoutIdOfLast = gymHistory.first.workoutId;
    final sets = gymHistory
        .where((set) => set.workoutId == workoutIdOfLast)
        .toList();
    sets.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return sets;
  }

  String _number(double? value) {
    if (value == null) return '';
    if (value == value.roundToDouble()) return value.round().toString();
    return value.toString();
  }

  String _previousLabel(ExerciseSet? set) {
    if (set == null) return '—';
    final kg = _number(set.loadKg);
    final reps = _number(set.reps);
    if (kg.isEmpty && reps.isEmpty) return '—';
    return '$kg kg × $reps';
  }

  int get _doneSets => _blocks.fold(
    0,
    (count, block) => count + block.sets.where((set) => set.done).length,
  );

  double get _volume {
    var total = 0.0;
    for (final block in _blocks) {
      for (final set in block.sets.where((row) => row.done && !row.warmup)) {
        final kg = double.tryParse(set.kg.text.replaceAll(',', '.')) ?? 0;
        final text = set.reps.text.trim();
        final parts = text.split('/');
        if (block.exercise.einseitig &&
            set.legacyRightReps != null &&
            parts.length == 2) {
          final left =
              double.tryParse(parts[0].trim().replaceAll(',', '.')) ?? 0;
          total += kg * left + kg * set.legacyRightReps!;
        } else if (block.exercise.einseitig && set.bothSides) {
          final reps = double.tryParse(text.replaceAll(',', '.')) ?? 0;
          total += kg * reps * 2;
        } else {
          final reps = double.tryParse(text.replaceAll(',', '.')) ?? 0;
          total += kg * reps;
        }
      }
    }
    return total;
  }

  String get _elapsed {
    final started = _workout?.startedAt ?? DateTime.now();
    final duration = DateTime.now().difference(started);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (hours > 0) return '$hours:$minutes:$seconds';
    return '$minutes:$seconds';
  }

  Future<void> _toggle(int blockIndex, int setIndex) async {
    if (_busy || _workout == null) return;
    final block = _blocks[blockIndex];
    final row = block.sets[setIndex];
    setState(() => _busy = true);
    try {
      if (row.done && (row.setId != null || row.rightSetId != null)) {
        await deleteExerciseSets(db, [
          if (row.setId != null) row.setId!,
          if (row.rightSetId != null) row.rightSetId!,
        ]);
        row.done = false;
        row.setId = null;
        row.rightSetId = null;
        row.bothSides = false;
        row.legacyRightReps = null;
        if (row.reps.text.contains('/')) {
          row.reps.text = _number(_plainReps(row.reps.text));
        }
        if (mounted) context.read<TimerState>().stopTimer();
      } else {
        if (row.reps.text.contains('/')) {
          row.reps.text = _number(_plainReps(row.reps.text));
        }
        final kg = double.tryParse(row.kg.text.replaceAll(',', '.')) ?? 0;
        final reps = double.tryParse(row.reps.text.replaceAll(',', '.')) ?? 0;
        final hadHistory = row.previous != '—';
        final saved = await insertExerciseSet(
          db,
          exerciseId: block.exercise.id,
          workoutId: _workout!.id,
          exerciseSet: ExerciseSetView(
            id: 0,
            bodyWeight: 0,
            cardio: block.exercise.kind == 'cardio',
            created: DateTime.now(),
            distance: 0,
            duration: 0,
            name: block.exercise.name,
            notes: encodeSetNotes(
              gymId: alphaPrefs.activeGymId,
              warmup: row.warmup,
              userNote: block.note,
            ),
            planId: widget.plan.id,
            reps: reps,
            unit: 'kg',
            weight: kg,
          ),
        );
        row.done = true;
        row.setId = saved.id;
        row.rightSetId = null;
        row.legacyRightReps = null;
        row.bothSides = block.exercise.einseitig;
        await _startRest(block);
        final best =
            !row.warmup &&
            hadHistory &&
            await isBestExerciseSet(
              db,
              saved,
              gymId: alphaPrefs.activeGymId,
              firstGymId: firstStudio(alphaPrefs.gyms)?.id,
            );
        if (best && mounted) await _showRecord(kg, reps);
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
        _publishLive();
      }
    }
  }

  Future<void> _startRest(_ExerciseBlock block) async {
    if (!mounted || block.restSeconds <= 0) return;
    final settings = context.read<Setting>();
    if (!settings.restTimers) return;
    final timer = context.read<TimerState>();
    try {
      await timer.startTimer(
        localizedExerciseName(
          context,
          block.exercise.name,
          german: block.exercise.germanName,
          english: block.exercise.englishName,
        ),
        Duration(seconds: block.restSeconds),
        settings.alarmSound,
        settings.vibrate,
        settings.enableSound,
        'plan:${widget.plan.id}',
        false,
        settings.restVolume,
      );
    } catch (error, stack) {
      talker.handle(error, stack, 'Rest timer failed');
    }
  }

  Future<void> _shiftRest(int seconds) async {
    final timer = context.read<TimerState>();
    final remaining = timer.timer.getRemaining() + Duration(seconds: seconds);
    if (remaining.inSeconds <= 0) {
      await timer.stopTimer();
      return;
    }
    final settings = context.read<Setting>();
    await timer.startTimer(
      context.l10n.restTimer,
      remaining,
      settings.alarmSound,
      settings.vibrate,
      settings.enableSound,
      'plan:${widget.plan.id}',
      false,
      settings.restVolume,
    );
  }

  Future<void> _showRecord(double kg, double reps) async {
    final palette = AlphaTheme.of(context);
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: palette.card,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(palette.figureAsset, height: 180),
            const SizedBox(height: 12),
            Text(
              context.l10n.newRecordTitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Bebas Neue',
                fontSize: 42,
                color: palette.accent,
              ),
            ),
            Text(
              '${_number(kg)} kg × ${_number(reps)}',
              style: const TextStyle(fontFamily: 'Bebas Neue', fontSize: 36),
            ),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.recordKeepGoing),
          ),
        ],
      ),
    );
  }

  int _restMs(Exercise exercise, int? planRest, int globalMs) {
    final raw = planRest ?? exercise.defaultRestDurationMs ?? globalMs;
    return nearestRestMs(raw);
  }

  int _restFor(Exercise exercise, Setting settings) {
    return _restMs(exercise, _planRest[exercise.id], settings.timerDuration);
  }

  void _stampStudioUse() {
    final id = alphaPrefs.activeGymId;
    for (final gym in alphaPrefs.gyms) {
      if (gym.id == id) gym.lastUsedAt = DateTime.now();
    }
  }

  Future<void> _finish() async {
    final workout = _workout;
    if (workout == null) return;
    final palette = AlphaTheme.of(context);
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: palette.card,
        title: Text(l10n.finishWorkoutAsk),
        content: Text(l10n.finishWorkoutBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            key: const Key('confirm-finish'),
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.workoutFinish),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await _commitPendingExercise();
    _stampStudioUse();
    await alphaPrefs.save();
    await (db.update(db.workouts)..where((row) => row.id.equals(workout.id)))
        .write(WorkoutsCompanion(endedAt: Value(DateTime.now())));
    if (mounted) await context.read<TimerState>().stopTimer();
    await _offerProgression();
    if (liveWorkout.value?.workoutId == workout.id) liveWorkout.value = null;
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  Future<void> _offerProgression() async {
    if (!alphaPrefs.progression || !mounted) return;
    for (final block in _blocks) {
      final ceiling = block.repMax;
      final floor = block.repMin ?? ceiling;
      if (ceiling == null || floor == null) continue;
      final working = block.sets.where((set) => set.done && !set.warmup);
      if (working.isEmpty ||
          working.any((set) {
            final reps =
                double.tryParse(set.reps.text.replaceAll(',', '.')) ?? 0;
            return reps < ceiling;
          })) {
        continue;
      }
      final heaviest = working
          .map((set) => double.tryParse(set.kg.text.replaceAll(',', '.')) ?? 0)
          .fold<double>(0, (best, value) => value > best ? value : best);
      final next = heaviest + 2.5;
      if (!mounted) return;
      final palette = AlphaTheme.of(context);
      final name = localizedExerciseName(
        context,
        block.exercise.name,
        german: block.exercise.germanName,
        english: block.exercise.englishName,
      );
      final accepted = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: palette.card,
          content: Text(
            context.l10n.progressionAsk(name, _number(next), floor),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(context.l10n.actionReject),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(context.l10n.actionAccept),
            ),
          ],
        ),
      );
      if (accepted == true) {
        alphaPrefs.nextWeight['${block.exercise.id}'] = next;
        alphaPrefs.nextReps['${block.exercise.id}'] = floor;
        await alphaPrefs.save();
      }
    }
  }

  Future<void> _openSort(int highlightedId) async {
    final order = await showWorkoutSortSheet(
      context,
      highlightedId: highlightedId,
      exercises: [
        for (final block in _blocks)
          SortableExercise(
            id: block.exercise.id,
            name: localizedExerciseName(
              context,
              block.exercise.name,
              german: block.exercise.germanName,
              english: block.exercise.englishName,
            ),
          ),
      ],
    );
    if (order == null || !mounted) return;
    final byId = {for (final block in _blocks) block.exercise.id: block};
    if (order.length != _blocks.length ||
        order.any((id) => !byId.containsKey(id))) {
      return;
    }
    setState(() {
      _blocks
        ..clear()
        ..addAll([for (final id in order) byId[id]!]);
    });
    await _persistOrder();
    _publishLive();
  }

  Future<void> _addSet(_ExerciseBlock block) async {
    setState(() {
      block.sets.add(
        _SetRow(
          kg: TextEditingController(),
          reps: TextEditingController(),
          previous: '—',
        ),
      );
    });
  }

  Future<void> _removeBlock(int index) async {
    await _commitPendingExercise();
    if (!mounted || index < 0 || index >= _blocks.length) return;
    final block = _blocks[index];
    setState(() => _blocks.removeAt(index));
    await _persistOrder();
    if (mounted) _publishLive();
    _offerExerciseUndo(block, index, swapped: false);
  }

  Future<void> _swap(int index) async {
    final picked = await _pickExercise(title: context.l10n.swapExercise);
    if (picked == null || _workout == null || !mounted) return;
    await _commitPendingExercise();
    if (!mounted || index < 0 || index >= _blocks.length) return;
    final current = _blocks[index];
    final settings = context.read<Setting>();
    final replacement = await _blockFor(
      picked,
      _workout!.id,
      settings.maxSets,
      _restFor(picked, settings),
      const [],
    );
    if (!mounted) return;
    setState(() => _blocks[index] = replacement);
    await _persistOrder();
    if (mounted) _publishLive();
    _offerExerciseUndo(current, index, swapped: true, replacement: replacement);
  }

  void _offerExerciseUndo(
    _ExerciseBlock block,
    int index, {
    required bool swapped,
    _ExerciseBlock? replacement,
  }) {
    _undoingExercise = false;
    _pendingExercise = _PendingExercise(
      block: block,
      index: index,
      replacement: replacement,
      swapped: swapped,
    );
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger
        .showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 4),
            persist: false,
            content: Text(
              swapped
                  ? context.l10n.exerciseSwappedUndo
                  : context.l10n.exerciseRemovedUndo,
            ),
            action: SnackBarAction(
              label: context.l10n.actionUndo,
              onPressed: () {
                _undoingExercise = true;
                _undoExercise();
              },
            ),
          ),
        )
        .closed
        .then((reason) {
          if (!mounted || _undoingExercise) return;
          if (reason == SnackBarClosedReason.action) return;
          unawaited(_commitPendingExercise());
        });
  }

  void _undoExercise() {
    final pending = _pendingExercise;
    if (pending == null) return;
    setState(() {
      if (pending.swapped) {
        final currentIndex = _blocks.indexOf(pending.replacement!);
        final index = currentIndex < 0
            ? pending.index.clamp(0, _blocks.length)
            : currentIndex;
        if (currentIndex >= 0) _blocks.removeAt(currentIndex);
        _blocks.insert(index, pending.block);
        pending.replacement!.dispose();
      } else {
        final index = pending.index.clamp(0, _blocks.length);
        _blocks.insert(index, pending.block);
      }
    });
    _pendingExercise = null;
    unawaited(_persistOrder());
    _publishLive();
  }

  Future<void> _commitPendingExercise() async {
    final pending = _pendingExercise;
    if (pending == null) return;
    _pendingExercise = null;
    final ids = [
      for (final set in pending.block.sets) ...[
        if (set.setId != null) set.setId!,
        if (set.rightSetId != null) set.rightSetId!,
      ],
    ];
    await deleteExerciseSets(db, ids);
    pending.block.dispose();
    if (mounted) _publishLive();
  }

  Future<Exercise?> _pickExercise({String? title}) {
    return showExercisePicker(context, title: title);
  }

  Future<void> _addExercise() async {
    final picked = await _pickExercise();
    if (!mounted || picked == null || _workout == null) return;
    final settings = context.read<Setting>();
    final block = await _blockFor(
      picked,
      _workout!.id,
      settings.maxSets,
      _restFor(picked, settings),
      const [],
    );
    setState(() => _blocks.add(block));
    await _persistOrder();
    if (mounted) _publishLive();
  }

  Future<void> _editRest(_ExerciseBlock block) async {
    final choices = restChoices();
    var selected = nearestRest(block.restSeconds);
    var saveInTemplate = true;
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setLocal) => AlertDialog(
          title: Text(context.l10n.restWheelTitle),
          content: SizedBox(
            width: 280,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 180,
                  child: ListWheelScrollView.useDelegate(
                    itemExtent: 36,
                    physics: const FixedExtentScrollPhysics(),
                    controller: FixedExtentScrollController(
                      initialItem: choices.indexOf(selected),
                    ),
                    onSelectedItemChanged: (index) => selected = choices[index],
                    childDelegate: ListWheelChildBuilderDelegate(
                      childCount: choices.length,
                      builder: (context, index) {
                        final seconds = choices[index];
                        return Center(child: Text('${seconds}s'));
                      },
                    ),
                  ),
                ),
                CheckboxListTile(
                  key: const Key('save-rest-template'),
                  contentPadding: EdgeInsets.zero,
                  value: saveInTemplate,
                  title: Text(context.l10n.saveRestInTemplate),
                  onChanged: (value) =>
                      setLocal(() => saveInTemplate = value ?? true),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(context.l10n.actionCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(context.l10n.actionSave),
            ),
          ],
        ),
      ),
    );
    if (saved != true || !mounted || _workout == null) return;
    setState(() => block.restSeconds = selected);
    final planId = widget.plan.id;
    final linked =
        await (db.select(db.planExercises)..where(
              (row) =>
                  row.planId.equals(planId) &
                  row.exerciseId.equals(block.exercise.id),
            ))
            .getSingleOrNull();
    if (saveInTemplate && linked != null) {
      await (db.update(db.planExercises)
            ..where((row) => row.id.equals(linked.id)))
          .write(PlanExercisesCompanion(restMs: Value(selected * 1000)));
      _planRest[block.exercise.id] = selected * 1000;
    }
  }

  Future<void> _feedback(_ExerciseBlock block) async {
    final name = localizedExerciseName(
      context,
      block.exercise.name,
      german: block.exercise.germanName,
      english: block.exercise.englishName,
    );
    await Navigator.of(context).push(
      FlexPageRoute(
        builder: (context) => FeedbackPage(
          exerciseName: name,
          exerciseId: block.exercise.catalogId ?? block.exercise.name,
        ),
      ),
    );
  }

  Future<void> _editNote(_ExerciseBlock block) async {
    final controller = TextEditingController(text: block.note);
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.addNote),
        content: TextField(
          controller: controller,
          minLines: 2,
          maxLines: 4,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.l10n.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.l10n.actionSave),
          ),
        ],
      ),
    );
    final note = controller.text.trim();
    controller.dispose();
    if (saved != true) return;
    setState(() => block.note = note);
    final ids = block.sets.map((set) => set.setId).whereType<int>().toList();
    if (ids.isEmpty) return;
    await (db.update(db.exerciseSets)..where((row) => row.id.isIn(ids))).write(
      ExerciseSetsCompanion(notes: Value(note)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = AlphaTheme.of(context);
    final l10n = context.l10n;
    final title = planTitleOf(
      context,
      title: widget.plan.title,
      sequence: widget.plan.sequence,
      id: widget.plan.id,
    );
    return PopScope(
      canPop: true,
      child: Scaffold(
        backgroundColor: palette.background,
        appBar: AppBar(
          leading: BackButton(
            key: const Key('leave-workout'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(title),
          actions: [
            IconButton(
              tooltip: l10n.plateCalculator,
              onPressed: () {
                Navigator.of(context).push(
                  FlexPageRoute(
                    builder: (context) => const PlateCalculatorPage(),
                  ),
                );
              },
              icon: const Icon(Icons.calculate_outlined),
            ),
            IconButton(
              tooltip: l10n.voiceInput,
              onPressed: _voice,
              icon: const Icon(Icons.mic_none),
            ),
          ],
        ),
        body: !_ready
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  _summary(palette, l10n),
                  _restBar(palette, l10n),
                  Expanded(
                    child: Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                            itemCount: _blocks.length,
                            itemBuilder: (context, index) =>
                                _exerciseCard(index, palette, l10n),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                            child: OutlinedButton.icon(
                              key: const Key('add-exercise'),
                              onPressed: _addExercise,
                              icon: const Icon(Icons.add),
                              label: Text(l10n.addExerciseWorkout),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                      child: SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          key: const Key('finish-workout'),
                          onPressed: _ready ? _finish : null,
                          child: Text(l10n.workoutFinish),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _summary(AlphaPalette palette, AppLocalizations l10n) {
    Widget stat(String label, String value) {
      return Expanded(
        child: Column(
          children: [
            Text(label, style: TextStyle(color: palette.muted, fontSize: 11)),
            Text(
              value,
              style: const TextStyle(fontFamily: 'Bebas Neue', fontSize: 28),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
      child: Row(
        children: [
          stat(l10n.durationLabel, _elapsed),
          stat(l10n.volumeLabel, _volume.toStringAsFixed(0)),
          stat(l10n.setsLabel, '$_doneSets'),
        ],
      ),
    );
  }

  Widget _restBar(AlphaPalette palette, AppLocalizations l10n) {
    return ListenableBuilder(
      listenable: context.read<TimerState>(),
      builder: (context, _) {
        final timer = context.read<TimerState>().timer;
        final running = timer.isRunning();
        final remaining = running ? timer.getRemaining() : Duration.zero;
        final label =
            '${remaining.inMinutes.remainder(60).toString().padLeft(2, '0')}:${remaining.inSeconds.remainder(60).toString().padLeft(2, '0')}';
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: palette.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: palette.border),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final skipMax = (constraints.maxWidth * 0.42).clamp(72.0, 160.0);
              return Row(
                children: [
                  _restNudge('-15', running ? () => _shiftRest(-15) : null),
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        running ? label : '00:00',
                        maxLines: 1,
                        softWrap: false,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Bebas Neue',
                          fontSize: 28,
                          color: running ? palette.accent : palette.muted,
                        ),
                      ),
                    ),
                  ),
                  _restNudge('+15', running ? () => _shiftRest(15) : null),
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: skipMax),
                    child: TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: running
                          ? () => context.read<TimerState>().stopTimer()
                          : null,
                      child: Text(
                        l10n.restSkip,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _restNudge(String label, VoidCallback? onPressed) {
    return SizedBox(
      width: 48,
      height: 48,
      child: TextButton(
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        onPressed: onPressed,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(label, maxLines: 1, softWrap: false),
          ),
        ),
      ),
    );
  }

  Widget _exerciseCard(int index, AlphaPalette palette, AppLocalizations l10n) {
    final block = _blocks[index];
    final name = localizedExerciseName(
      context,
      block.exercise.name,
      german: block.exercise.germanName,
      english: block.exercise.englishName,
    );
    return Card(
      key: ObjectKey(block),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 4, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    key: Key('sort-exercise-${block.exercise.id}'),
                    onTap: () {
                      Navigator.of(context).push(
                        FlexPageRoute(
                          builder: (context) =>
                              ExerciseDetailPage(exercise: block.exercise),
                        ),
                      );
                    },
                    onLongPress: () => _openSort(block.exercise.id),
                    child: Row(
                      children: [
                        _thumb(block, palette),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            name,
                            style: const TextStyle(
                              fontFamily: 'Bebas Neue',
                              fontSize: 24,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  key: Key('exercise-menu-${block.exercise.id}'),
                  onSelected: (value) {
                    switch (value) {
                      case 'swap':
                        unawaited(_swap(index));
                      case 'up':
                        if (index == 0) return;
                        setState(() {
                          final item = _blocks.removeAt(index);
                          _blocks.insert(index - 1, item);
                        });
                        unawaited(_persistOrder());
                        _publishLive();
                      case 'down':
                        if (index >= _blocks.length - 1) return;
                        setState(() {
                          final item = _blocks.removeAt(index);
                          _blocks.insert(index + 1, item);
                        });
                        unawaited(_persistOrder());
                        _publishLive();
                      case 'remove':
                        unawaited(_removeBlock(index));
                      case 'rest':
                        unawaited(_editRest(block));
                      case 'note':
                        unawaited(_editNote(block));
                      case 'feedback':
                        unawaited(_feedback(block));
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'swap',
                      child: Text(l10n.swapExercise),
                    ),
                    PopupMenuItem(
                      value: 'up',
                      child: Text(l10n.moveExerciseUp),
                    ),
                    PopupMenuItem(
                      value: 'down',
                      child: Text(l10n.moveExerciseDown),
                    ),
                    PopupMenuItem(
                      value: 'rest',
                      child: Text(l10n.restSecondsLabel),
                    ),
                    PopupMenuItem(value: 'note', child: Text(l10n.addNote)),
                    PopupMenuItem(
                      value: 'feedback',
                      child: Text(l10n.feedbackSettings),
                    ),
                    PopupMenuItem(
                      value: 'remove',
                      child: Text(l10n.removeExercise),
                    ),
                  ],
                ),
              ],
            ),
            TextButton(
              onPressed: () => _editRest(block),
              child: Text('${block.restSeconds}s'),
            ),
            TextButton(
              onPressed: () => _addWarmup(block),
              child: Text(l10n.warmupAction),
            ),
            TextButton(
              onPressed: () => _editNote(block),
              child: Text(block.note.isEmpty ? l10n.addNote : block.note),
            ),
            _tableHeader(palette, l10n, block.exercise.id),
            for (var setIndex = 0; setIndex < block.sets.length; setIndex++)
              _setLine(index, setIndex, palette, l10n),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                key: Key('add-set-${block.exercise.id}'),
                onPressed: () => _addSet(block),
                icon: const Icon(Icons.add),
                label: Text(l10n.addSet),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _thumb(_ExerciseBlock block, AlphaPalette palette) {
    final image = block.exercise.image;
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: palette.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: palette.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: ExerciseImage(path: image, height: 48),
    );
  }

  Widget _tableHeader(AlphaPalette palette, AppLocalizations l10n, int id) {
    final style = TextStyle(color: palette.muted, fontSize: 11);
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: SetTableRow(
        set: setTableLabel(
          l10n.columnSet,
          key: Key('set-header-set-$id'),
          style: style,
        ),
        previous: setTableLabel(
          l10n.columnPrevious,
          key: Key('set-header-previous-$id'),
          style: style,
        ),
        kg: setTableLabel(
          l10n.columnKg,
          key: Key('set-header-kg-$id'),
          style: style,
        ),
        reps: setTableLabel(
          l10n.columnReps,
          key: Key('set-header-reps-$id'),
          style: style,
        ),
        check: SizedBox(
          key: Key('set-header-check-$id'),
          width: setTableActionWidth,
        ),
        menu: const SizedBox(width: setTableActionWidth),
      ),
    );
  }

  Widget _setLine(
    int blockIndex,
    int setIndex,
    AlphaPalette palette,
    AppLocalizations l10n,
  ) {
    final block = _blocks[blockIndex];
    final row = block.sets[setIndex];
    final id = block.exercise.id;
    return Dismissible(
      key: ObjectKey(row),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => _removeSet(blockIndex, setIndex, alreadyGone: true),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: palette.accent,
        child: Icon(Icons.delete_outline, color: palette.onAccent),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 2),
        decoration: BoxDecoration(
          color: row.done ? palette.accent.withValues(alpha: 0.18) : null,
          borderRadius: BorderRadius.circular(8),
        ),
        child: SetTableRow(
          set: setTableLabel(
            row.warmup
                ? '${l10n.warmupMark}${setIndex + 1}'
                : '${setIndex + 1}',
          ),
          previous: setTableLabel(
            row.previous,
            key: Key('set-previous-$id-$setIndex'),
            style: TextStyle(color: palette.muted, fontSize: 12),
          ),
          kg: _field(row.kg, row.done, Key('set-kg-$id-$setIndex')),
          reps: _field(row.reps, row.done, Key('set-reps-$id-$setIndex')),
          check: IconButton(
            key: Key('set-check-$id-$setIndex'),
            padding: EdgeInsets.zero,
            constraints: setTableActionConstraints,
            onPressed: () => _toggle(blockIndex, setIndex),
            icon: Icon(
              row.done ? Icons.check_circle : Icons.circle_outlined,
              color: row.done ? palette.accent : palette.muted,
            ),
          ),
          menu: PopupMenuButton<String>(
            key: Key('set-menu-$id-$setIndex'),
            padding: EdgeInsets.zero,
            style: IconButton.styleFrom(
              fixedSize: const Size(setTableActionWidth, setTableActionWidth),
              padding: EdgeInsets.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            onSelected: (value) {
              if (value == 'delete') _removeSet(blockIndex, setIndex);
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'delete', child: Text(l10n.deleteSet)),
            ],
          ),
        ),
      ),
    );
  }

  void _removeSet(int blockIndex, int setIndex, {bool alreadyGone = false}) {
    unawaited(_removeSetNow(blockIndex, setIndex, alreadyGone: alreadyGone));
  }

  Future<void> _removeSetNow(
    int blockIndex,
    int setIndex, {
    required bool alreadyGone,
  }) async {
    if (blockIndex < 0 || blockIndex >= _blocks.length) return;
    final block = _blocks[blockIndex];
    if (setIndex < 0 || setIndex >= block.sets.length) return;
    final row = block.sets[setIndex];
    final ids = [
      if (row.setId != null) row.setId!,
      if (row.rightSetId != null) row.rightSetId!,
    ];
    if (!alreadyGone) {
      setState(() => block.sets.removeAt(setIndex));
      WidgetsBinding.instance.addPostFrameCallback((_) => row.dispose());
    } else {
      block.sets.removeAt(setIndex);
      row.dispose();
    }
    if (ids.isNotEmpty) await deleteExerciseSets(db, ids);
  }

  void _addWarmup(_ExerciseBlock block) {
    final working = block.sets.where((set) => !set.warmup).toList();
    final sample = working.isEmpty ? null : working.first;
    final kg =
        double.tryParse((sample?.kg.text ?? '').replaceAll(',', '.')) ?? 20;
    setState(() {
      block.sets.insert(
        0,
        _SetRow(
          kg: TextEditingController(text: _number(kg / 2)),
          reps: TextEditingController(text: '5'),
          previous: '—',
        )..warmup = true,
      );
      block.sets.insert(
        0,
        _SetRow(
          kg: TextEditingController(text: _number(20)),
          reps: TextEditingController(text: '10'),
          previous: '—',
        )..warmup = true,
      );
    });
  }

  Future<void> _voice() async {
    final ready = await _aiReady();
    if (!mounted) return;
    if (!ready) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.aiOffNotice)));
      return;
    }
    final transcript = await androidChannel.invokeMethod<String>(
      'listenSpeech',
    );
    if (!mounted || transcript == null || transcript.trim().isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(context.l10n.speechFailed)));
      }
      return;
    }
    final parsed = await _parseVoice(transcript);
    if (!mounted || parsed == null) return;
    final palette = AlphaTheme.of(context);
    final accepted = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: palette.card,
        title: Text(context.l10n.confirmVoiceSet),
        content: Text(context.l10n.voiceUnderstood(transcript)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.l10n.actionReject),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.l10n.actionAccept),
          ),
        ],
      ),
    );
    if (accepted != true || !mounted) return;
    final block = _blocks.cast<_ExerciseBlock?>().firstWhere(
      (item) => item!.sets.any((set) => !set.done),
      orElse: () => _blocks.isEmpty ? null : _blocks.first,
    );
    if (block == null) return;
    final row = block.sets.cast<_SetRow?>().firstWhere(
      (set) => !set!.done,
      orElse: () => block.sets.isEmpty ? null : block.sets.last,
    );
    if (row == null) return;
    setState(() {
      if (parsed.kg != null) row.kg.text = _number(parsed.kg);
      if (parsed.reps != null) row.reps.text = _number(parsed.reps);
    });
  }

  Future<bool> _aiReady() async {
    try {
      final key = await readAiKey();
      return key.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<({double? kg, double? reps})?> _parseVoice(String transcript) async {
    final parsed = await parseVoiceCommand(transcript);
    if (parsed == null) return null;
    return (kg: parsed.kg, reps: parsed.reps);
  }

  Widget _field(TextEditingController controller, bool locked, Key key) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: TextField(
        key: key,
        controller: controller,
        enabled: !locked,
        textAlign: TextAlign.center,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
        ],
        decoration: const InputDecoration(
          isDense: true,
          contentPadding: EdgeInsets.symmetric(vertical: 8),
        ),
      ),
    );
  }
}
