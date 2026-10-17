import 'package:flexify/database/catalog_seed.dart';
import 'package:flexify/exercise_keys.dart';
import 'package:flexify/l10n/generated/app_localizations.dart';
import 'package:flexify/theme/alpha_theme.dart';
import 'package:flutter/material.dart';

const muscleRegions = exerciseMuscleKeys;

String muscleLabel(AppLocalizations l10n, String id) {
  return switch (id) {
    'brust' => l10n.muscleChest,
    'brust_oben' => l10n.muscleUpperChest,
    'schulter_vorne' => l10n.muscleFrontShoulder,
    'schulter_seitlich' => l10n.muscleSideShoulder,
    'schulter_hinten' => l10n.muscleRearShoulder,
    'latissimus' => l10n.muscleLatissimus,
    'oberer_ruecken' => l10n.muscleUpperBack,
    'trapez' => l10n.muscleTrapez,
    'unterer_ruecken' => l10n.muscleLowerBack,
    'bizeps' => l10n.muscleBiceps,
    'unterarme' => l10n.muscleForearms,
    'trizeps' => l10n.muscleTriceps,
    'bauch_gerade' => l10n.muscleRectus,
    'bauch_schraeg' => l10n.muscleObliques,
    'quadrizeps' => l10n.muscleQuadriceps,
    'beinbeuger' => l10n.muscleHams,
    'gesaess' => l10n.muscleGlutes,
    'adduktoren' => l10n.muscleAdductors,
    'abduktoren' => l10n.muscleAbductors,
    'waden' => l10n.muscleCalves,
    'hueftbeuger' => l10n.muscleHipFlexors,
    _ => id,
  };
}

String? regionForGroup(String? muscle) {
  if (muscle != null && exerciseMuscleKeys.contains(muscle)) return muscle;
  return switch (muscle) {
    'Brust' => 'brust',
    'Schultern' => 'schulter_vorne',
    'Arme' => 'bizeps',
    'Bauch' => 'bauch_gerade',
    'Beine' => 'quadrizeps',
    'Rücken' => 'latissimus',
    'Bizeps' => 'bizeps',
    'Trizeps' => 'trizeps',
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
    heat['trizeps'] = (heat['trizeps'] ?? 0) + load * 0.5;
    heat['bizeps'] = (heat['bizeps'] ?? 0) + load * 0.5;
  }
  if (group == 'Beine') {
    heat['beinbeuger'] = (heat['beinbeuger'] ?? 0) + load * 0.4;
    heat['gesaess'] = (heat['gesaess'] ?? 0) + load * 0.3;
    heat['waden'] = (heat['waden'] ?? 0) + load * 0.15;
  }
  if (group == 'Rücken') {
    heat['trapez'] = (heat['trapez'] ?? 0) + load * 0.35;
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

class _Mark {
  const _Mark(this.id, this.rect);

  final String id;
  final Rect rect;
}

const _frontMarks = [
  _Mark('brust_oben', Rect.fromLTWH(19, 22, 22, 6)),
  _Mark('brust', Rect.fromLTWH(19, 28, 22, 9)),
  _Mark('schulter_vorne', Rect.fromLTWH(14, 19, 7, 8)),
  _Mark('schulter_vorne', Rect.fromLTWH(39, 19, 7, 8)),
  _Mark('schulter_seitlich', Rect.fromLTWH(8, 20, 6, 10)),
  _Mark('schulter_seitlich', Rect.fromLTWH(46, 20, 6, 10)),
  _Mark('bauch_schraeg', Rect.fromLTWH(18, 39, 6, 15)),
  _Mark('bauch_schraeg', Rect.fromLTWH(36, 39, 6, 15)),
  _Mark('bauch_gerade', Rect.fromLTWH(24, 39, 12, 16)),
  _Mark('bizeps', Rect.fromLTWH(7, 31, 7, 12)),
  _Mark('bizeps', Rect.fromLTWH(46, 31, 7, 12)),
  _Mark('unterarme', Rect.fromLTWH(6, 44, 7, 12)),
  _Mark('unterarme', Rect.fromLTWH(47, 44, 7, 12)),
  _Mark('hueftbeuger', Rect.fromLTWH(21, 56, 7, 7)),
  _Mark('hueftbeuger', Rect.fromLTWH(32, 56, 7, 7)),
  _Mark('abduktoren', Rect.fromLTWH(13, 64, 5, 16)),
  _Mark('abduktoren', Rect.fromLTWH(42, 64, 5, 16)),
  _Mark('adduktoren', Rect.fromLTWH(25, 68, 5, 24)),
  _Mark('adduktoren', Rect.fromLTWH(30, 68, 5, 24)),
  _Mark('quadrizeps', Rect.fromLTWH(17, 66, 8, 28)),
  _Mark('quadrizeps', Rect.fromLTWH(35, 66, 8, 28)),
  _Mark('waden', Rect.fromLTWH(19, 100, 8, 18)),
  _Mark('waden', Rect.fromLTWH(33, 100, 8, 18)),
];

const _backMarks = [
  _Mark('trapez', Rect.fromLTWH(22, 16, 16, 8)),
  _Mark('schulter_hinten', Rect.fromLTWH(12, 18, 8, 8)),
  _Mark('schulter_hinten', Rect.fromLTWH(40, 18, 8, 8)),
  _Mark('oberer_ruecken', Rect.fromLTWH(20, 25, 20, 8)),
  _Mark('unterer_ruecken', Rect.fromLTWH(22, 50, 16, 9)),
  _Mark('latissimus', Rect.fromLTWH(14, 33, 32, 16)),
  _Mark('trizeps', Rect.fromLTWH(5, 30, 8, 14)),
  _Mark('trizeps', Rect.fromLTWH(47, 30, 8, 14)),
  _Mark('unterarme', Rect.fromLTWH(5, 44, 8, 12)),
  _Mark('unterarme', Rect.fromLTWH(47, 44, 8, 12)),
  _Mark('gesaess', Rect.fromLTWH(18, 60, 24, 12)),
  _Mark('beinbeuger', Rect.fromLTWH(18, 74, 10, 22)),
  _Mark('beinbeuger', Rect.fromLTWH(32, 74, 10, 22)),
  _Mark('waden', Rect.fromLTWH(19, 100, 8, 18)),
  _Mark('waden', Rect.fromLTWH(33, 100, 8, 18)),
];

String? _hit(Offset point, double height, bool front) {
  final scale = height / 130;
  final local = Offset(point.dx / scale, point.dy / scale);
  for (final mark in front ? _frontMarks : _backMarks) {
    if (mark.rect.contains(local)) return mark.id;
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

    for (final mark in front ? _frontMarks : _backMarks) {
      blob(mark.id, mark.rect);
    }
  }

  @override
  bool shouldRepaint(covariant _BodyPainter oldDelegate) =>
      oldDelegate.heat != heat || oldDelegate.palette != palette;
}
