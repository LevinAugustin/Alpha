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
  });

  final String workoutTitle;
  final DateTime started;
  final DateTime? ended;
  final String exercise;
  final double kg;
  final double reps;
  final bool warmup;
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
  });

  final List<ImportedSet> sets;
  final List<ImportedTemplate> templates;
  final List<String> unknown;

  int get workoutCount =>
      sets.map((set) => '${set.workoutTitle}|${set.started}').toSet().length;

  int get exerciseCount =>
      sets.map((set) => set.exercise.toLowerCase()).toSet().length;

  DateTime? get first => sets.isEmpty
      ? null
      : sets.map((set) => set.started).reduce((a, b) => a.isBefore(b) ? a : b);

  DateTime? get last => sets.isEmpty
      ? null
      : sets.map((set) => set.started).reduce((a, b) => a.isAfter(b) ? a : b);
}

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
  if (title == null || exercise == null) return null;

  final sets = <ImportedSet>[];
  for (final row in rows.skip(1)) {
    if (row.length <= exercise || row.length <= title) continue;
    final exerciseName = _cell(row, exercise);
    final workout = _cell(row, title);
    if (exerciseName.isEmpty || workout.isEmpty) continue;
    final started = _date(_cell(row, start)) ?? DateTime.now();
    sets.add(
      ImportedSet(
        workoutTitle: workout,
        started: started,
        ended: _date(_cell(row, end)),
        exercise: exerciseName,
        kg: double.tryParse(_cell(row, weight).replaceAll(',', '.')) ?? 0,
        reps: double.tryParse(_cell(row, reps).replaceAll(',', '.')) ?? 0,
        warmup: _cell(row, setType).toLowerCase().contains('warm'),
      ),
    );
  }
  if (sets.isEmpty) return null;

  final grouped = <String, List<ImportedSet>>{};
  for (final set in sets) {
    grouped.putIfAbsent(set.workoutTitle, () => []).add(set);
  }
  final templates = <ImportedTemplate>[];
  for (final entry in grouped.entries) {
    final order = <String>[];
    final counts = <String, int>{};
    final weights = <String, double>{};
    for (final set in entry.value) {
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
  return WorkoutImport(sets: sets, templates: templates, unknown: const []);
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
    final at = _date(_cell(row, dateIndex));
    final kg = double.tryParse(_cell(row, weightIndex).replaceAll(',', '.'));
    if (at == null || kg == null) continue;
    points.add((at: at, kg: kg));
  }
  return points;
}

String _cell(List<dynamic> row, int? index) {
  if (index == null || index < 0 || index >= row.length) return '';
  return '${row[index] ?? ''}'.trim();
}

DateTime? _date(String raw) {
  if (raw.isEmpty) return null;
  final parsed = DateTime.tryParse(raw.replaceAll(' ', 'T'));
  if (parsed != null) return parsed;
  final match = RegExp(r'(\d{1,2})[./](\d{1,2})[./](\d{2,4})').firstMatch(raw);
  if (match == null) return null;
  final year = int.parse(match.group(3)!);
  return DateTime(
    year < 100 ? 2000 + year : year,
    int.parse(match.group(2)!),
    int.parse(match.group(1)!),
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
