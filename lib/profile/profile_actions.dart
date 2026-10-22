import 'package:drift/drift.dart' hide Column;
import 'package:flexify/alpha/alpha_prefs.dart';
import 'package:flexify/alpha/live_workout.dart';
import 'package:flexify/database/database.dart';
import 'package:flexify/l10n/l10n.dart';
import 'package:flexify/main.dart';
import 'package:flexify/profile/local_profiles.dart';
import 'package:flexify/shell/language_choice_page.dart';
import 'package:flexify/theme/alpha_theme.dart';
import 'package:flutter/material.dart';

Future<bool> switchLocalProfile(
  BuildContext context,
  LocalProfile profile,
) async {
  final registry = await loadProfileRegistry();
  if (profile.id != registry.activeId) {
    final open = await (db.select(
      db.workouts,
    )..where((row) => row.endedAt.isNull())).get();
    if (open.isNotEmpty || liveWorkout.value != null) {
      if (!context.mounted) return false;
      final choice = await showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          final l10n = context.l10n;
          final palette = AlphaTheme.of(context);
          return AlertDialog(
            backgroundColor: palette.card,
            title: Text(l10n.finishBeforeSwitch),
            actions: [
              TextButton(
                key: const Key('switch-workout-cancel'),
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.actionCancel),
              ),
              TextButton(
                key: const Key('switch-workout-discard'),
                onPressed: () => Navigator.pop(context, 'discard'),
                child: Text(l10n.switchDiscardWorkout),
              ),
              FilledButton(
                key: const Key('switch-workout-finish'),
                onPressed: () => Navigator.pop(context, 'finish'),
                child: Text(l10n.switchFinishWorkout),
              ),
            ],
          );
        },
      );
      if (choice != 'finish' && choice != 'discard') return false;
      if (choice == 'finish') {
        await (db.update(db.workouts)..where((row) => row.endedAt.isNull()))
            .write(WorkoutsCompanion(endedAt: Value(DateTime.now())));
      } else {
        final ids = [for (final workout in open) workout.id];
        if (ids.isNotEmpty) {
          await (db.delete(
            db.exerciseSets,
          )..where((row) => row.workoutId.isIn(ids))).go();
          await (db.delete(db.workouts)..where((row) => row.id.isIn(ids))).go();
        }
      }
      liveWorkout.value = null;
      await alphaPrefs.clearRestDeadline();
    }
    await activateLocalProfile(profile);
  }
  await alphaPrefs.load(replace: true);
  return true;
}

Future<bool> startNewProfile(BuildContext context) async {
  final locale = await showLanguageChoice(context);
  if (locale == null || !context.mounted) return false;
  final controller = TextEditingController();
  final name = await showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(context.l10n.newProfile),
      content: TextField(
        key: const Key('new-profile-field'),
        controller: controller,
        autofocus: true,
        textCapitalization: TextCapitalization.words,
        decoration: InputDecoration(hintText: context.l10n.profileNameHint),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(context.l10n.actionCancel),
        ),
        FilledButton(
          key: const Key('new-profile-save'),
          onPressed: () => Navigator.pop(context, controller.text.trim()),
          child: Text(context.l10n.actionSave),
        ),
      ],
    ),
  );
  controller.dispose();
  final trimmed = name?.trim() ?? '';
  if (trimmed.isEmpty) return false;
  final profile = await createLocalProfile(trimmed, locale: locale);
  await activateLocalProfile(profile);
  await alphaPrefs.load(replace: true);
  alphaPrefs.languageAsked = true;
  await alphaPrefs.save();
  return true;
}
