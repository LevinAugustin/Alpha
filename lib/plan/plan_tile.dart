import 'package:flexify/constants.dart';
import 'package:flexify/database/database.dart';
import 'package:flexify/l10n/l10n.dart';
import 'package:flexify/plan/plan_names.dart';
import 'package:flexify/plan/plan_queries.dart';
import 'package:flexify/plan/start_plan_page.dart';
import 'package:flexify/plan/workout_sessions.dart';
import 'package:flexify/responsive.dart';
import 'package:flexify/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flexify/platform_page_route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PlanTile extends StatefulWidget {
  final Plan plan;
  final List<PlanExerciseEntry>? exercises;
  final int index;
  final GlobalKey<NavigatorState> navigatorKey;
  final Function(int) onSelect;
  final Set<int> selected;
  final PlanCount? count;

  const PlanTile({
    super.key,
    required this.plan,
    required this.exercises,
    required this.index,
    required this.navigatorKey,
    required this.onSelect,
    required this.selected,
    required this.count,
  });

  @override
  State<PlanTile> createState() => _PlanTileState();
}

class _PlanTileState extends State<PlanTile> {
  @override
  Widget build(BuildContext context) {
    final name = planTitleOf(
      context,
      title: widget.plan.title,
      sequence: widget.plan.sequence,
      id: widget.plan.id,
    );
    final title = Text(name, style: Theme.of(context).textTheme.bodyLarge);

    final showImages = context.select<Setting, bool>(
      (settings) => settings.showImages,
    );

    Widget? leading;

    if (showImages)
      leading = GestureDetector(
        onTap: () => widget.onSelect(widget.plan.id),
        child: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              widget.plan.title?.isNotEmpty == true
                  ? widget.plan.title![0]
                  : name[0].toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ),
      );

    final desktop = isDesktopLayout(context);
    final colors = Theme.of(context).colorScheme;

    final tile = Material(
      color: widget.selected.contains(widget.plan.id)
          ? colors.primary.withValues(alpha: .18)
          : desktop
          ? colors.surfaceContainerLow
          : Colors.transparent,
      borderRadius: desktop ? BorderRadius.circular(16) : null,
      clipBehavior: desktop ? Clip.antiAlias : Clip.none,
      child: ListTile(
        contentPadding: desktop
            ? const EdgeInsets.symmetric(horizontal: 20, vertical: 10)
            : null,
        title: Row(children: [Flexible(child: title)]),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: widget.exercises == null
              ? Text(context.l10n.loadingExercises)
              : Text(
                  widget.exercises!
                      .map((entry) => entry.exercise.name)
                      .join('  •  '),
                  maxLines: desktop ? 2 : null,
                  overflow: desktop ? TextOverflow.ellipsis : null,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
        ),
        leading: leading,
        trailing: Builder(
          builder: (context) {
            final trailing = context.select<Setting, PlanTrailing>(
              (settings) => PlanTrailing.values.byName(
                settings.planTrailing.replaceFirst('PlanTrailing.', ''),
              ),
            );
            if (trailing == PlanTrailing.none) return const SizedBox();
            if (trailing == PlanTrailing.reorder && desktop) {
              return ReorderableDragStartListener(
                index: widget.index,
                child: Icon(
                  Icons.drag_indicator_rounded,
                  color: colors.onSurfaceVariant,
                ),
              );
            }
            if (trailing == PlanTrailing.reorder &&
                defaultTargetPlatform == TargetPlatform.linux)
              return const SizedBox();
            else if (trailing == PlanTrailing.reorder &&
                defaultTargetPlatform == TargetPlatform.android)
              return ReorderableDragStartListener(
                index: widget.index,
                child: const Icon(Icons.drag_handle),
              );

            final count = widget.count;
            if (count == null) return const SizedBox();

            if (trailing == PlanTrailing.count)
              return Text(
                formatDisplayNumber(
                  context,
                  count.total,
                  maximumFractionDigits: 0,
                ),
                style: const TextStyle(fontSize: 16),
              );

            if (trailing == PlanTrailing.percent)
              return Text(
                formatDisplayPercent(context, count.total / count.maxSets),
                style: const TextStyle(fontSize: 16),
              );
            else
              return Text(
                "${formatDisplayNumber(context, count.total, maximumFractionDigits: 0)} / ${formatDisplayNumber(context, count.maxSets, maximumFractionDigits: 0)}",
                style: const TextStyle(fontSize: 16),
              );
          },
        ),
        onTap: () {
          if (widget.selected.isNotEmpty) {
            widget.onSelect(widget.plan.id);
            return;
          }

          widget.navigatorKey.currentState!.push(
            FlexPageRoute(
              settings: RouteSettings(name: 'start-plan:${widget.plan.id}'),
              builder: (context) => StartPlanPage(
                plan: widget.plan,
                initialExercises: widget.exercises,
              ),
            ),
          );
        },
        onLongPress: desktop ? null : () => widget.onSelect(widget.plan.id),
      ),
    );

    if (!desktop) return tile;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onSecondaryTapDown: (_) => widget.onSelect(widget.plan.id),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        child: tile,
      ),
    );
  }
}
