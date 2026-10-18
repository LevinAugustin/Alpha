import 'package:flexify/database/catalog_seed.dart';
import 'package:flexify/workout/muscle_map.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('search reads the catalog fields and synonyms', () {
    expect(
      exerciseMatchesQuery(
        name: 'Barbell bench press',
        germanName: 'Bankdrücken',
        aliases: 'Bench Press|Flachbank',
        category: 'Brust',
        primaryMuscles: '["brust"]',
        movement: 'druecken',
        query: 'Push',
      ),
      isTrue,
    );
    expect(
      exerciseMatchesQuery(
        name: 'bankdruecken-multipresse',
        germanName: 'Bankdrücken an der Multipresse',
        aliases: 'Smith Machine|Multipresse',
        equipment: 'Multipresse',
        query: 'Multipresse',
      ),
      isTrue,
    );
    expect(
      exerciseMatchesQuery(
        name: 'cable-fly',
        germanName: 'Fliegende',
        aliases: 'Cable Fly|Kabelzug',
        query: 'Kabelturm',
      ),
      isFalse,
    );
    expect(
      exerciseMatchesQuery(
        name: 'Lateral Raise',
        germanName: 'Seitheben',
        aliases: 'schulter',
        query: 'lat',
      ),
      isFalse,
    );
    expect(
      exerciseMatchesQuery(
        name: 'Face Pulls',
        category: 'Schultern',
        primaryMuscles: '["schulter_hinten"]',
        movement: 'ziehen',
        query: 'Pull',
      ),
      isTrue,
    );
    expect(
      exerciseMatchesQuery(
        name: 'Bizepscurls mit SZ-Stange',
        category: 'Bizeps',
        movement: 'ziehen',
        query: 'Ziehen',
      ),
      isTrue,
    );
    expect(
      exerciseMatchesQuery(
        name: 'Bankdrücken',
        category: 'Brust',
        primaryMuscles: '["brust"]',
        query: 'Push',
      ),
      isFalse,
    );
    expect(
      exerciseMatchesQuery(
        name: 'Bankdrücken',
        category: 'Brust',
        movement: 'druecken',
        query: 'Drücken',
      ),
      isTrue,
    );
    expect(
      exerciseMatchesQuery(
        name: 'Kreuzheben',
        category: 'Rücken',
        movement: 'beine_huefte',
        query: 'Beine',
      ),
      isTrue,
    );
    expect(
      exerciseMatchesQuery(
        name: 'Kniebeuge',
        category: 'Beine',
        query: 'Beine',
      ),
      isTrue,
    );
    expect(
      matchesExerciseFilters(
        name: 'Face Pulls',
        movement: 'ziehen',
        query: '',
        motionFilter: 'ziehen',
      ),
      isTrue,
    );
    expect(
      matchesExerciseFilters(
        name: 'bankdruecken-multipresse',
        equipment: 'Multipresse',
        category: 'Brust',
        primaryMuscles: '["brust"]',
        query: 'Pull',
        equipmentFilter: 'Multipresse',
      ),
      isFalse,
    );
  });

  test('every word must match, in any order', () {
    const cableCurl = (
      name: 'cable-curl',
      germanName: 'Bizeps-Curl am Kabel',
      aliases: 'Cable Curl',
      equipment: 'Kabelzug',
      primaryMuscles: '["bizeps"]',
      category: 'Bizeps',
    );
    const barCurl = (
      name: 'barbell-curl',
      germanName: 'Bizeps-Curl mit der Langhantel',
      aliases: 'Barbell Curl',
      equipment: 'Langhantel',
      primaryMuscles: '["bizeps"]',
      category: 'Bizeps',
    );
    for (final query in ['Bizeps Kabel', 'kabel bizeps', 'KABEL Bizeps']) {
      expect(
        exerciseMatchesQuery(
          name: cableCurl.name,
          germanName: cableCurl.germanName,
          aliases: cableCurl.aliases,
          equipment: cableCurl.equipment,
          primaryMuscles: cableCurl.primaryMuscles,
          category: cableCurl.category,
          query: query,
        ),
        isTrue,
        reason: query,
      );
      expect(
        exerciseMatchesQuery(
          name: barCurl.name,
          germanName: barCurl.germanName,
          aliases: barCurl.aliases,
          equipment: barCurl.equipment,
          primaryMuscles: barCurl.primaryMuscles,
          category: barCurl.category,
          query: query,
        ),
        isFalse,
        reason: query,
      );
    }
    expect(
      exerciseMatchesQuery(
        name: 'pullover',
        germanName: 'Überzüge',
        query: 'ueberzuege',
      ),
      isTrue,
    );
    expect(
      exerciseMatchesQuery(
        name: 'strasse',
        germanName: 'Straße',
        query: 'strasse',
      ),
      isTrue,
    );
    expect(
      exerciseMatchesQuery(
        name: 'row',
        germanName: 'Rudern',
        category: 'Rücken',
        query: 'ruecken',
      ),
      isTrue,
    );
    final ranked =
        [
          (name: 'other', germanName: 'Kabelrudern', aliases: '["Bizeps"]'),
          (name: 'exact', germanName: 'Bizeps Kabel', aliases: ''),
        ]..sort(
          (a, b) => compareExerciseSearch(
            query: 'Bizeps Kabel',
            leftName: a.name,
            leftGermanName: a.germanName,
            leftAliases: a.aliases,
            rightName: b.name,
            rightGermanName: b.germanName,
            rightAliases: b.aliases,
          ),
        );
    expect(ranked.first.germanName, 'Bizeps Kabel');
  });

  test('muscle heat uses the muscle map keys', () {
    final heat = <String, double>{};
    contributeMuscleHeat(
      heat,
      load: 100,
      group: 'Brust',
      primaryMuscles: '["brust"]',
      secondaryMuscles: '["trizeps"]',
    );
    expect(heat['brust'], 100);
    expect(heat['trizeps'], closeTo(35, 0.001));
    expect(heat.containsKey('Brust'), isFalse);

    final legacy = <String, double>{};
    contributeMuscleHeat(legacy, load: 80, group: 'Beine');
    expect(legacy['quadrizeps'], 80);
    expect(legacy['beinbeuger'], closeTo(32, 0.001));
  });
}
