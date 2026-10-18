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

int nextPlanIndex({required int finishedThisWeek, required int planCount}) {
  if (planCount <= 0) return 0;
  final count = finishedThisWeek < 0 ? 0 : finishedThisWeek;
  return count % planCount;
}
