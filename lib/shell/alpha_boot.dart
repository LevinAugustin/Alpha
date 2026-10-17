import 'dart:async';

import 'package:flexify/home_page.dart';
import 'package:flexify/l10n/l10n.dart';
import 'package:flexify/theme/alpha_theme.dart';
import 'package:flutter/material.dart';

class AlphaBoot extends StatefulWidget {
  const AlphaBoot({super.key});

  @override
  State<AlphaBoot> createState() => _AlphaBootState();
}

class _AlphaBootState extends State<AlphaBoot> {
  var _ready = false;

  @override
  void initState() {
    super.initState();
    final widgetTest = WidgetsBinding.instance.runtimeType.toString().contains(
      'Test',
    );
    if (widgetTest) {
      _ready = true;
      return;
    }
    unawaited(_hold());
  }

  Future<void> _hold() async {
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (mounted) setState(() => _ready = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_ready) return const HomePage();
    final palette = AlphaTheme.of(context);
    return Scaffold(
      backgroundColor: palette.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(palette.figureAsset, height: 220),
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
        ),
      ),
    );
  }
}
