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

  test('rest snaps onto five-second steps from 5 to 500', () {
    expect(restChoices().first, 5);
    expect(restChoices().last, 500);
    expect(restChoices().length, 100);
    expect(restChoices(), isNot(contains(0)));
    expect(restChoices(), isNot(contains(7)));
    expect(nearestRest(0), 5);
    expect(nearestRest(2), 5);
    expect(nearestRest(7), 5);
    expect(nearestRest(8), 10);
    expect(nearestRest(210), 210);
    expect(nearestRest(600), 500);
    expect(nearestRestMs(7000), 5000);
    expect(nearestRestMs(212000), 210000);
  });
}
