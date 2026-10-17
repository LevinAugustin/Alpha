import 'package:drift/drift.dart' hide Column;
import 'package:flexify/database/database.dart';
import 'package:flexify/database/catalog_seed.dart';
import 'package:flexify/exercise_keys.dart';
import 'package:flexify/exercise_labels.dart';
import 'package:flexify/exercises/exercise_detail_page.dart';
import 'package:flexify/l10n/l10n.dart';
import 'package:flexify/main.dart';
import 'package:flexify/platform_page_route.dart';
import 'package:flexify/workout/muscle_map.dart';
import 'package:flutter/material.dart';

class ExercisesPage extends StatefulWidget {
  const ExercisesPage({super.key});

  @override
  State<ExercisesPage> createState() => _ExercisesPageState();
}

class _ExercisesPageState extends State<ExercisesPage> {
  final _search = TextEditingController();
  String _muscle = '';
  String _equipment = '';
  String _split = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: TextField(
            controller: _search,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: context.l10n.searchExercises,
              border: const OutlineInputBorder(),
            ),
            onChanged: (_) => setState(() {}),
          ),
        ),
        SizedBox(
          height: 44,
          child: StreamBuilder<List<Exercise>>(
            stream:
                (db.select(db.exercises)
                      ..where((row) => row.archived.equals(false))
                      ..orderBy([(row) => OrderingTerm.asc(row.name)]))
                    .watch(),
            builder: (context, snapshot) {
              final exercises = snapshot.data ?? const <Exercise>[];
              final muscles = _chipValues([
                for (final exercise in exercises) ...[
                  ...decodeCatalogList(exercise.primaryMuscles),
                  ...decodeCatalogList(exercise.secondaryMuscles),
                ],
              ], exerciseMuscleKeys);
              final equipment = _chipValues(
                exercises.map((exercise) => exercise.equipment),
                exerciseGearKeys,
              );
              final splits = _chipValues(
                exercises.map((exercise) => exercise.split),
                const ['push', 'pull', 'beine', 'core', 'cardio'],
              );
              return ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(context.l10n.allMuscles),
                      selected: _muscle.isEmpty,
                      onSelected: (_) => setState(() => _muscle = ''),
                    ),
                  ),
                  for (final muscle in muscles)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(muscleLabel(context.l10n, muscle)),
                        selected: _muscle == muscle,
                        onSelected: (_) => setState(() {
                          _muscle = _muscle == muscle ? '' : muscle;
                        }),
                      ),
                    ),
                  for (final item in equipment)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(gearLabel(context.l10n, item)),
                        selected: _equipment == item,
                        onSelected: (_) => setState(() {
                          _equipment = _equipment == item ? '' : item;
                        }),
                      ),
                    ),
                  for (final item in splits)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(item),
                        selected: _split == item,
                        onSelected: (_) => setState(() {
                          _split = _split == item ? '' : item;
                        }),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
        Expanded(
          child: StreamBuilder<List<Exercise>>(
            stream:
                (db.select(db.exercises)
                      ..where((row) => row.archived.equals(false))
                      ..orderBy([(row) => OrderingTerm.asc(row.name)]))
                    .watch(),
            builder: (context, snapshot) {
              final query = _search.text;
              final exercises =
                  (snapshot.data ?? const <Exercise>[]).where((exercise) {
                    return matchesExerciseFilters(
                      name: exercise.name,
                      germanName: exercise.germanName,
                      aliases: exercise.aliases,
                      muscle: exercise.muscle,
                      category: exercise.categoryName,
                      equipment: exercise.equipment,
                      split: exercise.split,
                      primaryMuscles: exercise.primaryMuscles,
                      secondaryMuscles: exercise.secondaryMuscles,
                      query: query,
                      group: _muscle,
                      equipmentFilter: _equipment,
                      splitFilter: _split,
                    );
                  }).toList()..sort((a, b) {
                    final left = (a.germanName ?? a.name).toLowerCase();
                    final right = (b.germanName ?? b.name).toLowerCase();
                    return left.compareTo(right);
                  });
              return ListView.builder(
                itemCount: exercises.length,
                itemBuilder: (context, index) {
                  final exercise = exercises[index];
                  final title = localizedExerciseName(
                    context,
                    exercise.name,
                    german: exercise.germanName,
                  );
                  final subtitle = title == exercise.name
                      ? exercise.muscle
                      : '${exercise.name}${exercise.muscle == null ? '' : ' · ${exercise.muscle}'}';
                  return ListTile(
                    title: Text(title),
                    subtitle: subtitle == null ? null : Text(subtitle),
                    onTap: () {
                      Navigator.of(context).push(
                        FlexPageRoute(
                          builder: (context) =>
                              ExerciseDetailPage(exercise: exercise),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

List<String> _chipValues(
  Iterable<String?> values, [
  List<String> order = const [],
]) {
  final present = values
      .map((value) => value?.trim() ?? '')
      .where((value) => value.isNotEmpty)
      .toSet();
  final ordered = [
    for (final item in order)
      if (present.remove(item)) item,
  ];
  final rest = present.toList()..sort();
  return [...ordered, ...rest];
}
