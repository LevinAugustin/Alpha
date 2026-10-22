import 'dart:convert';

import 'package:flexify/database/catalog_seed.dart';
import 'package:flexify/database/exercise_de_catalog.dart';
import 'package:flutter/widgets.dart';

class ExerciseVariant {
  const ExerciseVariant({
    required this.key,
    required this.labelDe,
    required this.labelEn,
    required this.stepsDe,
    required this.tipsDe,
    required this.stepsEn,
    required this.tipsEn,
    required this.image,
    required this.imageRendered,
  });

  final String key;
  final String labelDe;
  final String labelEn;
  final List<String> stepsDe;
  final List<String> tipsDe;
  final List<String> stepsEn;
  final List<String> tipsEn;
  final String image;
  final bool imageRendered;

  String label(BuildContext context) {
    final english = Localizations.localeOf(context).languageCode != 'de';
    final chosen = english ? labelEn : labelDe;
    if (chosen.trim().isNotEmpty) return chosen;
    return labelDe.trim().isNotEmpty ? labelDe : labelEn;
  }

  List<String> steps(BuildContext context) {
    if (Localizations.localeOf(context).languageCode == 'de') return stepsDe;
    return stepsEn.isEmpty ? stepsDe : stepsEn;
  }

  List<String> tips(BuildContext context) {
    if (Localizations.localeOf(context).languageCode == 'de') return tipsDe;
    return tipsEn.isEmpty ? tipsDe : tipsEn;
  }

  String? clipPath() {
    if (!imageRendered) return null;
    return resolveExerciseImage(image);
  }
}

List<ExerciseVariant> parseExerciseVariants(String? raw) {
  final decoded = decodeCatalogList(raw);
  if (decoded.isNotEmpty && raw != null && !raw.trim().startsWith('[')) {
    return const [];
  }
  final value = raw?.trim() ?? '';
  if (value.isEmpty) return const [];
  Object? json;
  try {
    json = jsonDecode(value);
  } catch (_) {
    return const [];
  }
  if (json is! List) return const [];
  final variants = <ExerciseVariant>[];
  for (final item in json) {
    if (item is! Map) continue;
    final row = Map<String, dynamic>.from(item);
    final key = (row['key'] as String? ?? '').trim();
    if (key.isEmpty) continue;
    variants.add(
      ExerciseVariant(
        key: key,
        labelDe: (row['label_de'] as String? ?? '').trim(),
        labelEn: (row['label_en'] as String? ?? '').trim(),
        stepsDe: _lines(row['ausfuehrung_de']),
        tipsDe: _lines(row['tipps_de']),
        stepsEn: _lines(row['ausfuehrung_en']),
        tipsEn: _lines(row['tipps_en']),
        image: (row['bild'] as String? ?? '').trim(),
        imageRendered: row['bild_gerendert'] == true,
      ),
    );
  }
  return variants;
}

List<String> _lines(Object? value) {
  if (value is! List) return const [];
  return [
    for (final item in value)
      if (item is String && item.trim().isNotEmpty) item.trim(),
  ];
}
