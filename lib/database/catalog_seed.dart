import 'dart:convert';

const movementSearch = <String, String>{
  'push': 'druecken',
  'drücken': 'druecken',
  'druecken': 'druecken',
  'pull': 'ziehen',
  'ziehen': 'ziehen',
  'beine': 'beine_huefte',
};

String? catalogText(String? value) {
  final text = value?.trim() ?? '';
  if (text.isEmpty || text.toLowerCase() == 'null') return null;
  return text;
}

List<String> decodeCatalogList(String? raw) {
  final value = raw?.trim() ?? '';
  if (value.isEmpty) return const [];
  try {
    final decoded = jsonDecode(value);
    if (decoded is List) {
      return [
        for (final item in decoded)
          if (item is String && item.trim().isNotEmpty) item.trim(),
      ];
    }
  } catch (_) {}
  return [
    for (final part in value.split('|'))
      if (part.trim().isNotEmpty) part.trim(),
  ];
}

bool exerciseMatchesQuery({
  required String name,
  String? germanName,
  String? aliases,
  String? muscle,
  String? category,
  String? equipment,
  String? mechanic,
  String? primaryMuscles,
  String? secondaryMuscles,
  String? movement,
  required String query,
}) {
  final needle = query.trim().toLowerCase();
  if (needle.isEmpty) return true;
  final mapped = movementSearch[needle];
  if (mapped != null) {
    if ((movement ?? '').trim().toLowerCase() == mapped) return true;
    if (mapped == 'beine_huefte') {
      final categoryName = (category ?? '').trim().toLowerCase();
      final muscleName = (muscle ?? '').trim().toLowerCase();
      if (categoryName == 'beine' || muscleName == 'beine') return true;
    }
    return false;
  }
  final haystack = [
    name,
    germanName ?? '',
    aliases ?? '',
    muscle ?? '',
    category ?? '',
    equipment ?? '',
    catalogText(mechanic) ?? '',
    decodeCatalogList(primaryMuscles).join(' '),
    decodeCatalogList(secondaryMuscles).join(' '),
  ].join(' ').toLowerCase();
  return _containsTerm(haystack, needle);
}

bool matchesExerciseFilters({
  required String name,
  String? germanName,
  String? aliases,
  String? muscle,
  String? category,
  String? equipment,
  String? mechanic,
  String? primaryMuscles,
  String? secondaryMuscles,
  String? grip,
  String? position,
  String? movement,
  required String query,
  String group = '',
  String equipmentFilter = '',
  String mechanicFilter = '',
  String gripFilter = '',
  String positionFilter = '',
  String motionFilter = '',
}) {
  if (group.isNotEmpty) {
    final groups = <String>{
      if ((muscle ?? '').trim().isNotEmpty) muscle!.trim().toLowerCase(),
      if ((category ?? '').trim().isNotEmpty) category!.trim().toLowerCase(),
      for (final item in decodeCatalogList(primaryMuscles)) item.toLowerCase(),
      for (final item in decodeCatalogList(secondaryMuscles))
        item.toLowerCase(),
    };
    if (!groups.contains(group.toLowerCase())) return false;
  }
  if (equipmentFilter.isNotEmpty &&
      (equipment ?? '').trim().toLowerCase() != equipmentFilter.toLowerCase()) {
    return false;
  }
  if (mechanicFilter.isNotEmpty &&
      (catalogText(mechanic) ?? '').toLowerCase() !=
          mechanicFilter.toLowerCase()) {
    return false;
  }
  if (gripFilter.isNotEmpty &&
      (grip ?? '').trim().toLowerCase() != gripFilter.toLowerCase()) {
    return false;
  }
  if (positionFilter.isNotEmpty &&
      (position ?? '').trim().toLowerCase() != positionFilter.toLowerCase()) {
    return false;
  }
  if (motionFilter.isNotEmpty &&
      (movement ?? '').trim().toLowerCase() != motionFilter.toLowerCase()) {
    return false;
  }
  return exerciseMatchesQuery(
    name: name,
    germanName: germanName,
    aliases: aliases,
    muscle: muscle,
    category: category,
    equipment: equipment,
    mechanic: mechanic,
    primaryMuscles: primaryMuscles,
    secondaryMuscles: secondaryMuscles,
    movement: movement,
    query: query,
  );
}

bool _containsTerm(String haystack, String word) {
  if (word.length >= 5) return haystack.contains(word);
  return RegExp('\\b${RegExp.escape(word)}\\b').hasMatch(haystack);
}
