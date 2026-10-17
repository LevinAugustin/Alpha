import 'package:flexify/database/catalog_seed.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('search understands split and equipment synonyms', () {
    expect(
      exerciseMatchesQuery(
        name: 'Bench Press',
        germanName: 'Bankdrücken',
        aliases: 'brust',
        query: 'Push',
      ),
      isTrue,
    );
    expect(
      exerciseMatchesQuery(
        name: 'Smith Machine Bench Press',
        germanName: 'Bankdrücken an der Multipresse',
        aliases: 'smith machine',
        query: 'Multipresse',
      ),
      isTrue,
    );
    expect(
      exerciseMatchesQuery(
        name: 'Cable Fly',
        germanName: 'Fliegende am Kabelzug',
        aliases: 'cable',
        query: 'Kabelturm',
      ),
      isTrue,
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
  });
}
