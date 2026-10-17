import 'dart:io';

import 'package:drift/drift.dart' hide Column;
import 'package:flexify/database/database.dart';
import 'package:flexify/database/gym_catalog.dart';
import 'package:flexify/exercise_labels.dart';
import 'package:flexify/l10n/l10n.dart';
import 'package:flexify/main.dart';
import 'package:flexify/shell/training_stats.dart';
import 'package:flexify/theme/alpha_theme.dart';
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
    final info = gymInfoFor(widget.exercise.name);
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
                _overview(context, info, sets, title),
                _history(context, sets),
                _howto(context, info),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _overview(
    BuildContext context,
    GymInfo? info,
    List<ExerciseSet> sets,
    String title,
  ) {
    final l10n = context.l10n;
    final palette = AlphaTheme.of(context);
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
        _image(info, widget.exercise.image, palette),
        const SizedBox(height: 12),
        Text(
          '${l10n.primaryMuscleLabel}: ${info?.detailMuscle ?? widget.exercise.muscle ?? '—'}',
        ),
        if ((info?.secondary ?? '').isNotEmpty)
          Text('${l10n.secondaryMuscleLabel}: ${info!.secondary}'),
        Text('${l10n.equipmentLabel}: ${info?.equipment ?? '—'}'),
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

  Widget _howto(BuildContext context, GymInfo? info) {
    final steps = (info?.steps ?? widget.exercise.notes ?? '')
        .split('\n')
        .where((line) => line.trim().isNotEmpty)
        .toList();
    if (steps.isEmpty) return Center(child: Text(context.l10n.noHistory));
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (var index = 0; index < steps.length; index++)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text('${index + 1}. ${steps[index]}'),
          ),
      ],
    );
  }

  Widget _image(GymInfo? info, String? stored, AlphaPalette palette) {
    final path = (stored ?? '').isNotEmpty ? stored! : info?.image;
    if (path == null || path.isEmpty) {
      return Icon(Icons.fitness_center, size: 72, color: palette.muted);
    }
    if (path.startsWith('assets/')) {
      return Image.asset(path, height: 180, fit: BoxFit.contain);
    }
    return Image.file(
      File(path),
      height: 180,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stack) =>
          Icon(Icons.fitness_center, color: palette.muted),
    );
  }
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
