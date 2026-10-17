import 'dart:async';

import 'package:drift/drift.dart' hide Column;
import 'package:flexify/database/database.dart';
import 'package:flexify/l10n/l10n.dart';
import 'package:flexify/main.dart';
import 'package:flexify/plan/start_plan_page.dart';
import 'package:flexify/platform_page_route.dart';
import 'package:flexify/settings/whats_new.dart';
import 'package:flexify/shell/calendar_page.dart';
import 'package:flexify/shell/exercises_page.dart';
import 'package:flexify/shell/profile_page.dart';
import 'package:flexify/shell/start_page.dart';
import 'package:flexify/shell/training_page.dart';
import 'package:flexify/timer/timer_progress_widgets.dart';
import 'package:flexify/timer/timer_state.dart';
import 'package:flexify/utils.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _index = 0;
  late final TimerState _timerState;

  @override
  void initState() {
    super.initState();
    _timerState = context.read<TimerState>();
    _timerState.addListener(_handleTimerNotificationTarget);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleTimerNotificationTarget();
    });
    unawaited(_announceVersion());
  }

  Future<void> _announceVersion() async {
    try {
      final pkg = await PackageInfo.fromPlatform();
      final buildNumber = int.tryParse(pkg.buildNumber);
      if (buildNumber == null) return;
      final settings = await (db.settings.select()..limit(1)).getSingle();
      final previousBuildNumber = settings.buildNumber;
      await db.settings.update().write(
        SettingsCompanion(buildNumber: Value(buildNumber)),
      );
      if (previousBuildNumber == null || buildNumber == previousBuildNumber) {
        return;
      }
      if (!mounted) return;
      toast(
        context.l10n.newVersion(pkg.version),
        action: SnackBarAction(
          label: context.l10n.changes,
          onPressed: () => Navigator.of(
            context,
          ).push(FlexPageRoute(builder: (context) => const WhatsNew())),
        ),
      );
    } catch (_) {}
  }

  Future<void> _handleTimerNotificationTarget() async {
    if (!mounted) return;
    final target = _timerState.consumeNotificationTarget();
    if (target == null || !target.startsWith('plan:')) return;
    final planId = int.tryParse(target.substring('plan:'.length));
    if (planId == null) return;
    final plan =
        await (db.plans.select()..where((row) => row.id.equals(planId)))
            .getSingleOrNull();
    if (plan == null || !mounted) return;
    setState(() => _index = 1);
    await Navigator.of(context).push(
      FlexPageRoute(
        settings: RouteSettings(name: 'start-plan:$planId'),
        builder: (context) => StartPlanPage(plan: plan),
      ),
    );
  }

  @override
  void dispose() {
    _timerState.removeListener(_handleTimerNotificationTarget);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final titles = [
      l10n.tabStart,
      l10n.tabTraining,
      l10n.tabExercises,
      l10n.tabProfile,
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text(titles[_index]),
        actions: [
          IconButton(
            key: const Key('open-calendar'),
            tooltip: l10n.calendarTitle,
            onPressed: () {
              Navigator.of(
                context,
              ).push(FlexPageRoute(builder: (context) => const CalendarPage()));
            },
            icon: const Icon(Icons.calendar_month),
          ),
        ],
      ),
      body: Column(
        children: [
          const TimerProgressIndicator(),
          Expanded(
            child: IndexedStack(
              index: _index,
              children: const [
                StartPage(),
                TrainingPage(),
                ExercisesPage(),
                ProfilePage(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (index) => setState(() => _index = index),
        destinations: [
          NavigationDestination(
            key: const Key('tab-start'),
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: l10n.tabStart,
          ),
          NavigationDestination(
            key: const Key('tab-training'),
            icon: const Icon(Icons.fitness_center_outlined),
            selectedIcon: const Icon(Icons.fitness_center),
            label: l10n.tabTraining,
          ),
          NavigationDestination(
            key: const Key('tab-exercises'),
            icon: const Icon(Icons.list_alt_outlined),
            selectedIcon: const Icon(Icons.list_alt),
            label: l10n.tabExercises,
          ),
          NavigationDestination(
            key: const Key('tab-profile'),
            icon: const Icon(Icons.person_outline),
            selectedIcon: const Icon(Icons.person),
            label: l10n.tabProfile,
          ),
        ],
      ),
    );
  }
}
