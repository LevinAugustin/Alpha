import 'package:flexify/shell/training_stats.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('day and week streaks count backward from today', () {
    final today = DateTime(2026, 10, 17);
    final days = {
      DateTime(2026, 10, 17),
      DateTime(2026, 10, 16),
      DateTime(2026, 10, 14),
      DateTime(2026, 10, 6),
    };

    expect(trainingDayStreak(days, today), 2);
    expect(trainingWeekStreak(days, today), 2);
    expect(estimatedOneRepMax(100, 1), 100);
    expect(estimatedOneRepMax(100, 5), greaterThan(100));
  });

  test('a missed today still keeps yesterday in the streak', () {
    final today = DateTime(2026, 10, 17);
    final days = {DateTime(2026, 10, 16), DateTime(2026, 10, 15)};
    expect(trainingDayStreak(days, today), 2);
  });
}
