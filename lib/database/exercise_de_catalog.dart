import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flexify/database/database.dart';
import 'package:flexify/exercise_keys.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

const exerciseCatalogAsset = 'assets/exercises/exercises_de.json';
const exerciseLegacyMapAsset = 'assets/exercises/legacy_map.json';
const exerciseImageDirectory = 'assets/exercises/img';

const allowedExerciseSplits = {'push', 'pull', 'beine', 'core', 'cardio'};
const allowedExerciseMechanics = {'grund', 'isolation'};
const allowedExerciseCategories = {...exerciseCategories};
const allowedShoulderRisk = {...shoulderRiskValues};

final catalogIdPattern = RegExp(r'^[a-z0-9]+(?:-[a-z0-9]+)*$');

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
    required this.imageSource,
    required this.imageLicense,
    required this.alternatives,
    required this.shoulderRisk,
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
  final String imageSource;
  final String imageLicense;
  final List<String> alternatives;
  final String shoulderRisk;
  final List<String> legacyNames;

  ExerciseDeEntry copyWith({List<String>? legacyNames}) {
    return ExerciseDeEntry(
      id: id,
      nameDe: nameDe,
      synonyms: synonyms,
      category: category,
      primaryMuscles: primaryMuscles,
      secondaryMuscles: secondaryMuscles,
      equipment: equipment,
      split: split,
      mechanic: mechanic,
      steps: steps,
      tips: tips,
      image: image,
      source: source,
      license: license,
      imageSource: imageSource,
      imageLicense: imageLicense,
      alternatives: alternatives,
      shoulderRisk: shoulderRisk,
      legacyNames: legacyNames ?? this.legacyNames,
    );
  }
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
  if (!value.endsWith('.webp')) return null;
  if (value.contains('/') || value.contains('\\')) return null;
  final stem = value.substring(0, value.length - 5);
  if (!catalogIdPattern.hasMatch(stem)) return null;
  return '$exerciseImageDirectory/$value';
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
        imageSource: _string(json['bild_quelle']),
        imageLicense: _string(json['bild_lizenz']),
        alternatives: _strings(json['alternativen']),
        shoulderRisk: _string(json['schulter_risiko']),
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
  String? legacyMapRaw;
  try {
    legacyMapRaw = await rootBundle.loadString(exerciseLegacyMapAsset);
  } catch (error) {
    debugPrint('Exercise legacy map was not loaded: $error');
  }
  return importExerciseCatalogJson(database, raw, legacyMapRaw: legacyMapRaw);
}

Map<String, List<String>> parseLegacyNameMap(String raw) {
  Object? decoded;
  try {
    decoded = jsonDecode(raw);
  } catch (error) {
    debugPrint('Exercise legacy map was ignored: $error');
    return const {};
  }
  if (decoded is! Map) return const {};
  final names = <String, List<String>>{};
  for (final entry in decoded.entries) {
    final id = entry.key;
    if (id is! String || !catalogIdPattern.hasMatch(id)) continue;
    final value = entry.value;
    if (value is! List) continue;
    final legacy = <String>[];
    for (final item in value) {
      if (item is! String) continue;
      final trimmed = item.trim();
      if (trimmed.isEmpty) continue;
      legacy.add(trimmed);
    }
    if (legacy.isEmpty) continue;
    names[id] = legacy;
  }
  return names;
}

Future<ExerciseImportResult> importExerciseCatalogJson(
  AppDatabase database,
  String raw, {
  String? legacyMapRaw,
}) async {
  final parsed = parseExerciseCatalog(raw);
  final legacyMap = legacyMapRaw == null
      ? const <String, List<String>>{}
      : parseLegacyNameMap(legacyMapRaw);
  final entries = [
    for (final entry in parsed.entries)
      _attachLegacyNames(entry, legacyMap[entry.id]),
  ];
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
    for (final entry in entries) {
      final matches = <int, Exercise>{};
      void consider(Exercise? row) {
        if (row == null || !_claimable(row, entry.id)) return;
        matches[row.id] = row;
      }

      consider(byCatalog[entry.id]);
      for (final legacy in entry.legacyNames) {
        consider(byName[legacy.toLowerCase()]);
      }
      consider(byName[entry.id.toLowerCase()]);

      final categoryId = await categoryIdFor(entry.category);
      final companion = _companion(entry, categoryId);
      if (matches.isEmpty) {
        final blocked = byName[entry.id.toLowerCase()];
        if (blocked != null) continue;
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

      Exercise? smallestLegacy;
      for (final legacy in entry.legacyNames) {
        final found = byName[legacy.toLowerCase()];
        if (found == null || !matches.containsKey(found.id)) continue;
        final current = smallestLegacy;
        if (current == null || found.id < current.id) smallestLegacy = found;
      }
      final survivor =
          smallestLegacy ??
          matches.values.reduce(
            (left, right) => left.id <= right.id ? left : right,
          );
      final duplicates = [
        for (final row in matches.values)
          if (row.id != survivor.id) row,
      ];
      for (final duplicate in duplicates) {
        await _moveHistory(database, fromId: duplicate.id, toId: survivor.id);
        byName.remove(duplicate.name.toLowerCase());
        final catalogId = duplicate.catalogId;
        if (catalogId != null && byCatalog[catalogId]?.id == duplicate.id) {
          byCatalog.remove(catalogId);
        }
        merged++;
      }
      if (_same(survivor, entry, categoryId) && duplicates.isEmpty) {
        unchanged++;
        byCatalog[entry.id] = survivor;
        continue;
      }
      await (database.update(
        database.exercises,
      )..where((row) => row.id.equals(survivor.id))).write(companion.update());
      final refreshed = await (database.select(
        database.exercises,
      )..where((row) => row.id.equals(survivor.id))).getSingle();
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

Future<List<({String source, String license, bool image})>> exerciseLicenseRows(
  AppDatabase database,
) async {
  final rows = await database.select(database.exercises).get();
  final seen = <String>{};
  final licenses = <({String source, String license, bool image})>[];
  void add(String? sourceRaw, String? licenseRaw, bool image) {
    final source = (sourceRaw ?? '').trim();
    final license = (licenseRaw ?? '').trim();
    if (source.isEmpty && license.isEmpty) return;
    final key = '$image\n$source\n$license';
    if (!seen.add(key)) return;
    licenses.add((source: source, license: license, image: image));
  }

  for (final row in rows) {
    add(row.catalogSource, row.catalogLicense, false);
    add(row.imageSource, row.imageLicense, true);
  }
  licenses.sort((a, b) {
    if (a.image != b.image) return a.image ? 1 : -1;
    final source = a.source.toLowerCase().compareTo(b.source.toLowerCase());
    if (source != 0) return source;
    return a.license.toLowerCase().compareTo(b.license.toLowerCase());
  });
  return licenses;
}

String? _validate(Map<String, dynamic> json, String id) {
  if (!catalogIdPattern.hasMatch(id)) {
    return 'id "$id" must be a lowercase ascii kebab slug.';
  }
  if (_string(json['name_de']).isEmpty) return '$id is missing name_de.';
  for (final key in ['synonyme', 'ausfuehrung_de', 'tipps_de']) {
    final reason = _stringList(json, key, id);
    if (reason != null) return reason;
  }
  for (final key in ['primaermuskeln', 'sekundaermuskeln']) {
    final reason = _muscleList(json, key, id);
    if (reason != null) return reason;
  }
  if (json.containsKey('legacy_names')) {
    final reason = _stringList(json, 'legacy_names', id);
    if (reason != null) return reason;
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
  for (final key in ['bild_quelle', 'bild_lizenz']) {
    final value = json[key];
    if (json.containsKey(key) && value != null && value is! String) {
      return '$id field $key must be a string.';
    }
  }
  final alternatives = _alternatives(json, id);
  if (alternatives != null) return alternatives;
  final shoulderRisk = _shoulderRisk(json, id);
  if (shoulderRisk != null) return shoulderRisk;
  final category = _string(json['kategorie']);
  if (!allowedExerciseCategories.contains(category)) {
    return '$id kategorie "$category" is not allowed.';
  }
  final split = _string(json['split']);
  if (!allowedExerciseSplits.contains(split)) {
    return '$id split "$split" is not allowed.';
  }
  final mechanic = _string(json['mechanik']);
  if (!allowedExerciseMechanics.contains(mechanic)) {
    return '$id mechanik "$mechanic" is not allowed.';
  }
  final gear = _string(json['geraet']);
  if (!exerciseGearValues.contains(gear)) {
    return '$id geraet "$gear" is not allowed.';
  }
  final bild = _string(json['bild']);
  if (bild != '$id.webp') {
    return '$id bild must be the file name $id.webp.';
  }
  return null;
}

String? _stringList(Map<String, dynamic> json, String key, String id) {
  final value = json[key];
  if (value is! List) return '$id field $key must be a list.';
  for (final item in value) {
    if (item is! String) return '$id field $key must contain strings.';
  }
  return null;
}

String? _muscleList(Map<String, dynamic> json, String key, String id) {
  final value = json[key];
  if (value is! List) return '$id field $key must be a list.';
  for (final item in value) {
    if (item is! String || !exerciseMuscleKeys.contains(item.trim())) {
      return '$id field $key must use a muscle map key.';
    }
  }
  return null;
}

String? _shoulderRisk(Map<String, dynamic> json, String id) {
  if (!json.containsKey('schulter_risiko')) return null;
  final value = json['schulter_risiko'];
  if (value == null) return null;
  if (value is! String || !allowedShoulderRisk.contains(value.trim())) {
    return '$id schulter_risiko is not allowed.';
  }
  return null;
}

String? _alternatives(Map<String, dynamic> json, String id) {
  if (!json.containsKey('alternativen')) return null;
  final value = json['alternativen'];
  if (value is! List) return '$id field alternativen must be a list.';
  for (final item in value) {
    if (item is! String || !catalogIdPattern.hasMatch(item.trim())) {
      return '$id field alternativen must list exercise ids.';
    }
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

  String get aliases {
    final seen = <String>{};
    final parts = <String>[];
    for (final name in [...entry.synonyms, ...entry.legacyNames]) {
      final trimmed = name.trim();
      final key = trimmed.toLowerCase();
      if (key.isEmpty || !seen.add(key)) continue;
      parts.add(trimmed);
    }
    return parts.join('|');
  }

  String get primary => jsonEncode(entry.primaryMuscles);
  String get secondary => jsonEncode(entry.secondaryMuscles);
  String get steps => jsonEncode(entry.steps);
  String get tips => jsonEncode(entry.tips);
  String get alternatives => jsonEncode(entry.alternatives);
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
      imageSource: Value(entry.imageSource),
      imageLicense: Value(entry.imageLicense),
      alternatives: Value(alternatives),
      schulterRisiko: Value(
        entry.shoulderRisk.isEmpty ? null : entry.shoulderRisk,
      ),
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
      imageSource: Value(entry.imageSource),
      imageLicense: Value(entry.imageLicense),
      alternatives: Value(alternatives),
      schulterRisiko: Value(
        entry.shoulderRisk.isEmpty ? null : entry.shoulderRisk,
      ),
    );
  }
}

_Fields _companion(ExerciseDeEntry entry, int? categoryId) =>
    _Fields(entry, categoryId);

ExerciseDeEntry _attachLegacyNames(ExerciseDeEntry entry, List<String>? extra) {
  if (extra == null || extra.isEmpty) return entry;
  return entry.copyWith(
    legacyNames: _uniqueNames([...entry.legacyNames, ...extra]),
  );
}

List<String> _uniqueNames(Iterable<String> names) {
  final seen = <String>{};
  final result = <String>[];
  for (final name in names) {
    final trimmed = name.trim();
    final key = trimmed.toLowerCase();
    if (key.isEmpty || !seen.add(key)) continue;
    result.add(trimmed);
  }
  return result;
}

bool _claimable(Exercise row, String catalogId) {
  final current = row.catalogId ?? '';
  return current.isEmpty || current == catalogId;
}

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
      row.catalogLicense == entry.license &&
      row.imageSource == entry.imageSource &&
      row.imageLicense == entry.imageLicense &&
      row.alternatives == fields.alternatives &&
      (row.schulterRisiko ?? '') == entry.shoulderRisk;
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
