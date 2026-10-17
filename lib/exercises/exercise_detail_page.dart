import 'dart:io';

import 'package:drift/drift.dart' hide Column;
import 'package:flexify/database/catalog_seed.dart';
import 'package:flexify/database/database.dart';
import 'package:flexify/exercise_labels.dart';
import 'package:flexify/l10n/l10n.dart';
import 'package:flexify/main.dart';
import 'package:flexify/platform_page_route.dart';
import 'package:flexify/shell/training_stats.dart';
import 'package:flexify/theme/alpha_theme.dart';
import 'package:flexify/workout/muscle_map.dart';
import 'package:flutter/material.dart';

class ExerciseDetailPage extends StatefulWidget {
  const ExerciseDetailPage({super.key, required this.exercise, this.onAdd});

  final Exercise exercise;
  final VoidCallback? onAdd;

  @override
  State<ExerciseDetailPage> createState() => _ExerciseDetailPageState();
}

class _ExerciseDetailPageState extends State<ExerciseDetailPage> {
  var _metric = 'weight';

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = AlphaTheme.of(context);
    final title = localizedExerciseName(
      context,
      widget.exercise.name,
      german: widget.exercise.germanName,
    );
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: palette.background,
        appBar: AppBar(
          title: Text(title),
          bottom: TabBar(
            tabs: [
              Tab(text: l10n.tabOverview),
              Tab(text: l10n.tabHistory),
              Tab(text: l10n.tabHowTo),
            ],
          ),
        ),
        bottomNavigationBar: widget.onAdd == null
            ? null
            : SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: FilledButton(
                    key: const Key('confirm-add-exercise'),
                    onPressed: () {
                      widget.onAdd!();
                      Navigator.pop(context, widget.exercise);
                    },
                    child: Text(l10n.confirmAddExercise),
                  ),
                ),
              ),
        body: StreamBuilder<List<ExerciseSet>>(
          stream:
              (db.select(db.exerciseSets)
                    ..where((row) => row.exerciseId.equals(widget.exercise.id))
                    ..orderBy([(row) => OrderingTerm.desc(row.timestamp)]))
                  .watch(),
          builder: (context, snapshot) {
            final sets = snapshot.data ?? const <ExerciseSet>[];
            return TabBarView(
              children: [
                _overview(context, sets, title),
                _history(context, sets),
                _howto(context),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _overview(BuildContext context, List<ExerciseSet> sets, String title) {
    final l10n = context.l10n;
    final palette = AlphaTheme.of(context);
    final exercise = widget.exercise;
    final primary = decodeCatalogList(exercise.primaryMuscles);
    final secondary = decodeCatalogList(exercise.secondaryMuscles);
    final primaryText = primary.isEmpty
        ? (exercise.muscle ?? '')
        : primary.map((key) => muscleLabel(l10n, key)).join(', ');
    final gear = (exercise.equipment ?? '').trim();
    final working = sets.where((set) => !(set.notes ?? '').contains('warmup'));
    double bestWeight = 0;
    double bestEstimate = 0;
    final points = <({DateTime x, double y})>[];
    final byDay = <DateTime, double>{};
    for (final set in working) {
      final load = set.loadKg ?? 0;
      final reps = set.reps ?? 0;
      if (load > bestWeight) bestWeight = load;
      final estimate = estimatedOneRepMax(load, reps);
      if (estimate > bestEstimate) bestEstimate = estimate;
      final day = dateOnly(set.timestamp);
      final metric = switch (_metric) {
        'oneRm' => estimate,
        'volume' => load * reps,
        _ => load,
      };
      final previous = byDay[day] ?? 0;
      if (metric > previous) byDay[day] = metric;
    }
    final days = byDay.keys.toList()..sort();
    for (final day in days) {
      points.add((x: day, y: byDay[day]!));
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        _image(exercise.image, palette),
        const SizedBox(height: 12),
        Text(
          '${l10n.primaryMuscleLabel}: ${primaryText.isEmpty ? '—' : primaryText}',
        ),
        if (secondary.isNotEmpty)
          Text(
            '${l10n.secondaryMuscleLabel}: ${secondary.map((key) => muscleLabel(l10n, key)).join(', ')}',
          ),
        Text('${l10n.equipmentLabel}: ${gear.isEmpty ? '—' : gear}'),
        _alternatives(context, exercise),
        if ((exercise.catalogSource ?? '').trim().isNotEmpty ||
            (exercise.catalogLicense ?? '').trim().isNotEmpty)
          Text(
            '${l10n.sourceLabel}: ${exercise.catalogSource ?? ''} · ${l10n.licenseLabel}: ${exercise.catalogLicense ?? ''}',
          ),
        if ((exercise.imageSource ?? '').trim().isNotEmpty ||
            (exercise.imageLicense ?? '').trim().isNotEmpty)
          Text(
            '${l10n.imageSourceLabel}: ${exercise.imageSource ?? ''} · ${l10n.imageLicenseLabel}: ${exercise.imageLicense ?? ''}',
          ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: [
            ChoiceChip(
              label: Text(l10n.heaviestWeight),
              selected: _metric == 'weight',
              onSelected: (_) => setState(() => _metric = 'weight'),
            ),
            ChoiceChip(
              label: Text(l10n.estimatedOneRm),
              selected: _metric == 'oneRm',
              onSelected: (_) => setState(() => _metric = 'oneRm'),
            ),
            ChoiceChip(
              label: Text(l10n.volumeChart),
              selected: _metric == 'volume',
              onSelected: (_) => setState(() => _metric = 'volume'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (points.length < 2)
          const SizedBox.shrink()
        else
          SizedBox(
            height: 140,
            child: CustomPaint(
              painter: _SparkPainter(points: points, color: palette.accent),
            ),
          ),
        const SizedBox(height: 12),
        Text(l10n.recordsTitle, style: Theme.of(context).textTheme.titleMedium),
        Text('${l10n.heaviestWeight}: ${_num(bestWeight)} kg'),
        Text('${l10n.estimatedOneRm}: ${_num(bestEstimate)} kg'),
      ],
    );
  }

  Widget _history(BuildContext context, List<ExerciseSet> sets) {
    if (sets.isEmpty) return Center(child: Text(context.l10n.noHistory));
    return ListView.builder(
      itemCount: sets.length,
      itemBuilder: (context, index) {
        final set = sets[index];
        final warmup =
            (set.notes ?? '').contains('[warmup') ||
            (set.notes ?? '').contains('warmup]');
        return ListTile(
          title: Text(
            '${warmup ? '${context.l10n.warmupMark} ' : ''}${_num(set.loadKg ?? 0)} kg × ${_num(set.reps ?? 0)}',
          ),
          subtitle: Text(
            MaterialLocalizations.of(context).formatShortDate(set.timestamp),
          ),
        );
      },
    );
  }

  Widget _howto(BuildContext context) {
    final steps = decodeCatalogList(widget.exercise.steps);
    final tips = decodeCatalogList(widget.exercise.tips);
    if (steps.isEmpty && tips.isEmpty) {
      return Center(child: Text(context.l10n.noHistory));
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (var index = 0; index < steps.length; index++)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text('${index + 1}. ${steps[index]}'),
          ),
        if (tips.isNotEmpty) ...[
          Text(
            context.l10n.tipsLabel,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          for (final tip in tips)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(tip),
            ),
        ],
      ],
    );
  }

  Widget _alternatives(BuildContext context, Exercise exercise) {
    final ids = decodeCatalogList(exercise.alternatives);
    if (ids.isEmpty) return const SizedBox.shrink();
    return FutureBuilder<List<Exercise>>(
      future: (db.select(
        db.exercises,
      )..where((row) => row.catalogId.isIn(ids))).get(),
      builder: (context, snapshot) {
        final rows = snapshot.data ?? const <Exercise>[];
        if (rows.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(context.l10n.alternativesLabel),
              for (final row in rows)
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      FlexPageRoute(
                        builder: (context) => ExerciseDetailPage(exercise: row),
                      ),
                    );
                  },
                  child: Text(
                    localizedExerciseName(
                      context,
                      row.name,
                      german: row.germanName,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _image(String? stored, AlphaPalette palette) {
    final path = (stored ?? '').trim();
    if (path.isEmpty) return _NeutralExerciseImage(palette: palette);
    if (path.startsWith('assets/')) {
      return Image.asset(
        path,
        height: 180,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stack) =>
            _NeutralExerciseImage(palette: palette),
      );
    }
    return Image.file(
      File(path),
      height: 180,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stack) =>
          _NeutralExerciseImage(palette: palette),
    );
  }
}

class _NeutralExerciseImage extends StatelessWidget {
  const _NeutralExerciseImage({required this.palette});

  final AlphaPalette palette;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
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
    canvas.drawCircle(center + const Offset(0, -48), 14, paint);
    final body = Path()
      ..moveTo(center.dx, center.dy - 32)
      ..lineTo(center.dx, center.dy + 18)
      ..moveTo(center.dx, center.dy - 18)
      ..lineTo(center.dx - 28, center.dy + 4)
      ..moveTo(center.dx, center.dy - 18)
      ..lineTo(center.dx + 28, center.dy + 4)
      ..moveTo(center.dx, center.dy + 18)
      ..lineTo(center.dx - 18, center.dy + 58)
      ..moveTo(center.dx, center.dy + 18)
      ..lineTo(center.dx + 18, center.dy + 58);
    canvas.drawPath(body, paint);
  }

  @override
  bool shouldRepaint(covariant _NeutralFigurePainter oldDelegate) =>
      oldDelegate.color != color;
}

String _num(double value) {
  if (value == value.roundToDouble()) return value.round().toString();
  return value.toStringAsFixed(1);
}

class _SparkPainter extends CustomPainter {
  _SparkPainter({required this.points, required this.color});

  final List<({DateTime x, double y})> points;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;
    final minY = points.map((point) => point.y).reduce((a, b) => a < b ? a : b);
    final maxY = points.map((point) => point.y).reduce((a, b) => a > b ? a : b);
    final span = (maxY - minY).abs() < 0.01 ? 1.0 : maxY - minY;
    final path = Path();
    for (var index = 0; index < points.length; index++) {
      final dx = size.width * index / (points.length - 1);
      final dy =
          size.height -
          ((points[index].y - minY) / span) * (size.height - 8) -
          4;
      if (index == 0) {
        path.moveTo(dx, dy);
      } else {
        path.lineTo(dx, dy);
      }
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant _SparkPainter oldDelegate) => true;
}
