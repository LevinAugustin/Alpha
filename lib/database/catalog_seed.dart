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
  final words = needle
      .split(RegExp(r'\s+'))
      .where((word) => word.isNotEmpty)
      .toList();
  if (words.length == 1) {
    final mapped = movementSearch[words.single];
    if (mapped != null) {
      if ((movement ?? '').trim().toLowerCase() == mapped) return true;
      if (mapped == 'beine_huefte') {
        final categoryName = (category ?? '').trim().toLowerCase();
        final muscleName = (muscle ?? '').trim().toLowerCase();
        if (categoryName == 'beine' || muscleName == 'beine') return true;
      }
      return false;
    }
  }
  final primary = decodeCatalogList(primaryMuscles);
  final secondary = decodeCatalogList(secondaryMuscles);
  final haystack = foldExerciseSearch(
    [
      name,
      germanName ?? '',
      aliases ?? '',
      muscle ?? '',
      category ?? '',
      equipment ?? '',
      catalogText(mechanic) ?? '',
      primary.join(' '),
      secondary.join(' '),
      for (final key in [...primary, ...secondary])
        germanMuscleSearchLabel(key),
    ].join(' '),
  );
  final foldedWords = foldExerciseSearch(
    query,
  ).split(RegExp(r'\s+')).where((word) => word.isNotEmpty);
  return foldedWords.every((word) => _containsTerm(haystack, word));
}

String germanMuscleSearchLabel(String key) {
  return const {
        'brust': 'brust',
        'brust_oben': 'obere brust',
        'schulter_vorne': 'vordere schulter',
        'schulter_seitlich': 'seitliche schulter',
        'schulter_hinten': 'hintere schulter',
        'latissimus': 'latissimus',
        'oberer_ruecken': 'oberer ruecken',
        'trapez': 'trapez',
        'unterer_ruecken': 'unterer ruecken',
        'bizeps': 'bizeps',
        'unterarme': 'unterarme',
        'trizeps': 'trizeps',
        'bauch_gerade': 'gerader bauch',
        'bauch_schraeg': 'schraeger bauch',
        'quadrizeps': 'quadrizeps',
        'beinbeuger': 'beinbeuger',
        'gesaess': 'gesaess',
        'adduktoren': 'adduktoren',
        'abduktoren': 'abduktoren',
        'waden': 'waden',
        'hueftbeuger': 'hueftbeuger',
      }[key] ??
      key;
}

String exerciseDisplayName(String name, String? germanName) {
  final german = (germanName ?? '').trim();
  return german.isEmpty ? name : german;
}

int? exerciseSearchRank({
  required String name,
  String? germanName,
  String? aliases,
  required String query,
}) {
  final needle = foldExerciseSearch(query);
  if (needle.isEmpty) return null;
  var best = _rankText(
    exerciseDisplayName(name, germanName),
    needle,
    nameField: true,
  );
  for (final synonym in decodeCatalogList(aliases)) {
    final rank = _rankText(synonym, needle, nameField: false);
    if (rank == null) continue;
    if (best == null || rank < best) best = rank;
  }
  return best;
}

int compareExerciseSearch({
  required String query,
  required String leftName,
  String? leftGermanName,
  String? leftAliases,
  required String rightName,
  String? rightGermanName,
  String? rightAliases,
}) {
  final left = _searchOrder(query, leftName, leftGermanName, leftAliases);
  final right = _searchOrder(query, rightName, rightGermanName, rightAliases);
  final byRank = left.rank.compareTo(right.rank);
  if (byRank != 0) return byRank;
  if (left.matched && right.matched) {
    final byLength = left.length.compareTo(right.length);
    if (byLength != 0) return byLength;
  }
  return left.alpha.compareTo(right.alpha);
}

String foldExerciseSearch(String value) {
  final buffer = StringBuffer();
  for (final rune in value.trim().toLowerCase().runes) {
    buffer.write(_foldedLetters[rune] ?? String.fromCharCode(rune));
  }
  return buffer
      .toString()
      .replaceAll('ae', 'a')
      .replaceAll('oe', 'o')
      .replaceAll('ue', 'u');
}

({int rank, bool matched, int length, String alpha}) _searchOrder(
  String query,
  String name,
  String? germanName,
  String? aliases,
) {
  final label = foldExerciseSearch(exerciseDisplayName(name, germanName));
  final rank = exerciseSearchRank(
    name: name,
    germanName: germanName,
    aliases: aliases,
    query: query,
  );
  return (
    rank: rank ?? 7,
    matched: rank != null,
    length: label.length,
    alpha: label,
  );
}

int? _rankText(String text, String needle, {required bool nameField}) {
  final folded = foldExerciseSearch(text);
  if (folded.isEmpty || needle.isEmpty) return null;
  if (folded == needle) return nameField ? 1 : 2;
  if (folded.startsWith(needle)) return nameField ? 3 : 4;
  if (RegExp('(?<![0-9a-z])${RegExp.escape(needle)}').hasMatch(folded)) {
    return 5;
  }
  if (folded.contains(needle)) return 6;
  return null;
}

const _foldedLetters = <int, String>{
  0xe0: 'a',
  0xe1: 'a',
  0xe2: 'a',
  0xe3: 'a',
  0xe4: 'a',
  0xe5: 'a',
  0xe6: 'ae',
  0xe7: 'c',
  0xe8: 'e',
  0xe9: 'e',
  0xea: 'e',
  0xeb: 'e',
  0xec: 'i',
  0xed: 'i',
  0xee: 'i',
  0xef: 'i',
  0xf1: 'n',
  0xf2: 'o',
  0xf3: 'o',
  0xf4: 'o',
  0xf5: 'o',
  0xf6: 'o',
  0xf8: 'o',
  0xf9: 'u',
  0xfa: 'u',
  0xfb: 'u',
  0xfc: 'u',
  0xfd: 'y',
  0xff: 'y',
  0xdf: 'ss',
};

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
