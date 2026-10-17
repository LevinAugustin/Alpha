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
        split: 'push',
        query: 'Push',
      ),
      isTrue,
    );
    expect(
      exerciseMatchesQuery(
        name: 'bankdruecken-multipresse',
        germanName: 'Bankdrücken an der Multipresse',
        aliases: 'Smith Machine|Multipresse',
        equipment: 'multipresse',
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
      matchesExerciseFilters(
        name: 'bankdruecken-multipresse',
        equipment: 'multipresse',
        split: 'push',
        category: 'Brust',
        query: '',
        equipmentFilter: 'multipresse',
        splitFilter: 'pull',
      ),
      isFalse,
    );
  });

  test('muscle heat uses the muscle map keys', () {
    final heat = <String, double>{};
    contributeMuscleHeat(
      heat,
      load: 100,
      group: 'Brust',
      primaryMuscles: '["chest"]',
      secondaryMuscles: '["triceps"]',
    );
    expect(heat['chest'], 100);
    expect(heat['triceps'], closeTo(35, 0.001));
    expect(heat.containsKey('Brust'), isFalse);

    final legacy = <String, double>{};
    contributeMuscleHeat(legacy, load: 80, group: 'Beine');
    expect(legacy['quads'], 80);
    expect(legacy['hams'], closeTo(32, 0.001));
  });
}
