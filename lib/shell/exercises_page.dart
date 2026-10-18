import 'package:drift/drift.dart' hide Column;
import 'package:flexify/database/database.dart';
import 'package:flexify/database/catalog_seed.dart';
import 'package:flexify/exercise_keys.dart';
import 'package:flexify/exercise_labels.dart';
import 'package:flexify/exercises/custom_exercise_page.dart';
import 'package:flexify/exercises/exercise_image.dart';
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
  String _mechanic = '';
  String _grip = '';
  String _position = '';
  String _motion = '';

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
              final mechanics = _chipValues(
                exercises.map((exercise) => catalogText(exercise.mechanic)),
                const ['grund', 'isolation'],
              );
              return ListView(
                key: const Key('exercise-filters'),
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
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Center(child: Text(context.l10n.movementLabel)),
                  ),
                  for (final item in exerciseMotionValues)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(movementLabel(context.l10n, item)),
                        selected: _motion == item,
                        onSelected: (_) => setState(() {
                          _motion = _motion == item ? '' : item;
                        }),
                      ),
                    ),
                  for (final muscle in exerciseMuscleKeys)
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
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Center(child: Text(context.l10n.equipmentLabel)),
                  ),
                  for (final item in exerciseGearValues)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(item),
                        selected: _equipment == item,
                        onSelected: (_) => setState(() {
                          _equipment = _equipment == item ? '' : item;
                        }),
                      ),
                    ),
                  for (final item in exerciseGripValues)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(item),
                        selected: _grip == item,
                        onSelected: (_) => setState(() {
                          _grip = _grip == item ? '' : item;
                        }),
                      ),
                    ),
                  for (final item in exercisePositionValues)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(item),
                        selected: _position == item,
                        onSelected: (_) => setState(() {
                          _position = _position == item ? '' : item;
                        }),
                      ),
                    ),
                  for (final item in mechanics)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(mechanicLabel(context.l10n, item)),
                        selected: _mechanic == item,
                        onSelected: (_) => setState(() {
                          _mechanic = _mechanic == item ? '' : item;
                        }),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            key: const Key('create-custom-exercise'),
            onPressed: () {
              Navigator.of(context).push(
                FlexPageRoute(builder: (context) => const CustomExercisePage()),
              );
            },
            icon: const Icon(Icons.add),
            label: Text(context.l10n.createCustomExercise),
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
                      mechanic: exercise.mechanic,
                      primaryMuscles: exercise.primaryMuscles,
                      secondaryMuscles: exercise.secondaryMuscles,
                      grip: exercise.griff,
                      position: exercise.position,
                      familie: exercise.familie,
                      movement: exercise.bewegung,
                      query: query,
                      group: _muscle,
                      equipmentFilter: _equipment,
                      mechanicFilter: _mechanic,
                      gripFilter: _grip,
                      positionFilter: _position,
                      motionFilter: _motion,
                    );
                  }).toList()..sort((a, b) {
                    final queryText = query.trim();
                    if (queryText.isEmpty) {
                      return foldExerciseSearch(
                        exerciseDisplayName(a.name, a.germanName),
                      ).compareTo(
                        foldExerciseSearch(
                          exerciseDisplayName(b.name, b.germanName),
                        ),
                      );
                    }
                    return compareExerciseSearch(
                      query: queryText,
                      leftName: a.name,
                      leftGermanName: a.germanName,
                      leftAliases: a.aliases,
                      rightName: b.name,
                      rightGermanName: b.germanName,
                      rightAliases: b.aliases,
                    );
                  });
              return ListView.builder(
                key: const Key('exercise-results'),
                itemCount: exercises.length,
                itemBuilder: (context, index) {
                  final exercise = exercises[index];
                  final title = localizedExerciseName(
                    context,
                    exercise.name,
                    german: exercise.germanName,
                  );
                  final subtitle = exerciseListSubtitle(
                    category: exercise.categoryName,
                    equipment: exercise.equipment,
                  );
                  return ListTile(
                    leading: ExerciseImage(path: exercise.image, height: 48),
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
