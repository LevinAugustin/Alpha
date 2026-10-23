import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull, Column;
import 'package:flexify/database/database.dart';
import 'package:flexify/exercise_labels.dart';
import 'package:flexify/exercises/exercise_detail_page.dart';
import 'package:flexify/exercises/exercise_image.dart';
import 'package:flexify/exercises/exercise_variants.dart';
import 'package:flexify/feedback/feedback_mail.dart';
import 'package:flexify/feedback/feedback_page.dart';
import 'package:flexify/l10n/generated/app_localizations.dart';
import 'package:flexify/l10n/locale_preferences.dart';
import 'package:flexify/settings/alpha_settings_page.dart';
import 'package:flexify/shell/language_choice_page.dart';
import 'package:flexify/theme/alpha_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'support/test_app.dart';

void main() {
  test('snackbar action stays readable on every dark palette', () {
    for (final palette in const [
      AlphaPalette.tiefschwarz,
      AlphaPalette.eisblau,
      AlphaPalette.pink,
    ]) {
      final theme = alphaThemeData(palette);
      expect(theme.snackBarTheme.backgroundColor, palette.card);
      expect(theme.snackBarTheme.actionTextColor, palette.accent);
      expect(theme.snackBarTheme.contentTextStyle?.color, palette.text);
    }
  });

  test('feedback text is a mail draft and is not sent by the app', () {
    final draft = FeedbackDraft(
      category: FeedbackCategory.bug,
      categoryLabel: 'Fehler',
      message: 'Der Clip fehlt.',
      version: '2.6.0',
      build: '458',
      language: 'de',
      manufacturer: 'Google',
      model: 'Pixel',
      androidVersion: '14',
      exerciseName: 'Hammercurls am Seil',
      exerciseId: 'hammercurls-seil',
      german: true,
    );
    expect(feedbackAddress, 'alpha-feedback@mail.grokbot.com');
    expect(draft.subject, '[Alpha-Feedback] Fehler 2.6.0+458');
    expect(draft.subject, isNot(contains('45803')));
    expect(draft.body, contains('App-Version: 2.6.0+458'));
    expect(draft.body, contains('Sprache: de'));
    expect(
      draft.body,
      contains('Übung: Hammercurls am Seil (hammercurls-seil)'),
    );
    expect(draft.body, contains('Gerät: Google Pixel, Android 14'));
    expect(draft.body, contains('Der Clip fehlt.'));
  });

  test('a missing variant clip has no rendered path', () {
    final variants = parseExerciseVariants(
      jsonEncode([
        {
          'key': 'beidarmig',
          'label_de': 'Beidarmig',
          'label_en': 'Two-arm',
          'ausfuehrung_de': ['Beide Hände.'],
          'tipps_de': ['Stabil.'],
          'ausfuehrung_en': ['Both hands.'],
          'tipps_en': ['Stable.'],
          'bild': 'hammercurls-seil-beidarmig.webp',
          'bild_gerendert': false,
        },
      ]),
    );
    expect(variants.single.clipPath(), isNull);
  });

  testWidgets('language choice returns the selected code', (tester) async {
    final harness = await FlexifyTestHarness.create();
    addTearDown(harness.database.close);
    String? chosen;
    await harness.pump(
      tester,
      Builder(
        builder: (context) => TextButton(
          onPressed: () async {
            chosen = await showLanguageChoice(context);
          },
          child: const Text('open'),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<FilledButton>(find.byKey(const Key('language-continue')))
          .onPressed,
      isNull,
    );
    await tester.tap(find.byKey(const Key('language-en')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('language-continue')));
    await tester.pumpAndSettle();
    expect(chosen, 'en');
  });

  testWidgets('overview hides the unilateral trait', (tester) async {
    final harness = await FlexifyTestHarness.create();
    addTearDown(harness.database.close);
    final id = await harness.database.exercises.insertOne(
      ExercisesCompanion.insert(
        name: 'one-side-demo',
        kind: 'strength',
        displayUnit: 'kg',
        einseitig: const Value(true),
        germanName: const Value('Einarmige Demo'),
      ),
    );
    final exercise =
        await (harness.database.exercises.select()
              ..where((row) => row.id.equals(id)))
            .getSingle();
    await harness.pump(
      tester,
      ExerciseDetailPage(exercise: exercise),
      locale: const Locale('de'),
    );
    await tester.pumpAndSettle();
    expect(find.text('Einseitig'), findsNothing);
    expect(exercise.einseitig, isTrue);
  });

  testWidgets('a variant explanation stays on one logged exercise', (
    tester,
  ) async {
    final harness = await FlexifyTestHarness.create();
    addTearDown(harness.database.close);
    final id = await harness.database.exercises.insertOne(
      ExercisesCompanion.insert(
        name: 'hammercurls-seil',
        kind: 'strength',
        displayUnit: 'kg',
        germanName: const Value('Hammercurls am Seil'),
        englishName: const Value('Cable Rope Hammer Curl'),
        steps: const Value('["Allgemein."]'),
        variants: Value(
          jsonEncode([
            {
              'key': 'einarmig',
              'label_de': 'Einarmig',
              'label_en': 'One-arm',
              'ausfuehrung_de': ['Eine Hand.'],
              'tipps_de': ['Langsam.'],
              'ausfuehrung_en': ['One hand.'],
              'tipps_en': ['Slow.'],
              'bild': 'hammercurls-seil.webp',
              'bild_gerendert': false,
            },
            {
              'key': 'beidarmig',
              'label_de': 'Beidarmig',
              'label_en': 'Two-arm',
              'ausfuehrung_de': ['Beide Hände.'],
              'tipps_de': ['Stabil.'],
              'ausfuehrung_en': ['Both hands.'],
              'tipps_en': ['Stable.'],
              'bild': 'hammercurls-seil-beidarmig.webp',
              'bild_gerendert': false,
            },
          ]),
        ),
      ),
    );
    final exercise =
        await (harness.database.exercises.select()
              ..where((row) => row.id.equals(id)))
            .getSingle();
    await harness.pump(tester, ExerciseDetailPage(exercise: exercise));
    await tester.pumpAndSettle();
    await tester.tap(find.text('How to'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('variant-choice')), findsOneWidget);
    expect(find.text('One-arm'), findsOneWidget);
    expect(find.text('Two-arm'), findsOneWidget);
    await tester.tap(find.byKey(const Key('variant-einarmig')));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.textContaining('One hand.'),
      200,
      scrollable: find.descendant(
        of: find.byKey(const Key('exercise-howto')),
        matching: find.byType(Scrollable),
      ),
    );
    expect(find.textContaining('One hand.'), findsOneWidget);
    expect(find.textContaining('Slow.'), findsOneWidget);
    expect(find.byType(ExerciseImagePlaceholder), findsWidgets);
    final rows = await harness.database.exercises.select().get();
    expect(rows.where((row) => row.catalogId == 'hammercurls-seil'), isEmpty);
    expect(rows.where((row) => row.name == 'hammercurls-seil'), hasLength(1));
  });

  testWidgets('feedback form copies the message into the mail draft', (
    tester,
  ) async {
    final harness = await FlexifyTestHarness.create();
    addTearDown(harness.database.close);
    FeedbackDraft? sent;
    await harness.pump(
      tester,
      FeedbackPage(
        exerciseName: 'Curl',
        exerciseId: 'hammercurls-seil',
        sender: (draft) async {
          sent = draft;
          return true;
        },
      ),
      locale: const Locale('de'),
    );
    await tester.pump();
    expect(find.byKey(const Key('feedback-dictate')), findsOneWidget);
    expect(find.byKey(const Key('feedback-record')), findsOneWidget);
    await tester.enterText(
      find.byKey(const Key('feedback-message')),
      'Bitte prüfen',
    );
    await tester.tap(find.byKey(const Key('feedback-send')));
    await tester.pump();
    expect(sent, isNotNull);
    expect(sent!.subject, '[Alpha-Feedback] Fehler 2.7.0+459');
    expect(sent!.body, contains('Sprache: de'));
    expect(sent!.body, contains('Übung: Curl (hammercurls-seil)'));
    expect(sent!.body, contains('Bitte prüfen'));
    expect(sent!.attachmentPath, isNull);
  });

  test('feedback subject uses the pubspec build, not the versionCode', () {
    expect(feedbackBuildLabel('45803'), '458');
    expect(feedbackBuildLabel('45801'), '458');
    expect(feedbackBuildLabel('45802'), '458');
    expect(feedbackBuildLabel('458'), '458');
    final draft = FeedbackDraft(
      category: FeedbackCategory.bug,
      categoryLabel: 'Fehler',
      message: 'Der Clip fehlt.',
      version: '2.6.0',
      build: feedbackBuildLabel('45803'),
      language: 'de',
      manufacturer: 'Google',
      model: 'Pixel',
      androidVersion: '14',
      german: true,
    );
    expect(draft.subject, '[Alpha-Feedback] Fehler 2.6.0+458');
    expect(draft.body, contains('App-Version: 2.6.0+458'));
    expect(draft.subject, isNot(contains('45803')));
  });

  testWidgets('settings search finds Sprache and Language and applies it', (
    tester,
  ) async {
    final harness = await FlexifyTestHarness.create();
    addTearDown(harness.database.close);
    final otherDir = Directory.systemTemp.createTempSync('alpha-language-');
    final other = AppDatabase.forPath('${otherDir.path}/other.sqlite');
    addTearDown(other.close);
    addTearDown(() => otherDir.deleteSync(recursive: true));
    await tester.binding.setSurfaceSize(const Size(400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final setting = await (harness.database.settings.select()..limit(1))
        .getSingle();
    expect(setting.localeOverride, 'de');

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          StreamProvider<Setting>(
            initialData: setting,
            create: (_) => harness.database.watchSettings(),
          ),
          ChangeNotifierProvider.value(value: harness.timerState),
        ],
        child: const _LanguageSettingsHost(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Latziehen'), findsOneWidget);
    expect(find.text('Langsam ziehen.'), findsOneWidget);
    expect(find.byKey(const Key('settings-language-de')), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('settings-search')),
      'Language',
    );
    await tester.pump();
    expect(find.byKey(const Key('settings-language-en')), findsOneWidget);
    expect(find.byKey(const Key('settings-feedback')), findsNothing);

    await tester.enterText(find.byKey(const Key('settings-search')), 'zzz');
    await tester.pump();
    expect(find.byKey(const Key('settings-language-de')), findsNothing);

    await tester.enterText(find.byKey(const Key('settings-search')), 'Sprache');
    await tester.pump();
    await tester.tap(find.byKey(const Key('settings-language-en')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Lat Pulldown'), findsOneWidget);
    expect(find.text('Pull slowly.'), findsOneWidget);
    expect(find.text('Latziehen'), findsNothing);
    expect(find.text('Langsam ziehen.'), findsNothing);
    final active = await (harness.database.settings.select()..limit(1))
        .getSingle();
    expect(active.localeOverride, 'en');
    final untouched = await (other.settings.select()..limit(1)).getSingle();
    expect(untouched.localeOverride, 'de');

    await tester.enterText(find.byKey(const Key('settings-search')), '');
    await tester.pump();
    await tester.tap(find.byKey(const Key('settings-language-de')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Latziehen'), findsOneWidget);
    expect(find.text('Langsam ziehen.'), findsOneWidget);
    final restored = await (harness.database.settings.select()..limit(1))
        .getSingle();
    expect(restored.localeOverride, 'de');
    final stillUntouched = await (other.settings.select()..limit(1))
        .getSingle();
    expect(stillUntouched.localeOverride, 'de');
  });
}

class _LanguageSettingsHost extends StatelessWidget {
  const _LanguageSettingsHost();

  @override
  Widget build(BuildContext context) {
    final override = context.select<Setting, String?>(
      (settings) => settings.localeOverride,
    );
    return MaterialApp(
      locale: localeOverrideFromIdentifier(override) ?? const Locale('de'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Column(
          children: [
            Builder(
              builder: (context) {
                final lines = localizedExerciseLines(
                  context,
                  german: 'Langsam ziehen.',
                  english: 'Pull slowly.',
                );
                return Column(
                  children: [
                    Text(
                      localizedExerciseName(
                        context,
                        'latziehen-breit',
                        german: 'Latziehen',
                        english: 'Lat Pulldown',
                      ),
                    ),
                    Text(lines.join(' ')),
                  ],
                );
              },
            ),
            const Expanded(child: AlphaSettingsPage()),
          ],
        ),
      ),
    );
  }
}
