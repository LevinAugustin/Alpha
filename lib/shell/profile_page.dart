import 'package:drift/drift.dart' hide Column;
import 'package:flexify/about_page.dart';
import 'package:flexify/database/database.dart';
import 'package:flexify/l10n/l10n.dart';
import 'package:flexify/main.dart';
import 'package:flexify/platform_page_route.dart';
import 'package:flexify/profile/local_profiles.dart';
import 'package:flexify/settings/settings_page.dart';
import 'package:flexify/update/app_update.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final TextEditingController _name;
  late final TextEditingController _height;
  late final TextEditingController _age;
  late final TextEditingController _goals;
  late final TextEditingController _apiKey;
  var _ready = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_ready) return;
    final settings = context.read<Setting>();
    _name = TextEditingController(text: settings.profileName ?? '');
    _height = TextEditingController(
      text: settings.heightCm == null
          ? ''
          : settings.heightCm!.toStringAsFixed(0),
    );
    _age = TextEditingController(
      text: settings.ageYears == null ? '' : '${settings.ageYears}',
    );
    _goals = TextEditingController(text: settings.goals ?? '');
    _apiKey = TextEditingController(text: settings.apiKey ?? '');
    _ready = true;
  }

  @override
  void dispose() {
    _name.dispose();
    _height.dispose();
    _age.dispose();
    _goals.dispose();
    _apiKey.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    await db.settings.update().write(
      SettingsCompanion(
        profileName: Value(_emptyToNull(_name.text)),
        heightCm: Value(double.tryParse(_height.text.replaceAll(',', '.'))),
        ageYears: Value(int.tryParse(_age.text.trim())),
        goals: Value(_emptyToNull(_goals.text)),
        apiKey: Value(_emptyToNull(_apiKey.text)),
      ),
    );
    await rememberProfileName(_name.text);
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(context.l10n.profileSaved)));
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) return const SizedBox.shrink();
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        TextField(
          controller: _name,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(labelText: context.l10n.profileName),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _height,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(labelText: context.l10n.heightCm),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _age,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: context.l10n.ageOptional),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _goals,
          minLines: 2,
          maxLines: 4,
          decoration: InputDecoration(labelText: context.l10n.goals),
        ),
        const SizedBox(height: 12),
        FilledButton(onPressed: _save, child: Text(context.l10n.actionSave)),
        const SizedBox(height: 24),
        Text(
          context.l10n.bodyData,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        const _BodyWeightSection(),
        const SizedBox(height: 24),
        Text(
          context.l10n.aiCoaching,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(context.l10n.apiKeyStoredLocally),
        const SizedBox(height: 8),
        TextField(
          controller: _apiKey,
          obscureText: true,
          autocorrect: false,
          enableSuggestions: false,
          decoration: InputDecoration(labelText: context.l10n.apiKey),
        ),
        const SizedBox(height: 8),
        FilledButton(onPressed: _save, child: Text(context.l10n.actionSave)),
        const SizedBox(height: 24),
        ValueListenableBuilder(
          valueListenable: pendingAppUpdate,
          builder: (context, release, _) {
            if (release == null) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: FilledButton(
                onPressed: () => downloadAndInstallUpdate(release),
                child: Text(context.l10n.installUpdate),
              ),
            );
          },
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.settings),
          title: Text(context.l10n.navSettings),
          onTap: () {
            Navigator.of(
              context,
            ).push(FlexPageRoute(builder: (context) => const SettingsPage()));
          },
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.info_outline),
          title: Text(context.l10n.aboutTitle),
          onTap: () {
            Navigator.of(
              context,
            ).push(FlexPageRoute(builder: (context) => const AboutPage()));
          },
        ),
      ],
    );
  }
}

String? _emptyToNull(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) return null;
  return trimmed;
}

class _BodyWeightSection extends StatelessWidget {
  const _BodyWeightSection();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<BodyWeight>>(
      stream: (db.select(
        db.bodyWeights,
      )..orderBy([(row) => OrderingTerm.desc(row.timestamp)])).watch(),
      builder: (context, snapshot) {
        final rows = snapshot.data ?? const <BodyWeight>[];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FilledButton.tonalIcon(
              onPressed: () => _addWeight(context),
              icon: const Icon(Icons.add),
              label: Text(context.l10n.addBodyWeight),
            ),
            for (final row in rows.take(12))
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('${row.weightKg.toStringAsFixed(1)} kg'),
                subtitle: Text(
                  MaterialLocalizations.of(
                    context,
                  ).formatFullDate(row.timestamp),
                ),
              ),
          ],
        );
      },
    );
  }

  Future<void> _addWeight(BuildContext context) async {
    final controller = TextEditingController();
    var date = DateTime.now();
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(context.l10n.addBodyWeight),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                autofocus: true,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(labelText: context.l10n.weightKg),
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  MaterialLocalizations.of(context).formatFullDate(date),
                ),
                trailing: const Icon(Icons.event),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: date,
                    firstDate: DateTime(1970),
                    lastDate: DateTime.now().add(const Duration(days: 1)),
                  );
                  if (picked == null) return;
                  setState(() => date = picked);
                },
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
    final kilos = double.tryParse(controller.text.replaceAll(',', '.'));
    controller.dispose();
    if (saved != true || kilos == null || kilos <= 0) return;
    await db.bodyWeights.insertOne(
      BodyWeightsCompanion.insert(timestamp: date, weightKg: kilos),
    );
  }
}
