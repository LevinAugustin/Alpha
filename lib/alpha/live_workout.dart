import 'package:flutter/foundation.dart';

class LiveWorkout {
  LiveWorkout({
    required this.planId,
    required this.workoutId,
    required this.title,
    required this.exercise,
  });

  final int planId;
  final int workoutId;
  String title;
  String exercise;
}

final ValueNotifier<LiveWorkout?> liveWorkout = ValueNotifier(null);
