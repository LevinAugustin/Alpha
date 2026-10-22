import 'package:flexify/database/catalog_seed.dart';
import 'package:flexify/database/exercise_de_catalog.dart';
import 'package:flexify/l10n/generated/app_localizations.dart';
import 'package:flutter/widgets.dart';

String localizedExerciseName(
  BuildContext context,
  String name, {
  String? german,
  String? english,
}) {
  final de = (german ?? '').trim();
  final en = (english ?? '').trim();
  if (Localizations.localeOf(context).languageCode == 'de') {
    if (de.isNotEmpty) return de;
    if (en.isNotEmpty) return en;
    return name;
  }
  if (en.isNotEmpty) return en;
  if (de.isNotEmpty) return de;
  return name;
}

List<String> localizedExerciseLines(
  BuildContext context, {
  String? german,
  String? english,
}) {
  final de = decodeCatalogList(german);
  if (Localizations.localeOf(context).languageCode == 'de') return de;
  final en = decodeCatalogList(english);
  return en.isEmpty ? de : en;
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

String? exerciseListSubtitle({
  String? category,
  String? equipment,
  String? unassigned,
}) {
  final left = (category ?? '').trim();
  final right = (equipment ?? '').trim();
  if (left.isEmpty && right.isEmpty) return unassigned;
  if (left.isEmpty) return right;
  if (right.isEmpty) return left;
  return '$left · $right';
}

bool _usesGermanCatalog(AppLocalizations l10n) =>
    l10n.localeName.toLowerCase().startsWith('de');

CatalogEnglishText? _catalogEnglish(String? catalogId) {
  final id = (catalogId ?? '').trim();
  if (id.isEmpty) return null;
  return catalogEnglishById[id];
}

String _localizedToken(
  AppLocalizations l10n,
  String stored, {
  String? english,
  required String fallback,
}) {
  if (stored.isEmpty || _usesGermanCatalog(l10n)) return stored;
  final override = (english ?? '').trim();
  if (override.isNotEmpty) return override;
  return fallback;
}

String localizedCategory(
  AppLocalizations l10n,
  String? value, {
  String? catalogId,
}) {
  final stored = (value ?? '').trim();
  final fallback = switch (stored) {
    'Brust' => l10n.muscleChest,
    'Rücken' => l10n.muscleBack,
    'Schultern' => l10n.muscleShoulders,
    'Beine' => l10n.groupLegs,
    'Bizeps' => l10n.muscleBiceps,
    'Trizeps' => l10n.muscleTriceps,
    'Bauch' => l10n.muscleAbs,
    'Cardio' => l10n.motionCardio,
    _ => stored,
  };
  return _localizedToken(
    l10n,
    stored,
    english: _catalogEnglish(catalogId)?.category,
    fallback: fallback,
  );
}

String localizedGear(
  AppLocalizations l10n,
  String? value, {
  String? catalogId,
}) {
  final stored = (value ?? '').trim();
  final fallback = switch (stored) {
    'Langhantel' => l10n.gearBarbell,
    'Kurzhantel' => l10n.gearDumbbell,
    'SZ-Stange' => l10n.gearEzBar,
    'Kabelzug' => l10n.gearCable,
    'Maschine' => l10n.gearMachine,
    'Multipresse' => l10n.gearSmith,
    'Körpergewicht' => l10n.gearBodyweight,
    'Kettlebell' => l10n.gearKettlebell,
    'Widerstandsband' => l10n.gearBand,
    'Cardiogerät' => l10n.gearCardio,
    'Hantelscheibe' => l10n.gearPlate,
    'Bauchroller' => l10n.gearAbWheel,
    'Battle Rope' => l10n.gearBattleRope,
    'Schlitten' => l10n.gearSled,
    'Springseil' => l10n.gearJumpRope,
    _ => stored,
  };
  return _localizedToken(
    l10n,
    stored,
    english: _catalogEnglish(catalogId)?.equipment,
    fallback: fallback,
  );
}

String localizedPosition(
  AppLocalizations l10n,
  String? value, {
  String? catalogId,
}) {
  final stored = (value ?? '').trim();
  final fallback = switch (stored) {
    'flach' => l10n.positionFlat,
    'schraeg' => l10n.positionIncline,
    'negativ' => l10n.positionDecline,
    'sitzend' => l10n.positionSeated,
    'stehend' => l10n.positionStanding,
    'liegend' => l10n.positionLying,
    'vorgebeugt' => l10n.positionBent,
    _ => stored,
  };
  return _localizedToken(
    l10n,
    stored,
    english: _catalogEnglish(catalogId)?.position,
    fallback: fallback,
  );
}

String localizedGrip(
  AppLocalizations l10n,
  String? value, {
  String? catalogId,
}) {
  final stored = (value ?? '').trim();
  final fallback = switch (stored) {
    'eng' => l10n.gripClose,
    'breit' => l10n.gripWide,
    'obergriff' => l10n.gripOverhand,
    'untergriff' => l10n.gripUnderhand,
    'neutral' => l10n.gripNeutral,
    _ => stored,
  };
  return _localizedToken(
    l10n,
    stored,
    english: _catalogEnglish(catalogId)?.grip,
    fallback: fallback,
  );
}

String? formatRepRange(int? min, int? max) {
  if (min == null && max == null) return null;
  if (min != null && max != null) {
    if (min == max) return '$min';
    return '$min–$max';
  }
  return '${min ?? max}';
}
