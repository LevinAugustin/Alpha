import 'dart:async';

import 'package:drift/drift.dart' hide Column;
import 'package:flexify/app_fab.dart';
import 'package:flexify/database/database.dart';
import 'package:flexify/empty_state.dart';
import 'package:flexify/exercises/exercise_picker.dart';
import 'package:flexify/l10n/l10n.dart';
import 'package:flexify/logging.dart';
import 'package:flexify/main.dart';
import 'package:flexify/plan/exercise_tile.dart';
import 'package:flexify/plan/plan_queries.dart';
import 'package:flexify/responsive.dart';
import 'package:flexify/utils.dart';
import 'package:flutter/material.dart';

class EditPlanPage extends StatefulWidget {
  final PlansCompanion plan;

  const EditPlanPage({required this.plan, super.key});

  @override
  createState() => _EditPlanPageState();
}

class _EditPlanPageState extends State<EditPlanPage> {
  List<PlanExerciseDraft> _exercises = [];
  bool _loadingExercises = true;
  bool _hasUnsavedChanges = false;
  bool _allowPop = false;
  String _search = '';

  final _node = FocusNode();
  final _searchCtrl = TextEditingController();
  final _titleCtrl = TextEditingController();

  Future<void> addExercise() async {
    final exercise = await showExercisePicker(
      context,
      title: context.l10n.addExercise,
      initialQuery: _search,
      selectOnTap: true,
    );
    if (exercise == null || !mounted) return;

    final alreadyActive = _includeExercise(exercise);
    if (alreadyActive) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.exerciseAlreadyInPlan)),
      );
      return;
    }
    setState(() {
      _search = '';
      _hasUnsavedChanges = true;
    });
    _searchCtrl.text = '';
  }

  bool _includeExercise(Exercise exercise) {
    final index = _exercises.indexWhere(
      (draft) => draft.planExercise.exerciseId.value == exercise.id,
    );
    if (index >= 0) {
      final current = _exercises[index];
      final enabled =
          current.planExercise.enabled.present &&
          current.planExercise.enabled.value;
      if (enabled) return true;
      final sequence = Value(_endSequence());
      _exercises[index] = current.copyWithPlanExercise(
        current.planExercise.copyWith(
          enabled: const Value(true),
          sequence: sequence,
        ),
      );
    } else {
      _exercises.add(_draftFor(exercise, Value(_endSequence())));
    }
    _exercises.sort(comparePlanExerciseDrafts);
    return false;
  }

  int _endSequence() {
    var highest = -1;
    for (final draft in _exercises) {
      final sequence = draft.planExercise.sequence;
      if (sequence.present && sequence.value > highest) {
        highest = sequence.value;
      }
    }
    final end = _exercises.length;
    return end > highest ? end : highest + 1;
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.plan.id.present
        ? context.l10n.editPlan
        : context.l10n.addPlan;

    final matched = _search.isEmpty
        ? _exercises.where(
            (draft) =>
                draft.planExercise.enabled.value || !widget.plan.id.present,
          )
        : filterPlanExerciseDrafts(_exercises, _search);
    final exercises = matched.take(80).toList();
    final desktop = isDesktopLayout(context);
    final colors = Theme.of(context).colorScheme;

    return PopScope(
      canPop: _allowPop || !_hasUnsavedChanges,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop || _allowPop || !_hasUnsavedChanges) return;
        unawaited(_confirmDiscard(result));
      },
      child: Scaffold(
        floatingActionButtonAnimator: FloatingActionButtonAnimator.noAnimation,
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text(title),
          actions: [
            if (desktop)
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: FilledButton.icon(
                  onPressed: save,
                  icon: const Icon(Icons.save_rounded),
                  label: Text(context.l10n.savePlan),
                ),
              ),
          ],
        ),
        body: ResponsiveContent(
          maxWidth: 1040,
          desktopPadding: const EdgeInsets.fromLTRB(32, 16, 32, 32),
          mobilePadding: const EdgeInsets.symmetric(horizontal: 16),
          child: ListView(
            children: [
              if (desktop)
                Text(
                  context.l10n.planDetails,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
              if (desktop) const SizedBox(height: 12),
              Container(
                padding: desktop ? const EdgeInsets.all(20) : EdgeInsets.zero,
                decoration: desktop
                    ? BoxDecoration(
                        color: colors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(20),
                      )
                    : null,
                child: Column(
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        labelText: context.l10n.titleOptional,
                      ),
                      controller: _titleCtrl,
                      textCapitalization: TextCapitalization.sentences,
                      onChanged: (_) => _markDirty(),
                    ),
                  ],
                ),
              ),
              SizedBox(height: desktop ? 24 : 8),
              if (desktop)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    context.l10n.exercisesLabel,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              SearchBar(
                controller: _searchCtrl,
                focusNode: _node,
                onTap: () => _node.requestFocus(),
                leading: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Icon(Icons.search),
                ),
                textCapitalization: TextCapitalization.sentences,
                hintText: context.l10n.searchExercises,
                onChanged: (value) => setState(() {
                  _search = value;
                }),
              ),
              const SizedBox(height: 10),
              Material(
                color: desktop
                    ? colors.surfaceContainerLow
                    : Colors.transparent,
                borderRadius: desktop ? BorderRadius.circular(14) : null,
                child: ListTile(
                  leading: const Icon(Icons.add_rounded),
                  title: Text(
                    _search.isEmpty
                        ? context.l10n.addExercise
                        : context.l10n.addNamed(_search),
                  ),
                  trailing: desktop
                      ? const Icon(Icons.chevron_right_rounded)
                      : null,
                  onTap: addExercise,
                ),
              ),
              const SizedBox(height: 6),
              if (_loadingExercises)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (exercises.isEmpty)
                SizedBox(
                  height: 260,
                  child: AppEmptyState(
                    icon: Icons.search_off_rounded,
                    title: context.l10n.noExercisesFound,
                    message: _search.isEmpty
                        ? context.l10n.addExerciseToPlan
                        : context.l10n.nothingMatchesExerciseSearch(_search),
                    actionLabel: _search.isEmpty
                        ? context.l10n.addExercise
                        : context.l10n.addNamed(_search),
                    actionIcon: Icons.add_rounded,
                    onAction: addExercise,
                  ),
                )
              else
                for (final pe in exercises)
                  ExerciseTile(
                    planExercise: pe.planExercise,
                    exerciseName: pe.exerciseName,
                    germanName: pe.germanName,
                    onChange: (value) {
                      final id = _exercises.indexWhere(
                        (exercise) =>
                            exercise.planExercise.exerciseId.value ==
                            pe.planExercise.exerciseId.value,
                      );
                      if (id == -1) return;
                      setState(() {
                        _exercises[id] = pe.copyWithPlanExercise(value);
                        _hasUnsavedChanges = true;
                      });
                    },
                  ),
              SizedBox(height: desktop ? 40 : 176),
            ],
          ),
        ),
        floatingActionButton: desktop
            ? null
            : AppFab(
                onPressed: save,
                label: Text(context.l10n.actionSave),
                icon: const Icon(Icons.save),
              ),
      ),
    );
  }

  @override
  void dispose() {
    _node.dispose();
    _searchCtrl.dispose();
    _titleCtrl.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _titleCtrl.text = widget.plan.title.value ?? '';
    _loadExercises();
  }

  Future<void> _loadExercises() async {
    final exercises = await loadPlanExerciseDrafts(widget.plan);
    if (!mounted) return;
    setState(() {
      _exercises = exercises;
      _loadingExercises = false;
    });
  }

  void _markDirty() {
    if (_hasUnsavedChanges) return;
    setState(() => _hasUnsavedChanges = true);
  }

  Future<void> _confirmDiscard(Object? result) async {
    final discard = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog.adaptive(
        title: Text(context.l10n.unsavedChanges),
        content: Text(context.l10n.discardUnsavedChanges),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.l10n.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.l10n.actionDiscard),
          ),
        ],
      ),
    );
    if (discard != true || !mounted) return;
    setState(() => _allowPop = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) Navigator.of(context).pop(result);
    });
  }

  Iterable<PlanExercisesCompanion> _orderedExercises(int planId) sync* {
    var sequence = 0;
    for (final draft in _exercises) {
      if (!draft.planExercise.enabled.value) continue;
      yield draft.planExercise.copyWith(
        planId: Value(planId),
        sequence: Value(sequence++),
      );
    }
    for (final draft in _exercises) {
      if (draft.planExercise.enabled.value) continue;
      yield draft.planExercise.copyWith(
        planId: Value(planId),
        sequence: Value(sequence++),
      );
    }
  }

  Future<void> save() async {
    if (_exercises.where((draft) => draft.planExercise.enabled.value).isEmpty) {
      return toast(context.l10n.selectExercises);
    }

    final days = widget.plan.days.present ? widget.plan.days.value : '';
    var newPlan = PlansCompanion.insert(
      days: days,
      title: Value(_titleCtrl.text),
    );

    if (widget.plan.id.present) {
      final planId = widget.plan.id.value;
      await db.transaction(() async {
        await (db.update(
          db.plans,
        )..where((plan) => plan.id.equals(planId))).write(
          PlansCompanion(days: Value(days), title: Value(_titleCtrl.text)),
        );

        for (final exercise in _orderedExercises(planId)) {
          if (exercise.id.present) {
            await (db.update(db.planExercises)
                  ..where((row) => row.id.equals(exercise.id.value)))
                .write(exercise);
          } else {
            await db.into(db.planExercises).insert(exercise);
          }
        }
      });
    } else {
      final highest =
          await (db.plans.select()
                ..orderBy([(u) => OrderingTerm.desc(u.sequence)])
                ..limit(1))
              .getSingleOrNull();
      final sequence = (highest?.sequence ?? 0) + 1;
      newPlan = newPlan.copyWith(sequence: Value(sequence));

      final id = await db.into(db.plans).insert(newPlan);
      await db.planExercises.insertAll(
        _orderedExercises(
          id,
        ).where((exercise) => exercise.enabled.value).toList(),
      );
    }

    talker.info(
      widget.plan.id.present ? 'Updated workout plan' : 'Created workout plan',
    );

    if (!mounted) return;
    _allowPop = true;
    Navigator.pop(context);
  }
}

PlanExerciseDraft _draftFor(Exercise exercise, Value<int> sequence) {
  return PlanExerciseDraft(
    exerciseName: exercise.name,
    germanName: exercise.germanName ?? '',
    aliases: exercise.aliases ?? '',
    muscle: exercise.muscle ?? '',
    category: exercise.categoryName ?? '',
    equipment: exercise.equipment ?? '',
    primaryMuscles: exercise.primaryMuscles ?? '',
    secondaryMuscles: exercise.secondaryMuscles ?? '',
    familie: exercise.familie ?? '',
    grip: exercise.griff ?? '',
    position: exercise.position ?? '',
    movement: exercise.bewegung ?? '',
    catalogId: exercise.catalogId ?? '',
    catalogSource: exercise.catalogSource ?? '',
    planExercise: PlanExercisesCompanion(
      exerciseId: Value(exercise.id),
      enabled: const Value(true),
      sequence: sequence,
    ),
  );
}

int comparePlanExerciseDrafts(PlanExerciseDraft a, PlanExerciseDraft b) {
  final aEnabled =
      a.planExercise.enabled.present && a.planExercise.enabled.value;
  final bEnabled =
      b.planExercise.enabled.present && b.planExercise.enabled.value;
  if (aEnabled != bEnabled) return aEnabled ? -1 : 1;
  return _sequenceRank(a).compareTo(_sequenceRank(b));
}

int _sequenceRank(PlanExerciseDraft draft) {
  final sequence = draft.planExercise.sequence;
  if (!sequence.present) return 1 << 20;
  return sequence.value;
}
