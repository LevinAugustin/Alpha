import 'package:flexify/l10n/generated/app_localizations.dart';
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

String movementLabel(AppLocalizations l10n, String value) {
  return switch (value) {
    'druecken' => l10n.motionPress,
    'ziehen' => l10n.motionPull,
    'beine_huefte' => l10n.motionLegs,
    'rumpf' => l10n.motionCore,
    'cardio' => l10n.motionCardio,
    _ => value,
  };
}

String mechanicLabel(AppLocalizations l10n, String value) {
  return switch (value) {
    'grund' => l10n.mechanicCompound,
    'isolation' => l10n.mechanicIsolation,
    _ => value,
  };
}

String? exerciseListSubtitle({String? category, String? equipment}) {
  final left = (category ?? '').trim();
  final right = (equipment ?? '').trim();
  if (left.isEmpty && right.isEmpty) return null;
  if (left.isEmpty) return right;
  if (right.isEmpty) return left;
  return '$left · $right';
}

String? formatRepRange(int? min, int? max) {
  if (min == null && max == null) return null;
  if (min != null && max != null) {
    if (min == max) return '$min';
    return '$min–$max';
  }
  return '${min ?? max}';
}
