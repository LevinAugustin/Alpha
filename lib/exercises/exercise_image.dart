import 'dart:io';

import 'package:flexify/database/exercise_de_catalog.dart';
import 'package:flexify/theme/alpha_theme.dart';
import 'package:flutter/material.dart';

bool exerciseImageFileExists(String? path) {
  final value = (path ?? '').trim();
  if (value.isEmpty || value.startsWith('assets/')) return false;
  return File(value).existsSync();
}

String? bundledExerciseAsset(String? path) {
  final value = (path ?? '').trim();
  if (!bundledExerciseImages.contains(value)) return null;
  return value;
}

class ExerciseImage extends StatelessWidget {
  const ExerciseImage({super.key, required this.path, this.height = 180});

  final String? path;
  final double height;

  @override
  Widget build(BuildContext context) {
    final palette = AlphaTheme.of(context);
    final stored = (path ?? '').trim();
    final asset = bundledExerciseAsset(stored);
    final Widget picture;
    if (asset != null) {
      picture = Image.asset(
        asset,
        height: height,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stack) =>
            ExerciseImagePlaceholder(palette: palette, height: height),
      );
    } else if (exerciseImageFileExists(stored)) {
      picture = Image.file(
        File(stored),
        height: height,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stack) =>
            ExerciseImagePlaceholder(palette: palette, height: height),
      );
    } else {
      picture = ExerciseImagePlaceholder(palette: palette, height: height);
    }
    return picture;
  }
}

class ExerciseImagePlaceholder extends StatelessWidget {
  const ExerciseImagePlaceholder({
    super.key,
    required this.palette,
    required this.height,
  });

  final AlphaPalette palette;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: palette.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: palette.border),
        ),
        child: CustomPaint(painter: _NeutralFigurePainter(palette.muted)),
      ),
    );
  }
}

class _NeutralFigurePainter extends CustomPainter {
  const _NeutralFigurePainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    final center = Offset(size.width / 2, size.height / 2);
    final scale = size.height / 180;
    canvas.drawCircle(center + Offset(0, -48 * scale), 14 * scale, paint);
    final body = Path()
      ..moveTo(center.dx, center.dy - 32 * scale)
      ..lineTo(center.dx, center.dy + 18 * scale)
      ..moveTo(center.dx, center.dy - 18 * scale)
      ..lineTo(center.dx - 28 * scale, center.dy + 4 * scale)
      ..moveTo(center.dx, center.dy - 18 * scale)
      ..lineTo(center.dx + 28 * scale, center.dy + 4 * scale)
      ..moveTo(center.dx, center.dy + 18 * scale)
      ..lineTo(center.dx - 18 * scale, center.dy + 58 * scale)
      ..moveTo(center.dx, center.dy + 18 * scale)
      ..lineTo(center.dx + 18 * scale, center.dy + 58 * scale);
    canvas.drawPath(body, paint);
  }

  @override
  bool shouldRepaint(covariant _NeutralFigurePainter oldDelegate) =>
      oldDelegate.color != color;
}
