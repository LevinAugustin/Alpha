import 'package:flutter/widgets.dart';

String localizedExerciseName(
  BuildContext context,
  String english, {
  String? german,
}) {
  if (Localizations.localeOf(context).languageCode == 'de' &&
      german != null &&
      german.isNotEmpty) {
    return german;
  }
  return english;
}

String? formatRepRange(int? min, int? max) {
  if (min == null && max == null) return null;
  if (min != null && max != null) {
    if (min == max) return '$min';
    return '$min–$max';
  }
  return '${min ?? max}';
}
