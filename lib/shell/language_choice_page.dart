import 'package:flexify/theme/alpha_theme.dart';
import 'package:flutter/material.dart';

Future<String?> showLanguageChoice(BuildContext context) {
  return Navigator.of(context).push<String>(
    MaterialPageRoute(builder: (context) => const LanguageChoicePage()),
  );
}

class LanguageChoicePage extends StatefulWidget {
  const LanguageChoicePage({super.key});

  @override
  State<LanguageChoicePage> createState() => _LanguageChoicePageState();
}

class _LanguageChoicePageState extends State<LanguageChoicePage> {
  String? _choice;

  @override
  Widget build(BuildContext context) {
    final palette = AlphaTheme.of(context);
    return Scaffold(
      backgroundColor: palette.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'ALPHA',
                style: TextStyle(
                  fontFamily: 'Bebas Neue',
                  fontSize: 64,
                  letterSpacing: 4,
                  color: palette.text,
                  height: 0.9,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Sprache  ·  Language',
                style: TextStyle(color: palette.muted, fontFamily: 'Inter'),
              ),
              const SizedBox(height: 28),
              _option(
                palette,
                key: const Key('language-de'),
                code: 'de',
                title: 'Deutsch',
                subtitle: 'Oberfläche und Übungen',
              ),
              const SizedBox(height: 12),
              _option(
                palette,
                key: const Key('language-en'),
                code: 'en',
                title: 'English',
                subtitle: 'Interface and exercises',
              ),
              const Spacer(),
              FilledButton(
                key: const Key('language-continue'),
                onPressed: _choice == null
                    ? null
                    : () => Navigator.of(context).pop(_choice),
                child: const Text('Weiter  ·  Continue'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _option(
    AlphaPalette palette, {
    required Key key,
    required String code,
    required String title,
    required String subtitle,
  }) {
    final selected = _choice == code;
    return Material(
      color: palette.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: selected ? palette.accent : palette.border,
          width: selected ? 2 : 1,
        ),
      ),
      child: InkWell(
        key: key,
        borderRadius: BorderRadius.circular(12),
        onTap: () => setState(() => _choice = code),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: 'Bebas Neue',
                        fontSize: 32,
                        color: palette.text,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: palette.muted,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                selected ? Icons.check_circle : Icons.circle_outlined,
                color: selected ? palette.accent : palette.muted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
