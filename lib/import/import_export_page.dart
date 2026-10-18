import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' hide Column;
import 'package:file_picker/file_picker.dart';
import 'package:flexify/exercises/custom_exercise_page.dart';
import 'package:flexify/database/database.dart';
import 'package:flexify/database/exercise_set_repository.dart';
import 'package:flexify/import/hevy_import.dart';
import 'package:flexify/import/import_cleanup.dart';
import 'package:flexify/import_data.dart';
import 'package:flexify/l10n/l10n.dart';
import 'package:flexify/logging.dart';
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
            key: const Key('import-backup-zip'),
            leading: const Icon(Icons.folder_zip_outlined),
            title: Text(l10n.importBackupZip),
            onTap: () => _importBackup(context),
          ),
          ListTile(
            leading: const Icon(Icons.download),
            title: Text(l10n.exportAlphaData),
            onTap: () => _export(context),
          ),
          ListTile(
            key: const Key('cleanup-imports'),
            leading: const Icon(Icons.cleaning_services_outlined),
            title: Text(l10n.cleanupImports),
            onTap: () => _cleanup(context),
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.measurementsImported(points.length))),
    );
  }

  Future<void> _cleanup(BuildContext context) async {
    final preview = await previewImportCleanup(db);
    if (!context.mounted) return;
    if (preview.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.cleanupImportsEmpty)));
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.cleanupImports),
        content: Text(
          context.l10n.cleanupImportsPreview(
            preview.workoutIds.length,
            preview.planIds.length,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.l10n.actionCancel),
          ),
          FilledButton(
            key: const Key('confirm-cleanup'),
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.l10n.actionDelete),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    await applyImportCleanup(db, preview);
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(context.l10n.cleanupImportsDone)));
  }

  Future<void> _importBackup(BuildContext context) async {
    final l10n = context.l10n;
    final picked = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['zip'],
    );
    if (picked.isEmpty || !context.mounted) return;
    final path = picked.single.path;
    if (path == null || !context.mounted) return;
    try {
      await finishFlexifyBackupImport(context, File(path));
    } catch (error, stackTrace) {
      talker.handle(error, stackTrace, 'Failed to import Flexify database');
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.failedToImportDatabase('$error'))),
      );
    }
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
  const ImportPreviewPage({super.key, required this.preview, this.pause});

  final WorkoutImport preview;
  final Future<void> Function()? pause;

  @override
  State<ImportPreviewPage> createState() => _ImportPreviewPageState();
}

class _ImportPreviewPageState extends State<ImportPreviewPage> {
  late final List<ImportedTemplate> _templates;
  final Map<String, int?> _mapping = {};
  final Map<String, Exercise?> _matchCache = {};
  List<Exercise> _exercises = const [];
  Set<String> _existingTitles = const {};
  var _existingPlanCount = 0;
  var _applying = false;
  var _applied = 0;
  var _applyTotal = 0;

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
    final plans = await db.select(db.plans).get();
    if (!mounted) return;
    setState(() {
      _exercises = exercises;
      _matchCache.clear();
      _existingPlanCount = plans.length;
      _existingTitles = {
        for (final plan in plans)
          if ((plan.title ?? '').trim().isNotEmpty) plan.title!.trim(),
      };
    });
  }

  List<String> get _unmatched {
    final names = <String>[];
    for (final template in _templates) {
      for (final name in template.exercises) {
        if (_cachedMatch(name) == null && !names.contains(name)) {
          names.add(name);
        }
      }
    }
    return names;
  }

  List<String> get _skippedTemplateTitles {
    var room = hevyTemplateLimit - _existingPlanCount;
    if (room < 0) room = 0;
    final skipped = <String>[];
    for (final template in _templates.where((row) => row.include)) {
      if (_existingTitles.contains(template.title.trim())) continue;
      if (room == 0) {
        skipped.add(template.title);
      } else {
        room -= 1;
      }
    }
    return skipped;
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
            onPressed: _applying ? null : _apply,
            child: _applying
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      const SizedBox(width: 12),
                      Text(l10n.importApplying(_applied, _applyTotal)),
                    ],
                  )
                : Text(l10n.actionAccept),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Text(
            l10n.importSetSummary(preview.workoutCount, preview.sets.length),
          ),
          if (preview.errors.isNotEmpty)
            Text(l10n.importDateErrorCount(preview.errors.length)),
          if (range.isNotEmpty) Text(range),
          if (_unmatched.isNotEmpty)
            Text(l10n.importUnmatchedNames(_unmatched.join(', '))),
          if (_skippedTemplateTitles.isNotEmpty)
            Text(
              l10n.importTemplatesSkipped(_skippedTemplateTitles.join(', ')),
            ),
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
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
          Text(
            '${template.setCounts[name] ?? 0} · ${template.lastWeights[name] ?? 0} kg',
          ),
          if (known == null) ...[
            DropdownButton<int>(
              isExpanded: true,
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
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
              onChanged: (value) => setState(() {
                _mapping[name] = value;
                _matchCache.remove(name);
              }),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
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
                    _matchCache.remove(name);
                  });
                },
                icon: const Icon(Icons.add),
              ),
            ),
          ],
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
      final aliasHit = (exercise.aliases ?? '')
          .toLowerCase()
          .split('|')
          .map((part) => part.trim())
          .contains(name.toLowerCase());
      if (exercise.name.toLowerCase() == name.toLowerCase() ||
          (exercise.germanName ?? '').toLowerCase() == name.toLowerCase() ||
          aliasHit) {
        return exercise;
      }
    }
    return null;
  }

  Exercise? _cachedMatch(String name) {
    if (_matchCache.containsKey(name)) return _matchCache[name];
    final match = _match(name);
    _matchCache[name] = match;
    return match;
  }

  Future<void> _apply() async {
    if (_applying) return;
    _applying = true;
    final included = _templates.where((template) => template.include).toList();
    final byOriginal = {
      for (final template in included) template.originalTitle: template,
    };
    final usable = widget.preview.sets
        .where((set) => byOriginal.containsKey(set.workoutTitle))
        .toList();
    final names = usable.map((set) => set.exercise).toSet();
    for (final name in names) {
      _cachedMatch(name);
    }
    setState(() {
      _applied = 0;
      _applyTotal = usable.length;
    });
    try {
      await widget.pause?.call();
      if (!mounted) return;
      await db.transaction(() async {
        final byWorkout = <String, int>{};
        final planIds = <String, int?>{};
        var createdPlans = _existingPlanCount;
        for (final set in usable) {
          final template = byOriginal[set.workoutTitle]!;
          final key = '${set.workoutTitle}|${set.started.toIso8601String()}';
          var workoutId = byWorkout[key];
          if (workoutId == null) {
            planIds[template.originalTitle] ??= await _planFor(
              template,
              createdPlans,
            );
            if (planIds[template.originalTitle] != null &&
                !_existingTitles.contains(template.title.trim())) {
              createdPlans += 1;
              _existingTitles.add(template.title.trim());
            }
            workoutId = await db.workouts.insertOne(
              WorkoutsCompanion.insert(
                planId: Value(planIds[template.originalTitle]),
                startedAt: set.started,
                endedAt: Value(set.ended ?? set.started),
              ),
            );
            byWorkout[key] = workoutId;
          }
          final exercise = _cachedMatch(set.exercise);
          if (exercise != null) {
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
          _applied += 1;
          if (mounted && (_applied == usable.length || _applied % 25 == 0)) {
            setState(() {});
          }
        }
      });
      if (!mounted) return;
      Navigator.pop(context);
    } finally {
      _applying = false;
      if (mounted) setState(() {});
    }
  }

  Future<int?> _planFor(ImportedTemplate template, int createdPlans) async {
    final existing = await (db.select(
      db.plans,
    )..where((row) => row.title.equals(template.title))).getSingleOrNull();
    if (existing != null) return existing.id;
    if (createdPlans >= hevyTemplateLimit) return null;
    final id = await db.plans.insertOne(
      PlansCompanion.insert(
        days: '',
        title: Value(template.title),
        sequence: Value(createdPlans),
      ),
    );
    var sequence = 0;
    for (final name in template.exercises) {
      final exercise = _cachedMatch(name);
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
}
