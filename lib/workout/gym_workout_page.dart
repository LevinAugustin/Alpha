import 'dart:async';
import 'dart:io';

import 'package:drift/drift.dart' hide Column;
import 'package:flexify/alpha/alpha_prefs.dart';
import 'package:flexify/alpha/live_workout.dart';
import 'package:flexify/alpha/plates.dart';
import 'package:flexify/alpha/set_notes.dart';
import 'package:flexify/coach/api_key_store.dart';
import 'package:flexify/coach/coach_client.dart';
import 'package:flexify/database/catalog_seed.dart';
import 'package:flexify/database/database.dart';
import 'package:flexify/database/exercise_set_repository.dart';
import 'package:flexify/exercises/exercise_detail_page.dart';
import 'package:flexify/exercises/exercise_image.dart';
import 'package:flexify/exercise_labels.dart';
import 'package:flexify/l10n/generated/app_localizations.dart';
import 'package:flexify/l10n/l10n.dart';
import 'package:flexify/logging.dart';
import 'package:flexify/main.dart';
import 'package:flexify/platform_page_route.dart';
import 'package:flexify/theme/alpha_theme.dart';
import 'package:flexify/timer/timer_state.dart';
import 'package:flexify/workout/plate_calculator_page.dart';
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
  _SetRow({
    required this.kg,
    required this.reps,
    required this.repsRight,
    required this.previous,
  });

  final TextEditingController kg;
  final TextEditingController reps;
  final TextEditingController repsRight;
  String previous;
  bool done = false;
  bool warmup = false;
  int? setId;
  int? rightSetId;

  void dispose() {
    kg.dispose();
    reps.dispose();
    repsRight.dispose();
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

class _GymWorkoutPageState extends State<GymWorkoutPage> {
  final List<_ExerciseBlock> _blocks = [];
  Workout? _workout;
  Timer? _clock;
  var _ready = false;
  var _busy = false;

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
    if (mounted && alphaPrefs.gyms.length > 1) {
      await _chooseGym();
    }
    final settings = await (db.settings.select()..limit(1)).getSingle();
    final workout = await _activeWorkout();
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
      blocks.add(
        await _blockFor(
          exercise,
          workout.id,
          planExercise?.maxSets ?? settings.maxSets,
          exercise.defaultRestDurationMs ?? settings.timerDuration,
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

  Future<void> _chooseGym() async {
    final picked = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(context.l10n.chooseGym),
        children: [
          for (final gym in alphaPrefs.gyms)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, gym.id),
              child: Text(gym.name),
            ),
        ],
      ),
    );
    if (picked == null) return;
    alphaPrefs.activeGymId = picked;
    await alphaPrefs.save();
  }

  void _publishLive() {
    if (_workout == null) return;
    final title = (widget.plan.title ?? '').trim().isEmpty
        ? widget.plan.days
        : widget.plan.title!.trim();
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

  Future<Workout> _activeWorkout() async {
    final existing =
        await (db.select(db.workouts)..where(
              (row) => row.planId.equals(widget.plan.id) & row.endedAt.isNull(),
            ))
            .getSingleOrNull();
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
          reps: TextEditingController(
            text: _number((saved?.left ?? earlier?.left)?.reps),
          ),
          repsRight: TextEditingController(
            text: _number((saved?.right ?? earlier?.right)?.reps),
          ),
          previous: _pairPrevious(earlier),
        );
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
          repsRight: TextEditingController(),
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

  List<_SidePair> _sidePairs(List<ExerciseSet> sets) {
    final pairs = <_SidePair>[];
    final open = <int, ExerciseSet>{};
    for (final set in sets) {
      final stamp = set.timestamp.millisecondsSinceEpoch ~/ 1000;
      final other = open.remove(stamp);
      if (other == null) {
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
    return '${_number(load)} kg × ${_number(pair.left?.reps)}/${_number(pair.right?.reps)}';
  }

  Future<ExerciseSetView> _saveSide(
    _ExerciseBlock block, {
    required double kg,
    required double reps,
    required String side,
    required DateTime created,
    required bool warmup,
  }) {
    return insertExerciseSet(
      db,
      exerciseId: block.exercise.id,
      workoutId: _workout!.id,
      exerciseSet: ExerciseSetView(
        id: 0,
        bodyWeight: 0,
        cardio: block.exercise.kind == 'cardio',
        created: created,
        distance: 0,
        duration: 0,
        name: block.exercise.name,
        notes: encodeSetNotes(
          gymId: alphaPrefs.activeGymId,
          warmup: warmup,
          userNote: block.note,
        ),
        planId: widget.plan.id,
        reps: reps,
        unit: 'kg',
        weight: kg,
        side: side,
      ),
    );
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
    final gymHistory = history
        .where((set) => sameGym(set.notes, alphaPrefs.activeGymId))
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
        final reps = double.tryParse(set.reps.text.replaceAll(',', '.')) ?? 0;
        final right =
            double.tryParse(set.repsRight.text.replaceAll(',', '.')) ?? 0;
        total += kg * reps;
        if (block.exercise.einseitig) total += kg * right;
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
        if (mounted) context.read<TimerState>().stopTimer();
      } else if (block.exercise.einseitig) {
        final kg = double.tryParse(row.kg.text.replaceAll(',', '.')) ?? 0;
        final left = double.tryParse(row.reps.text.replaceAll(',', '.')) ?? 0;
        final right =
            double.tryParse(row.repsRight.text.replaceAll(',', '.')) ?? 0;
        if (left == 0 && right == 0) return;
        final now = DateTime.now();
        var best = false;
        if (left > 0) {
          final saved = await _saveSide(
            block,
            kg: kg,
            reps: left,
            side: 'links',
            created: now,
            warmup: row.warmup,
          );
          row.setId = saved.id;
          best = await isBestExerciseSet(db, saved) || best;
        }
        if (right > 0) {
          final saved = await _saveSide(
            block,
            kg: kg,
            reps: right,
            side: 'rechts',
            created: now,
            warmup: row.warmup,
          );
          row.rightSetId = saved.id;
          best = await isBestExerciseSet(db, saved) || best;
        }
        row.done = true;
        await _startRest(block);
        if (best && mounted) await _showRecord(kg, left > right ? left : right);
      } else {
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
        await _startRest(block);
        final best =
            !row.warmup && hadHistory && await isBestExerciseSet(db, saved);
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
    await (db.update(db.workouts)..where((row) => row.id.equals(workout.id)))
        .write(WorkoutsCompanion(endedAt: Value(DateTime.now())));
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

  Future<void> _addSet(_ExerciseBlock block) async {
    setState(() {
      block.sets.add(
        _SetRow(
          kg: TextEditingController(),
          reps: TextEditingController(),
          repsRight: TextEditingController(),
          previous: '—',
        ),
      );
    });
  }

  Future<void> _removeBlock(int index) async {
    final block = _blocks[index];
    final ids = [
      for (final set in block.sets) ...[
        if (set.setId != null) set.setId!,
        if (set.rightSetId != null) set.rightSetId!,
      ],
    ];
    await deleteExerciseSets(db, ids);
    block.dispose();
    setState(() => _blocks.removeAt(index));
    await _persistOrder();
    if (mounted) _publishLive();
  }

  Future<void> _swap(int index) async {
    final picked = await _pickExercise(title: context.l10n.swapExercise);
    if (picked == null || _workout == null) return;
    final current = _blocks[index];
    await deleteExerciseSets(
      db,
      current.sets.map((set) => set.setId).whereType<int>(),
    );
    current.dispose();
    if (!mounted || _workout == null) return;
    final settings = context.read<Setting>();
    final replacement = await _blockFor(
      picked,
      _workout!.id,
      settings.maxSets,
      picked.defaultRestDurationMs ?? settings.timerDuration,
      const [],
    );
    setState(() => _blocks[index] = replacement);
    await _persistOrder();
    if (mounted) _publishLive();
  }

  Future<Exercise?> _pickExercise({String? title}) async {
    final exercises =
        await (db.select(db.exercises)
              ..where((row) => row.archived.equals(false))
              ..orderBy([(row) => OrderingTerm.asc(row.name)]))
            .get();
    if (!mounted) return null;
    return showDialog<Exercise>(
      context: context,
      builder: (context) {
        var query = '';
        return StatefulBuilder(
          builder: (context, setLocal) {
            final needle = query.trim();
            final matches =
                exercises
                    .where(
                      (exercise) => exerciseMatchesQuery(
                        name: exercise.name,
                        germanName: exercise.germanName,
                        aliases: exercise.aliases,
                        muscle: exercise.muscle,
                        category: exercise.categoryName,
                        equipment: exercise.equipment,
                        mechanic: exercise.mechanic,
                        primaryMuscles: exercise.primaryMuscles,
                        secondaryMuscles: exercise.secondaryMuscles,
                        movement: exercise.bewegung,
                        query: needle,
                      ),
                    )
                    .toList()
                  ..sort(
                    (a, b) => needle.isEmpty
                        ? foldExerciseSearch(
                            exerciseDisplayName(a.name, a.germanName),
                          ).compareTo(
                            foldExerciseSearch(
                              exerciseDisplayName(b.name, b.germanName),
                            ),
                          )
                        : compareExerciseSearch(
                            query: needle,
                            leftName: a.name,
                            leftGermanName: a.germanName,
                            leftAliases: a.aliases,
                            rightName: b.name,
                            rightGermanName: b.germanName,
                            rightAliases: b.aliases,
                          ),
                  );
            final shown = matches.take(40);
            return AlertDialog(
              title: Text(title ?? context.l10n.addExerciseWorkout),
              content: SizedBox(
                width: 420,
                height: 420,
                child: Column(
                  children: [
                    TextField(
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: context.l10n.exerciseSearchHint,
                      ),
                      onChanged: (value) => setLocal(() => query = value),
                    ),
                    Expanded(
                      child: ListView(
                        children: [
                          for (final exercise in shown)
                            ListTile(
                              title: Text(
                                localizedExerciseName(
                                  context,
                                  exercise.name,
                                  german: exercise.germanName,
                                ),
                              ),
                              onTap: () async {
                                final added = await Navigator.of(context)
                                    .push<Exercise>(
                                      FlexPageRoute(
                                        builder: (context) =>
                                            ExerciseDetailPage(
                                              exercise: exercise,
                                              onAdd: () {},
                                            ),
                                      ),
                                    );
                                if (added != null && context.mounted) {
                                  Navigator.pop(context, added);
                                }
                              },
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _addExercise() async {
    final picked = await _pickExercise();
    if (!mounted || picked == null || _workout == null) return;
    final settings = context.read<Setting>();
    final block = await _blockFor(
      picked,
      _workout!.id,
      settings.maxSets,
      picked.defaultRestDurationMs ?? settings.timerDuration,
      const [],
    );
    setState(() => _blocks.add(block));
    await _persistOrder();
    if (mounted) _publishLive();
  }

  Future<void> _editRest(_ExerciseBlock block) async {
    final choices = restChoices();
    var selected = nearestRest(block.restSeconds);
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.restWheelTitle),
        content: SizedBox(
          height: 180,
          width: 160,
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
                return Center(
                  child: Text(
                    seconds == 0 ? context.l10n.noRest : '${seconds}s',
                  ),
                );
              },
            ),
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
    );
    if (saved != true) return;
    setState(() => block.restSeconds = selected);
    await (db.update(
      db.exercises,
    )..where((row) => row.id.equals(block.exercise.id))).write(
      ExercisesCompanion(
        defaultRestDurationMs: Value(block.restSeconds * 1000),
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
    final title = (widget.plan.title ?? '').trim().isEmpty
        ? widget.plan.days
        : widget.plan.title!.trim();
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
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
                      children: [
                        for (var index = 0; index < _blocks.length; index++)
                          _exerciseCard(index, palette, l10n),
                        OutlinedButton.icon(
                          key: const Key('add-exercise'),
                          onPressed: _addExercise,
                          icon: const Icon(Icons.add),
                          label: Text(l10n.addExerciseWorkout),
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
          child: Row(
            children: [
              IconButton(
                onPressed: running ? () => _shiftRest(-15) : null,
                icon: const Text('-15'),
              ),
              Expanded(
                child: Text(
                  running ? label : '00:00',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Bebas Neue',
                    fontSize: 28,
                    color: running ? palette.accent : palette.muted,
                  ),
                ),
              ),
              IconButton(
                onPressed: running ? () => _shiftRest(15) : null,
                icon: const Text('+15'),
              ),
              TextButton(
                onPressed: running
                    ? () => context.read<TimerState>().stopTimer()
                    : null,
                child: Text(l10n.restSkip),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _exerciseCard(int index, AlphaPalette palette, AppLocalizations l10n) {
    final block = _blocks[index];
    final name = localizedExerciseName(
      context,
      block.exercise.name,
      german: block.exercise.germanName,
    );
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 4, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _thumb(block, palette),
                const SizedBox(width: 10),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        FlexPageRoute(
                          builder: (context) =>
                              ExerciseDetailPage(exercise: block.exercise),
                        ),
                      );
                    },
                    child: Text(
                      name,
                      style: const TextStyle(
                        fontFamily: 'Bebas Neue',
                        fontSize: 24,
                      ),
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
                      value: 'remove',
                      child: Text(l10n.removeExercise),
                    ),
                  ],
                ),
              ],
            ),
            TextButton(
              onPressed: () => _editRest(block),
              child: Text(
                block.restSeconds == 0 ? l10n.noRest : '${block.restSeconds}s',
              ),
            ),
            TextButton(
              onPressed: () => _addWarmup(block),
              child: Text(l10n.warmupAction),
            ),
            TextButton(
              onPressed: () => _editNote(block),
              child: Text(block.note.isEmpty ? l10n.addNote : block.note),
            ),
            _tableHeader(palette, l10n, block.exercise.einseitig),
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

  Widget _tableHeader(
    AlphaPalette palette,
    AppLocalizations l10n,
    bool unilateral,
  ) {
    Widget cell(String text) => Expanded(
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(color: palette.muted, fontSize: 11),
      ),
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          cell(l10n.columnSet),
          cell(l10n.columnPrevious),
          cell(l10n.columnKg),
          if (unilateral) cell(l10n.sideLeft) else cell(l10n.columnReps),
          if (unilateral) cell(l10n.sideRight),
          const SizedBox(width: 40),
        ],
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
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        color: row.done ? palette.accent.withValues(alpha: 0.18) : null,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Center(
              child: Text(
                row.warmup
                    ? '${l10n.warmupMark}${setIndex + 1}'
                    : '${setIndex + 1}',
              ),
            ),
          ),
          Expanded(
            child: Text(
              row.previous,
              textAlign: TextAlign.center,
              style: TextStyle(color: palette.muted, fontSize: 12),
            ),
          ),
          Expanded(
            child: _field(row.kg, row.done, Key('set-kg-$id-$setIndex')),
          ),
          Expanded(
            child: _field(row.reps, row.done, Key('set-reps-$id-$setIndex')),
          ),
          if (block.exercise.einseitig)
            Expanded(
              child: _field(
                row.repsRight,
                row.done,
                Key('set-reps-right-$id-$setIndex'),
              ),
            ),
          IconButton(
            key: Key('set-check-$id-$setIndex'),
            onPressed: () => _toggle(blockIndex, setIndex),
            icon: Icon(
              row.done ? Icons.check_circle : Icons.circle_outlined,
              color: row.done ? palette.accent : palette.muted,
            ),
          ),
        ],
      ),
    );
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
          repsRight: TextEditingController(text: '5'),
          previous: '—',
        )..warmup = true,
      );
      block.sets.insert(
        0,
        _SetRow(
          kg: TextEditingController(text: _number(20)),
          reps: TextEditingController(text: '10'),
          repsRight: TextEditingController(text: '10'),
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
