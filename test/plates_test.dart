import 'package:flexify/alpha/plates.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('barbell subtracts the bar and does not invent a plate', () {
    final load = barbellLoad(
      totalKg: 100,
      barKg: 20,
      plates: const [25, 20, 15, 10, 5, 2.5, 1.25],
    );
    expect(load.sides.map((side) => side.kg), [25, 15]);
    expect(load.sides.map((side) => side.count), [1, 1]);
    expect(load.extraKg, 0);
  });

  test('cable stack keeps the remainder once', () {
    final load = cableLoad(totalKg: 55, stepKg: 5);
    expect(load.sides, hasLength(1));
    expect(load.sides.single.kg, 5);
    expect(load.sides.single.count, 11);
    expect(load.extraKg, 0);

    final odd = cableLoad(totalKg: 52.5, stepKg: 5);
    expect(odd.sides.single.count, 10);
    expect(odd.extraKg, 2.5);
  });

  test('rest of zero stays zero', () {
    expect(restChoices().first, 0);
    expect(nearestRest(0), 0);
    expect(nearestRest(2), 0);
    expect(nearestRest(7), 5);
    expect(restChoices(), contains(300));
    expect(restChoices(), isNot(contains(7)));
  });
}
