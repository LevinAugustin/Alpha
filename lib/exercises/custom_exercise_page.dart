import 'dart:convert';

import 'package:flexify/database/database.dart';
import 'package:flexify/exercise_keys.dart';
import 'package:flexify/exercises/custom_exercise.dart';
import 'package:flexify/l10n/l10n.dart';
import 'package:flexify/main.dart';
import 'package:flexify/workout/muscle_map.dart';
import 'package:flutter/material.dart';

class CustomExercisePage extends StatefulWidget {
  const CustomExercisePage({super.key, this.exercise, this.initialName = ''});

  final Exercise? exercise;
  final String initialName;

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

  @override
  void initState() {
    super.initState();
    final exercise = widget.exercise;
    _name = TextEditingController(
      text: exercise?.germanName ?? exercise?.name ?? widget.initialName,
    );
    _family = TextEditingController(text: exercise?.familie ?? '');
    if (exercise != null) {
      _category = exercise.categoryName ?? _category;
      _equipment = exercise.equipment ?? _equipment;
      _movement = exercise.bewegung ?? '';
      _grip = exercise.griff ?? '';
      _position = exercise.position ?? '';
      _unilateral = exercise.einseitig;
      _primary.addAll(_list(exercise.primaryMuscles));
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
              for (final category in exerciseCategories)
                DropdownMenuItem(value: category, child: Text(category)),
            ],
            onChanged: (value) =>
                setState(() => _category = value ?? _category),
          ),
          const SizedBox(height: 12),
          Text(l10n.primaryMuscleLabel),
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
                DropdownMenuItem(value: motion, child: Text(motion)),
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
              DropdownMenuItem(value: '', child: Text(l10n.allMuscles)),
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
              DropdownMenuItem(value: '', child: Text(l10n.allMuscles)),
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
    if (validateCustomExercise(draft) != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.customExerciseInvalid)),
      );
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
