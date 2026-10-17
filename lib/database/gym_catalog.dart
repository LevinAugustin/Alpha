import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flexify/database/catalog_seed.dart';
import 'package:flexify/database/database.dart';
import 'package:flutter/services.dart';

class GymInfo {
  GymInfo({
    required this.name,
    required this.germanName,
    required this.muscle,
    required this.detailMuscle,
    required this.equipment,
    required this.secondary,
    required this.aliases,
    required this.steps,
    required this.image,
    required this.cardio,
  });

  final String name;
  final String germanName;
  final String muscle;
  final String detailMuscle;
  final String equipment;
  final String secondary;
  final String aliases;
  final String steps;
  final String? image;
  final bool cardio;

  factory GymInfo.fromJson(Map<String, dynamic> json) => GymInfo(
    name: json['n'] as String,
    germanName: json['g'] as String,
    muscle: json['m'] as String,
    detailMuscle: json['d'] as String? ?? '',
    equipment: json['e'] as String? ?? '',
    secondary: json['s'] as String? ?? '',
    aliases: json['a'] as String? ?? '',
    steps: json['t'] as String? ?? '',
    image: json['i'] as String?,
    cardio: json['c'] as bool? ?? false,
  );
}

Map<String, GymInfo>? _byKey;

Future<Map<String, GymInfo>> gymCatalogByKey() async {
  final cached = _byKey;
  if (cached != null) return cached;
  final raw = await rootBundle.loadString('assets/gym_catalog.json');
  final rows = jsonDecode(raw) as List;
  final map = <String, GymInfo>{};
  for (final row in rows) {
    final info = GymInfo.fromJson(Map<String, dynamic>.from(row as Map));
    map[normalizeExerciseKey(info.name)] = info;
  }
  _byKey = map;
  return map;
}

GymInfo? gymInfoFor(String name) => _byKey?[normalizeExerciseKey(name)];

Future<void> applyGymCatalog(AppDatabase database) async {
  final catalog = await gymCatalogByKey();
  final existing = await database.select(database.exercises).get();
  final byKey = <String, Exercise>{
    for (final exercise in existing)
      normalizeExerciseKey(exercise.name): exercise,
  };
  final categoryIds = {
    for (final category in await database.select(database.categories).get())
      category.name: category.id,
  };

  Future<int> categoryIdFor(String name) async {
    final known = categoryIds[name];
    if (known != null) return known;
    await database
        .into(database.categories)
        .insert(
          CategoriesCompanion.insert(name: name),
          mode: InsertMode.insertOrIgnore,
        );
    final id = (await (database.select(
      database.categories,
    )..where((row) => row.name.equals(name))).getSingle()).id;
    categoryIds[name] = id;
    return id;
  }

  await database.transaction(() async {
    for (final info in catalog.values) {
      final current = byKey[normalizeExerciseKey(info.name)];
      final aliases = _mergeAliases(current?.aliases, info.aliases);
      final image = (current?.image ?? '').isEmpty
          ? info.image
          : current!.image;
      if (current == null) {
        await database
            .into(database.exercises)
            .insert(
              ExercisesCompanion.insert(
                name: info.name,
                kind: info.cardio ? 'cardio' : 'strength',
                displayUnit: info.cardio ? 'km' : 'kg',
                categoryId: Value(await categoryIdFor(info.muscle)),
                germanName: Value(info.germanName),
                aliases: Value(aliases),
                muscle: Value(info.muscle),
                notes: Value(info.steps),
                image: Value(image),
              ),
              mode: InsertMode.insertOrIgnore,
            );
        continue;
      }
      final notes = (current.notes ?? '').trim().isEmpty
          ? info.steps
          : current.notes;
      if (current.germanName == info.germanName &&
          current.aliases == aliases &&
          current.muscle == info.muscle &&
          current.notes == notes &&
          current.image == image) {
        continue;
      }
      await (database.update(
        database.exercises,
      )..where((row) => row.id.equals(current.id))).write(
        ExercisesCompanion(
          germanName: Value(info.germanName),
          aliases: Value(aliases),
          muscle: Value(info.muscle),
          notes: Value(notes),
          image: Value(image),
        ),
      );
    }
  });
}

String _mergeAliases(String? current, String extra) {
  final parts = <String>{
    for (final part in '${current ?? ''}|$extra'.split('|'))
      if (part.trim().isNotEmpty) part.trim(),
  };
  return parts.join('|');
}

const muscleGroups = [
  'Brust',
  'Rücken',
  'Schultern',
  'Beine',
  'Arme',
  'Bauch',
  'Cardio',
];

const equipmentFilters = [
  'Langhantel',
  'Kurzhantel',
  'Kabelzug',
  'Maschine',
  'Multipresse',
  'Körpergewicht',
];

bool matchesExerciseFilters({
  required String name,
  String? germanName,
  String? aliases,
  String? muscle,
  required String query,
  String group = '',
  String equipment = '',
  String split = '',
}) {
  final haystack = '$name ${germanName ?? ''} ${aliases ?? ''} ${muscle ?? ''}'
      .toLowerCase();
  if (group.isNotEmpty &&
      (muscle ?? '') != group &&
      !haystack.contains(group.toLowerCase())) {
    return false;
  }
  if (equipment.isNotEmpty && !haystack.contains(equipment.toLowerCase())) {
    return false;
  }
  if (split.isNotEmpty &&
      !haystack.contains('split:${split.toLowerCase()}') &&
      !haystack.contains(split.toLowerCase())) {
    return false;
  }
  return exerciseMatchesQuery(
    name: name,
    germanName: germanName,
    aliases: '$aliases ${muscle ?? ''}',
    query: query,
  );
}
