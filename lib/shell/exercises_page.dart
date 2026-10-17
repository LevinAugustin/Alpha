import 'package:drift/drift.dart' hide Column;
import 'package:flexify/database/database.dart';
import 'package:flexify/database/gym_catalog.dart';
import 'package:flexify/exercise_labels.dart';
import 'package:flexify/exercises/exercise_detail_page.dart';
import 'package:flexify/l10n/l10n.dart';
import 'package:flexify/main.dart';
import 'package:flexify/platform_page_route.dart';
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
              final muscles =
                  exercises
                      .map((exercise) => exercise.muscle ?? '')
                      .where((muscle) => muscle.isNotEmpty)
                      .toSet()
                      .toList()
                    ..sort();
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
                  for (final muscle in muscleGroups)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(muscle),
                        selected: _muscle == muscle,
                        onSelected: (_) => setState(() {
                          _muscle = _muscle == muscle ? '' : muscle;
                        }),
                      ),
                    ),
                  for (final equipment in equipmentFilters)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(equipment),
                        selected: _equipment == equipment,
                        onSelected: (_) => setState(() {
                          _equipment = _equipment == equipment ? '' : equipment;
                        }),
                      ),
                    ),
                  for (final split in const [
                    (id: 'push', label: 'Push'),
                    (id: 'pull', label: 'Pull'),
                    (id: 'beine', label: 'Beine'),
                  ])
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(split.label),
                        selected: _split == split.id,
                        onSelected: (_) => setState(() {
                          _split = _split == split.id ? '' : split.id;
                        }),
                      ),
                    ),
                  for (final muscle in muscles)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(muscle),
                        selected: _muscle == muscle,
                        onSelected: (_) => setState(() {
                          _muscle = _muscle == muscle ? '' : muscle;
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
                      query: query,
                      group: _muscle,
                      equipment: _equipment,
                      split: _split,
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
