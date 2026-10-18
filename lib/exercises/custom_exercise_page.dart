import 'dart:convert';

import 'package:flexify/database/database.dart';
import 'package:flexify/exercise_keys.dart';
import 'package:flexify/exercise_labels.dart';
import 'package:flexify/exercises/custom_exercise.dart';
import 'package:flexify/l10n/l10n.dart';
import 'package:flexify/main.dart';
import 'package:flexify/workout/muscle_map.dart';
import 'package:flutter/material.dart';

class CustomExercisePage extends StatefulWidget {
  const CustomExercisePage({
    super.key,
    this.exercise,
    this.initialName = '',
    this.initialEquipment,
  });

  final Exercise? exercise;
  final String initialName;
  final String? initialEquipment;

  @override
  State<CustomExercisePage> createState() => _CustomExercisePageState();
}

class _CustomExercisePageState extends State<CustomExercisePage> {
  late final TextEditingController _name;
  late final TextEditingController _family;
  String _category = exerciseCategories.first;
  String _equipment = exerciseGearValues.first;
  String _movement = '';
  String _grip = '';
  String _position = '';
  var _unilateral = false;
  final _primary = <String>{};
  final _secondary = <String>{};
  var _saving = false;
  String? _formError;

  @override
  void initState() {
    super.initState();
    final exercise = widget.exercise;
    _name = TextEditingController(
      text: exercise?.germanName ?? exercise?.name ?? widget.initialName,
    );
    _family = TextEditingController(text: exercise?.familie ?? '');
    final initialGear = widget.initialEquipment;
    if (initialGear != null && exerciseGearValues.contains(initialGear)) {
      _equipment = initialGear;
    }
    if (exercise != null) {
      final invented = inventedCategoryFallback(exercise);
      final fields = normalizeLegacyCustomExercise(exercise);
      _category = !invented && exerciseCategories.contains(fields.category)
          ? fields.category
          : '';
      _equipment = !invented && exerciseGearValues.contains(fields.equipment)
          ? fields.equipment
          : '';
      _movement = exercise.bewegung ?? '';
      if (!exerciseMotionValues.contains(_movement)) _movement = '';
      _grip = invented ? '' : fields.grip;
      _position = invented ? '' : fields.position;
      _unilateral = exercise.einseitig;
      if (!invented) _primary.addAll(fields.primaryMuscles);
      _secondary.addAll(_list(exercise.secondaryMuscles));
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _family.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final editing = widget.exercise != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          editing ? l10n.editCustomExercise : l10n.createCustomExercise,
        ),
      ),
      body: ListView(
        key: const Key('custom-exercise-form'),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          TextField(
            key: const Key('custom-exercise-name'),
            controller: _name,
            decoration: InputDecoration(labelText: l10n.customExerciseName),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            key: const Key('custom-exercise-category'),
            initialValue: _category,
            decoration: InputDecoration(labelText: l10n.categoryLabel),
            items: [
              DropdownMenuItem(value: '', child: Text(l10n.unassignedExercise)),
              for (final category in exerciseCategories)
                DropdownMenuItem(value: category, child: Text(category)),
            ],
            onChanged: (value) =>
                setState(() => _category = value ?? _category),
          ),
          const SizedBox(height: 12),
          Text(l10n.primaryMuscleLabel),
          if (_formError != null)
            Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 4),
              child: Text(
                _formError!,
                key: const Key('custom-exercise-error'),
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          Wrap(
            spacing: 8,
            children: [
              for (final key in exerciseMuscleKeys)
                FilterChip(
                  label: Text(muscleLabel(l10n, key)),
                  selected: _primary.contains(key),
                  onSelected: (selected) => setState(() {
                    if (selected) {
                      _primary.add(key);
                    } else {
                      _primary.remove(key);
                    }
                  }),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(l10n.secondaryMuscleLabel),
          Wrap(
            spacing: 8,
            children: [
              for (final key in exerciseMuscleKeys)
                FilterChip(
                  label: Text(muscleLabel(l10n, key)),
                  selected: _secondary.contains(key),
                  onSelected: (selected) => setState(() {
                    if (selected) {
                      _secondary.add(key);
                    } else {
                      _secondary.remove(key);
                    }
                  }),
                ),
            ],
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            key: const Key('custom-exercise-gear'),
            initialValue: _equipment,
            decoration: InputDecoration(labelText: l10n.equipmentLabel),
            items: [
              DropdownMenuItem(value: '', child: Text(l10n.unassignedExercise)),
              for (final gear in exerciseGearValues)
                DropdownMenuItem(value: gear, child: Text(gear)),
            ],
            onChanged: (value) =>
                setState(() => _equipment = value ?? _equipment),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            key: const Key('custom-exercise-motion'),
            initialValue: _movement.isEmpty ? null : _movement,
            decoration: InputDecoration(labelText: l10n.movementLabel),
            items: [
              for (final motion in exerciseMotionValues)
                DropdownMenuItem(
                  value: motion,
                  child: Text(movementLabel(l10n, motion)),
                ),
            ],
            onChanged: (value) => setState(() => _movement = value ?? ''),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _family,
            decoration: InputDecoration(labelText: l10n.customExerciseFamily),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _grip,
            decoration: InputDecoration(labelText: l10n.gripLabel),
            items: [
              DropdownMenuItem(value: '', child: Text(l10n.notSpecified)),
              for (final grip in exerciseGripValues)
                DropdownMenuItem(value: grip, child: Text(grip)),
            ],
            onChanged: (value) => setState(() => _grip = value ?? ''),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _position,
            decoration: InputDecoration(labelText: l10n.positionLabel),
            items: [
              DropdownMenuItem(value: '', child: Text(l10n.notSpecified)),
              for (final position in exercisePositionValues)
                DropdownMenuItem(value: position, child: Text(position)),
            ],
            onChanged: (value) => setState(() => _position = value ?? ''),
          ),
          SwitchListTile(
            key: const Key('custom-exercise-unilateral'),
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.unilateralLabel),
            value: _unilateral,
            onChanged: (value) => setState(() => _unilateral = value),
          ),
          const SizedBox(height: 12),
          FilledButton(
            key: const Key('save-custom-exercise'),
            onPressed: _saving ? null : _save,
            child: Text(l10n.actionSave),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    final draft = CustomExerciseDraft(
      name: _name.text,
      category: _category,
      primaryMuscles: _primary.toList(),
      secondaryMuscles: _secondary.toList(),
      equipment: _equipment,
      movement: _movement,
      family: _family.text,
      grip: _grip,
      position: _position,
      unilateral: _unilateral,
    );
    final error = validateCustomExercise(draft);
    if (error != null) {
      final message = switch (error) {
        'movement' => context.l10n.customExerciseMovementRequired,
        'muscles' => context.l10n.customExerciseMuscleRequired,
        _ => context.l10n.customExerciseInvalid,
      };
      setState(() => _formError = error == 'muscles' ? message : null);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
      return;
    }
    setState(() => _saving = true);
    final saved = await saveCustomExercise(
      db,
      draft,
      existing: widget.exercise,
    );
    if (!mounted) return;
    Navigator.pop(context, saved);
  }
}

List<String> _list(String? raw) {
  if (raw == null || raw.trim().isEmpty) return const [];
  final decoded = jsonDecode(raw);
  if (decoded is! List) return const [];
  return [
    for (final item in decoded)
      if (item is String) item,
  ];
}
