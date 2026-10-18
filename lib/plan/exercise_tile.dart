import 'package:drift/drift.dart' hide Column;
import 'package:flexify/database/database.dart';
import 'package:flexify/exercise_labels.dart';
import 'package:flexify/l10n/l10n.dart';
import 'package:flexify/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ExerciseTile extends StatefulWidget {
  final PlanExercisesCompanion planExercise;
  final String exerciseName;
  final String germanName;
  final Function(PlanExercisesCompanion) onChange;

  const ExerciseTile({
    super.key,
    required this.onChange,
    required this.planExercise,
    required this.exerciseName,
    this.germanName = '',
  });

  @override
  State<ExerciseTile> createState() => _ExerciseTileState();
}

class _ExerciseTileState extends State<ExerciseTile> {
  late final TextEditingController _max;
  late final TextEditingController _warmup;
  late final TextEditingController _repMin;
  late final TextEditingController _repMax;
  late final TextEditingController _rest;

  @override
  void initState() {
    super.initState();
    final settings = context.read<Setting>();
    _max = TextEditingController(
      text:
          widget.planExercise.maxSets.value?.toString() ??
          settings.maxSets.toString(),
    );
    _warmup = TextEditingController(
      text:
          widget.planExercise.warmupSets.value?.toString() ??
          (settings.warmupSets ?? 0).toString(),
    );
    _repMin = TextEditingController(
      text: widget.planExercise.repMin.present
          ? (widget.planExercise.repMin.value?.toString() ?? '')
          : '',
    );
    _repMax = TextEditingController(
      text: widget.planExercise.repMax.present
          ? (widget.planExercise.repMax.value?.toString() ?? '')
          : '',
    );
    final restMs = widget.planExercise.restMs.present
        ? widget.planExercise.restMs.value
        : null;
    _rest = TextEditingController(
      text: restMs == null ? '' : '${(restMs / 1000).round()}',
    );
  }

  @override
  void dispose() {
    _max.dispose();
    _warmup.dispose();
    _repMin.dispose();
    _repMax.dispose();
    _rest.dispose();
    super.dispose();
  }

  void _writeReps() {
    widget.onChange(
      widget.planExercise.copyWith(
        enabled: const Value(true),
        repMin: Value(int.tryParse(_repMin.text)),
        repMax: Value(int.tryParse(_repMax.text)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: IconButton(
        tooltip: context.l10n.navSettings,
        icon: const Icon(Icons.settings),
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              bool timers = widget.planExercise.timers.present
                  ? widget.planExercise.timers.value
                  : true;

              return AlertDialog.adaptive(
                title: Text(widget.exerciseName),
                content: SingleChildScrollView(
                  child: Column(
                    children: [
                      Selector<Setting, int?>(
                        selector: (context, settings) => settings.warmupSets,
                        builder: (context, value, child) => TextField(
                          controller: _warmup,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: false,
                          ),
                          onTap: () => selectAll(_warmup),
                          onChanged: (value) {
                            final pe = widget.planExercise.copyWith(
                              enabled: const Value(true),
                              warmupSets: Value(int.tryParse(_warmup.text)),
                            );
                            widget.onChange(pe);
                          },
                          decoration: InputDecoration(
                            labelText: context.l10n.warmupSets,
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Selector<Setting, int>(
                        selector: (context, settings) => settings.maxSets,
                        builder: (context, value, child) => TextField(
                          controller: _max,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: false,
                          ),
                          onTap: () => selectAll(_max),
                          onChanged: (value) {
                            final parsed = int.tryParse(_max.text);
                            if (parsed != null && parsed > 0 && parsed <= 20) {
                              final pe = widget.planExercise.copyWith(
                                enabled: const Value(true),
                                maxSets: Value(parsed),
                              );
                              widget.onChange(pe);
                            }
                          },
                          decoration: InputDecoration(
                            labelText: context.l10n.workingSetsMax,
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                      TextField(
                        controller: _repMin,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: false,
                        ),
                        onTap: () => selectAll(_repMin),
                        onChanged: (_) => _writeReps(),
                        decoration: InputDecoration(
                          labelText: context.l10n.repMinLabel,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        key: const Key('plan-exercise-rest'),
                        controller: _rest,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: false,
                        ),
                        onTap: () => selectAll(_rest),
                        onChanged: (_) {
                          final seconds = int.tryParse(_rest.text.trim());
                          widget.onChange(
                            widget.planExercise.copyWith(
                              enabled: const Value(true),
                              restMs: Value(
                                seconds == null ? null : seconds * 1000,
                              ),
                            ),
                          );
                        },
                        decoration: InputDecoration(
                          labelText: context.l10n.restSecondsLabel,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _repMax,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: false,
                        ),
                        onTap: () => selectAll(_repMax),
                        onChanged: (_) => _writeReps(),
                        decoration: InputDecoration(
                          labelText: context.l10n.repMaxLabel,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      StatefulBuilder(
                        builder: (context, setState) => ListTile(
                          title: Text(context.l10n.restTimers),
                          trailing: Switch(
                            value: timers,
                            onChanged: (value) {
                              setState(() {
                                timers = value;
                              });
                              widget.onChange(
                                widget.planExercise.copyWith(
                                  timers: Value(value),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    label: Text(context.l10n.actionOk),
                    icon: const Icon(Icons.check),
                  ),
                ],
              );
            },
          );
        },
      ),
      title: Text(
        localizedExerciseName(
          context,
          widget.exerciseName,
          german: widget.germanName,
        ),
      ),
      subtitle: _rangeSubtitle(context),
      trailing: Switch(
        value: widget.planExercise.enabled.value,
        onChanged: (value) {
          widget.onChange(widget.planExercise.copyWith(enabled: Value(value)));
        },
      ),
      onTap: () {
        widget.onChange(
          widget.planExercise.copyWith(
            enabled: Value(!widget.planExercise.enabled.value),
          ),
        );
      },
    );
  }

  Widget? _rangeSubtitle(BuildContext context) {
    final range = formatRepRange(
      widget.planExercise.repMin.present
          ? widget.planExercise.repMin.value
          : null,
      widget.planExercise.repMax.present
          ? widget.planExercise.repMax.value
          : null,
    );
    final sets = widget.planExercise.maxSets.present
        ? widget.planExercise.maxSets.value
        : null;
    final parts = [
      if (sets != null) context.l10n.targetSets(sets),
      if (range != null) context.l10n.repRangeLabel(range),
    ];
    if (parts.isEmpty) return null;
    return Text(parts.join(' · '));
  }
}
