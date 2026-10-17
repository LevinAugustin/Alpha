import 'package:drift/drift.dart' hide Column;
import 'package:flexify/database/database.dart';
import 'package:flexify/l10n/l10n.dart';
import 'package:flexify/main.dart';
import 'package:flexify/profile/local_profiles.dart';
import 'package:flexify/theme/alpha_theme.dart';
import 'package:flexify/update/app_update.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AlphaSettingsPage extends StatelessWidget {
  const AlphaSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<Setting>();
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.alphaSettings)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Text(
            l10n.localProfiles,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          const _ProfileList(),
          const SizedBox(height: 24),
          Text(
            l10n.themeSetting,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
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
          const SizedBox(height: 24),
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
          const SizedBox(height: 12),
          ValueListenableBuilder(
            valueListenable: pendingAppUpdate,
            builder: (context, release, _) {
              if (release == null) return const SizedBox.shrink();
              return FilledButton(
                onPressed: () => downloadAndInstallUpdate(release),
                child: Text(l10n.installUpdate),
              );
            },
          ),
        ],
      ),
    );
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
        return Column(
          children: [
            for (final profile in registry.profiles)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(profile.name),
                trailing: profile.id == registry.activeId
                    ? Text(context.l10n.profileActive)
                    : TextButton(
                        onPressed: () => activateLocalProfile(profile),
                        child: Text(context.l10n.switchProfile),
                      ),
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
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.newProfile),
        content: TextField(
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
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: Text(context.l10n.actionSave),
          ),
        ],
      ),
    );
    controller.dispose();
    if (name == null || name.isEmpty) return;
    final profile = await createLocalProfile(name);
    await activateLocalProfile(profile);
  }
}
