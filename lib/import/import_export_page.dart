import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' hide Column;
import 'package:file_picker/file_picker.dart';
import 'package:flexify/database/catalog_seed.dart';
import 'package:flexify/exercises/custom_exercise_page.dart';
import 'package:flexify/database/database.dart';
import 'package:flexify/database/exercise_set_repository.dart';
import 'package:flexify/import/hevy_import.dart';
import 'package:flexify/l10n/l10n.dart';
import 'package:flexify/main.dart';
import 'package:flexify/theme/alpha_theme.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class ImportExportPage extends StatelessWidget {
  const ImportExportPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.importExportTitle)),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.upload_file),
            title: Text(l10n.importWorkouts),
            onTap: () => _pickWorkouts(context),
          ),
          ListTile(
            leading: const Icon(Icons.monitor_weight_outlined),
            title: Text(l10n.importMeasurements),
            onTap: () => _pickMeasurements(context),
          ),
          ListTile(
            leading: const Icon(Icons.download),
            title: Text(l10n.exportAlphaData),
            onTap: () => _export(context),
          ),
        ],
      ),
    );
  }

  Future<void> _pickWorkouts(BuildContext context) async {
    final picked = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['csv', 'txt'],
    );
    if (picked.isEmpty || !context.mounted) return;
    final raw = utf8.decode(await picked.single.readAsBytes());
    final parsed = parseWorkoutCsv(raw);
    if (parsed == null || !context.mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => ImportPreviewPage(preview: parsed),
      ),
    );
  }

  Future<void> _pickMeasurements(BuildContext context) async {
    final picked = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['csv', 'txt'],
    );
    if (picked.isEmpty || !context.mounted) return;
    final raw = utf8.decode(await picked.single.readAsBytes());
    final points = parseMeasurementCsv(raw);
    for (final point in points) {
      await db
          .into(db.bodyWeights)
          .insert(
            BodyWeightsCompanion.insert(
              timestamp: point.at,
              weightKg: point.kg,
            ),
          );
    }
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('${points.length}')));
  }

  Future<void> _export(BuildContext context) async {
    final rows = await (db.select(db.exerciseSets).join([
      innerJoin(
        db.exercises,
        db.exercises.id.equalsExp(db.exerciseSets.exerciseId),
      ),
      leftOuterJoin(
        db.workouts,
        db.workouts.id.equalsExp(db.exerciseSets.workoutId),
      ),
    ])).get();
    final sets = <ImportedSet>[];
    for (final row in rows) {
      final set = row.readTable(db.exerciseSets);
      final exercise = row.readTable(db.exercises);
      final workout = row.readTableOrNull(db.workouts);
      sets.add(
        ImportedSet(
          workoutTitle: 'Alpha ${set.workoutId ?? 0}',
          started: workout?.startedAt ?? set.timestamp,
          ended: workout?.endedAt,
          exercise: exercise.germanName?.isNotEmpty == true
              ? exercise.germanName!
              : exercise.name,
          kg: set.loadKg ?? 0,
          reps: set.reps ?? 0,
          warmup: (set.notes ?? '').contains('warmup'),
        ),
      );
    }
    final csv = exportWorkoutCsv(sets);
    final file = File('${Directory.systemTemp.path}/alpha-export.csv');
    await file.writeAsString(csv);
    await SharePlus.instance.share(ShareParams(files: [XFile(file.path)]));
  }
}

class ImportPreviewPage extends StatefulWidget {
  const ImportPreviewPage({super.key, required this.preview});

  final WorkoutImport preview;

  @override
  State<ImportPreviewPage> createState() => _ImportPreviewPageState();
}

class _ImportPreviewPageState extends State<ImportPreviewPage> {
  late final List<ImportedTemplate> _templates;
  final Map<String, int?> _mapping = {};
  List<Exercise> _exercises = const [];

  @override
  void initState() {
    super.initState();
    _templates = widget.preview.templates;
    _load();
  }

  Future<void> _load() async {
    final exercises = await (db.select(
      db.exercises,
    )..where((row) => row.archived.equals(false))).get();
    if (!mounted) return;
    setState(() => _exercises = exercises);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = AlphaTheme.of(context);
    final preview = widget.preview;
    final range = preview.first == null
        ? ''
        : '${MaterialLocalizations.of(context).formatShortDate(preview.first!)} – ${MaterialLocalizations.of(context).formatShortDate(preview.last!)}';
    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(title: Text(l10n.importPreviewTitle)),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton(
            key: const Key('apply-import'),
            onPressed: _apply,
            child: Text(l10n.actionAccept),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Text(l10n.importSummary(preview.workoutCount, preview.exerciseCount)),
          if (range.isNotEmpty) Text(range),
          const SizedBox(height: 16),
          Text(
            l10n.templatesDetected,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          for (final template in _templates) _templateCard(template),
        ],
      ),
    );
  }

  Widget _templateCard(ImportedTemplate template) {
    final l10n = context.l10n;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Checkbox(
                  value: template.include,
                  onChanged: (value) =>
                      setState(() => template.include = value ?? false),
                ),
                Expanded(
                  child: TextFormField(
                    initialValue: template.title,
                    decoration: InputDecoration(labelText: l10n.renameLabel),
                    onChanged: (value) => template.title = value,
                  ),
                ),
              ],
            ),
            for (final name in template.exercises) _exerciseRow(name, template),
          ],
        ),
      ),
    );
  }

  Widget _exerciseRow(String name, ImportedTemplate template) {
    final known = _match(name);
    final mapped = _mapping[name];
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(name),
      subtitle: Text(
        '${template.setCounts[name] ?? 0} · ${template.lastWeights[name] ?? 0} kg',
      ),
      trailing: known != null
          ? null
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButton<int>(
                  hint: Text(context.l10n.mapExercise),
                  value: mapped,
                  items: [
                    for (final exercise in _exercises.take(80))
                      DropdownMenuItem(
                        value: exercise.id,
                        child: Text(
                          (exercise.germanName ?? '').isEmpty
                              ? exercise.name
                              : exercise.germanName!,
                        ),
                      ),
                  ],
                  onChanged: (value) => setState(() => _mapping[name] = value),
                ),
                IconButton(
                  key: Key('create-custom-import-$name'),
                  tooltip: context.l10n.createAsCustomExercise,
                  onPressed: () async {
                    final created = await Navigator.of(context).push<Exercise>(
                      MaterialPageRoute(
                        builder: (context) => CustomExercisePage(
                          initialName: name,
                          initialEquipment: _gearFor(name),
                        ),
                      ),
                    );
                    if (created == null || !mounted) return;
                    setState(() {
                      _exercises = [..._exercises, created];
                      _mapping[name] = created.id;
                    });
                  },
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
    );
  }

  String? _gearFor(String name) {
    for (final set in widget.preview.sets) {
      if (set.exercise != name || set.equipment.trim().isEmpty) continue;
      return hevyEquipmentGear(set.equipment);
    }
    return null;
  }

  Exercise? _match(String name) {
    final forced = _mapping[name];
    if (forced != null) {
      return _exercises.where((exercise) => exercise.id == forced).firstOrNull;
    }
    for (final exercise in _exercises) {
      if (exerciseMatchesQuery(
        name: exercise.name,
        germanName: exercise.germanName,
        aliases: exercise.aliases,
        query: name,
      )) {
        if (exercise.name.toLowerCase() == name.toLowerCase() ||
            (exercise.germanName ?? '').toLowerCase() == name.toLowerCase() ||
            (exercise.aliases ?? '').toLowerCase().contains(
              name.toLowerCase(),
            )) {
          return exercise;
        }
      }
    }
    return null;
  }

  Future<void> _apply() async {
    final included = _templates.where((template) => template.include).toList();
    final byOriginal = {
      for (final template in included) template.originalTitle: template,
    };
    final usable = widget.preview.sets
        .where((set) => byOriginal.containsKey(set.workoutTitle))
        .toList();
    final byWorkout = <String, int>{};
    final planIds = <String, int?>{};
    for (final set in usable) {
      final template = byOriginal[set.workoutTitle]!;
      final key = '${set.workoutTitle}|${set.started.toIso8601String()}';
      var workoutId = byWorkout[key];
      if (workoutId == null) {
        planIds[template.originalTitle] ??= await _planFor(template);
        workoutId = await db.workouts.insertOne(
          WorkoutsCompanion.insert(
            planId: Value(planIds[template.originalTitle]),
            startedAt: set.started,
            endedAt: Value(set.ended ?? set.started),
          ),
        );
        byWorkout[key] = workoutId;
      }
      final exercise = await _exerciseFor(set.exercise);
      if (exercise == null) continue;
      await insertExerciseSet(
        db,
        exerciseId: exercise.id,
        workoutId: workoutId,
        exerciseSet: ExerciseSetView(
          id: 0,
          bodyWeight: 0,
          cardio: exercise.kind == 'cardio',
          created: set.started,
          distance: 0,
          duration: 0,
          name: exercise.name,
          notes: set.warmup ? '[warmup]' : '',
          planId: planIds[template.originalTitle],
          reps: set.reps,
          unit: 'kg',
          weight: set.kg,
        ),
      );
    }
    if (!mounted) return;
    Navigator.pop(context);
  }

  Future<int?> _planFor(ImportedTemplate template) async {
    final existing = await (db.select(
      db.plans,
    )..where((row) => row.title.equals(template.title))).getSingleOrNull();
    if (existing != null) return existing.id;
    final count = await db.plans.count().getSingle();
    if (count >= 7) return null;
    final id = await db.plans.insertOne(
      PlansCompanion.insert(
        days: '',
        title: Value(template.title),
        sequence: Value(count),
      ),
    );
    var sequence = 0;
    for (final name in template.exercises) {
      final exercise = await _exerciseFor(name);
      if (exercise == null) continue;
      await db
          .into(db.planExercises)
          .insert(
            PlanExercisesCompanion.insert(
              enabled: true,
              exerciseId: exercise.id,
              planId: id,
              maxSets: Value(template.setCounts[name]),
              sequence: Value(sequence++),
            ),
            mode: InsertMode.insertOrIgnore,
          );
    }
    return id;
  }

  Future<Exercise?> _exerciseFor(String name) async {
    final known = _match(name);
    if (known != null) return known;
    final all = _exercises.isEmpty
        ? await db.select(db.exercises).get()
        : _exercises;
    Exercise? best;
    var bestScore = 0;
    final needle = name.toLowerCase();
    for (final exercise in all) {
      final haystack =
          '${exercise.name} ${exercise.germanName ?? ''} ${exercise.aliases ?? ''}'
              .toLowerCase();
      if (haystack.contains(needle) ||
          needle.contains(exercise.name.toLowerCase())) {
        final score = exercise.name.length;
        if (score > bestScore) {
          best = exercise;
          bestScore = score;
        }
      }
    }
    return best;
  }
}
