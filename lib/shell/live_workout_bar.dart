import 'dart:async';

import 'package:flexify/alpha/live_workout.dart';
import 'package:flexify/l10n/l10n.dart';
import 'package:flexify/main.dart';
import 'package:flexify/platform_page_route.dart';
import 'package:flexify/theme/alpha_theme.dart';
import 'package:flexify/timer/timer_state.dart';
import 'package:flexify/workout/gym_workout_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LiveWorkoutBar extends StatelessWidget {
  const LiveWorkoutBar({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<LiveWorkout?>(
      valueListenable: liveWorkout,
      builder: (context, session, _) {
        if (session == null) return const SizedBox.shrink();
        final palette = AlphaTheme.of(context);
        final l10n = context.l10n;
        return Material(
          color: palette.card,
          child: SafeArea(
            top: false,
            child: InkWell(
              onTap: () => _open(context, session),
              child: Container(
                height: 58,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: palette.accent)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: ListenableBuilder(
                        listenable: context.read<TimerState>(),
                        builder: (context, _) {
                          final timer = context.read<TimerState>().timer;
                          final running = timer.isRunning();
                          final remaining = running
                              ? timer.getRemaining()
                              : Duration.zero;
                          final clock = running
                              ? '${remaining.inMinutes.remainder(60)}:${remaining.inSeconds.remainder(60).toString().padLeft(2, '0')}'
                              : l10n.liveWorkoutLabel;
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                clock,
                                style: TextStyle(
                                  color: palette.accent,
                                  fontFamily: 'Bebas Neue',
                                  fontSize: 20,
                                ),
                              ),
                              Text(
                                session.exercise,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    IconButton(
                      tooltip: l10n.discardWorkoutAsk,
                      onPressed: () => _discard(context, session),
                      icon: Icon(Icons.delete_outline, color: palette.accent),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _open(BuildContext context, LiveWorkout session) async {
    final plan = await (db.select(
      db.plans,
    )..where((row) => row.id.equals(session.planId))).getSingleOrNull();
    if (plan == null || !context.mounted) return;
    await Navigator.of(context).push(
      FlexPageRoute(
        settings: RouteSettings(name: 'start-plan:${plan.id}'),
        builder: (context) => GymWorkoutPage(plan: plan),
      ),
    );
  }

  Future<void> _discard(BuildContext context, LiveWorkout session) async {
    final l10n = context.l10n;
    final palette = AlphaTheme.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: palette.card,
        title: Text(l10n.discardWorkoutAsk),
        content: Text(l10n.discardWorkoutBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.actionDelete),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await (db.delete(
      db.exerciseSets,
    )..where((row) => row.workoutId.equals(session.workoutId))).go();
    await (db.delete(
      db.workouts,
    )..where((row) => row.id.equals(session.workoutId))).go();
    if (liveWorkout.value?.workoutId == session.workoutId) {
      liveWorkout.value = null;
    }
  }
}
