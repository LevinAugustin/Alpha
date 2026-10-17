import 'package:flexify/l10n/l10n.dart';
import 'package:flexify/profile/local_profiles.dart';
import 'package:flexify/theme/alpha_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key, required this.onFinished});

  final VoidCallback onFinished;

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
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
      await completeOnboarding(name: name, bodyWeight: weight, unit: _unit);
      if (!mounted) return;
      widget.onFinished();
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
    return Scaffold(
      backgroundColor: palette.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          children: [
            SizedBox(
              height: 280,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          palette.accent.withValues(alpha: 0.45),
                          palette.accent.withValues(alpha: 0),
                        ],
                      ),
                    ),
                  ),
                  Image.asset(palette.figureAsset, height: 250),
                ],
              ),
            ),
            Text(
              l10n.whoAreYou,
              style: TextStyle(
                fontFamily: 'Bebas Neue',
                fontSize: 48,
                height: 0.9,
                color: palette.accent,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              key: const Key('onboarding-name'),
              controller: _name,
              textCapitalization: TextCapitalization.words,
              autofocus: true,
              onChanged: (_) => setState(() {}),
              style: TextStyle(color: palette.text),
              decoration: InputDecoration(
                hintText: l10n.profileNameHint,
                filled: true,
                fillColor: palette.card,
              ),
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
              style: TextStyle(color: palette.text),
              decoration: InputDecoration(
                hintText: l10n.onboardingWeightHint,
                errorText: weightInvalid ? l10n.onboardingWeightHint : null,
                filled: true,
                fillColor: palette.card,
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
            const SizedBox(height: 24),
            SizedBox(
              height: 52,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: nameReady && !weightInvalid
                      ? (palette.buttonGradient == null ? palette.accent : null)
                      : palette.card,
                  gradient: nameReady && !weightInvalid
                      ? palette.buttonGradient
                      : null,
                ),
                child: TextButton(
                  key: const Key('onboarding-start'),
                  onPressed: nameReady && !weightInvalid && !_saving
                      ? _submit
                      : null,
                  child: Text(
                    l10n.letsGo,
                    style: TextStyle(
                      fontFamily: 'Bebas Neue',
                      fontSize: 22,
                      color: nameReady ? palette.onAccent : palette.muted,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
