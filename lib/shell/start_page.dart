import 'package:drift/drift.dart' hide Column;
import 'package:flexify/database/database.dart';
import 'package:flexify/l10n/l10n.dart';
import 'package:flexify/main.dart';
import 'package:flexify/shell/training_stats.dart';
import 'package:flexify/theme/alpha_theme.dart';
import 'package:flexify/update/app_update.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  late Future<_Dashboard> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_Dashboard>(
      future: _future,
      builder: (context, snapshot) {
        final data = snapshot.data;
        if (data == null) {
          return const Center(child: CircularProgressIndicator());
        }
        final l10n = context.l10n;
        final palette = AlphaTheme.of(context);
        final name = context.select<Setting, String?>(
          (settings) => settings.profileName,
        );
        final greeting = (name ?? '').trim().isEmpty
            ? 'Alpha'
            : l10n.helloName(name!.trim());
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: palette.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: palette.border),
              ),
              child: Row(
                children: [
                  Image.asset(palette.figureAsset, height: 96),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      greeting,
                      style: const TextStyle(
                        fontFamily: 'Bebas Neue',
                        fontSize: 36,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ValueListenableBuilder(
              valueListenable: pendingAppUpdate,
              builder: (context, release, _) {
                if (release == null) return const SizedBox.shrink();
                return Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () => downloadAndInstallUpdate(release),
                    child: Text(l10n.installUpdate),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    label: l10n.dayStreak(data.dayStreak),
                    icon: Icons.local_fire_department,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    label: l10n.weekStreak(data.weekStreak),
                    icon: Icons.calendar_view_week,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(l10n.thisWeek, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            _WeekStrip(days: data.weekDays, trained: data.trainedDays),
            const SizedBox(height: 20),
            _ChartCard(
              title: l10n.bodyWeightChart,
              points: data.weights,
              unit: 'kg',
              empty: l10n.noChartData,
            ),
            const SizedBox(height: 12),
            _ChartCard(
              title: l10n.strengthChart,
              points: data.strength,
              unit: 'kg',
              empty: l10n.noChartData,
              caption: data.strengthName == null
                  ? null
                  : (Localizations.localeOf(context).languageCode == 'de' &&
                            (data.strengthGerman ?? '').isNotEmpty
                        ? data.strengthGerman
                        : data.strengthName),
            ),
            const SizedBox(height: 12),
            _ChartCard(
              title: l10n.weeklyVolumeChart,
              points: data.weeklyVolume,
              unit: 'kg',
              empty: l10n.noChartData,
            ),
          ],
        );
      },
    );
  }
}

class _Dashboard {
  const _Dashboard({
    required this.dayStreak,
    required this.weekStreak,
    required this.weekDays,
    required this.trainedDays,
    required this.weights,
    required this.strength,
    required this.strengthName,
    required this.strengthGerman,
    required this.weeklyVolume,
  });

  final int dayStreak;
  final int weekStreak;
  final List<DateTime> weekDays;
  final Set<DateTime> trainedDays;
  final List<({DateTime x, double y})> weights;
  final List<({DateTime x, double y})> strength;
  final String? strengthName;
  final String? strengthGerman;
  final List<({DateTime x, double y})> weeklyVolume;
}

Future<_Dashboard> _load() async {
  final now = DateTime.now();
  final sets = await (db.select(db.exerciseSets).join([
    innerJoin(
      db.exercises,
      db.exercises.id.equalsExp(db.exerciseSets.exerciseId),
    ),
  ])).get();
  final trained = <DateTime>{};
  final bestByExercise = <int, _Lift>{};
  final dailyBest = <int, Map<DateTime, double>>{};
  final volumeByWeek = <DateTime, double>{};

  for (final row in sets) {
    final set = row.readTable(db.exerciseSets);
    final exercise = row.readTable(db.exercises);
    final day = dateOnly(set.timestamp);
    trained.add(day);
    final reps = set.reps ?? 0;
    final load = set.loadKg ?? 0;
    volumeByWeek[mondayOf(set.timestamp)] =
        (volumeByWeek[mondayOf(set.timestamp)] ?? 0) + reps * load;
    final estimate = estimatedOneRepMax(load, reps);
    if (estimate <= 0) continue;
    final current = bestByExercise[exercise.id];
    if (current == null || estimate > current.best) {
      bestByExercise[exercise.id] = _Lift(
        id: exercise.id,
        name: exercise.name,
        germanName: exercise.germanName,
        best: estimate,
      );
    }
    final perDay = dailyBest.putIfAbsent(exercise.id, () => {});
    final previous = perDay[day] ?? 0;
    if (estimate > previous) perDay[day] = estimate;
  }

  final weekStart = mondayOf(now);
  final weekDays = List.generate(
    7,
    (index) => weekStart.add(Duration(days: index)),
  );
  final weights = await (db.select(
    db.bodyWeights,
  )..orderBy([(row) => OrderingTerm.asc(row.timestamp)])).get();
  final top = bestByExercise.values.toList()
    ..sort((a, b) => b.best.compareTo(a.best));
  final leader = top.isEmpty ? null : top.first;
  final strength = leader == null
      ? <({DateTime x, double y})>[]
      : (dailyBest[leader.id]!.entries.toList()
              ..sort((a, b) => a.key.compareTo(b.key)))
            .map((entry) => (x: entry.key, y: entry.value))
            .toList();
  final volume =
      (volumeByWeek.entries.toList()..sort((a, b) => a.key.compareTo(b.key)))
          .map((entry) => (x: entry.key, y: entry.value))
          .toList();

  return _Dashboard(
    dayStreak: trainingDayStreak(trained, now),
    weekStreak: trainingWeekStreak(trained, now),
    weekDays: weekDays,
    trainedDays: trained,
    weights: [for (final row in weights) (x: row.timestamp, y: row.weightKg)],
    strength: strength,
    strengthName: leader?.name,
    strengthGerman: leader?.germanName,
    weeklyVolume: volume.length > 12
        ? volume.sublist(volume.length - 12)
        : volume,
  );
}

class _Lift {
  const _Lift({
    required this.id,
    required this.name,
    required this.germanName,
    required this.best,
  });

  final int id;
  final String name;
  final String? germanName;
  final double best;
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(child: Text(label)),
          ],
        ),
      ),
    );
  }
}

class _WeekStrip extends StatelessWidget {
  const _WeekStrip({required this.days, required this.trained});

  final List<DateTime> days;
  final Set<DateTime> trained;

  @override
  Widget build(BuildContext context) {
    final today = dateOnly(DateTime.now());
    return Row(
      children: [
        for (final day in days)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Column(
                children: [
                  Text(
                    MaterialLocalizations.of(
                      context,
                    ).narrowWeekdays[day.weekday % 7],
                  ),
                  const SizedBox(height: 6),
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: trained.contains(day)
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.surfaceContainerHighest,
                    child: Text(
                      '${day.day}',
                      style: TextStyle(
                        color: day == today
                            ? Theme.of(context).colorScheme.onPrimary
                            : null,
                        fontWeight: day == today ? FontWeight.bold : null,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({
    required this.title,
    required this.points,
    required this.unit,
    required this.empty,
    this.caption,
  });

  final String title;
  final List<({DateTime x, double y})> points;
  final String unit;
  final String empty;
  final String? caption;

  @override
  Widget build(BuildContext context) {
    final latest = points.isEmpty ? null : points.last.y;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            if (caption != null)
              Text(caption!, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 12),
            if (points.length < 2)
              Text(empty)
            else ...[
              SizedBox(height: 120, child: _Sparkline(points: points)),
              const SizedBox(height: 8),
              Text(
                '${latest!.toStringAsFixed(1)} $unit',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Sparkline extends StatelessWidget {
  const _Sparkline({required this.points});

  final List<({DateTime x, double y})> points;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _SparklinePainter(
        values: [for (final point in points) point.y],
        color: Theme.of(context).colorScheme.primary,
      ),
      child: const SizedBox.expand(),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  _SparklinePainter({required this.values, required this.color});

  final List<double> values;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final minY = values.reduce((a, b) => a < b ? a : b);
    final maxY = values.reduce((a, b) => a > b ? a : b);
    final span = (maxY - minY).abs() < 0.001 ? 1.0 : maxY - minY;
    final path = Path();
    for (var i = 0; i < values.length; i++) {
      final x = values.length == 1
          ? size.width / 2
          : size.width * i / (values.length - 1);
      final y =
          size.height - ((values[i] - minY) / span) * (size.height - 8) - 4;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) =>
      oldDelegate.values != values || oldDelegate.color != color;
}
