import 'dart:convert';

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
  String? split,
  String? primaryMuscles,
  String? secondaryMuscles,
  required String query,
}) {
  final needle = query.trim().toLowerCase();
  if (needle.isEmpty) return true;
  final haystack = [
    name,
    germanName ?? '',
    aliases ?? '',
    muscle ?? '',
    category ?? '',
    equipment ?? '',
    split ?? '',
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
  String? split,
  String? primaryMuscles,
  String? secondaryMuscles,
  required String query,
  String group = '',
  String equipmentFilter = '',
  String splitFilter = '',
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
  if (splitFilter.isNotEmpty &&
      (split ?? '').trim().toLowerCase() != splitFilter.toLowerCase()) {
    return false;
  }
  return exerciseMatchesQuery(
    name: name,
    germanName: germanName,
    aliases: aliases,
    muscle: muscle,
    category: category,
    equipment: equipment,
    split: split,
    primaryMuscles: primaryMuscles,
    secondaryMuscles: secondaryMuscles,
    query: query,
  );
}

bool _containsTerm(String haystack, String word) {
  if (word.length >= 5) return haystack.contains(word);
  return RegExp('\\b${RegExp.escape(word)}\\b').hasMatch(haystack);
}
