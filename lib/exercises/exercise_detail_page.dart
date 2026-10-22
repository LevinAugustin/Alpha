import 'package:drift/drift.dart' hide Column;
import 'package:flexify/alpha/unilateral_sets.dart';
import 'package:flexify/database/catalog_seed.dart';
import 'package:flexify/database/database.dart';
import 'package:flexify/exercise_labels.dart';
import 'package:flexify/exercises/custom_exercise.dart';
import 'package:flexify/exercises/exercise_image.dart';
import 'package:flexify/exercises/exercise_variants.dart';
import 'package:flexify/exercises/custom_exercise_page.dart';
import 'package:flexify/feedback/feedback_page.dart';
import 'package:flexify/l10n/generated/app_localizations.dart';
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
  var _variantKey = '';

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = AlphaTheme.of(context);
    final title = localizedExerciseName(
      context,
      widget.exercise.name,
      german: widget.exercise.germanName,
      english: widget.exercise.englishName,
    );
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: palette.background,
        appBar: AppBar(
          title: Text(title),
          actions: [
            IconButton(
              key: const Key('exercise-feedback'),
              tooltip: l10n.feedbackSettings,
              onPressed: () {
                Navigator.of(context).push(
                  FlexPageRoute(
                    builder: (context) => FeedbackPage(
                      exerciseName: title,
                      exerciseId:
                          widget.exercise.catalogId ?? widget.exercise.name,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.feedback_outlined),
            ),
            if (isCustomExercise(widget.exercise)) ...[
              IconButton(
                key: const Key('edit-custom-exercise'),
                tooltip: l10n.editCustomExercise,
                onPressed: () async {
                  final navigator = Navigator.of(context);
                  final saved = await navigator.push<Exercise>(
                    FlexPageRoute(
                      builder: (context) =>
                          CustomExercisePage(exercise: widget.exercise),
                    ),
                  );
                  if (saved == null || !mounted) return;
                  navigator.pushReplacement(
                    FlexPageRoute(
                      builder: (context) => ExerciseDetailPage(
                        exercise: saved,
                        onAdd: widget.onAdd,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.edit_outlined),
              ),
              IconButton(
                key: const Key('delete-custom-exercise'),
                tooltip: l10n.deleteCustomExercise,
                onPressed: () async {
                  final navigator = Navigator.of(context);
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(l10n.deleteCustomExercise),
                      content: Text(l10n.deleteCustomExerciseBody),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: Text(l10n.actionReject),
                        ),
                        FilledButton(
                          key: const Key('confirm-delete-custom-exercise'),
                          onPressed: () => Navigator.pop(context, true),
                          child: Text(l10n.deleteCustomExercise),
                        ),
                      ],
                    ),
                  );
                  if (confirmed != true || !mounted) return;
                  await deleteCustomExercise(db, widget.exercise);
                  if (!mounted) return;
                  navigator.pop();
                },
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ],
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
    final gear = localizedGear(
      l10n,
      exercise.equipment,
      catalogId: exercise.catalogId,
    );
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
      final volume = unilateralVolume(
        unilateral: exercise.einseitig,
        side: set.side,
        loadKg: load,
        reps: reps,
      );
      final metric = switch (_metric) {
        'oneRm' => estimate,
        'volume' => volume,
        _ => load,
      };
      if (_metric == 'volume' && exercise.einseitig) {
        byDay[day] = (byDay[day] ?? 0) + metric;
        continue;
      }
      final previous = byDay[day] ?? 0;
      if (metric > previous) byDay[day] = metric;
    }
    final days = byDay.keys.toList()..sort();
    for (final day in days) {
      points.add((x: day, y: byDay[day]!));
    }
    return ListView(
      key: const Key('exercise-overview'),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        ExerciseImage(path: exercise.image),
        const SizedBox(height: 12),
        Text(
          '${l10n.primaryMuscleLabel}: ${primaryText.isEmpty ? '—' : primaryText}',
        ),
        if (secondary.isNotEmpty)
          Text(
            '${l10n.secondaryMuscleLabel}: ${secondary.map((key) => muscleLabel(l10n, key)).join(', ')}',
          ),
        Text('${l10n.equipmentLabel}: ${gear.isEmpty ? '—' : gear}'),
        if (catalogText(exercise.mechanic) case final mechanic?)
          Text('${l10n.mechanicLabel}: ${mechanicLabel(l10n, mechanic)}'),
        if (catalogText(exercise.bewegung) case final movement?)
          Text('${l10n.movementLabel}: ${movementLabel(l10n, movement)}'),
        if (catalogText(exercise.griff) case final grip?)
          Text(
            '${l10n.gripLabel}: ${localizedGrip(l10n, grip, catalogId: exercise.catalogId)}',
          ),
        if (catalogText(exercise.position) case final position?)
          Text(
            '${l10n.positionLabel}: ${localizedPosition(l10n, position, catalogId: exercise.catalogId)}',
          ),
        _family(context, exercise),
        _alternatives(context, exercise),
        if (_catalogCredit(l10n, exercise) case final credit?) Text(credit),
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
    final lines = groupSideSets(sets);
    if (lines.isEmpty) return Center(child: Text(context.l10n.noHistory));
    return ListView.builder(
      itemCount: lines.length,
      itemBuilder: (context, index) {
        final line = lines[index];
        final reps = line.repsText(
          (value) => _num(value ?? 0),
          leftName: context.l10n.sideLeft,
          rightName: context.l10n.sideRight,
        );
        return ListTile(
          title: Text(
            '${line.warmup ? '${context.l10n.warmupMark} ' : ''}${_num(line.kg)} kg × $reps',
          ),
          subtitle: Text(
            MaterialLocalizations.of(context).formatShortDate(line.time),
          ),
        );
      },
    );
  }

  Widget _howto(BuildContext context) {
    final variants = parseExerciseVariants(widget.exercise.variants);
    if (variants.isNotEmpty) {
      final active = variants.where((item) => item.key == _variantKey);
      if (active.isEmpty) return _variantChoice(context, variants);
      final variant = active.first;
      return _stepsPage(
        context,
        steps: variant.steps(context),
        tips: variant.tips(context),
        clip: variant.clipPath(),
        showClip: true,
        onBack: () => setState(() => _variantKey = ''),
      );
    }
    return _stepsPage(
      context,
      steps: localizedExerciseLines(
        context,
        german: widget.exercise.steps,
        english: widget.exercise.englishSteps,
      ),
      tips: localizedExerciseLines(
        context,
        german: widget.exercise.tips,
        english: widget.exercise.englishTips,
      ),
    );
  }

  Widget _variantChoice(BuildContext context, List<ExerciseVariant> variants) {
    final palette = AlphaTheme.of(context);
    return ListView(
      key: const Key('variant-choice'),
      padding: const EdgeInsets.all(16),
      children: [
        for (final variant in variants)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Material(
              color: palette.card,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: palette.border),
              ),
              child: InkWell(
                key: Key('variant-${variant.key}'),
                borderRadius: BorderRadius.circular(12),
                onTap: () => setState(() => _variantKey = variant.key),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 22,
                  ),
                  child: Text(
                    variant.label(context),
                    style: TextStyle(
                      fontFamily: 'Bebas Neue',
                      fontSize: 32,
                      letterSpacing: 0.6,
                      color: palette.text,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _stepsPage(
    BuildContext context, {
    required List<String> steps,
    required List<String> tips,
    String? clip,
    bool showClip = false,
    VoidCallback? onBack,
  }) {
    if (steps.isEmpty && tips.isEmpty && !showClip) {
      return Center(child: Text(context.l10n.noHistory));
    }
    return ListView(
      key: const Key('exercise-howto'),
      padding: const EdgeInsets.all(16),
      children: [
        if (onBack != null)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              key: const Key('variant-back'),
              onPressed: onBack,
              child: Text(context.l10n.otherVariant),
            ),
          ),
        if (showClip) ...[
          ExerciseImage(path: clip),
          const SizedBox(height: 12),
        ],
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

  String? _catalogCredit(AppLocalizations l10n, Exercise exercise) {
    final source = (exercise.catalogSource ?? '').trim();
    final license = (exercise.catalogLicense ?? '').trim();
    if (source == 'custom') {
      return '${l10n.sourceLabel}: ${l10n.ownExerciseSource}';
    }
    final parts = <String>[
      if (source.isNotEmpty) '${l10n.sourceLabel}: $source',
      if (license.isNotEmpty) '${l10n.licenseLabel}: $license',
    ];
    if (parts.isEmpty) return null;
    return parts.join(' · ');
  }

  String _variantLabel(BuildContext context, Exercise row) {
    final title = localizedExerciseName(
      context,
      row.name,
      german: row.germanName,
      english: row.englishName,
    );
    final category = localizedCategory(
      context.l10n,
      row.categoryName,
      catalogId: row.catalogId,
    );
    if (category.isEmpty) return title;
    return '$title · $category';
  }

  Widget _family(BuildContext context, Exercise exercise) {
    final family = (exercise.familie ?? '').trim();
    if (family.isEmpty) return const SizedBox.shrink();
    return FutureBuilder<List<Exercise>>(
      future:
          (db.select(db.exercises)..where(
                (row) =>
                    row.familie.equals(family) &
                    row.archived.equals(false) &
                    row.id.isNotValue(exercise.id),
              ))
              .get(),
      builder: (context, snapshot) {
        final rows = snapshot.data ?? const <Exercise>[];
        if (rows.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(context.l10n.otherVariants),
              for (final row in rows)
                TextButton(
                  key: Key('family-${row.catalogId ?? row.id}'),
                  onPressed: () {
                    Navigator.of(context).push(
                      FlexPageRoute(
                        builder: (context) => ExerciseDetailPage(exercise: row),
                      ),
                    );
                  },
                  child: Text(_variantLabel(context, row)),
                ),
            ],
          ),
        );
      },
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
                      english: row.englishName,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
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
