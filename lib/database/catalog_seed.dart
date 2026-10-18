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
  String? familie,
  String? grip,
  String? position,
  String? movement,
  required String query,
}) {
  final normalized = foldExerciseSearch(query);
  if (normalized.isEmpty) return true;
  final tokens = normalized.split(' ');
  if (tokens.length == 1) {
    final mapped = movementSearch[tokens.single];
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
  final haystack = exerciseSearchText(
    name: name,
    germanName: germanName,
    aliases: aliases,
    muscle: muscle,
    category: category,
    equipment: equipment,
    primaryMuscles: primaryMuscles,
    secondaryMuscles: secondaryMuscles,
    familie: familie,
    grip: grip,
    position: position,
  );
  return tokens.every((token) => exerciseSearchTokenMatches(haystack, token));
}

bool exerciseExactNameOrAlias({
  required String name,
  String? germanName,
  String? aliases,
  required String query,
}) {
  final needle = foldExerciseSearch(query);
  if (needle.isEmpty) return false;
  if (foldExerciseSearch(name) == needle) return true;
  if (foldExerciseSearch(germanName ?? '') == needle) return true;
  for (final alias in decodeCatalogList(aliases)) {
    if (foldExerciseSearch(alias) == needle) return true;
  }
  return false;
}

String exerciseSearchText({
  required String name,
  String? germanName,
  String? aliases,
  String? muscle,
  String? category,
  String? equipment,
  String? primaryMuscles,
  String? secondaryMuscles,
  String? familie,
  String? grip,
  String? position,
}) {
  final primary = decodeCatalogList(primaryMuscles);
  final secondary = decodeCatalogList(secondaryMuscles);
  final parts = <String>[
    name,
    germanName ?? '',
    for (final alias in decodeCatalogList(aliases)) alias,
    muscle ?? '',
    category ?? '',
    equipment ?? '',
    familie ?? '',
    for (final key in [...primary, ...secondary]) ...[
      key,
      germanMuscleSearchLabel(key),
    ],
    grip ?? '',
    if ((grip ?? '').isNotEmpty) germanGripSearchLabel(grip!),
    position ?? '',
    if ((position ?? '').isNotEmpty) germanPositionSearchLabel(position!),
  ];
  final text = [
    for (final part in parts)
      if (foldExerciseSearch(part).isNotEmpty) foldExerciseSearch(part),
  ].join(' ');
  return ' $text ';
}

bool exerciseSearchTokenMatches(String haystack, String token) {
  if (token.length <= 2) return haystack.contains(' $token');
  return haystack.contains(token);
}

String germanMuscleSearchLabel(String key) {
  return const {
        'brust': 'Brust',
        'brust_oben': 'obere Brust',
        'schulter_vorne': 'vordere Schulter',
        'schulter_seitlich': 'seitliche Schulter',
        'schulter_hinten': 'hintere Schulter',
        'latissimus': 'Latissimus',
        'oberer_ruecken': 'oberer Rücken',
        'trapez': 'Trapez/Nacken',
        'unterer_ruecken': 'unterer Rücken',
        'bizeps': 'Bizeps',
        'unterarme': 'Unterarme',
        'trizeps': 'Trizeps',
        'bauch_gerade': 'gerade Bauchmuskeln',
        'bauch_schraeg': 'schräge Bauchmuskeln',
        'quadrizeps': 'Quadrizeps',
        'beinbeuger': 'Beinbeuger',
        'gesaess': 'Gesäß',
        'adduktoren': 'Adduktoren',
        'abduktoren': 'Abduktoren',
        'waden': 'Waden',
        'hueftbeuger': 'Hüftbeuger',
      }[key] ??
      key;
}

String germanGripSearchLabel(String key) {
  return const {
        'eng': 'enger Griff',
        'breit': 'breiter Griff',
        'obergriff': 'Obergriff',
        'untergriff': 'Untergriff',
        'neutral': 'neutraler Griff',
      }[key] ??
      key;
}

String germanPositionSearchLabel(String key) {
  return const {
        'flach': 'flach',
        'schraeg': 'schräg',
        'negativ': 'negativ',
        'sitzend': 'sitzend',
        'stehend': 'stehend',
        'liegend': 'liegend',
        'vorgebeugt': 'vorgebeugt',
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
  final tokens = needle.split(' ');
  final label = foldExerciseSearch(exerciseDisplayName(name, germanName));
  final synonyms = [
    for (final synonym in decodeCatalogList(aliases))
      foldExerciseSearch(synonym),
  ].where((synonym) => synonym.isNotEmpty);
  if (label == needle) return 1;
  if (label.startsWith(needle)) return 2;
  if (synonyms.contains(needle)) return 3;
  final words = label.split(' ');
  if (tokens.every((token) => words.any((word) => word.startsWith(token)))) {
    return 4;
  }
  if (synonyms.any((synonym) => synonym.startsWith(needle))) return 5;
  if (label.isNotEmpty && tokens.every((token) => label.contains(token))) {
    return 6;
  }
  if (synonyms.any(
    (synonym) => tokens.every((token) => synonym.contains(token)),
  )) {
    return 7;
  }
  return 8;
}

bool isCatalogExercise({String? catalogId, String? catalogSource}) {
  final id = (catalogId ?? '').trim();
  if (id.isEmpty || id.startsWith('eigen-')) return false;
  if ((catalogSource ?? '').trim().toLowerCase() == 'custom') return false;
  return true;
}

int compareExerciseSearch({
  required String query,
  required String leftName,
  String? leftGermanName,
  String? leftAliases,
  required String rightName,
  String? rightGermanName,
  String? rightAliases,
  bool leftCatalog = true,
  bool rightCatalog = true,
}) {
  final left = _searchOrder(query, leftName, leftGermanName, leftAliases);
  final right = _searchOrder(query, rightName, rightGermanName, rightAliases);
  final byRank = left.rank.compareTo(right.rank);
  if (byRank != 0) return byRank;
  if (leftCatalog != rightCatalog) return leftCatalog ? -1 : 1;
  final byLength = left.length.compareTo(right.length);
  if (byLength != 0) return byLength;
  return left.alpha.compareTo(right.alpha);
}

String foldExerciseSearch(String value) {
  final buffer = StringBuffer();
  for (final rune in value.toLowerCase().runes) {
    final chunk = switch (rune) {
      0xe4 => 'ae',
      0xf6 => 'oe',
      0xfc => 'ue',
      0xdf => 'ss',
      _ => _foldedLetters[rune] ?? String.fromCharCode(rune),
    };
    for (final code in chunk.runes) {
      final isDigit = code >= 0x30 && code <= 0x39;
      final isLetter = code >= 0x61 && code <= 0x7a;
      buffer.writeCharCode(isDigit || isLetter ? code : 0x20);
    }
  }
  return buffer.toString().replaceAll(RegExp(r' +'), ' ').trim();
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
    rank: rank ?? 8,
    matched: rank != null,
    length: label.length,
    alpha: label,
  );
}

const _foldedLetters = <int, String>{
  0xe0: 'a',
  0xe1: 'a',
  0xe2: 'a',
  0xe3: 'a',
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
  0xf8: 'o',
  0xf9: 'u',
  0xfa: 'u',
  0xfb: 'u',
  0xfd: 'y',
  0xff: 'y',
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
  String? familie,
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
    familie: familie,
    grip: grip,
    position: position,
    movement: movement,
    query: query,
  );
}
