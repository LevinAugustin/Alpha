import 'package:flexify/alpha/set_notes.dart';
import 'package:flexify/database/database.dart';

double unilateralVolume({
  required bool unilateral,
  required String? side,
  required double loadKg,
  required double reps,
}) {
  final perSide = side == 'links' || side == 'rechts';
  final factor = unilateral && !perSide ? 2 : 1;
  return loadKg * reps * factor;
}

String pairedRepsLabel(
  double? left,
  double? right,
  String Function(double?) format,
) {
  if (left == null && right == null) return '';
  if (left == null) return format(right);
  if (right == null) return format(left);
  if (left == right) return format(left);
  return '${format(left)}/${format(right)}';
}

class SideGroup {
  SideGroup({
    required this.kg,
    required this.time,
    required this.warmup,
    this.leftReps,
    this.rightReps,
    this.plainReps,
  });

  double kg;
  DateTime time;
  bool warmup;
  double? leftReps;
  double? rightReps;
  double? plainReps;

  String repsText(
    String Function(double?) format, {
    String? leftName,
    String? rightName,
  }) {
    if (plainReps != null && leftReps == null && rightReps == null) {
      return format(plainReps);
    }
    if (leftReps != null && rightReps != null) {
      return pairedRepsLabel(leftReps, rightReps, format);
    }
    if (leftReps != null) {
      final value = format(leftReps);
      if (leftName == null || leftName.isEmpty) return value;
      return '$value · $leftName';
    }
    if (rightReps != null) {
      final value = format(rightReps);
      if (rightName == null || rightName.isEmpty) return value;
      return '$value · $rightName';
    }
    return '';
  }
}

List<SideGroup> groupSideSets(List<ExerciseSet> sets) {
  final result = <SideGroup>[];
  final open = <int, int>{};
  for (final set in sets) {
    final side = set.side;
    final sided = side == 'links' || side == 'rechts';
    if (!sided) {
      result.add(
        SideGroup(
          kg: set.loadKg ?? 0,
          time: set.timestamp,
          warmup: notesAreWarmup(set.notes),
          plainReps: set.reps,
        ),
      );
      continue;
    }
    final stamp = set.timestamp.millisecondsSinceEpoch ~/ 1000;
    final index = open[stamp];
    if (index == null) {
      open[stamp] = result.length;
      result.add(
        SideGroup(
          kg: set.loadKg ?? 0,
          time: set.timestamp,
          warmup: notesAreWarmup(set.notes),
          leftReps: side == 'links' ? set.reps : null,
          rightReps: side == 'rechts' ? set.reps : null,
        ),
      );
      continue;
    }
    final current = result[index];
    final sameSide =
        (side == 'links' && current.leftReps != null) ||
        (side == 'rechts' && current.rightReps != null);
    if (sameSide) {
      open[stamp] = result.length;
      result.add(
        SideGroup(
          kg: set.loadKg ?? 0,
          time: set.timestamp,
          warmup: notesAreWarmup(set.notes),
          leftReps: side == 'links' ? set.reps : null,
          rightReps: side == 'rechts' ? set.reps : null,
        ),
      );
      continue;
    }
    open.remove(stamp);
    if (side == 'links') {
      current.leftReps = set.reps;
    } else {
      current.rightReps = set.reps;
    }
    current.warmup = current.warmup || notesAreWarmup(set.notes);
  }
  return result;
}

class SideExportRow {
  const SideExportRow({
    required this.exerciseId,
    required this.loggedAt,
    required this.side,
    required this.kg,
    required this.reps,
  });

  final int exerciseId;
  final DateTime loggedAt;
  final String? side;
  final double kg;
  final double reps;
}

List<int> indexesAfterEqualSideCollapse(List<SideExportRow> rows) {
  final keep = List<bool>.filled(rows.length, true);
  final open = <String, int>{};
  for (var i = 0; i < rows.length; i++) {
    final row = rows[i];
    final side = row.side;
    if (side != 'links' && side != 'rechts') continue;
    final key =
        '${row.exerciseId}:${row.loggedAt.millisecondsSinceEpoch ~/ 1000}';
    final other = open.remove(key);
    if (other == null) {
      open[key] = i;
      continue;
    }
    final first = rows[other];
    final opposite =
        first.side != side && (first.side == 'links' || first.side == 'rechts');
    if (opposite && first.kg == row.kg && first.reps == row.reps) {
      keep[i] = false;
      continue;
    }
    open[key] = i;
  }
  return [
    for (var i = 0; i < rows.length; i++)
      if (keep[i]) i,
  ];
}
