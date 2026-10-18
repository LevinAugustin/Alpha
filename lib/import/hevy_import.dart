import 'package:csv/csv.dart';

class ImportedSet {
  ImportedSet({
    required this.workoutTitle,
    required this.started,
    required this.ended,
    required this.exercise,
    required this.kg,
    required this.reps,
    required this.warmup,
    this.equipment = '',
  });

  final String workoutTitle;
  final DateTime started;
  final DateTime? ended;
  final String exercise;
  final double kg;
  final double reps;
  final bool warmup;
  final String equipment;
}

class ImportRowError {
  const ImportRowError({required this.line, required this.value});

  final int line;
  final String value;
}

String? hevyEquipmentGear(String raw) {
  final key = raw
      .trim()
      .toLowerCase()
      .replaceAll('ä', 'ae')
      .replaceAll('ö', 'oe')
      .replaceAll('ü', 'ue')
      .replaceAll('ß', 'ss')
      .replaceAll(RegExp(r'[^a-z0-9]+'), '');
  return const {
    'barbell': 'Langhantel',
    'langhantel': 'Langhantel',
    'dumbbell': 'Kurzhantel',
    'kurzhantel': 'Kurzhantel',
    'ezbar': 'SZ-Stange',
    'ezbarbell': 'SZ-Stange',
    'szstange': 'SZ-Stange',
    'cable': 'Kabelzug',
    'kabelzug': 'Kabelzug',
    'machine': 'Maschine',
    'maschine': 'Maschine',
    'smith': 'Multipresse',
    'smithmachine': 'Multipresse',
    'multipresse': 'Multipresse',
    'bodyweight': 'Körpergewicht',
    'koerpergewicht': 'Körpergewicht',
    'kettlebell': 'Kettlebell',
    'band': 'Widerstandsband',
    'resistanceband': 'Widerstandsband',
    'widerstandsband': 'Widerstandsband',
    'cardio': 'Cardiogerät',
    'cardiomachine': 'Cardiogerät',
    'cardiogeraet': 'Cardiogerät',
    'plate': 'Hantelscheibe',
    'plates': 'Hantelscheibe',
    'weightplate': 'Hantelscheibe',
    'scheibe': 'Hantelscheibe',
    'scheiben': 'Hantelscheibe',
    'hantelscheibe': 'Hantelscheibe',
    'abwheel': 'Bauchroller',
    'abroller': 'Bauchroller',
    'bauchroller': 'Bauchroller',
    'battlerope': 'Battle Rope',
    'battleropes': 'Battle Rope',
    'sled': 'Schlitten',
    'schlitten': 'Schlitten',
    'jumprope': 'Springseil',
    'jumpropes': 'Springseil',
    'skippingrope': 'Springseil',
    'springseil': 'Springseil',
  }[key];
}

class ImportedTemplate {
  ImportedTemplate({
    required this.title,
    required this.exercises,
    required this.setCounts,
    required this.lastWeights,
  }) : originalTitle = title;

  final String originalTitle;
  String title;
  bool include = true;
  final List<String> exercises;
  final Map<String, int> setCounts;
  final Map<String, double> lastWeights;
}

class WorkoutImport {
  WorkoutImport({
    required this.sets,
    required this.templates,
    required this.unknown,
    this.errors = const [],
  });

  final List<ImportedSet> sets;
  final List<ImportedTemplate> templates;
  final List<String> unknown;
  final List<ImportRowError> errors;

  int get workoutCount => sets
      .map((set) => '${set.workoutTitle}|${set.started.toIso8601String()}')
      .toSet()
      .length;

  int get exerciseCount =>
      sets.map((set) => set.exercise.toLowerCase()).toSet().length;

  DateTime? get first => sets.isEmpty
      ? null
      : sets.map((set) => set.started).reduce((a, b) => a.isBefore(b) ? a : b);

  DateTime? get last => sets.isEmpty
      ? null
      : sets.map((set) => set.started).reduce((a, b) => a.isAfter(b) ? a : b);
}

const hevyTemplateLimit = 7;

WorkoutImport? parseWorkoutCsv(String raw) {
  final rows = csv.decode(raw.replaceAll('\r\n', '\n'));
  if (rows.isEmpty) return null;
  final header = rows.first
      .map((cell) => '${cell ?? ''}'.trim().toLowerCase())
      .toList();
  int? indexOf(List<String> names) {
    for (final name in names) {
      final index = header.indexOf(name);
      if (index >= 0) return index;
    }
    return null;
  }

  final title = indexOf(['title', 'workout', 'workout name', 'workout_name']);
  final start = indexOf(['start_time', 'start', 'date', 'started']);
  final end = indexOf(['end_time', 'end', 'ended']);
  final exercise = indexOf([
    'exercise_title',
    'exercise',
    'exercise name',
    'exercise_name',
  ]);
  final weight = indexOf(['weight_kg', 'weight', 'kg']);
  final reps = indexOf(['reps', 'repetitions']);
  final setType = indexOf(['set_type', 'type']);
  final equipment = indexOf([
    'equipment',
    'exercise_equipment',
    'gear',
    'geraet',
    'gerät',
  ]);
  if (title == null || exercise == null) return null;

  final sets = <ImportedSet>[];
  final errors = <ImportRowError>[];
  var line = 1;
  for (final row in rows.skip(1)) {
    line++;
    if (row.length <= exercise || row.length <= title) continue;
    final exerciseName = _cell(row, exercise);
    final workout = _cell(row, title);
    if (exerciseName.isEmpty || workout.isEmpty) continue;
    final startRaw = _cell(row, start);
    final started = parseImportDate(startRaw);
    if (started == null) {
      errors.add(ImportRowError(line: line, value: startRaw));
      continue;
    }
    sets.add(
      ImportedSet(
        workoutTitle: workout,
        started: started,
        ended: parseImportDate(_cell(row, end)),
        exercise: exerciseName,
        kg: double.tryParse(_cell(row, weight).replaceAll(',', '.')) ?? 0,
        reps: double.tryParse(_cell(row, reps).replaceAll(',', '.')) ?? 0,
        warmup: _cell(row, setType).toLowerCase().contains('warm'),
        equipment: _cell(row, equipment),
      ),
    );
  }
  if (sets.isEmpty && errors.isEmpty) return null;

  final grouped = <String, List<ImportedSet>>{};
  for (final set in sets) {
    grouped.putIfAbsent(set.workoutTitle, () => []).add(set);
  }
  final templates = <ImportedTemplate>[];
  for (final entry in grouped.entries) {
    final newest = entry.value
        .map((set) => set.started)
        .reduce((a, b) => a.isAfter(b) ? a : b);
    final session = entry.value.where((set) => set.started == newest).toList();
    final order = <String>[];
    final counts = <String, int>{};
    final weights = <String, double>{};
    for (final set in session) {
      if (!order.contains(set.exercise)) order.add(set.exercise);
      counts[set.exercise] = (counts[set.exercise] ?? 0) + 1;
      if (set.kg > 0 && !set.warmup) weights[set.exercise] = set.kg;
    }
    templates.add(
      ImportedTemplate(
        title: entry.key,
        exercises: order,
        setCounts: counts,
        lastWeights: weights,
      ),
    );
  }
  return WorkoutImport(
    sets: sets,
    templates: templates,
    unknown: const [],
    errors: errors,
  );
}

List<({DateTime at, double kg})> parseMeasurementCsv(String raw) {
  final rows = csv.decode(raw.replaceAll('\r\n', '\n'));
  if (rows.isEmpty) return const [];
  final header = rows.first
      .map((cell) => '${cell ?? ''}'.trim().toLowerCase())
      .toList();
  var dateIndex = header.indexWhere(
    (cell) => cell.contains('date') || cell.contains('datum'),
  );
  var weightIndex = header.indexWhere(
    (cell) =>
        cell.contains('weight') || cell.contains('gewicht') || cell == 'kg',
  );
  final hasHeader = dateIndex >= 0 || weightIndex >= 0;
  if (dateIndex < 0) dateIndex = 0;
  if (weightIndex < 0) weightIndex = header.length > 1 ? 1 : 0;
  final points = <({DateTime at, double kg})>[];
  for (final row in rows.skip(hasHeader ? 1 : 0)) {
    final at = parseImportDate(_cell(row, dateIndex));
    final kg = double.tryParse(_cell(row, weightIndex).replaceAll(',', '.'));
    if (at == null || kg == null || kg <= 0) continue;
    points.add((at: at, kg: kg));
  }
  return points;
}

String _cell(List<dynamic> row, int? index) {
  if (index == null || index < 0 || index >= row.length) return '';
  return '${row[index] ?? ''}'.trim();
}

const _monthNumbers = <String, int>{
  'januar': 1,
  'january': 1,
  'jan': 1,
  'februar': 2,
  'february': 2,
  'feb': 2,
  'marz': 3,
  'märz': 3,
  'mrz': 3,
  'march': 3,
  'mar': 3,
  'april': 4,
  'apr': 4,
  'mai': 5,
  'may': 5,
  'juni': 6,
  'june': 6,
  'jun': 6,
  'juli': 7,
  'july': 7,
  'jul': 7,
  'august': 8,
  'aug': 8,
  'september': 9,
  'sept': 9,
  'sep': 9,
  'oktober': 10,
  'october': 10,
  'okt': 10,
  'oct': 10,
  'november': 11,
  'nov': 11,
  'dezember': 12,
  'december': 12,
  'dez': 12,
  'dec': 12,
};

DateTime? parseImportDate(String raw) {
  final text = raw.trim();
  if (text.isEmpty) return null;
  final iso = DateTime.tryParse(text.replaceFirst(' ', 'T'));
  if (iso != null) return iso.isUtc ? iso.toLocal() : iso;

  final numeric = RegExp(
    r'^(\d{1,2})[./](\d{1,2})[./](\d{2,4})(?:[,\s]+(\d{1,2}):(\d{2}))?$',
  ).firstMatch(text);
  if (numeric != null) {
    return _localDate(
      _year(numeric.group(3)!),
      int.parse(numeric.group(2)!),
      int.parse(numeric.group(1)!),
      numeric.group(4),
      numeric.group(5),
    );
  }

  final named = RegExp(
    r'^(\d{1,2})\.?\s+([A-Za-zÄÖÜäöü.]+)\s+(\d{4})(?:[,\s]+(\d{1,2}):(\d{2}))?$',
  ).firstMatch(text);
  if (named == null) return null;
  final month =
      _monthNumbers[named.group(2)!.replaceAll('.', '').toLowerCase()];
  if (month == null) return null;
  return _localDate(
    int.parse(named.group(3)!),
    month,
    int.parse(named.group(1)!),
    named.group(4),
    named.group(5),
  );
}

int _year(String raw) {
  final year = int.parse(raw);
  return year < 100 ? 2000 + year : year;
}

DateTime? _localDate(
  int year,
  int month,
  int day,
  String? hour,
  String? minute,
) {
  if (month < 1 || month > 12 || day < 1 || day > 31) return null;
  return DateTime(
    year,
    month,
    day,
    hour == null ? 0 : int.parse(hour),
    minute == null ? 0 : int.parse(minute),
  );
}

String exportWorkoutCsv(List<ImportedSet> sets) {
  final rows = <List<String>>[
    [
      'title',
      'start_time',
      'end_time',
      'exercise_title',
      'set_type',
      'weight_kg',
      'reps',
    ],
    for (final set in sets)
      [
        set.workoutTitle,
        set.started.toIso8601String(),
        set.ended?.toIso8601String() ?? '',
        set.exercise,
        set.warmup ? 'warmup' : 'normal',
        set.kg.toString(),
        set.reps.toString(),
      ],
  ];
  return csv.encode(rows);
}
