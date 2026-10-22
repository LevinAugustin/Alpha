import 'package:flexify/alpha/alpha_prefs.dart';
import 'package:flexify/l10n/l10n.dart';
import 'package:flexify/profile/local_profiles.dart';
import 'package:flexify/shell/language_choice_page.dart';
import 'package:flexify/theme/alpha_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<bool> showCreateProfileDialog(BuildContext context) async {
  final locale = await showLanguageChoice(context);
  if (locale == null || !context.mounted) return false;
  final saved = await showDialog<bool>(
    context: context,
    builder: (context) => _CreateProfileDialog(locale: locale),
  );
  return saved ?? false;
}

class _CreateProfileDialog extends StatefulWidget {
  const _CreateProfileDialog({required this.locale});

  final String locale;

  @override
  State<_CreateProfileDialog> createState() => _CreateProfileDialogState();
}

class _CreateProfileDialogState extends State<_CreateProfileDialog> {
  final _name = TextEditingController();
  final _weight = TextEditingController();
  String? _unit;
  var _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _weight.dispose();
    super.dispose();
  }

  double? _parsedWeight() {
    final raw = _weight.text.trim().replaceAll(',', '.');
    if (raw.isEmpty) return null;
    return double.tryParse(raw);
  }

  Future<void> _submit() async {
    final name = _name.text.trim();
    if (name.isEmpty || _saving) return;
    final raw = _weight.text.trim();
    final weight = _parsedWeight();
    if (raw.isNotEmpty && (weight == null || weight <= 0)) {
      setState(() {});
      return;
    }
    setState(() => _saving = true);
    try {
      await completeOnboarding(
        name: name,
        bodyWeight: weight,
        unit: _unit,
        locale: widget.locale,
      );
      alphaPrefs.languageAsked = true;
      await alphaPrefs.save();
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = AlphaTheme.of(context);
    final nameReady = _name.text.trim().isNotEmpty;
    final weightInvalid =
        _weight.text.trim().isNotEmpty && ((_parsedWeight() ?? 0) <= 0);
    return AlertDialog(
      backgroundColor: palette.card,
      title: Text(l10n.createProfileButton),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              key: const Key('onboarding-name'),
              controller: _name,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(hintText: l10n.profileNameHint),
            ),
            const SizedBox(height: 12),
            TextField(
              key: const Key('onboarding-weight'),
              controller: _weight,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
              ],
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: l10n.onboardingWeightHint,
                errorText: weightInvalid ? l10n.onboardingWeightHint : null,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                FilterChip(
                  key: const Key('onboarding-unit-kg'),
                  label: Text(l10n.kilogramsUnit),
                  selected: _unit == 'kg',
                  onSelected: (selected) =>
                      setState(() => _unit = selected ? 'kg' : null),
                ),
                FilterChip(
                  key: const Key('onboarding-unit-lb'),
                  label: Text(l10n.poundsUnit),
                  selected: _unit == 'lb',
                  onSelected: (selected) =>
                      setState(() => _unit = selected ? 'lb' : null),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.actionCancel),
        ),
        TextButton(
          key: const Key('onboarding-save'),
          onPressed: nameReady && !weightInvalid && !_saving ? _submit : null,
          child: Text(l10n.actionSave),
        ),
      ],
    );
  }
}
