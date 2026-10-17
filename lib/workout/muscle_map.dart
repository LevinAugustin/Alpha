import 'package:flexify/database/catalog_seed.dart';
import 'package:flexify/exercise_keys.dart';
import 'package:flexify/l10n/generated/app_localizations.dart';
import 'package:flexify/theme/alpha_theme.dart';
import 'package:flutter/material.dart';

const muscleRegions = exerciseMuscleKeys;

String muscleLabel(AppLocalizations l10n, String id) {
  return switch (id) {
    'chest' => l10n.muscleChest,
    'delts' => l10n.muscleShoulders,
    'biceps' => l10n.muscleBiceps,
    'triceps' => l10n.muscleTriceps,
    'abs' => l10n.muscleAbs,
    'quads' => l10n.muscleQuads,
    'calves' => l10n.muscleCalves,
    'traps' => l10n.muscleTraps,
    'lats' => l10n.muscleBack,
    'glutes' => l10n.muscleGlutes,
    'hams' => l10n.muscleHams,
    _ => id,
  };
}

String gearLabel(AppLocalizations l10n, String id) {
  return switch (id) {
    'langhantel' => l10n.gearLanghantel,
    'kurzhantel' => l10n.gearKurzhantel,
    'kabelzug' => l10n.gearKabelzug,
    'maschine' => l10n.gearMaschine,
    'multipresse' => l10n.gearMultipresse,
    'koerpergewicht' => l10n.gearKoerpergewicht,
    _ => id,
  };
}

String? regionForGroup(String? muscle) {
  if (muscle != null && exerciseMuscleKeys.contains(muscle)) return muscle;
  return switch (muscle) {
    'Brust' => 'chest',
    'Schultern' => 'delts',
    'Arme' => 'biceps',
    'Bauch' => 'abs',
    'Beine' => 'quads',
    'Rücken' => 'lats',
    'Cardio' => null,
    _ => null,
  };
}

void contributeMuscleHeat(
  Map<String, double> heat, {
  required double load,
  String? group,
  String? primaryMuscles,
  String? secondaryMuscles,
}) {
  if (load == 0) return;
  final primary = [
    for (final key in decodeCatalogList(primaryMuscles))
      if (exerciseMuscleKeys.contains(key)) key,
  ];
  final secondary = [
    for (final key in decodeCatalogList(secondaryMuscles))
      if (exerciseMuscleKeys.contains(key)) key,
  ];
  if (primary.isNotEmpty || secondary.isNotEmpty) {
    for (final key in primary) {
      heat[key] = (heat[key] ?? 0) + load;
    }
    for (final key in secondary) {
      heat[key] = (heat[key] ?? 0) + load * 0.35;
    }
    return;
  }
  final region = regionForGroup(group);
  if (region != null) {
    heat[region] = (heat[region] ?? 0) + load;
  }
  if (group == 'Arme') {
    heat['triceps'] = (heat['triceps'] ?? 0) + load * 0.5;
    heat['biceps'] = (heat['biceps'] ?? 0) + load * 0.5;
  }
  if (group == 'Beine') {
    heat['hams'] = (heat['hams'] ?? 0) + load * 0.4;
    heat['glutes'] = (heat['glutes'] ?? 0) + load * 0.3;
    heat['calves'] = (heat['calves'] ?? 0) + load * 0.15;
  }
  if (group == 'Rücken') {
    heat['traps'] = (heat['traps'] ?? 0) + load * 0.35;
  }
}

class MuscleMap extends StatelessWidget {
  const MuscleMap({
    super.key,
    required this.heat,
    this.compact = false,
    this.onTap,
    this.female = false,
  });

  final Map<String, double> heat;
  final bool compact;
  final ValueChanged<String>? onTap;
  final bool female;

  @override
  Widget build(BuildContext context) {
    final palette = AlphaTheme.of(context);
    final height = compact ? 78.0 : 280.0;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _Figure(
          front: true,
          height: height,
          heat: heat,
          palette: palette,
          female: female,
          onTap: onTap,
        ),
        SizedBox(width: compact ? 8 : 24),
        _Figure(
          front: false,
          height: height,
          heat: heat,
          palette: palette,
          female: female,
          onTap: onTap,
        ),
      ],
    );
  }
}

class _Figure extends StatelessWidget {
  const _Figure({
    required this.front,
    required this.height,
    required this.heat,
    required this.palette,
    required this.female,
    required this.onTap,
  });

  final bool front;
  final double height;
  final Map<String, double> heat;
  final AlphaPalette palette;
  final bool female;
  final ValueChanged<String>? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: height * 0.46,
      height: height,
      child: GestureDetector(
        onTapDown: onTap == null
            ? null
            : (details) {
                final region = _hit(details.localPosition, height, front);
                if (region != null) onTap!(region);
              },
        child: CustomPaint(
          painter: _BodyPainter(
            front: front,
            heat: heat,
            palette: palette,
            female: female,
          ),
        ),
      ),
    );
  }
}

String? _hit(Offset point, double height, bool front) {
  final scale = height / 130;
  final x = point.dx / scale;
  final y = point.dy / scale;
  bool inside(Rect rect) => rect.contains(Offset(x, y));
  if (front) {
    if (inside(const Rect.fromLTWH(18, 22, 24, 16))) return 'chest';
    if (inside(const Rect.fromLTWH(8, 22, 12, 14)) ||
        inside(const Rect.fromLTWH(40, 22, 12, 14))) {
      return 'delts';
    }
    if (inside(const Rect.fromLTWH(6, 36, 10, 22)) ||
        inside(const Rect.fromLTWH(44, 36, 10, 22))) {
      return 'biceps';
    }
    if (inside(const Rect.fromLTWH(22, 40, 16, 18))) return 'abs';
    if (inside(const Rect.fromLTWH(16, 68, 12, 28)) ||
        inside(const Rect.fromLTWH(32, 68, 12, 28))) {
      return 'quads';
    }
    if (y > 98) return 'calves';
  } else {
    if (inside(const Rect.fromLTWH(20, 20, 20, 12))) return 'traps';
    if (inside(const Rect.fromLTWH(12, 32, 36, 28))) return 'lats';
    if (inside(const Rect.fromLTWH(18, 62, 24, 16))) return 'glutes';
    if (inside(const Rect.fromLTWH(16, 78, 12, 22)) ||
        inside(const Rect.fromLTWH(32, 78, 12, 22))) {
      return 'hams';
    }
    if (inside(const Rect.fromLTWH(4, 34, 10, 20)) ||
        inside(const Rect.fromLTWH(46, 34, 10, 20))) {
      return 'triceps';
    }
  }
  return null;
}

class _BodyPainter extends CustomPainter {
  _BodyPainter({
    required this.front,
    required this.heat,
    required this.palette,
    required this.female,
  });

  final bool front;
  final Map<String, double> heat;
  final AlphaPalette palette;
  final bool female;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.height / 130;
    canvas.scale(scale);
    final skin = palette.card;
    final off = Color.alphaBlend(
      palette.border.withValues(alpha: 0.8),
      palette.card,
    );
    Color fill(String id) {
      final value = (heat[id] ?? 0).clamp(0, 1).toDouble();
      if (value <= 0) return off;
      return Color.lerp(off, palette.accent, 0.35 + value * 0.65)!;
    }

    final body = Path();
    final shoulder = female ? 16.0 : 14.0;
    final hip = female ? 16.0 : 13.0;
    final waist = female ? 11.0 : 12.0;
    body.moveTo(30, 18);
    body.cubicTo(30 - shoulder, 20, 30 - shoulder, 34, 30 - waist, 48);
    body.cubicTo(30 - hip, 62, 30 - hip, 70, 30 - 8, 96);
    body.lineTo(30 - 5, 124);
    body.lineTo(30 - 1, 124);
    body.lineTo(30 - 2, 98);
    body.lineTo(30 + 2, 98);
    body.lineTo(30 + 1, 124);
    body.lineTo(30 + 5, 124);
    body.lineTo(30 + 8, 96);
    body.cubicTo(30 + hip, 70, 30 + hip, 62, 30 + waist, 48);
    body.cubicTo(30 + shoulder, 34, 30 + shoulder, 20, 30, 18);
    canvas.drawPath(body, Paint()..color = skin);
    canvas.drawOval(
      const Rect.fromLTWH(23.5, 2, 13, 16),
      Paint()..color = skin,
    );

    void blob(String id, Rect rect) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(4)),
        Paint()..color = fill(id),
      );
    }

    if (front) {
      blob('delts', const Rect.fromLTWH(10, 20, 10, 12));
      blob('delts', const Rect.fromLTWH(40, 20, 10, 12));
      blob('chest', const Rect.fromLTWH(18, 24, 24, 14));
      blob('biceps', const Rect.fromLTWH(8, 34, 8, 18));
      blob('biceps', const Rect.fromLTWH(44, 34, 8, 18));
      blob('abs', const Rect.fromLTWH(23, 40, 14, 18));
      blob('quads', const Rect.fromLTWH(18, 70, 10, 26));
      blob('quads', const Rect.fromLTWH(32, 70, 10, 26));
      blob('calves', const Rect.fromLTWH(20, 100, 7, 18));
      blob('calves', const Rect.fromLTWH(33, 100, 7, 18));
    } else {
      blob('traps', const Rect.fromLTWH(22, 18, 16, 10));
      blob('lats', const Rect.fromLTWH(14, 30, 32, 24));
      blob('triceps', const Rect.fromLTWH(6, 32, 8, 18));
      blob('triceps', const Rect.fromLTWH(46, 32, 8, 18));
      blob('glutes', const Rect.fromLTWH(18, 60, 24, 14));
      blob('hams', const Rect.fromLTWH(18, 78, 10, 20));
      blob('hams', const Rect.fromLTWH(32, 78, 10, 20));
      blob('calves', const Rect.fromLTWH(20, 100, 7, 18));
      blob('calves', const Rect.fromLTWH(33, 100, 7, 18));
    }
  }

  @override
  bool shouldRepaint(covariant _BodyPainter oldDelegate) =>
      oldDelegate.heat != heat || oldDelegate.palette != palette;
}
