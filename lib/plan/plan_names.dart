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
