import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flexify/database/database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

const exerciseCatalogAsset = 'assets/exercises/exercises_de.json';
const exerciseImageDirectory = 'assets/exercises/images';

const allowedExerciseSplits = {'push', 'pull', 'beine', 'core', 'cardio'};
const allowedExerciseMechanics = {'grund', 'isolation'};

class ExerciseDeEntry {
  const ExerciseDeEntry({
    required this.id,
    required this.nameDe,
    required this.synonyms,
    required this.category,
    required this.primaryMuscles,
    required this.secondaryMuscles,
    required this.equipment,
    required this.split,
    required this.mechanic,
    required this.steps,
    required this.tips,
    required this.image,
    required this.source,
    required this.license,
    required this.legacyNames,
  });

  final String id;
  final String nameDe;
  final List<String> synonyms;
  final String category;
  final List<String> primaryMuscles;
  final List<String> secondaryMuscles;
  final String equipment;
  final String split;
  final String mechanic;
  final List<String> steps;
  final List<String> tips;
  final String image;
  final String source;
  final String license;
  final List<String> legacyNames;
}

class ExerciseCatalogParse {
  const ExerciseCatalogParse({required this.entries, required this.skipped});

  final List<ExerciseDeEntry> entries;
  final List<String> skipped;
}

class ExerciseImportResult {
  const ExerciseImportResult({
    required this.inserted,
    required this.updated,
    required this.unchanged,
    required this.merged,
    required this.skipped,
  });

  final int inserted;
  final int updated;
  final int unchanged;
  final int merged;
  final List<String> skipped;
}

String? resolveExerciseImage(String bild) {
  final value = bild.trim();
  if (value.isEmpty) return null;
  if (value.startsWith('assets/')) return value;
  final name = value.split(RegExp(r'[/\\]')).last.trim();
  if (name.isEmpty) return null;
  return '$exerciseImageDirectory/$name';
}

ExerciseCatalogParse parseExerciseCatalog(String raw) {
  final decoded = jsonDecode(raw);
  if (decoded is! List) {
    return const ExerciseCatalogParse(
      entries: [],
      skipped: ['The catalog file must be a JSON array.'],
    );
  }
  final entries = <ExerciseDeEntry>[];
  final skipped = <String>[];
  final seen = <String>{};
  for (var index = 0; index < decoded.length; index++) {
    final row = decoded[index];
    if (row is! Map) {
      skipped.add('Item $index is not an object.');
      continue;
    }
    final json = Map<String, dynamic>.from(row);
    final id = _string(json['id']);
    final error = _validate(json, id);
    if (error != null) {
      skipped.add(error);
      continue;
    }
    if (!seen.add(id)) {
      skipped.add('Duplicate id "$id".');
      continue;
    }
    entries.add(
      ExerciseDeEntry(
        id: id,
        nameDe: _string(json['name_de']),
        synonyms: _strings(json['synonyme']),
        category: _string(json['kategorie']),
        primaryMuscles: _strings(json['primaermuskeln']),
        secondaryMuscles: _strings(json['sekundaermuskeln']),
        equipment: _string(json['geraet']),
        split: _string(json['split']),
        mechanic: _string(json['mechanik']),
        steps: _strings(json['ausfuehrung_de']),
        tips: _strings(json['tipps_de']),
        image: _string(json['bild']),
        source: _string(json['quelle']),
        license: _string(json['lizenz']),
        legacyNames: _strings(json['legacy_names']),
      ),
    );
  }
  return ExerciseCatalogParse(entries: entries, skipped: skipped);
}

Future<ExerciseImportResult> importExerciseCatalog(AppDatabase database) async {
  if (Platform.environment.containsKey('FLUTTER_TEST')) {
    return const ExerciseImportResult(
      inserted: 0,
      updated: 0,
      unchanged: 0,
      merged: 0,
      skipped: [],
    );
  }
  final raw = await rootBundle.loadString(exerciseCatalogAsset);
  return importExerciseCatalogJson(database, raw);
}

Future<ExerciseImportResult> importExerciseCatalogJson(
  AppDatabase database,
  String raw,
) async {
  final parsed = parseExerciseCatalog(raw);
  final existing = await database.select(database.exercises).get();
  final byCatalog = <String, Exercise>{
    for (final exercise in existing)
      if ((exercise.catalogId ?? '').isNotEmpty) exercise.catalogId!: exercise,
  };
  final byName = <String, Exercise>{
    for (final exercise in existing) exercise.name.toLowerCase(): exercise,
  };
  final categoryIds = {
    for (final category in await database.select(database.categories).get())
      category.name: category.id,
  };
  var inserted = 0;
  var updated = 0;
  var unchanged = 0;
  var merged = 0;

  Future<int?> categoryIdFor(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return null;
    final known = categoryIds[trimmed];
    if (known != null) return known;
    await database
        .into(database.categories)
        .insert(
          CategoriesCompanion.insert(name: trimmed),
          mode: InsertMode.insertOrIgnore,
        );
    final id = (await (database.select(
      database.categories,
    )..where((row) => row.name.equals(trimmed))).getSingle()).id;
    categoryIds[trimmed] = id;
    return id;
  }

  await database.transaction(() async {
    for (final entry in parsed.entries) {
      final catalogRow = byCatalog[entry.id];
      Exercise? legacyRow;
      for (final legacy in entry.legacyNames) {
        final found = byName[legacy.toLowerCase()];
        if (found == null) continue;
        if ((found.catalogId ?? '').isEmpty || found.catalogId == entry.id) {
          legacyRow = found;
          break;
        }
      }
      final namedRow = byName[entry.id.toLowerCase()];
      Exercise? target = catalogRow ?? legacyRow ?? namedRow;
      Exercise? duplicate;
      if (legacyRow != null &&
          catalogRow != null &&
          catalogRow.id != legacyRow.id) {
        target = legacyRow;
        duplicate = catalogRow;
      }
      final categoryId = await categoryIdFor(entry.category);
      final companion = _companion(entry, categoryId);
      if (target == null) {
        final id = await database
            .into(database.exercises)
            .insert(companion.insert(name: entry.id));
        final created = await (database.select(
          database.exercises,
        )..where((row) => row.id.equals(id))).getSingle();
        byCatalog[entry.id] = created;
        byName[created.name.toLowerCase()] = created;
        inserted++;
        continue;
      }
      final current = target;
      if (duplicate != null) {
        await _moveHistory(database, fromId: duplicate.id, toId: current.id);
        byName.remove(duplicate.name.toLowerCase());
        merged++;
      }
      if (_same(current, entry, categoryId) && duplicate == null) {
        unchanged++;
        byCatalog[entry.id] = current;
        continue;
      }
      await (database.update(
        database.exercises,
      )..where((row) => row.id.equals(current.id))).write(companion.update());
      final refreshed = await (database.select(
        database.exercises,
      )..where((row) => row.id.equals(current.id))).getSingle();
      byCatalog[entry.id] = refreshed;
      byName[refreshed.name.toLowerCase()] = refreshed;
      updated++;
    }
  });

  if (parsed.skipped.isNotEmpty) {
    debugPrint('Exercise catalog skipped rows: ${parsed.skipped.join(' ')}');
  }
  return ExerciseImportResult(
    inserted: inserted,
    updated: updated,
    unchanged: unchanged,
    merged: merged,
    skipped: parsed.skipped,
  );
}

Future<List<({String source, String license})>> exerciseLicenseRows(
  AppDatabase database,
) async {
  final rows = await database.select(database.exercises).get();
  final seen = <String>{};
  final licenses = <({String source, String license})>[];
  for (final row in rows) {
    final source = (row.catalogSource ?? '').trim();
    final license = (row.catalogLicense ?? '').trim();
    if (source.isEmpty && license.isEmpty) continue;
    final key = '$source\n$license';
    if (!seen.add(key)) continue;
    licenses.add((source: source, license: license));
  }
  licenses.sort((a, b) {
    final source = a.source.toLowerCase().compareTo(b.source.toLowerCase());
    if (source != 0) return source;
    return a.license.toLowerCase().compareTo(b.license.toLowerCase());
  });
  return licenses;
}

String? _validate(Map<String, dynamic> json, String id) {
  if (id.isEmpty) return 'An exercise is missing id.';
  if (_string(json['name_de']).isEmpty) return '$id is missing name_de.';
  for (final key in [
    'synonyme',
    'primaermuskeln',
    'sekundaermuskeln',
    'ausfuehrung_de',
    'tipps_de',
  ]) {
    if (json[key] is! List) return '$id field $key must be a list.';
  }
  if (json.containsKey('legacy_names') && json['legacy_names'] is! List) {
    return '$id field legacy_names must be a list.';
  }
  for (final key in [
    'kategorie',
    'geraet',
    'split',
    'mechanik',
    'bild',
    'quelle',
    'lizenz',
  ]) {
    if (json[key] is! String) return '$id field $key must be a string.';
  }
  final split = _string(json['split']);
  if (!allowedExerciseSplits.contains(split)) {
    return '$id split "$split" is not allowed.';
  }
  final mechanic = _string(json['mechanik']);
  if (!allowedExerciseMechanics.contains(mechanic)) {
    return '$id mechanik "$mechanic" is not allowed.';
  }
  return null;
}

String _string(Object? value) => value is String ? value.trim() : '';

List<String> _strings(Object? value) {
  if (value is! List) return const [];
  return [
    for (final item in value)
      if (item is String && item.trim().isNotEmpty) item.trim(),
  ];
}

class _Fields {
  const _Fields(this.entry, this.categoryId);

  final ExerciseDeEntry entry;
  final int? categoryId;

  String get aliases => entry.synonyms.join('|');
  String get primary => jsonEncode(entry.primaryMuscles);
  String get secondary => jsonEncode(entry.secondaryMuscles);
  String get steps => jsonEncode(entry.steps);
  String get tips => jsonEncode(entry.tips);
  String? get image => resolveExerciseImage(entry.image);

  ExercisesCompanion insert({required String name}) {
    final cardio = entry.split == 'cardio';
    return ExercisesCompanion.insert(
      name: name,
      kind: cardio ? 'cardio' : 'strength',
      displayUnit: cardio ? 'km' : 'kg',
      categoryId: Value(categoryId),
      image: Value(image),
      germanName: Value(entry.nameDe),
      aliases: Value(aliases),
      muscle: Value(entry.category),
      catalogId: Value(entry.id),
      categoryName: Value(entry.category),
      equipment: Value(entry.equipment),
      primaryMuscles: Value(primary),
      secondaryMuscles: Value(secondary),
      split: Value(entry.split),
      mechanic: Value(entry.mechanic),
      steps: Value(steps),
      tips: Value(tips),
      catalogSource: Value(entry.source),
      catalogLicense: Value(entry.license),
    );
  }

  ExercisesCompanion update() {
    return ExercisesCompanion(
      categoryId: Value(categoryId),
      image: Value(image),
      germanName: Value(entry.nameDe),
      aliases: Value(aliases),
      muscle: Value(entry.category),
      catalogId: Value(entry.id),
      categoryName: Value(entry.category),
      equipment: Value(entry.equipment),
      primaryMuscles: Value(primary),
      secondaryMuscles: Value(secondary),
      split: Value(entry.split),
      mechanic: Value(entry.mechanic),
      steps: Value(steps),
      tips: Value(tips),
      catalogSource: Value(entry.source),
      catalogLicense: Value(entry.license),
    );
  }
}

_Fields _companion(ExerciseDeEntry entry, int? categoryId) =>
    _Fields(entry, categoryId);

bool _same(Exercise row, ExerciseDeEntry entry, int? categoryId) {
  final fields = _Fields(entry, categoryId);
  return row.catalogId == entry.id &&
      row.germanName == entry.nameDe &&
      row.aliases == fields.aliases &&
      row.muscle == entry.category &&
      row.categoryId == categoryId &&
      row.categoryName == entry.category &&
      row.equipment == entry.equipment &&
      row.primaryMuscles == fields.primary &&
      row.secondaryMuscles == fields.secondary &&
      row.split == entry.split &&
      row.mechanic == entry.mechanic &&
      row.steps == fields.steps &&
      row.tips == fields.tips &&
      row.image == fields.image &&
      row.catalogSource == entry.source &&
      row.catalogLicense == entry.license;
}

Future<void> _moveHistory(
  AppDatabase database, {
  required int fromId,
  required int toId,
}) async {
  final sourcePlans = await (database.select(
    database.planExercises,
  )..where((row) => row.exerciseId.equals(fromId))).get();
  for (final source in sourcePlans) {
    final target =
        await (database.select(database.planExercises)..where(
              (row) =>
                  row.planId.equals(source.planId) &
                  row.exerciseId.equals(toId),
            ))
            .getSingleOrNull();
    if (target == null) {
      await (database.update(database.planExercises)
            ..where((row) => row.id.equals(source.id)))
          .write(PlanExercisesCompanion(exerciseId: Value(toId)));
    } else {
      await (database.delete(
        database.planExercises,
      )..where((row) => row.id.equals(source.id))).go();
    }
  }
  await (database.update(database.exerciseSets)
        ..where((row) => row.exerciseId.equals(fromId)))
      .write(ExerciseSetsCompanion(exerciseId: Value(toId)));
  await (database.delete(
    database.exercises,
  )..where((row) => row.id.equals(fromId))).go();
}
