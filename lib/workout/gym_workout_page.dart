import 'dart:async';
import 'dart:io';

import 'package:drift/drift.dart' hide Column;
import 'package:flexify/database/database.dart';
import 'package:flexify/database/exercise_set_repository.dart';
import 'package:flexify/exercise_labels.dart';
import 'package:flexify/l10n/generated/app_localizations.dart';
import 'package:flexify/l10n/l10n.dart';
import 'package:flexify/logging.dart';
import 'package:flexify/main.dart';
import 'package:flexify/theme/alpha_theme.dart';
import 'package:flexify/timer/timer_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class GymWorkoutPage extends StatefulWidget {
  const GymWorkoutPage({super.key, required this.plan});

  final Plan plan;

  @override
  State<GymWorkoutPage> createState() => _GymWorkoutPageState();
}

class _SetRow {
  _SetRow({required this.kg, required this.reps, required this.previous});

  final TextEditingController kg;
  final TextEditingController reps;
  String previous;
  bool done = false;
  int? setId;

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
    _clock = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _clock?.cancel();
    for (final block in _blocks) {
      block.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
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
    List<ExerciseSet> current,
  ) async {
    current.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    final previous = await _previousSets(exercise.id, workoutId);
    final count = [
      targetSets,
      previous.length,
      current.length,
      1,
    ].reduce((a, b) => a > b ? a : b);
    final rows = <_SetRow>[];
    for (var index = 0; index < count; index++) {
      final earlier = index < previous.length ? previous[index] : null;
      final logged = index < current.length ? current[index] : null;
      final source = logged ?? earlier;
      final row = _SetRow(
        kg: TextEditingController(text: _number(source?.loadKg)),
        reps: TextEditingController(text: _number(source?.reps)),
        previous: _previousLabel(earlier),
      );
      if (logged != null) {
        row.done = true;
        row.setId = logged.id;
      }
      rows.add(row);
    }
    return _ExerciseBlock(
      exercise: exercise,
      restSeconds: (restMs / 1000).round().clamp(15, 600),
      sets: rows,
    );
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
    if (history.isEmpty) return const [];
    final workoutIdOfLast = history.first.workoutId;
    final sets = history
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
      for (final set in block.sets.where((row) => row.done)) {
        final kg = double.tryParse(set.kg.text.replaceAll(',', '.')) ?? 0;
        final reps = double.tryParse(set.reps.text.replaceAll(',', '.')) ?? 0;
        total += kg * reps;
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
      if (row.done && row.setId != null) {
        await deleteExerciseSets(db, [row.setId!]);
        row.done = false;
        row.setId = null;
        if (mounted) context.read<TimerState>().stopTimer();
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
            notes: block.note,
            planId: widget.plan.id,
            reps: reps,
            unit: 'kg',
            weight: kg,
          ),
        );
        row.done = true;
        row.setId = saved.id;
        await _startRest(block);
        final best = hadHistory && await isBestExerciseSet(db, saved);
        if (best && mounted) await _showRecord(kg, reps);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _startRest(_ExerciseBlock block) async {
    if (!mounted) return;
    final settings = context.read<Setting>();
    final timer = context.read<TimerState>();
    try {
      await timer.startTimer(
        localizedExerciseName(
          context,
          block.exercise.name,
          german: block.exercise.germanName,
        ),
        Duration(seconds: block.restSeconds),
        '',
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
      '',
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
    await (db.update(db.workouts)..where((row) => row.id.equals(workout.id)))
        .write(WorkoutsCompanion(endedAt: Value(DateTime.now())));
    if (!mounted) return;
    Navigator.of(context).pop();
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
    final block = _blocks[index];
    final ids = block.sets.map((set) => set.setId).whereType<int>();
    await deleteExerciseSets(db, ids);
    block.dispose();
    setState(() => _blocks.removeAt(index));
    await _persistOrder();
  }

  Future<void> _swap(int index) async {
    final picked = await _pickExercise();
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
  }

  Future<Exercise?> _pickExercise() async {
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
            final matches = exercises
                .where((exercise) {
                  final haystack =
                      '${exercise.name} ${exercise.germanName ?? ''} ${exercise.aliases ?? ''}'
                          .toLowerCase();
                  return haystack.contains(query.trim().toLowerCase());
                })
                .take(40);
            return AlertDialog(
              title: Text(context.l10n.addExerciseWorkout),
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
                          for (final exercise in matches)
                            ListTile(
                              title: Text(
                                localizedExerciseName(
                                  context,
                                  exercise.name,
                                  german: exercise.germanName,
                                ),
                              ),
                              onTap: () => Navigator.pop(context, exercise),
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
  }

  Future<void> _editRest(_ExerciseBlock block) async {
    final controller = TextEditingController(text: '${block.restSeconds}');
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.restSecondsLabel),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
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
    final seconds = int.tryParse(controller.text.trim());
    controller.dispose();
    if (saved != true || seconds == null) return;
    setState(() => block.restSeconds = seconds.clamp(5, 900));
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
    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        title: Text(title),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton(
              key: const Key('finish-workout'),
              onPressed: _ready ? _finish : null,
              child: Text(l10n.workoutFinish),
            ),
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
              ],
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
                  child: Text(
                    name,
                    style: const TextStyle(
                      fontFamily: 'Bebas Neue',
                      fontSize: 24,
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
                      case 'down':
                        if (index >= _blocks.length - 1) return;
                        setState(() {
                          final item = _blocks.removeAt(index);
                          _blocks.insert(index + 1, item);
                        });
                        unawaited(_persistOrder());
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
              child: Text('${block.restSeconds}s'),
            ),
            TextButton(
              onPressed: () => _editNote(block),
              child: Text(block.note.isEmpty ? l10n.addNote : block.note),
            ),
            _tableHeader(palette, l10n),
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
      child: image == null || image.isEmpty
          ? Icon(Icons.fitness_center, color: palette.muted)
          : Image.file(
              File(image),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stack) {
                return Icon(Icons.fitness_center, color: palette.muted);
              },
            ),
    );
  }

  Widget _tableHeader(AlphaPalette palette, AppLocalizations l10n) {
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
          cell(l10n.columnReps),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(child: Center(child: Text('${setIndex + 1}'))),
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
