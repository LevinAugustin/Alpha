import 'package:flexify/database/catalog_seed.dart';
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
        name: 'smith-bench-press',
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
      matchesExerciseFilters(
        name: 'smith-bench-press',
        equipment: 'Multipresse',
        split: 'push',
        category: 'Brust',
        query: '',
        equipmentFilter: 'Multipresse',
        splitFilter: 'pull',
      ),
      isFalse,
    );
  });
}
