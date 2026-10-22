import 'package:drift/drift.dart' hide Column;
import 'package:flexify/alpha/alpha_prefs.dart';
import 'package:flexify/coach/api_key_store.dart';
import 'package:flexify/coach/coach_page.dart';
import 'package:flexify/database/database.dart';
import 'package:flexify/feedback/feedback_page.dart';
import 'package:flexify/import/import_export_page.dart';
import 'package:flexify/l10n/l10n.dart';
import 'package:flexify/main.dart';
import 'package:flexify/platform_page_route.dart';
import 'package:flexify/profile/local_profiles.dart';
import 'package:flexify/profile/profile_actions.dart';
import 'package:flexify/settings/format_settings.dart';
import 'package:flexify/settings/licenses_page.dart';
import 'package:flexify/theme/alpha_theme.dart';
import 'package:flexify/update/app_update.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

Future<bool> editWeeklyGoal(BuildContext context) async {
  final controller = TextEditingController(text: '${alphaPrefs.weeklyGoal}');
  var manual = alphaPrefs.weeklyGoalManual;
  final saved = await showDialog<bool>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Text(context.l10n.weekGoal),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(context.l10n.weekGoalManual),
              value: manual,
              onChanged: (value) => setState(() => manual = value),
            ),
            TextField(
              controller: controller,
              enabled: manual,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: context.l10n.sessionsPerWeek,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.l10n.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.l10n.actionSave),
          ),
        ],
      ),
    ),
  );
  final next = int.tryParse(controller.text.trim());
  controller.dispose();
  if (saved != true) return false;
  alphaPrefs.weeklyGoalManual = manual;
  if (manual && next != null && next > 0) alphaPrefs.weeklyGoal = next;
  await alphaPrefs.save();
  return true;
}

class AlphaSettingsPage extends StatefulWidget {
  const AlphaSettingsPage({super.key});

  @override
  State<AlphaSettingsPage> createState() => _AlphaSettingsPageState();
}

class _AlphaSettingsPageState extends State<AlphaSettingsPage> {
  final _search = TextEditingController();
  final _key = TextEditingController();
  var _loadedKey = false;

  @override
  void initState() {
    super.initState();
    _prepare();
  }

  Future<void> _prepare() async {
    await alphaPrefs.load();
    final stored = await readAiKey();
    if (!mounted) return;
    setState(() {
      _key.text = stored;
      _loadedKey = true;
    });
  }

  @override
  void dispose() {
    _search.dispose();
    _key.dispose();
    super.dispose();
  }

  bool _hit(String haystack) {
    final query = _search.text.trim().toLowerCase();
    if (query.isEmpty) return true;
    return haystack.toLowerCase().contains(query);
  }

  String? _languageCode(String? stored) {
    return switch ((stored ?? '').trim()) {
      'de' => 'de',
      'en' => 'en',
      _ => null,
    };
  }

  Future<void> _setLanguage(String? code) async {
    if (code != 'de' && code != 'en') return;
    await db.settings.update().write(
      SettingsCompanion(localeOverride: Value(code)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final settings = context.watch<Setting>();
    final formats = getFormatSettings(context, _search.text, settings);
    final query = _search.text.trim();
    return Scaffold(
      appBar: AppBar(title: Text(l10n.alphaSettings)),
      body: ListenableBuilder(
        listenable: alphaPrefs,
        builder: (context, _) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              TextField(
                key: const Key('settings-search'),
                controller: _search,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: l10n.searchHint,
                ),
                onChanged: (_) => setState(() {}),
              ),
              if (_hit(
                'Sprache Language Deutsch English ${l10n.settingsLanguage} ${l10n.settingsLanguageDescription} ${l10n.languageNameGerman} ${l10n.languageNameEnglish}',
              )) ...[
                const SizedBox(height: 16),
                Text(
                  l10n.settingsLanguage,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                RadioGroup<String>(
                  groupValue: _languageCode(settings.localeOverride),
                  onChanged: (value) {
                    _setLanguage(value);
                  },
                  child: Column(
                    children: [
                      RadioListTile<String>(
                        key: const Key('settings-language-de'),
                        contentPadding: EdgeInsets.zero,
                        title: Text(l10n.languageNameGerman),
                        value: 'de',
                      ),
                      RadioListTile<String>(
                        key: const Key('settings-language-en'),
                        contentPadding: EdgeInsets.zero,
                        title: Text(l10n.languageNameEnglish),
                        value: 'en',
                      ),
                    ],
                  ),
                ),
              ],
              if (_hit(l10n.localProfiles)) ...[
                const SizedBox(height: 16),
                Text(
                  l10n.localProfiles,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const _ProfileList(),
              ],
              if (_hit(
                '${l10n.themeSetting} ${l10n.themeTiefschwarz} ${l10n.themeEisblau} ${l10n.themePink}',
              )) ...[
                const SizedBox(height: 16),
                Text(
                  l10n.themeSetting,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                _ThemeTile(
                  id: 'tiefschwarz',
                  label: l10n.themeTiefschwarz,
                  selected: settings.themeId == 'tiefschwarz',
                ),
                _ThemeTile(
                  id: 'eisblau',
                  label: l10n.themeEisblau,
                  selected: settings.themeId == 'eisblau',
                ),
                _ThemeTile(
                  id: 'pink',
                  label: l10n.themePink,
                  selected: settings.themeId == 'pink',
                ),
              ],
              if (_hit('${l10n.restSound} ${l10n.restSoundVolume}')) ...[
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.restSound),
                  subtitle: Text(l10n.restSoundCredit),
                  value: settings.enableSound,
                  onChanged: (value) {
                    db.settings.update().write(
                      SettingsCompanion(enableSound: Value(value)),
                    );
                  },
                ),
                Text(l10n.restSoundVolume),
                Slider(
                  value: settings.restVolume.clamp(0, 1),
                  onChanged: (value) {
                    db.settings.update().write(
                      SettingsCompanion(restVolume: Value(value)),
                    );
                  },
                ),
              ],
              if (query.isEmpty || formats.isNotEmpty) ...[
                if (query.isEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    l10n.formats,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
                ...formats,
              ],
              if (_hit(
                '${l10n.lengthUnitLabel} ${l10n.centimetersShort} ${l10n.inchesShort}',
              ))
                DropdownButtonFormField<String>(
                  initialValue: alphaPrefs.lengthUnit,
                  decoration: InputDecoration(labelText: l10n.lengthUnitLabel),
                  items: [
                    DropdownMenuItem(
                      value: 'cm',
                      child: Text(l10n.centimetersShort),
                    ),
                    DropdownMenuItem(
                      value: 'inch',
                      child: Text(l10n.inchesShort),
                    ),
                  ],
                  onChanged: (value) async {
                    if (value == null) return;
                    alphaPrefs.lengthUnit = value;
                    await alphaPrefs.save();
                  },
                ),
              if (_hit(
                '${l10n.importExportTitle} ${l10n.importWorkouts} ${l10n.exportAlphaData}',
              ))
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.import_export),
                  title: Text(l10n.importExportTitle),
                  subtitle: Text(l10n.importWorkouts),
                  onTap: () {
                    Navigator.of(context).push(
                      FlexPageRoute(
                        builder: (context) => const ImportExportPage(),
                      ),
                    );
                  },
                ),
              if (_hit(
                '${l10n.aiCoachTitle} ${l10n.aiProviderLabel} ${l10n.apiKey}',
              )) ...[
                const SizedBox(height: 8),
                Text(
                  l10n.aiCoachTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(l10n.aiOffNotice),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: alphaPrefs.aiProvider,
                  decoration: InputDecoration(labelText: l10n.aiProviderLabel),
                  items: [
                    for (final provider in const [
                      (id: 'gemini', label: 'Gemini'),
                      (id: 'grok', label: 'Grok'),
                      (id: 'openai', label: 'ChatGPT'),
                    ])
                      DropdownMenuItem(
                        value: provider.id,
                        child: Text(provider.label),
                      ),
                  ],
                  onChanged: (value) async {
                    if (value == null) return;
                    alphaPrefs.aiProvider = value;
                    await alphaPrefs.save();
                  },
                ),
                if (_loadedKey) ...[
                  const SizedBox(height: 8),
                  TextField(
                    controller: _key,
                    obscureText: true,
                    autocorrect: false,
                    enableSuggestions: false,
                    decoration: InputDecoration(labelText: l10n.apiKey),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () async {
                        await writeAiKey(_key.text);
                        if (!context.mounted) return;
                        setState(() {});
                      },
                      child: Text(l10n.actionSave),
                    ),
                  ),
                ],
                FutureBuilder<String>(
                  future: readAiKey(),
                  builder: (context, snapshot) {
                    if ((snapshot.data ?? '').isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.chat_bubble_outline),
                      title: Text(l10n.coachHint),
                      onTap: () {
                        Navigator.of(context).push(
                          FlexPageRoute(
                            builder: (context) => const CoachPage(),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
              if (_hit(l10n.progressionHelp))
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.progressionHelp),
                  value: alphaPrefs.progression,
                  onChanged: (value) async {
                    alphaPrefs.progression = value;
                    await alphaPrefs.save();
                  },
                ),
              if (_hit(
                '${l10n.gymsTitle} ${l10n.newGym} ${l10n.chooseGym}',
              )) ...[
                const SizedBox(height: 8),
                Text(
                  l10n.gymsTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                for (final gym in alphaPrefs.gyms)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(gym.name),
                    subtitle: gym.id == alphaPrefs.activeGymId
                        ? Text(l10n.profileActive)
                        : null,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (gym.id != alphaPrefs.activeGymId)
                          TextButton(
                            onPressed: () async {
                              alphaPrefs.activeGymId = gym.id;
                              await alphaPrefs.save();
                            },
                            child: Text(l10n.chooseGym),
                          ),
                        IconButton(
                          key: Key('rename-gym-${gym.id}'),
                          tooltip: l10n.renameGym,
                          onPressed: () => _renameGym(gym),
                          icon: const Icon(Icons.edit_outlined),
                        ),
                        IconButton(
                          key: Key('delete-gym-${gym.id}'),
                          tooltip: l10n.deleteGymAction,
                          onPressed: () => _deleteGym(gym),
                          icon: const Icon(Icons.delete_outline),
                        ),
                      ],
                    ),
                  ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: _addGym,
                    icon: const Icon(Icons.add),
                    label: Text(l10n.newGym),
                  ),
                ),
              ],
              if (_hit('${l10n.weekGoal} ${l10n.weekGoalManual}'))
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.weekGoal),
                  subtitle: Text('${alphaPrefs.weeklyGoal}'),
                  onTap: () => editWeeklyGoal(context),
                ),
              if (_hit(
                '${l10n.checkForUpdates} ${l10n.upToDate} ${l10n.updateCheckFailed}',
              )) ...[
                const SizedBox(height: 8),
                ListenableBuilder(
                  listenable: Listenable.merge([
                    pendingAppUpdate,
                    updateCheckFailed,
                    updateCheckCompleted,
                    pendingInstallPath,
                  ]),
                  builder: (context, _) {
                    final release = pendingAppUpdate.value;
                    final waiting = pendingInstallPath.value != null;
                    final subtitle = updateStatusLabel(
                      failed: updateCheckFailed.value,
                      completed: updateCheckCompleted.value,
                      release: release,
                      failedLabel: l10n.updateCheckFailed,
                      availableLabel: l10n.updateVersionAvailable(
                        release?.version ?? '',
                      ),
                      currentLabel: l10n.upToDate,
                      idleLabel: l10n.checkForUpdates,
                    );
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.system_update_alt),
                          title: Text(l10n.checkForUpdates),
                          subtitle: Text(subtitle),
                          onTap: _checkUpdates,
                        ),
                        if (release != null || waiting)
                          FilledButton(
                            onPressed: () async {
                              try {
                                if (waiting) {
                                  await installDownloadedUpdate(context);
                                } else if (release != null) {
                                  await installAppUpdate(context, release);
                                }
                              } catch (error) {
                                if (!context.mounted) return;
                                await showUpdateFailure(
                                  context,
                                  error,
                                  release?.apkUrl ?? '',
                                );
                              }
                            },
                            child: Text(
                              waiting ? l10n.tapToInstall : l10n.installUpdate,
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ],
              if (_hit(l10n.feedbackSettings))
                ListTile(
                  key: const Key('settings-feedback'),
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.feedback_outlined),
                  title: Text(l10n.feedbackSettings),
                  onTap: () {
                    Navigator.of(context).push(
                      FlexPageRoute(builder: (context) => const FeedbackPage()),
                    );
                  },
                ),
              if (_hit('${l10n.licensesTitle} ${l10n.versionAndLicenses('')}'))
                FutureBuilder<String>(
                  future: _versionLabel(),
                  builder: (context, snapshot) {
                    return Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            FlexPageRoute(
                              builder: (context) => const LicensesPage(),
                            ),
                          );
                        },
                        child: Text(
                          l10n.versionAndLicenses(snapshot.data ?? '2.6.0'),
                        ),
                      ),
                    );
                  },
                ),
            ],
          );
        },
      ),
    );
  }

  Future<String> _versionLabel() async {
    try {
      return (await PackageInfo.fromPlatform()).version;
    } catch (_) {
      return '2.6.0';
    }
  }

  Future<void> _checkUpdates() async {
    final ok = await checkForAppUpdate();
    if (!mounted) return;
    final message = !ok
        ? context.l10n.updateCheckFailed
        : pendingAppUpdate.value == null
        ? context.l10n.upToDate
        : context.l10n.updateAvailable;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _addGym() async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.newGym),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(hintText: context.l10n.gymNameHint),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: Text(context.l10n.actionSave),
          ),
        ],
      ),
    );
    controller.dispose();
    if (name == null || name.isEmpty) return;
    alphaPrefs.gyms.add(
      GymPlace(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        createdAt: DateTime.now(),
      ),
    );
    await alphaPrefs.save();
  }

  Future<void> _renameGym(GymPlace gym) async {
    final controller = TextEditingController(text: gym.name);
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.renameGym),
        content: TextField(
          key: const Key('rename-gym-field'),
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: Text(context.l10n.actionSave),
          ),
        ],
      ),
    );
    controller.dispose();
    if (name == null || name.isEmpty) return;
    gym.name = name;
    await alphaPrefs.save();
  }

  Future<void> _deleteGym(GymPlace gym) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.deleteGymTitle),
        content: Text(context.l10n.deleteGymBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.l10n.actionCancel),
          ),
          FilledButton(
            key: const Key('confirm-delete-gym'),
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.l10n.actionDelete),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    alphaPrefs.gyms.removeWhere((row) => row.id == gym.id);
    if (alphaPrefs.gyms.isEmpty) {
      alphaPrefs.activeGymId = '';
    } else if (alphaPrefs.activeGymId == gym.id ||
        !alphaPrefs.gyms.any((row) => row.id == alphaPrefs.activeGymId)) {
      alphaPrefs.activeGymId = alphaPrefs.gyms.first.id;
    }
    await alphaPrefs.save();
  }
}

class _ThemeTile extends StatelessWidget {
  const _ThemeTile({
    required this.id,
    required this.label,
    required this.selected,
  });

  final String id;
  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final palette = AlphaPalette.byId(id);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(backgroundColor: palette.accent, radius: 12),
      title: Text(label),
      trailing: selected
          ? Icon(Icons.check, color: AlphaTheme.of(context).accent)
          : null,
      onTap: () {
        db.settings.update().write(SettingsCompanion(themeId: Value(id)));
      },
    );
  }
}

class _ProfileList extends StatefulWidget {
  const _ProfileList();

  @override
  State<_ProfileList> createState() => _ProfileListState();
}

class _ProfileListState extends State<_ProfileList> {
  late Future<ProfileRegistry> _registry;

  @override
  void initState() {
    super.initState();
    _registry = loadProfileRegistry();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ProfileRegistry>(
      future: _registry,
      builder: (context, snapshot) {
        final registry = snapshot.data;
        if (registry == null) return const SizedBox.shrink();
        final lastProfile = registry.profiles.length <= 1;
        return Column(
          children: [
            for (final profile in registry.profiles)
              _ProfileRow(
                profile: profile,
                active: profile.id == registry.activeId,
                lastProfile: lastProfile,
                onSwitch: () => _switch(profile),
                onRename: () => _rename(profile),
                onDelete: () => _delete(profile),
              ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: _create,
                icon: const Icon(Icons.add),
                label: Text(context.l10n.newProfile),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _create() async {
    final created = await startNewProfile(context);
    if (!created || !mounted) return;
    setState(() {
      _registry = loadProfileRegistry();
    });
  }

  Future<void> _switch(LocalProfile profile) async {
    final switched = await switchLocalProfile(context, profile);
    if (!switched || !mounted) return;
    setState(() {
      _registry = loadProfileRegistry();
    });
  }

  Future<void> _rename(LocalProfile profile) async {
    final controller = TextEditingController(text: profile.name);
    var error = '';
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setLocal) => AlertDialog(
          title: Text(context.l10n.renameProfile),
          content: TextField(
            key: const Key('rename-profile-field'),
            controller: controller,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              errorText: error.isEmpty ? null : error,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(context.l10n.actionCancel),
            ),
            FilledButton(
              key: const Key('confirm-rename-profile'),
              onPressed: () async {
                final result = await renameLocalProfile(
                  profile,
                  controller.text,
                );
                if (result == null) {
                  if (context.mounted) Navigator.pop(context, true);
                  return;
                }
                setLocal(() {
                  error = result == 'duplicate'
                      ? context.l10n.profileNameDuplicate
                      : context.l10n.profileNameEmpty;
                });
              },
              child: Text(context.l10n.actionSave),
            ),
          ],
        ),
      ),
    );
    if (saved != true || !mounted) return;
    setState(() {
      _registry = loadProfileRegistry();
    });
  }

  Future<void> _delete(LocalProfile profile) async {
    final controller = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setLocal) {
          final matches = controller.text.trim() == profile.name;
          return AlertDialog(
            title: Text(context.l10n.deleteProfileTitle),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(context.l10n.deleteProfileBody(profile.name)),
                const SizedBox(height: 12),
                TextField(
                  key: const Key('delete-profile-field'),
                  controller: controller,
                  autofocus: true,
                  onChanged: (_) => setLocal(() {}),
                  decoration: InputDecoration(
                    hintText: context.l10n.profileNameHint,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(context.l10n.actionCancel),
              ),
              FilledButton(
                key: const Key('confirm-delete-profile'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFB42318),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: const Color(0xFFB42318),
                  disabledForegroundColor: Colors.white70,
                ),
                onPressed: matches ? () => Navigator.pop(context, true) : null,
                child: Text(context.l10n.actionDelete),
              ),
            ],
          );
        },
      ),
    );
    if (confirmed != true) return;
    await deleteLocalProfile(profile);
    if (!mounted) return;
    setState(() {
      _registry = loadProfileRegistry();
    });
  }
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({
    required this.profile,
    required this.active,
    required this.lastProfile,
    required this.onSwitch,
    required this.onRename,
    required this.onDelete,
  });

  final LocalProfile profile;
  final bool active;
  final bool lastProfile;
  final VoidCallback onSwitch;
  final VoidCallback onRename;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final blocked = active || lastProfile;
    final hint = active
        ? l10n.deleteProfileBlockedActive
        : lastProfile
        ? l10n.deleteProfileBlockedLast
        : null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(profile.name),
          subtitle: Text([if (active) l10n.profileActive, ?hint].join(' · ')),
        ),
        Wrap(
          spacing: 4,
          children: [
            if (!active)
              TextButton(
                key: Key('profile-switch-${profile.id}'),
                onPressed: onSwitch,
                child: Text(l10n.switchProfile),
              ),
            TextButton(
              key: Key('profile-rename-${profile.id}'),
              onPressed: onRename,
              child: Text(l10n.renameProfile),
            ),
            TextButton(
              key: Key('profile-delete-${profile.id}'),
              onPressed: blocked ? null : onDelete,
              child: Text(l10n.deleteProfile),
            ),
          ],
        ),
      ],
    );
  }
}
