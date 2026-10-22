import 'dart:convert';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flexify/database/database.dart';
import 'package:flexify/exercises/exercise_detail_page.dart';
import 'package:flexify/exercises/exercise_image.dart';
import 'package:flexify/exercises/exercise_variants.dart';
import 'package:flexify/feedback/feedback_mail.dart';
import 'package:flexify/feedback/feedback_page.dart';
import 'package:flexify/shell/language_choice_page.dart';
import 'package:flexify/theme/alpha_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

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
    expect(sent!.subject, '[Alpha-Feedback] Fehler 2.6.0+458');
    expect(sent!.body, contains('Sprache: de'));
    expect(sent!.body, contains('Übung: Curl (hammercurls-seil)'));
    expect(sent!.body, contains('Bitte prüfen'));
    expect(sent!.attachmentPath, isNull);
  });
}
