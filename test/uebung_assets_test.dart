import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull, Column;
import 'package:flexify/database/database.dart';
import 'package:flexify/exercises/exercise_detail_page.dart';
import 'package:flexify/exercises/exercise_image.dart';
import 'package:flexify/exercises/exercise_media.dart';
import 'package:flexify/exercises/uebung_assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/test_app.dart';

void main() {
  Set<String> bundledOnDisk() {
    final assets = <String>{};
    for (final entity in Directory(
      'assets/uebungen',
    ).listSync(recursive: true)) {
      if (entity is! File) continue;
      final path = entity.path.replaceAll('\\', '/');
      final marker = '$uebungAssetRoot/';
      final index = path.lastIndexOf(marker);
      if (index < 0) continue;
      assets.add(path.substring(index));
    }
    return assets;
  }

  UebungAssetIndex realIndex() {
    final raw = jsonDecode(File(uebungManifestAsset).readAsStringSync());
    return UebungAssetIndex.parse(raw, bundledOnDisk());
  }

  tearDown(resetUebungAssetIndex);

  test('clip, still, and icon fall back by what is actually bundled', () {
    final index = UebungAssetIndex.parse(
      {
        'uebungen': [
          {
            'id': 'demo-curl',
            'dateien': [
              {'datei': 'demo-curl.mp4', 'rolle': 'clip'},
              {'datei': 'demo-curl.webp', 'rolle': 'standbild'},
              {'datei': 'icons/demo-curl.webp', 'rolle': 'icon256'},
            ],
          },
          {
            'id': 'demo-press',
            'dateien': [
              {'datei': 'demo-press.webp', 'rolle': 'standbild'},
              {'datei': 'icons/demo-press.webp', 'rolle': 'icon256'},
              {'datei': 'missing.webp', 'rolle': 'standbild'},
            ],
          },
          {
            'id': 'demo-row',
            'dateien': [
              {'datei': 'icons/demo-row.webp', 'rolle': 'icon256'},
            ],
          },
        ],
      },
      {
        'assets/uebungen/demo-curl.mp4',
        'assets/uebungen/demo-curl.webp',
        'assets/uebungen/icons/demo-curl.webp',
        'assets/uebungen/demo-press.webp',
        'assets/uebungen/icons/demo-press.webp',
        'assets/uebungen/icons/demo-row.webp',
      },
    );

    final clip = index.visual(catalogId: 'demo-curl');
    expect(clip.kind, ExerciseVisualKind.clip);
    expect(clip.clip, 'assets/uebungen/demo-curl.mp4');
    expect(clip.still, 'assets/uebungen/demo-curl.webp');
    expect(
      index.icon(catalogId: 'demo-curl'),
      'assets/uebungen/icons/demo-curl.webp',
    );

    final still = index.visual(catalogId: 'demo-press');
    expect(still.kind, ExerciseVisualKind.still);
    expect(still.still, 'assets/uebungen/demo-press.webp');
    expect(still.clip, isNull);

    final iconOnly = index.visual(catalogId: 'demo-row');
    expect(iconOnly.kind, ExerciseVisualKind.none);
    expect(
      index.icon(catalogId: 'demo-row'),
      'assets/uebungen/icons/demo-row.webp',
    );
    expect(
      index.visual(catalogId: 'not-in-the-box').kind,
      ExerciseVisualKind.none,
    );
    expect(index.icon(catalogId: 'not-in-the-box'), isNull);
    expect(
      index.icon(imagePath: 'assets/exercises/img/demo-press.webp'),
      'assets/uebungen/icons/demo-press.webp',
    );
    expect(index.icon(imagePath: '/storage/photo.jpg'), isNull);
  });

  test(
    'a new category is picked up from the manifest without a code change',
    () {
      final index = UebungAssetIndex.parse(
        {
          'uebungen': [
            {
              'id': 'kniebeuge-langhantel',
              'dateien': [
                {'datei': 'kniebeuge-langhantel.mp4', 'rolle': 'clip'},
                {'datei': 'kniebeuge-langhantel.webp', 'rolle': 'standbild'},
                {
                  'datei': 'icons/kniebeuge-langhantel.webp',
                  'rolle': 'icon256',
                },
              ],
            },
          ],
        },
        {
          'assets/uebungen/kniebeuge-langhantel.mp4',
          'assets/uebungen/kniebeuge-langhantel.webp',
          'assets/uebungen/icons/kniebeuge-langhantel.webp',
        },
      );

      final visual = index.visual(catalogId: 'kniebeuge-langhantel');
      expect(visual.kind, ExerciseVisualKind.clip);
      expect(visual.still, 'assets/uebungen/kniebeuge-langhantel.webp');
      expect(
        index.icon(catalogId: 'kniebeuge-langhantel'),
        'assets/uebungen/icons/kniebeuge-langhantel.webp',
      );
    },
  );

  test('a placed file counts even before its manifest row exists', () {
    final index = UebungAssetIndex.parse(
      {'uebungen': <Object>[]},
      {
        'assets/uebungen/neue-uebung.mp4',
        'assets/uebungen/neue-uebung.webp',
        'assets/uebungen/icons/neue-uebung.webp',
      },
    );
    final visual = index.visual(catalogId: 'neue-uebung');
    expect(visual.kind, ExerciseVisualKind.clip);
    expect(visual.still, 'assets/uebungen/neue-uebung.webp');
    expect(
      index.icon(catalogId: 'neue-uebung'),
      'assets/uebungen/icons/neue-uebung.webp',
    );
  });

  test('variant art comes from the manifest link or the stored bild name', () {
    final index = realIndex();
    final parent = index.visual(catalogId: 'hammercurls-seil');
    expect(parent.kind, ExerciseVisualKind.none);
    expect(
      index.icon(catalogId: 'hammercurls-seil'),
      'assets/uebungen/icons/hammercurls-seil.webp',
    );

    final linked = index.visual(
      catalogId: 'hammercurls-seil',
      variantKey: 'beidarmig',
      variantImage: 'something-else.webp',
    );
    expect(linked.kind, ExerciseVisualKind.still);
    expect(linked.still, 'assets/uebungen/hammercurls-seil-beidarmig.webp');
    expect(
      index.icon(catalogId: 'hammercurls-seil-beidarmig'),
      'assets/uebungen/icons/hammercurls-seil-beidarmig.webp',
    );

    final fromBild =
        UebungAssetIndex.parse(
          {
            'uebungen': [
              {
                'id': 'demo-curl',
                'dateien': [
                  {'datei': 'icons/demo-curl.webp', 'rolle': 'icon256'},
                ],
              },
            ],
          },
          {
            'assets/uebungen/icons/demo-curl.webp',
            'assets/uebungen/demo-curl-breit.webp',
          },
        ).visual(
          catalogId: 'demo-curl',
          variantKey: 'breit',
          variantImage: 'demo-curl-breit.webp',
        );
    expect(fromBild.kind, ExerciseVisualKind.still);
    expect(fromBild.still, 'assets/uebungen/demo-curl-breit.webp');

    final missing = index.visual(
      catalogId: 'hammercurls-seil',
      variantKey: 'einarmig',
      variantImage: 'hammercurls-seil.webp',
    );
    expect(missing.kind, ExerciseVisualKind.none);

    final curl = index.visual(catalogId: 'bizepscurls-kurzhantel');
    expect(curl.kind, ExerciseVisualKind.clip);
    expect(curl.clip, 'assets/uebungen/bizepscurls-kurzhantel.mp4');
    expect(curl.still, 'assets/uebungen/bizepscurls-kurzhantel.webp');
  });

  testWidgets('the detail stage shows a still and otherwise the placeholder', (
    tester,
  ) async {
    installUebungAssetIndex(realIndex());
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: ExerciseStage(catalogId: 'dipmaschine')),
      ),
    );
    await tester.pump();
    final still = tester.widget<Image>(
      find.byKey(const Key('exercise-media-still')),
    );
    expect(
      (still.image as AssetImage).assetName,
      'assets/uebungen/dipmaschine.webp',
    );
    expect(find.byType(ExerciseImagePlaceholder), findsNothing);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ExerciseStage(
            catalogId: 'hammercurls-seil',
            variantKey: 'beidarmig',
            variantImage: 'hammercurls-seil-beidarmig.webp',
          ),
        ),
      ),
    );
    await tester.pump();
    final variant = tester.widget<Image>(
      find.byKey(const Key('exercise-media-still')),
    );
    expect(
      (variant.image as AssetImage).assetName,
      'assets/uebungen/hammercurls-seil-beidarmig.webp',
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: ExerciseStage(catalogId: 'not-a-real-exercise')),
      ),
    );
    await tester.pump();
    expect(find.byType(ExerciseImagePlaceholder), findsOneWidget);
  });

  testWidgets('selecting the two-arm variant shows its still', (tester) async {
    installUebungAssetIndex(realIndex());
    final harness = await FlexifyTestHarness.create();
    addTearDown(harness.database.close);
    final id = await harness.database.exercises.insertOne(
      ExercisesCompanion.insert(
        name: 'hammercurls-seil',
        kind: 'strength',
        displayUnit: 'kg',
        catalogId: const Value('hammercurls-seil'),
        variants: Value(
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
    await tester.tap(find.byKey(const Key('variant-beidarmig')));
    await tester.pumpAndSettle();
    final image = tester.widget<Image>(
      find.byKey(const Key('exercise-media-still')),
    );
    expect(
      (image.image as AssetImage).assetName,
      'assets/uebungen/hammercurls-seil-beidarmig.webp',
    );
    await tester.scrollUntilVisible(
      find.textContaining('Both hands.'),
      200,
      scrollable: find.descendant(
        of: find.byKey(const Key('exercise-howto')),
        matching: find.byType(Scrollable),
      ),
    );
    expect(find.textContaining('Both hands.'), findsOneWidget);
  });
}
