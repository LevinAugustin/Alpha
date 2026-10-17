import 'package:drift/drift.dart' hide Column;
import 'package:flexify/database/catalog_seed.dart';
import 'package:flexify/database/database.dart';
import 'package:flexify/exercise_labels.dart';
import 'package:flexify/l10n/l10n.dart';
import 'package:flexify/main.dart';
import 'package:flexify/platform_page_route.dart';
import 'package:flexify/shell/training_stats.dart';
import 'package:flutter/material.dart';

class ExercisesPage extends StatefulWidget {
  const ExercisesPage({super.key});

  @override
  State<ExercisesPage> createState() => _ExercisesPageState();
}

class _ExercisesPageState extends State<ExercisesPage> {
  final _search = TextEditingController();
  String _muscle = '';

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
              final exercises = (snapshot.data ?? const <Exercise>[]).where((
                exercise,
              ) {
                if (_muscle.isNotEmpty && exercise.muscle != _muscle) {
                  return false;
                }
                return exerciseMatchesQuery(
                  name: exercise.name,
                  germanName: exercise.germanName,
                  aliases: exercise.aliases,
                  query: query,
                );
              }).toList();
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

class ExerciseDetailPage extends StatelessWidget {
  const ExerciseDetailPage({super.key, required this.exercise});

  final Exercise exercise;

  @override
  Widget build(BuildContext context) {
    final title = localizedExerciseName(
      context,
      exercise.name,
      german: exercise.germanName,
    );
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: StreamBuilder<List<ExerciseSet>>(
        stream:
            (db.select(db.exerciseSets)
                  ..where((row) => row.exerciseId.equals(exercise.id))
                  ..orderBy([(row) => OrderingTerm.desc(row.timestamp)]))
                .watch(),
        builder: (context, snapshot) {
          final sets = snapshot.data ?? const <ExerciseSet>[];
          var bestLoad = 0.0;
          var bestEstimate = 0.0;
          for (final set in sets) {
            final load = set.loadKg ?? 0;
            final reps = set.reps ?? 0;
            if (load > bestLoad) bestLoad = load;
            final estimate = estimatedOneRepMax(load, reps);
            if (estimate > bestEstimate) bestEstimate = estimate;
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (exercise.muscle != null)
                Text(
                  exercise.muscle!,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              if (title != exercise.name) Text(exercise.name),
              const SizedBox(height: 12),
              Text(
                bestEstimate <= 0
                    ? context.l10n.noHistory
                    : context.l10n.bestOneRepMax(
                        bestEstimate.toStringAsFixed(1),
                      ),
              ),
              if (bestLoad > 0)
                Text(context.l10n.bestLoad(bestLoad.toStringAsFixed(1))),
              const SizedBox(height: 16),
              if (sets.isEmpty)
                Text(context.l10n.noHistory)
              else
                for (final set in sets)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(_setLine(set)),
                    subtitle: Text(
                      MaterialLocalizations.of(
                        context,
                      ).formatFullDate(set.timestamp),
                    ),
                  ),
            ],
          );
        },
      ),
    );
  }

  String _setLine(ExerciseSet set) {
    final reps = set.reps == null ? '-' : set.reps!.toStringAsFixed(0);
    final load = set.loadKg == null ? '-' : set.loadKg!.toStringAsFixed(1);
    return '$load kg × $reps';
  }
}
