import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flexify/database/database.dart';
import 'package:flexify/exercise_keys.dart';
import 'package:flexify/exercises/custom_exercise.dart';
import 'package:flexify/exercises/uebung_assets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

const exerciseCatalogAsset = 'assets/exercises/exercises_de.json';
const exerciseLegacyMapAsset = 'assets/exercises/legacy_map.json';
const exerciseFlexifyMapAsset = 'assets/exercises/flexify_mapping.json';
const exerciseFlexifyOhneZielAsset = 'assets/exercises/flexify_ohne_ziel.json';
const exerciseImageDirectory = 'assets/exercises/img';

const allowedExerciseMechanics = {'grund', 'isolation'};
const allowedExerciseCategories = {...exerciseCategories};
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
    required this.mechanic,
    required this.steps,
    required this.tips,
    required this.image,
    required this.source,
    required this.license,
    required this.imageSource,
    required this.imageLicense,
    required this.alternatives,
    required this.legacyNames,
    required this.family,
    required this.movement,
    required this.grip,
    required this.position,
    required this.unilateral,
    this.englishName,
    this.englishSteps = const [],
    this.englishTips = const [],
    this.englishSynonyms = const [],
    this.variantsJson,
  });

  final String id;
  final String nameDe;
  final List<String> synonyms;
  final String category;
  final List<String> primaryMuscles;
  final List<String> secondaryMuscles;
  final String equipment;
  final String mechanic;
  final List<String> steps;
  final List<String> tips;
  final String image;
  final String source;
  final String license;
  final String imageSource;
  final String imageLicense;
  final List<String> alternatives;
  final List<String> legacyNames;
  final String family;
  final String movement;
  final String grip;
  final String position;
  final bool unilateral;
  final String? englishName;
  final List<String> englishSteps;
  final List<String> englishTips;
  final List<String> englishSynonyms;
  final String? variantsJson;

  ExerciseDeEntry copyWith({List<String>? legacyNames}) {
    return ExerciseDeEntry(
      id: id,
      nameDe: nameDe,
      synonyms: synonyms,
      category: category,
      primaryMuscles: primaryMuscles,
      secondaryMuscles: secondaryMuscles,
      equipment: equipment,
      mechanic: mechanic,
      steps: steps,
      tips: tips,
      image: image,
      source: source,
      license: license,
      imageSource: imageSource,
      imageLicense: imageLicense,
      alternatives: alternatives,
      legacyNames: legacyNames ?? this.legacyNames,
      family: family,
      movement: movement,
      grip: grip,
      position: position,
      unilateral: unilateral,
      englishName: englishName,
      englishSteps: englishSteps,
      englishTips: englishTips,
      englishSynonyms: englishSynonyms,
      variantsJson: variantsJson,
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

final bundledExerciseImages = <String>{};

Future<void> refreshBundledExerciseImages() async {
  bundledExerciseImages.clear();
  if (Platform.environment.containsKey('FLUTTER_TEST')) return;
  try {
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    for (final asset in manifest.listAssets()) {
      if (asset.startsWith('$exerciseImageDirectory/') &&
          asset.endsWith('.webp')) {
        bundledExerciseImages.add(asset);
      }
    }
  } catch (_) {}
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
        mechanic: _string(json['mechanik']),
        steps: _strings(json['ausfuehrung_de']),
        tips: _strings(json['tipps_de']),
        image: _string(json['bild']),
        source: _string(json['quelle']),
        license: _string(json['lizenz']),
        imageSource: _string(json['bild_quelle']),
        imageLicense: _string(json['bild_lizenz']),
        alternatives: _strings(json['alternativen']),
        legacyNames: _strings(json['legacy_names']),
        family: _string(json['familie']),
        movement: _string(json['bewegung']),
        grip: _string(json['griff']),
        position: _string(json['position']),
        unilateral: json['einseitig'] == true,
        englishName: _optionalStoredText(json['name_en']),
        englishSteps: _strings(json['ausfuehrung_en']),
        englishTips: _strings(json['tipps_en']),
        englishSynonyms: _strings(json['synonyme_en']),
        variantsJson: _variantsJson(json['varianten']),
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
  await loadUebungAssets();
  await refreshBundledExerciseImages();
  final raw = await rootBundle.loadString(exerciseCatalogAsset);
  String? flexifyMapRaw;
  try {
    flexifyMapRaw = await rootBundle.loadString(exerciseFlexifyMapAsset);
  } catch (error) {
    debugPrint('Exercise flexify map was not loaded: $error');
  }
  String? ohneZielRaw;
  try {
    ohneZielRaw = await rootBundle.loadString(exerciseFlexifyOhneZielAsset);
  } catch (_) {}
  return importExerciseCatalogJson(
    database,
    raw,
    flexifyMapRaw: flexifyMapRaw,
    ohneZielRaw: ohneZielRaw,
  );
}

String normalizedExerciseName(String name) {
  return name
      .trim()
      .toLowerCase()
      .replaceAll("\\'", "'")
      .replaceAll('\u2018', "'")
      .replaceAll('\u2019', "'")
      .replaceAll('\u02BC', "'");
}

Map<String, List<String>> parseFlexifyMapping(String raw) {
  Object? decoded;
  try {
    decoded = jsonDecode(raw);
  } catch (error) {
    debugPrint('Exercise flexify map was ignored: $error');
    return const {};
  }
  if (decoded is! Map) return const {};
  final names = <String, List<String>>{};
  for (final entry in decoded.entries) {
    final id = entry.key;
    if (id is! String || !catalogIdPattern.hasMatch(id)) continue;
    final value = entry.value;
    if (value is! Map) continue;
    final list = value['seed_namen'];
    if (list is! List) continue;
    final legacy = <String>[];
    final seen = <String>{};
    for (final item in list) {
      if (item is! String) continue;
      final trimmed = item.trim();
      if (trimmed.isEmpty || !seen.add(normalizedExerciseName(trimmed))) {
        continue;
      }
      legacy.add(trimmed);
    }
    if (legacy.isEmpty) continue;
    names[id] = legacy;
  }
  return names;
}

Map<String, String> parseFlexifySuggestions(String? raw) {
  if (raw == null || raw.trim().isEmpty) return const {};
  Object? decoded;
  try {
    decoded = jsonDecode(raw);
  } catch (error) {
    debugPrint('Exercise flexify suggestions were ignored: $error');
    return const {};
  }
  if (decoded is! Map) return const {};
  final names = <String, String>{};
  for (final entry in decoded.entries) {
    final id = entry.key;
    if (id is! String || !catalogIdPattern.hasMatch(id)) continue;
    final value = entry.value;
    if (value is! Map) continue;
    final list = value['aussortiert_naechste_entsprechung'];
    if (list is! List) continue;
    for (final item in list) {
      if (item is! String) continue;
      final key = normalizedExerciseName(item);
      if (key.isEmpty || names.containsKey(key)) continue;
      names[key] = id;
    }
  }
  return names;
}

Map<String, List<String>> _combineNameMaps(
  Iterable<Map<String, List<String>>> maps,
) {
  final names = <String, List<String>>{};
  for (final source in maps) {
    for (final entry in source.entries) {
      final current = names[entry.key] ?? <String>[];
      final seen = current.map(normalizedExerciseName).toSet();
      for (final name in entry.value) {
        if (seen.add(normalizedExerciseName(name))) current.add(name);
      }
      if (current.isNotEmpty) names[entry.key] = current;
    }
  }
  return names;
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

Set<String> parseFlexifyOhneZiel(String? raw) {
  if (raw == null || raw.trim().isEmpty) return const {};
  Object? decoded;
  try {
    decoded = jsonDecode(raw);
  } catch (error) {
    debugPrint('Exercise flexify ohne ziel was ignored: $error');
    return const {};
  }
  final items = decoded is List
      ? decoded
      : decoded is Map
      ? decoded['eintraege']
      : null;
  if (items is! List) return const {};
  final names = <String>{};
  for (final item in items) {
    final raw = item is String
        ? item
        : item is Map
        ? item['seed_name']
        : null;
    if (raw is! String) continue;
    final key = normalizedExerciseName(raw);
    if (key.isEmpty) continue;
    names.add(key);
  }
  return names;
}

class CatalogEnglishText {
  const CatalogEnglishText({
    this.category,
    this.equipment,
    this.position,
    this.grip,
  });

  final String? category;
  final String? equipment;
  final String? position;
  final String? grip;
}

final catalogEnglishById = <String, CatalogEnglishText>{};

Map<String, CatalogEnglishText> parseCatalogEnglishLabels(String raw) {
  Object? decoded;
  try {
    decoded = jsonDecode(raw);
  } catch (_) {
    return const {};
  }
  if (decoded is! List) return const {};
  final labels = <String, CatalogEnglishText>{};
  for (final row in decoded) {
    if (row is! Map) continue;
    final id = _string(row['id']);
    if (id.isEmpty) continue;
    final category = _optionalStoredText(row['kategorie_en']);
    final equipment = _optionalStoredText(row['geraet_en']);
    final position = _optionalStoredText(row['position_en']);
    final grip = _optionalStoredText(row['griff_en']);
    if (category == null &&
        equipment == null &&
        position == null &&
        grip == null) {
      continue;
    }
    labels[id] = CatalogEnglishText(
      category: category,
      equipment: equipment,
      position: position,
      grip: grip,
    );
  }
  return labels;
}

void rememberCatalogEnglishLabels(String raw) {
  catalogEnglishById
    ..clear()
    ..addAll(parseCatalogEnglishLabels(raw));
}

Future<ExerciseImportResult> importExerciseCatalogJson(
  AppDatabase database,
  String raw, {
  String? legacyMapRaw,
  String? flexifyMapRaw,
  String? ohneZielRaw,
}) async {
  rememberCatalogEnglishLabels(raw);
  final parsed = parseExerciseCatalog(raw);
  final legacyMap = _combineNameMaps([
    if (legacyMapRaw != null) parseLegacyNameMap(legacyMapRaw),
    if (flexifyMapRaw != null) parseFlexifyMapping(flexifyMapRaw),
  ]);
  final entries = [
    for (final entry in parsed.entries)
      _attachLegacyNames(entry, legacyMap[entry.id]),
  ];
  final existing = await database.select(database.exercises).get();
  final byCatalog = <String, Exercise>{
    for (final exercise in existing)
      if ((exercise.catalogId ?? '').isNotEmpty) exercise.catalogId!: exercise,
  };
  final ohneZiel = parseFlexifyOhneZiel(ohneZielRaw);
  final suggestions = parseFlexifySuggestions(flexifyMapRaw);
  final byName = <String, List<Exercise>>{};
  void remember(Exercise row) {
    final key = normalizedExerciseName(row.name);
    if (key.isEmpty) return;
    final rows = byName.putIfAbsent(key, () => <Exercise>[]);
    rows.removeWhere((item) => item.id == row.id);
    rows.add(row);
  }

  void forget(Exercise row) {
    final key = normalizedExerciseName(row.name);
    final rows = byName[key];
    if (rows == null) return;
    rows.removeWhere((item) => item.id == row.id);
    if (rows.isEmpty) byName.remove(key);
  }

  for (final exercise in existing) {
    remember(exercise);
  }
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
        final key = normalizedExerciseName(legacy);
        if (ohneZiel.contains(key)) continue;
        for (final row in byName[key] ?? const <Exercise>[]) {
          consider(row);
        }
      }

      final categoryId = await categoryIdFor(entry.category);
      final companion = _companion(entry, categoryId);
      if (matches.isEmpty) {
        final blocked =
            (byName[normalizedExerciseName(entry.id)] ?? const <Exercise>[])
                .any((row) => row.name == entry.id);
        if (blocked) continue;
        final id = await database
            .into(database.exercises)
            .insert(companion.insert(name: entry.id));
        final created = await (database.select(
          database.exercises,
        )..where((row) => row.id.equals(id))).getSingle();
        byCatalog[entry.id] = created;
        remember(created);
        inserted++;
        continue;
      }

      Exercise? smallestLegacy;
      for (final legacy in entry.legacyNames) {
        final key = normalizedExerciseName(legacy);
        if (ohneZiel.contains(key)) continue;
        for (final found in byName[key] ?? const <Exercise>[]) {
          if (!matches.containsKey(found.id)) continue;
          final current = smallestLegacy;
          if (current == null || found.id < current.id) smallestLegacy = found;
        }
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
        forget(duplicate);
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
      remember(refreshed);
      updated++;
    }
    await _keepTrainedCustomExercises(database, {
      ...ohneZiel,
      ...suggestions.keys,
    }, suggestions);
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
  if (id.startsWith('eigen-')) {
    return 'id "$id" is reserved for custom exercises.';
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
  for (final key in ['kategorie', 'geraet', 'bild', 'quelle', 'lizenz']) {
    if (json[key] is! String) return '$id field $key must be a string.';
  }
  final mechanic = _mechanic(json, id);
  if (mechanic != null) return mechanic;
  for (final key in ['bild_quelle', 'bild_lizenz']) {
    final value = json[key];
    if (json.containsKey(key) && value != null && value is! String) {
      return '$id field $key must be a string.';
    }
  }
  final alternatives = _alternatives(json, id);
  if (alternatives != null) return alternatives;
  final family = _family(json, id);
  if (family != null) return family;
  final movement = _movement(json, id);
  if (movement != null) return movement;
  final grip = _optionalToken(json, 'griff', id, exerciseGripValues);
  if (grip != null) return grip;
  final position = _optionalToken(json, 'position', id, exercisePositionValues);
  if (position != null) return position;
  final unilateral = _unilateral(json, id);
  if (unilateral != null) return unilateral;
  final englishName = _optionalText(json, 'name_en', id);
  if (englishName != null) return englishName;
  for (final key in ['ausfuehrung_en', 'tipps_en', 'synonyme_en']) {
    final reason = _optionalStringList(json, key, id);
    if (reason != null) return reason;
  }
  final variants = _variants(json, id);
  if (variants != null) return variants;
  final category = _string(json['kategorie']);
  if (!allowedExerciseCategories.contains(category)) {
    return '$id kategorie "$category" is not allowed.';
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

String? _family(Map<String, dynamic> json, String id) {
  final value = json['familie'];
  if (value is! String || !catalogIdPattern.hasMatch(value.trim())) {
    return '$id familie is not a family id.';
  }
  return null;
}

String? _movement(Map<String, dynamic> json, String id) {
  final value = json['bewegung'];
  if (value is! String || !exerciseMotionValues.contains(value.trim())) {
    return '$id bewegung is not allowed.';
  }
  return null;
}

String? _optionalToken(
  Map<String, dynamic> json,
  String key,
  String id,
  Iterable<String> allowed,
) {
  if (!json.containsKey(key) || json[key] == null) return null;
  final value = json[key];
  if (value is String && value.trim().isEmpty) return null;
  if (value is! String || !allowed.contains(value.trim())) {
    return '$id $key is not allowed.';
  }
  return null;
}

String? _optionalText(Map<String, dynamic> json, String key, String id) {
  if (!json.containsKey(key) || json[key] == null) return null;
  if (json[key] is! String || _string(json[key]).isEmpty) {
    return '$id field $key must be a string.';
  }
  return null;
}

String? _optionalStringList(Map<String, dynamic> json, String key, String id) {
  if (!json.containsKey(key) || json[key] == null) return null;
  return _stringList(json, key, id);
}

String? _variants(Map<String, dynamic> json, String id) {
  if (!json.containsKey('varianten') || json['varianten'] == null) return null;
  final value = json['varianten'];
  if (value is! List) return '$id field varianten must be a list.';
  final seen = <String>{};
  for (final item in value) {
    if (item is! Map) return '$id varianten must contain objects.';
    final row = Map<String, dynamic>.from(item);
    final key = _string(row['key']);
    if (key.isEmpty || !seen.add(key)) {
      return '$id varianten key is missing.';
    }
    for (final field in ['label_de', 'label_en', 'bild']) {
      if (row[field] is! String || _string(row[field]).isEmpty) {
        return '$id varianten $field must be a string.';
      }
    }
    for (final field in [
      'ausfuehrung_de',
      'tipps_de',
      'ausfuehrung_en',
      'tipps_en',
    ]) {
      final reason = _stringList(row, field, '$id varianten');
      if (reason != null) return reason;
    }
    if (resolveExerciseImage(_string(row['bild'])) == null) {
      return '$id varianten bild is not a clip name.';
    }
    if (row['bild_gerendert'] is! bool) {
      return '$id varianten bild_gerendert must be true or false.';
    }
  }
  return null;
}

String? _optionalStoredText(Object? value) {
  final text = _string(value);
  return text.isEmpty ? null : text;
}

String? _variantsJson(Object? value) {
  if (value is! List || value.isEmpty) return null;
  return jsonEncode(value);
}

String? _unilateral(Map<String, dynamic> json, String id) {
  if (json['einseitig'] is! bool) {
    return '$id einseitig must be true or false.';
  }
  return null;
}

String? _mechanic(Map<String, dynamic> json, String id) {
  if (!json.containsKey('mechanik') || json['mechanik'] == null) return null;
  final value = json['mechanik'];
  if (value is String && value.trim().isEmpty) return null;
  if (value is! String || !allowedExerciseMechanics.contains(value.trim())) {
    return '$id mechanik is not allowed.';
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
      final key = normalizedExerciseName(trimmed);
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
  String? get mechanic => entry.mechanic.isEmpty ? null : entry.mechanic;
  String? get englishSteps =>
      entry.englishSteps.isEmpty ? null : jsonEncode(entry.englishSteps);
  String? get englishTips =>
      entry.englishTips.isEmpty ? null : jsonEncode(entry.englishTips);
  String? get englishAliases =>
      entry.englishSynonyms.isEmpty ? null : jsonEncode(entry.englishSynonyms);
  String? get variants => entry.variantsJson;

  ExercisesCompanion insert({required String name}) {
    final cardio = entry.category == 'Cardio';
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
      mechanic: Value(mechanic),
      steps: Value(steps),
      tips: Value(tips),
      catalogSource: Value(entry.source),
      catalogLicense: Value(entry.license),
      imageSource: Value(entry.imageSource),
      imageLicense: Value(entry.imageLicense),
      alternatives: Value(alternatives),
      familie: Value(entry.family.isEmpty ? null : entry.family),
      bewegung: Value(entry.movement),
      griff: Value(entry.grip.isEmpty ? null : entry.grip),
      position: Value(entry.position.isEmpty ? null : entry.position),
      einseitig: Value(entry.unilateral),
      englishName: Value(entry.englishName),
      englishSteps: Value(englishSteps),
      englishTips: Value(englishTips),
      englishAliases: Value(englishAliases),
      variants: Value(variants),
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
      mechanic: Value(mechanic),
      steps: Value(steps),
      tips: Value(tips),
      catalogSource: Value(entry.source),
      catalogLicense: Value(entry.license),
      imageSource: Value(entry.imageSource),
      imageLicense: Value(entry.imageLicense),
      alternatives: Value(alternatives),
      familie: Value(entry.family.isEmpty ? null : entry.family),
      bewegung: Value(entry.movement),
      griff: Value(entry.grip.isEmpty ? null : entry.grip),
      position: Value(entry.position.isEmpty ? null : entry.position),
      einseitig: Value(entry.unilateral),
      englishName: Value(entry.englishName),
      englishSteps: Value(englishSteps),
      englishTips: Value(englishTips),
      englishAliases: Value(englishAliases),
      variants: Value(variants),
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
    final key = normalizedExerciseName(trimmed);
    if (key.isEmpty || !seen.add(key)) continue;
    result.add(trimmed);
  }
  return result;
}

Future<void> _keepTrainedCustomExercises(
  AppDatabase database,
  Set<String> names,
  Map<String, String> suggestions,
) async {
  if (names.isEmpty) return;
  final trained = <int>{
    for (final set in await database.select(database.exerciseSets).get())
      set.exerciseId,
  };
  if (trained.isEmpty) return;
  final rows = await database.select(database.exercises).get();
  rows.sort((left, right) => left.id.compareTo(right.id));
  for (final row in rows) {
    if (!trained.contains(row.id)) continue;
    if ((row.catalogId ?? '').isNotEmpty) continue;
    final key = normalizedExerciseName(row.name);
    if (!names.contains(key)) continue;
    final catalogId = await uniqueCustomCatalogId(
      database,
      row.name,
      keepId: row.id,
    );
    final german = (row.germanName ?? '').trim();
    final source = (row.catalogSource ?? '').trim();
    final suggested = suggestions[key];
    final currentAlternatives = (row.alternatives ?? '').trim();
    final link =
        suggested != null &&
        (currentAlternatives.isEmpty || currentAlternatives == '[]');
    await (database.update(
      database.exercises,
    )..where((item) => item.id.equals(row.id))).write(
      ExercisesCompanion(
        catalogId: Value(catalogId),
        germanName: german.isEmpty ? Value(row.name) : const Value.absent(),
        catalogSource: source.isEmpty
            ? const Value('custom')
            : const Value.absent(),
        alternatives: link
            ? Value(jsonEncode([suggested]))
            : const Value.absent(),
      ),
    );
  }
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
      (row.mechanic ?? '') == entry.mechanic &&
      row.steps == fields.steps &&
      row.tips == fields.tips &&
      row.image == fields.image &&
      row.catalogSource == entry.source &&
      row.catalogLicense == entry.license &&
      row.imageSource == entry.imageSource &&
      row.imageLicense == entry.imageLicense &&
      row.alternatives == fields.alternatives &&
      (row.familie ?? '') == entry.family &&
      (row.bewegung ?? '') == entry.movement &&
      (row.griff ?? '') == entry.grip &&
      (row.position ?? '') == entry.position &&
      row.einseitig == entry.unilateral &&
      (row.englishName ?? '') == (entry.englishName ?? '') &&
      (row.englishSteps ?? '') == (fields.englishSteps ?? '') &&
      (row.englishTips ?? '') == (fields.englishTips ?? '') &&
      (row.englishAliases ?? '') == (fields.englishAliases ?? '') &&
      (row.variants ?? '') == (fields.variants ?? '');
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
      if (source.enabled) {
        await (database.update(
          database.planExercises,
        )..where((row) => row.id.equals(target.id))).write(
          PlanExercisesCompanion(
            enabled: const Value(true),
            sequence: Value(source.sequence),
            maxSets: Value(source.maxSets),
            warmupSets: Value(source.warmupSets),
            repMin: Value(source.repMin),
            repMax: Value(source.repMax),
            restMs: Value(source.restMs),
            timers: Value(source.timers),
          ),
        );
      }
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
