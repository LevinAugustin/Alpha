import 'package:flutter/material.dart';

class AlphaPalette {
  const AlphaPalette({
    required this.id,
    required this.background,
    required this.card,
    required this.text,
    required this.muted,
    required this.accent,
    required this.onAccent,
    required this.border,
    required this.figureAsset,
    required this.buttonGradient,
    required this.glow,
  });

  final String id;
  final Color background;
  final Color card;
  final Color text;
  final Color muted;
  final Color accent;
  final Color onAccent;
  final Color border;
  final String figureAsset;
  final Gradient? buttonGradient;
  final Color glow;

  static const tiefschwarz = AlphaPalette(
    id: 'tiefschwarz',
    background: Color(0xFF0D0D0D),
    card: Color(0xFF1A1A1A),
    text: Color(0xFFF2F2F2),
    muted: Color(0xFFC0C0C0),
    accent: Color(0xFFE53935),
    onAccent: Color(0xFFFFFFFF),
    border: Color(0xFF2A2A2A),
    figureAsset: 'assets/figures/gorilla_body.png',
    buttonGradient: null,
    glow: Color(0x66E53935),
  );

  static const eisblau = AlphaPalette(
    id: 'eisblau',
    background: Color(0xFF010B26),
    card: Color(0xFF081D4A),
    text: Color(0xFFFFFFFF),
    muted: Color(0xFF7F98BE),
    accent: Color(0xFF9CCDF4),
    onAccent: Color(0xFF021033),
    border: Color(0xFF11306A),
    figureAsset: 'assets/figures/eisbaer.png',
    buttonGradient: LinearGradient(
      colors: [Color(0xFFD6EEFF), Color(0xFF9CCDF4), Color(0xFF6AAEEA)],
    ),
    glow: Color(0x669CCDF4),
  );

  static const pink = AlphaPalette(
    id: 'pink',
    background: Color(0xFF0B0509),
    card: Color(0xFF1C0C17),
    text: Color(0xFFFFF5FA),
    muted: Color(0xFFA08896),
    accent: Color(0xFFFF2E93),
    onAccent: Color(0xFFFFFFFF),
    border: Color(0xFF331828),
    figureAsset: 'assets/figures/bunny.png',
    buttonGradient: LinearGradient(
      colors: [Color(0xFFFF4FA3), Color(0xFFFF2E93), Color(0xFFC21BC9)],
    ),
    glow: Color(0x66FF2E93),
  );

  static AlphaPalette byId(String? id) {
    return switch (id) {
      'eisblau' => eisblau,
      'pink' => pink,
      _ => tiefschwarz,
    };
  }
}

class AlphaTheme extends ThemeExtension<AlphaTheme> {
  const AlphaTheme(this.palette);

  final AlphaPalette palette;

  static AlphaPalette of(BuildContext context) {
    return Theme.of(context).extension<AlphaTheme>()?.palette ??
        AlphaPalette.tiefschwarz;
  }

  @override
  AlphaTheme copyWith({AlphaPalette? palette}) =>
      AlphaTheme(palette ?? this.palette);

  @override
  AlphaTheme lerp(ThemeExtension<AlphaTheme>? other, double t) => this;
}

ThemeData alphaThemeData(AlphaPalette palette) {
  final scheme = ColorScheme.dark(
    primary: palette.accent,
    onPrimary: palette.onAccent,
    secondary: palette.accent,
    onSecondary: palette.onAccent,
    surface: palette.card,
    onSurface: palette.text,
    surfaceContainerLow: palette.card,
    surfaceContainer: palette.card,
    outline: palette.border,
  );
  const radius = 12.0;
  final shape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(radius),
    side: BorderSide(color: palette.border),
  );
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: scheme,
    scaffoldBackgroundColor: palette.background,
    canvasColor: palette.background,
    fontFamily: 'Inter',
    splashFactory: InkSparkle.splashFactory,
    extensions: [AlphaTheme(palette)],
    appBarTheme: AppBarTheme(
      backgroundColor: palette.background,
      foregroundColor: palette.text,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: TextStyle(
        fontFamily: 'Bebas Neue',
        fontSize: 28,
        letterSpacing: 1.2,
        color: palette.text,
      ),
    ),
    cardTheme: CardThemeData(
      color: palette.card,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: shape,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: palette.background,
      labelStyle: TextStyle(color: palette.muted, fontFamily: 'Inter'),
      hintStyle: TextStyle(color: palette.muted),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius),
        borderSide: BorderSide(color: palette.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius),
        borderSide: BorderSide(color: palette.accent),
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(radius)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style:
          FilledButton.styleFrom(
            backgroundColor: palette.buttonGradient == null
                ? palette.accent
                : Colors.transparent,
            foregroundColor: palette.onAccent,
            elevation: 0,
            textStyle: const TextStyle(
              fontFamily: 'Bebas Neue',
              fontSize: 22,
              letterSpacing: 1,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radius),
            ),
            minimumSize: const Size.fromHeight(52),
          ).copyWith(
            backgroundBuilder: palette.buttonGradient == null
                ? null
                : (context, states, child) => DecoratedBox(
                    decoration: BoxDecoration(gradient: palette.buttonGradient),
                    child: child,
                  ),
          ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: palette.background,
      elevation: 0,
      indicatorColor: palette.glow,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final active = states.contains(WidgetState.selected);
        return TextStyle(
          fontFamily: 'Inter',
          fontSize: 12,
          fontWeight: active ? FontWeight.w700 : FontWeight.w500,
          color: active ? palette.accent : palette.muted,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final active = states.contains(WidgetState.selected);
        return IconThemeData(color: active ? palette.accent : palette.muted);
      }),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontFamily: 'Bebas Neue'),
      displayMedium: TextStyle(fontFamily: 'Bebas Neue'),
      displaySmall: TextStyle(fontFamily: 'Bebas Neue'),
      headlineLarge: TextStyle(fontFamily: 'Bebas Neue'),
      headlineMedium: TextStyle(fontFamily: 'Bebas Neue'),
      headlineSmall: TextStyle(fontFamily: 'Bebas Neue'),
      titleLarge: TextStyle(fontFamily: 'Bebas Neue', letterSpacing: 0.6),
    ).apply(bodyColor: palette.text, displayColor: palette.text),
    dividerColor: palette.border,
    iconTheme: IconThemeData(color: palette.text),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: palette.card,
      contentTextStyle: TextStyle(color: palette.text, fontFamily: 'Inter'),
      actionTextColor: palette.accent,
      closeIconColor: palette.text,
      behavior: SnackBarBehavior.floating,
    ),
  );
}
