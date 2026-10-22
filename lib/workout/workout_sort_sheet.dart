import 'dart:math' as math;

import 'package:flexify/l10n/l10n.dart';
import 'package:flexify/theme/alpha_theme.dart';
import 'package:flutter/material.dart';

class SortableExercise {
  const SortableExercise({required this.id, required this.name});

  final int id;
  final String name;
}

Future<List<int>?> showWorkoutSortSheet(
  BuildContext context, {
  required List<SortableExercise> exercises,
  required int highlightedId,
}) {
  final palette = AlphaTheme.of(context);
  return showModalBottomSheet<List<int>>(
    context: context,
    isScrollControlled: true,
    isDismissible: true,
    backgroundColor: palette.card,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (context) =>
        WorkoutSortSheet(exercises: exercises, highlightedId: highlightedId),
  );
}

class WorkoutSortSheet extends StatefulWidget {
  const WorkoutSortSheet({
    super.key,
    required this.exercises,
    required this.highlightedId,
  });

  final List<SortableExercise> exercises;
  final int highlightedId;

  @override
  State<WorkoutSortSheet> createState() => _WorkoutSortSheetState();
}

class _WorkoutSortSheetState extends State<WorkoutSortSheet> {
  late final List<SortableExercise> _items = [...widget.exercises];

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = AlphaTheme.of(context);
    final media = MediaQuery.sizeOf(context);
    final estimated = 220.0 + _items.length * 72;
    final height = math.min(media.height * 0.92, math.max(520.0, estimated));
    return SafeArea(
      child: SizedBox(
        key: const Key('workout-sort-sheet'),
        height: height,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: palette.border,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              Text(
                l10n.sortExercisesTitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Bebas Neue',
                  fontSize: 32,
                  color: palette.text,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.sortExercisesHint,
                textAlign: TextAlign.center,
                style: TextStyle(color: palette.muted, fontSize: 13),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ReorderableListView.builder(
                  buildDefaultDragHandles: false,
                  itemCount: _items.length,
                  onReorderItem: (oldIndex, newIndex) {
                    setState(() {
                      final item = _items.removeAt(oldIndex);
                      _items.insert(newIndex, item);
                    });
                  },
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    final highlighted = item.id == widget.highlightedId;
                    return Padding(
                      key: ValueKey('sort-row-${item.id}'),
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Material(
                        color: highlighted
                            ? palette.accent.withValues(alpha: 0.16)
                            : palette.background,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: BorderSide(
                            color: highlighted
                                ? palette.accent
                                : palette.border,
                            width: highlighted ? 2 : 1,
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.only(left: 8),
                          leading: ReorderableDragStartListener(
                            index: index,
                            child: Padding(
                              key: Key('sort-handle-${item.id}'),
                              padding: const EdgeInsets.all(8),
                              child: Icon(
                                Icons.drag_handle,
                                color: palette.muted,
                              ),
                            ),
                          ),
                          title: Text(
                            item.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: palette.text,
                              fontWeight: highlighted
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              FilledButton(
                key: const Key('workout-sort-done'),
                onPressed: () => Navigator.pop(
                  context,
                  _items.map((item) => item.id).toList(),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: palette.accent,
                  foregroundColor: palette.onAccent,
                  minimumSize: const Size.fromHeight(48),
                ),
                child: Text(l10n.actionDone),
              ),
              TextButton(
                key: const Key('workout-sort-cancel'),
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.actionCancel),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
