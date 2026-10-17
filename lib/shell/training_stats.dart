DateTime dateOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);

DateTime mondayOf(DateTime value) {
  final day = dateOnly(value);
  return day.subtract(Duration(days: day.weekday - 1));
}

int trainingDayStreak(Set<DateTime> trainingDays, DateTime today) {
  var cursor = dateOnly(today);
  if (!trainingDays.contains(cursor)) {
    cursor = cursor.subtract(const Duration(days: 1));
  }
  var streak = 0;
  while (trainingDays.contains(cursor)) {
    streak++;
    cursor = cursor.subtract(const Duration(days: 1));
  }
  return streak;
}

int trainingWeekStreak(Set<DateTime> trainingDays, DateTime today) {
  final weeks = trainingDays.map(mondayOf).toSet();
  var cursor = mondayOf(today);
  if (!weeks.contains(cursor)) {
    cursor = cursor.subtract(const Duration(days: 7));
  }
  var streak = 0;
  while (weeks.contains(cursor)) {
    streak++;
    cursor = cursor.subtract(const Duration(days: 7));
  }
  return streak;
}

double estimatedOneRepMax(double loadKg, double reps) {
  if (loadKg <= 0 || reps <= 0) return 0;
  if (reps <= 1) return loadKg;
  final factor = 1.0278 - 0.0278 * reps;
  if (factor <= 0) return loadKg;
  return loadKg / factor;
}
