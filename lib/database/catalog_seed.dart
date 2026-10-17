import 'dart:convert';

const searchPrimaryHelp = <String, Set<String>>{
  'push': {
    'brust',
    'brust_oben',
    'schulter_vorne',
    'schulter_seitlich',
    'trizeps',
  },
  'pull': {
    'latissimus',
    'oberer_ruecken',
    'schulter_hinten',
    'bizeps',
    'trapez',
    'unterarme',
    'unterer_ruecken',
  },
  'beine': {
    'quadrizeps',
    'beinbeuger',
    'gesaess',
    'adduktoren',
    'abduktoren',
    'waden',
    'hueftbeuger',
  },
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
  required String query,
}) {
  final needle = query.trim().toLowerCase();
  if (needle.isEmpty) return true;
  final help = searchPrimaryHelp[needle];
  if (help != null) {
    final primary = decodeCatalogList(
      primaryMuscles,
    ).map((key) => key.toLowerCase());
    if (primary.any(help.contains)) return true;
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
  required String query,
  String group = '',
  String equipmentFilter = '',
  String mechanicFilter = '',
  String gripFilter = '',
  String positionFilter = '',
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
    query: query,
  );
}

bool _containsTerm(String haystack, String word) {
  if (word.length >= 5) return haystack.contains(word);
  return RegExp('\\b${RegExp.escape(word)}\\b').hasMatch(haystack);
}
