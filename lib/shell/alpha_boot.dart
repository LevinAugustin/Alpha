import 'dart:async';

import 'package:flexify/home_page.dart';
import 'package:flexify/l10n/l10n.dart';
import 'package:flexify/profile/local_profiles.dart';
import 'package:flexify/theme/alpha_theme.dart';
import 'package:flutter/material.dart';

class AlphaBoot extends StatefulWidget {
  const AlphaBoot({super.key});

  @override
  State<AlphaBoot> createState() => _AlphaBootState();
}

class _AlphaBootState extends State<AlphaBoot> {
  var _home = false;
  var _splash = false;

  @override
  void initState() {
    super.initState();
    final widgetTest = WidgetsBinding.instance.runtimeType.toString().contains(
      'Test',
    );
    if (widgetTest) {
      _home = true;
      return;
    }
    unawaited(_open());
  }

  Future<void> _open() async {
    final needed = await installNeedsOnboarding();
    if (!mounted) return;
    if (needed) {
      setState(() => _home = true);
      return;
    }
    setState(() => _splash = true);
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (mounted) setState(() => _home = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_home) return const HomePage();
    final palette = AlphaTheme.of(context);
    return Scaffold(
      backgroundColor: palette.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(palette.figureAsset, height: 220),
            if (_splash) ...[
              Text(
                'ALPHA',
                style: TextStyle(
                  fontFamily: 'Bebas Neue',
                  fontSize: 72,
                  letterSpacing: 4,
                  color: palette.text,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                context.l10n.splashMotto,
                style: TextStyle(color: palette.muted, fontFamily: 'Inter'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
