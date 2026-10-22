import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

const germanWeekdayTitles = {
  'monday': 'Montag',
  'tuesday': 'Dienstag',
  'wednesday': 'Mittwoch',
  'thursday': 'Donnerstag',
  'friday': 'Freitag',
  'saturday': 'Samstag',
  'sunday': 'Sonntag',
};

String? germanTitleForEnglishPlan({
  required String days,
  required String? title,
}) {
  final mapped = germanWeekdayTitles[days.trim().toLowerCase()];
  if (mapped == null) return null;
  final current = (title ?? '').trim();
  if (current.isEmpty) return mapped;
  if (germanWeekdayTitles.containsKey(current.toLowerCase())) return mapped;
  return null;
}

final _weekdayDates = <String, DateTime>{
  'monday': DateTime.utc(2024, 1, 1),
  'montag': DateTime.utc(2024, 1, 1),
  'tuesday': DateTime.utc(2024, 1, 2),
  'dienstag': DateTime.utc(2024, 1, 2),
  'wednesday': DateTime.utc(2024, 1, 3),
  'mittwoch': DateTime.utc(2024, 1, 3),
  'thursday': DateTime.utc(2024, 1, 4),
  'donnerstag': DateTime.utc(2024, 1, 4),
  'friday': DateTime.utc(2024, 1, 5),
  'freitag': DateTime.utc(2024, 1, 5),
  'saturday': DateTime.utc(2024, 1, 6),
  'samstag': DateTime.utc(2024, 1, 6),
  'sunday': DateTime.utc(2024, 1, 7),
  'sonntag': DateTime.utc(2024, 1, 7),
};

String localizedPlanTitle({
  required String locale,
  String? title,
  int? sequence,
  int? id,
  int? number,
}) {
  final text = (title ?? '').trim();
  final date = _weekdayDates[text.toLowerCase()];
  final language = locale.trim();
  if (date != null && language.isNotEmpty) {
    return DateFormat.EEEE(language).format(date);
  }
  return planDisplayName(
    title: title,
    sequence: sequence,
    id: id,
    number: number,
  );
}

String planTitleOf(
  BuildContext context, {
  String? title,
  int? sequence,
  int? id,
  int? number,
}) {
  return localizedPlanTitle(
    locale: Localizations.localeOf(context).toLanguageTag(),
    title: title,
    sequence: sequence,
    id: id,
    number: number,
  );
}

String planDisplayName({String? title, int? sequence, int? id, int? number}) {
  final text = (title ?? '').trim();
  if (text.isNotEmpty) return text;
  final n = number ?? (sequence != null ? sequence + 1 : id);
  if (n == null || n <= 0) return 'Plan 1';
  return 'Plan $n';
}

int nextPlanIndex({
  required int? lastPlanIndex,
  required int completedCount,
  required int planCount,
}) {
  if (planCount <= 0) return 0;
  if (lastPlanIndex != null &&
      lastPlanIndex >= 0 &&
      lastPlanIndex < planCount) {
    return (lastPlanIndex + 1) % planCount;
  }
  final count = completedCount < 0 ? 0 : completedCount;
  return count % planCount;
}
