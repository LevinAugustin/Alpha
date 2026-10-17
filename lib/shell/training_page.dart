import 'package:drift/drift.dart' hide Column;
import 'package:flexify/database/database.dart';
import 'package:flexify/exercise_labels.dart';
import 'package:flexify/l10n/l10n.dart';
import 'package:flexify/main.dart';
import 'package:flexify/plan/edit_plan_page.dart';
import 'package:flexify/plan/start_plan_page.dart';
import 'package:flexify/platform_page_route.dart';
import 'package:flutter/material.dart';

const maxWorkoutTemplates = 7;

class TrainingPage extends StatelessWidget {
  const TrainingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Plan>>(
      stream: (db.select(
        db.plans,
      )..orderBy([(row) => OrderingTerm.asc(row.sequence)])).watch(),
      builder: (context, planSnapshot) {
        final plans = planSnapshot.data ?? const <Plan>[];
        return StreamBuilder<List<TypedResult>>(
          stream: (db.select(db.planExercises).join([
            innerJoin(
              db.exercises,
              db.exercises.id.equalsExp(db.planExercises.exerciseId),
            ),
          ])..where(db.planExercises.enabled.equals(true))).watch(),
          builder: (context, exerciseSnapshot) {
            final grouped = <int, List<TypedResult>>{};
            for (final row in exerciseSnapshot.data ?? const <TypedResult>[]) {
              final planId = row.readTable(db.planExercises).planId;
              grouped.putIfAbsent(planId, () => []).add(row);
            }
            for (final rows in grouped.values) {
              rows.sort(
                (a, b) => a
                    .readTable(db.planExercises)
                    .sequence
                    .compareTo(b.readTable(db.planExercises).sequence),
              );
            }
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                if (plans.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Text(context.l10n.templatesEmpty),
                  ),
                for (final plan in plans)
                  _TemplateCard(
                    plan: plan,
                    exercises: grouped[plan.id] ?? const [],
                  ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: plans.length >= maxWorkoutTemplates
                      ? null
                      : () => _createTemplate(context),
                  icon: const Icon(Icons.add),
                  label: Text(context.l10n.newTemplate),
                ),
                if (plans.length >= maxWorkoutTemplates)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(context.l10n.templateLimit),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _createTemplate(BuildContext context) async {
    final count = await db.plans.count().getSingle();
    if (!context.mounted) return;
    if (count >= maxWorkoutTemplates) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.templateLimit)));
      return;
    }
    await Navigator.of(context).push(
      FlexPageRoute(
        builder: (context) =>
            EditPlanPage(plan: PlansCompanion.insert(days: '')),
      ),
    );
  }
}

class _TemplateCard extends StatelessWidget {
  const _TemplateCard({required this.plan, required this.exercises});

  final Plan plan;
  final List<TypedResult> exercises;

  @override
  Widget build(BuildContext context) {
    final title = (plan.title ?? '').trim().isEmpty
        ? (plan.days.trim().isEmpty ? context.l10n.newTemplate : plan.days)
        : plan.title!.trim();
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            FlexPageRoute(builder: (context) => StartPlanPage(plan: plan)),
          );
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  IconButton(
                    tooltip: context.l10n.actionEdit,
                    onPressed: () {
                      Navigator.of(context).push(
                        FlexPageRoute(
                          builder: (context) => EditPlanPage(
                            plan: PlansCompanion(
                              id: Value(plan.id),
                              days: Value(plan.days),
                              sequence: Value(plan.sequence),
                              title: Value(plan.title),
                            ),
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.edit_outlined),
                  ),
                ],
              ),
              if (exercises.isEmpty)
                Text(context.l10n.templatesEmpty)
              else
                for (final row in exercises.take(8))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(_line(context, row)),
                  ),
            ],
          ),
        ),
      ),
    );
  }

  String _line(BuildContext context, TypedResult row) {
    final exercise = row.readTable(db.exercises);
    final planExercise = row.readTable(db.planExercises);
    final name = localizedExerciseName(
      context,
      exercise.name,
      german: exercise.germanName,
    );
    final sets = planExercise.maxSets;
    final range = formatRepRange(planExercise.repMin, planExercise.repMax);
    final details = [
      if (sets != null) context.l10n.targetSets(sets),
      if (range != null) context.l10n.repRangeLabel(range),
    ].join(' · ');
    if (details.isEmpty) return name;
    return '$name · $details';
  }
}
