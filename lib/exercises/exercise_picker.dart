import 'package:drift/drift.dart' hide Column;
import 'package:flexify/database/catalog_seed.dart';
import 'package:flexify/database/database.dart';
import 'package:flexify/exercise_labels.dart';
import 'package:flexify/exercises/custom_exercise_page.dart';
import 'package:flexify/exercises/exercise_detail_page.dart';
import 'package:flexify/exercises/exercise_media.dart';
import 'package:flexify/l10n/l10n.dart';
import 'package:flexify/main.dart';
import 'package:flexify/platform_page_route.dart';
import 'package:flutter/material.dart';

Future<Exercise?> showExercisePicker(
  BuildContext context, {
  String? title,
  String initialQuery = '',
  bool selectOnTap = false,
}) async {
  final exercises =
      await (db.select(db.exercises)
            ..where((row) => row.archived.equals(false))
            ..orderBy([(row) => OrderingTerm.asc(row.name)]))
          .get();
  if (!context.mounted) return null;
  return showDialog<Exercise>(
    context: context,
    builder: (context) => ExercisePickerDialog(
      exercises: exercises,
      title: title,
      initialQuery: initialQuery,
      selectOnTap: selectOnTap,
    ),
  );
}

class ExercisePickerDialog extends StatefulWidget {
  const ExercisePickerDialog({
    required this.exercises,
    this.title,
    this.initialQuery = '',
    this.selectOnTap = false,
    super.key,
  });

  final List<Exercise> exercises;
  final String? title;
  final String initialQuery;
  final bool selectOnTap;

  @override
  State<ExercisePickerDialog> createState() => _ExercisePickerDialogState();
}

class _ExercisePickerDialogState extends State<ExercisePickerDialog> {
  late final TextEditingController _query = TextEditingController(
    text: widget.initialQuery,
  );

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  List<Exercise> get _matches {
    final needle = _query.text.trim();
    final matches =
        widget.exercises
            .where(
              (exercise) => exerciseMatchesQuery(
                name: exercise.name,
                germanName: exercise.germanName,
                aliases: exercise.aliases,
                englishName: exercise.englishName,
                englishAliases: exercise.englishAliases,
                muscle: exercise.muscle,
                category: exercise.categoryName,
                equipment: exercise.equipment,
                mechanic: exercise.mechanic,
                primaryMuscles: exercise.primaryMuscles,
                secondaryMuscles: exercise.secondaryMuscles,
                familie: exercise.familie,
                grip: exercise.griff,
                position: exercise.position,
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
                    leftEnglishName: a.englishName,
                    leftEnglishAliases: a.englishAliases,
                    leftCatalog: isCatalogExercise(
                      catalogId: a.catalogId,
                      catalogSource: a.catalogSource,
                    ),
                    rightName: b.name,
                    rightGermanName: b.germanName,
                    rightAliases: b.aliases,
                    rightEnglishName: b.englishName,
                    rightEnglishAliases: b.englishAliases,
                    rightCatalog: isCatalogExercise(
                      catalogId: b.catalogId,
                      catalogSource: b.catalogSource,
                    ),
                  ),
          );
    return matches.take(40).toList();
  }

  Future<void> _choose(Exercise exercise) async {
    if (widget.selectOnTap) {
      Navigator.pop(context, exercise);
      return;
    }
    final added = await Navigator.of(context).push<Exercise>(
      FlexPageRoute(
        builder: (context) =>
            ExerciseDetailPage(exercise: exercise, onAdd: () {}),
      ),
    );
    if (added != null && mounted) Navigator.pop(context, added);
  }

  Future<void> _createOwn() async {
    final created = await Navigator.of(context).push<Exercise>(
      FlexPageRoute(
        builder: (context) =>
            CustomExercisePage(initialName: _query.text.trim()),
      ),
    );
    if (created != null && mounted) Navigator.pop(context, created);
  }

  @override
  Widget build(BuildContext context) {
    final shown = _matches;
    return AlertDialog(
      key: const Key('exercise-picker'),
      title: Text(widget.title ?? context.l10n.addExerciseWorkout),
      content: SizedBox(
        width: 420,
        height: 460,
        child: Column(
          children: [
            TextField(
              controller: _query,
              autofocus: true,
              decoration: InputDecoration(
                hintText: context.l10n.exerciseSearchHint,
              ),
              onChanged: (_) => setState(() {}),
            ),
            Expanded(
              child: ListView(
                children: [
                  for (final exercise in shown)
                    ListTile(
                      leading: exerciseLeading(
                        catalogId: exercise.catalogId,
                        imagePath: exercise.image,
                        size: 40,
                      ),
                      title: Text(
                        localizedExerciseName(
                          context,
                          exercise.name,
                          german: exercise.germanName,
                          english: exercise.englishName,
                        ),
                      ),
                      onTap: () => _choose(exercise),
                    ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                key: const Key('create-own-exercise'),
                onPressed: _createOwn,
                child: Text(context.l10n.createOwnExercise),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
