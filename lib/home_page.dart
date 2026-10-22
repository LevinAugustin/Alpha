import 'dart:async';

import 'package:drift/drift.dart' hide Column;
import 'package:flexify/database/database.dart';
import 'package:flexify/l10n/l10n.dart';
import 'package:flexify/main.dart';
import 'package:flexify/platform_page_route.dart';
import 'package:flexify/profile/local_profiles.dart';
import 'package:flexify/profile/profile_actions.dart';
import 'package:flexify/theme/alpha_theme.dart';
import 'package:flexify/workout/gym_workout_page.dart';
import 'package:flexify/settings/whats_new.dart';
import 'package:flexify/shell/calendar_page.dart';
import 'package:flexify/shell/exercises_page.dart';
import 'package:flexify/shell/profile_page.dart';
import 'package:flexify/alpha/alpha_prefs.dart';
import 'package:flexify/shell/language_choice_page.dart';
import 'package:flexify/shell/start_page.dart';
import 'package:flexify/shell/training_page.dart';
import 'package:flexify/timer/timer_progress_widgets.dart';
import 'package:flexify/timer/timer_state.dart';
import 'package:flexify/utils.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

class _ProfileButton extends StatelessWidget {
  const _ProfileButton({required this.name});

  final String? name;

  @override
  Widget build(BuildContext context) {
    final palette = AlphaTheme.of(context);
    final label = (name ?? '').trim();
    return InkWell(
      key: const Key('profile-switch'),
      onTap: () => _switch(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: palette.card,
              backgroundImage: AssetImage(palette.figureAsset),
            ),
            if (label.isNotEmpty) ...[const SizedBox(width: 6), Text(label)],
            Icon(Icons.swap_horiz, color: palette.accent, size: 18),
          ],
        ),
      ),
    );
  }

  Future<void> _switch(BuildContext context) async {
    final registry = await loadProfileRegistry();
    if (!context.mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(context.l10n.chooseProfile),
        children: [
          for (final profile in registry.profiles)
            SimpleDialogOption(
              key: Key('profile-option-${profile.id}'),
              onPressed: () async {
                final switched = await switchLocalProfile(context, profile);
                if (switched && context.mounted) Navigator.pop(context);
              },
              child: Text(profile.name),
            ),
          SimpleDialogOption(
            key: const Key('profile-create'),
            onPressed: () async {
              final created = await startNewProfile(context);
              if (created && context.mounted) Navigator.pop(context);
            },
            child: Text(context.l10n.createProfileAction),
          ),
        ],
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _index = 0;
  final _startActive = ValueNotifier(true);
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
    unawaited(_offerStartup());
  }

  Future<void> _offerStartup() async {
    if (WidgetsBinding.instance.runtimeType.toString().contains('Test')) return;
    await _offerProfileChoice();
    await _offerLanguage();
  }

  Future<void> _offerLanguage() async {
    if (alphaPrefs.languageAsked || !mounted) return;
    try {
      final registry = await loadProfileRegistry();
      if (!registry.onboarded || !mounted) return;
      final choice = await showLanguageChoice(context);
      if (!mounted) return;
      final setting = await (db.select(db.settings)..limit(1)).getSingle();
      final current = (setting.localeOverride ?? '').trim();
      if (choice == 'de' || choice == 'en') {
        await db.settings.update().write(
          SettingsCompanion(localeOverride: Value(choice!)),
        );
      } else if (current.isEmpty) {
        await db.settings.update().write(
          const SettingsCompanion(localeOverride: Value('de')),
        );
      }
      alphaPrefs.languageAsked = true;
      await alphaPrefs.save();
    } catch (_) {}
  }

  Future<void> _offerProfileChoice() async {
    try {
      final registry = await loadProfileRegistry();
      if (!mounted || registry.profiles.length < 2) return;
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Text(context.l10n.chooseProfile),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final profile in registry.profiles)
                ListTile(
                  title: Text(profile.name),
                  trailing: profile.id == registry.activeId
                      ? const Icon(Icons.check)
                      : null,
                  onTap: () async {
                    final switched = await switchLocalProfile(context, profile);
                    if (switched && context.mounted) Navigator.pop(context);
                  },
                ),
              TextButton(
                onPressed: () async {
                  final created = await startNewProfile(context);
                  if (created && context.mounted) Navigator.pop(context);
                },
                child: Text(context.l10n.createProfileAction),
              ),
            ],
          ),
        ),
      );
    } catch (_) {}
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
        builder: (context) => GymWorkoutPage(plan: plan),
      ),
    );
  }

  @override
  void dispose() {
    _startActive.dispose();
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
          _ProfileButton(
            name: context.select<Setting, String?>((s) => s.profileName),
          ),
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
              children: [
                StartPage(active: _startActive),
                const TrainingPage(),
                const ExercisesPage(),
                const ProfilePage(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (index) {
          setState(() => _index = index);
          _startActive.value = index == 0;
        },
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
