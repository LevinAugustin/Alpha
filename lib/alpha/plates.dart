class PlateSide {
  const PlateSide({required this.kg, required this.count});

  final double kg;
  final int count;
}

class PlateLoad {
  const PlateLoad({required this.sides, required this.extraKg});

  final List<PlateSide> sides;
  final double extraKg;
}

PlateLoad barbellLoad({
  required double totalKg,
  required double barKg,
  required List<double> plates,
}) {
  final available = [...plates.where((plate) => plate > 0)]
    ..sort((a, b) => b.compareTo(a));
  var perSide = (totalKg - barKg) / 2;
  if (perSide < 0) perSide = 0;
  final used = <PlateSide>[];
  for (final plate in available) {
    final count = (perSide / plate).floor();
    if (count <= 0) continue;
    used.add(PlateSide(kg: plate, count: count));
    perSide -= count * plate;
  }
  final extra = perSide * 2;
  return PlateLoad(sides: used, extraKg: extra.abs() < 0.05 ? 0 : extra);
}

PlateLoad cableLoad({required double totalKg, required double stepKg}) {
  if (stepKg <= 0) {
    return PlateLoad(sides: const [], extraKg: totalKg < 0 ? 0 : totalKg);
  }
  final steps = totalKg <= 0 ? 0 : (totalKg / stepKg).floor();
  final loaded = steps * stepKg;
  final extra = totalKg - loaded;
  return PlateLoad(
    sides: steps == 0 ? const [] : [PlateSide(kg: stepKg, count: steps)],
    extraKg: extra.abs() < 0.05 ? 0 : extra,
  );
}

const restStepSeconds = 5;
const restMinSeconds = 5;
const restMaxSeconds = 500;

List<int> restChoices() => [
  for (
    var seconds = restMinSeconds;
    seconds <= restMaxSeconds;
    seconds += restStepSeconds
  )
    seconds,
];

int nearestRest(int seconds) {
  if (seconds <= restMinSeconds) return restMinSeconds;
  if (seconds >= restMaxSeconds) return restMaxSeconds;
  return (seconds / restStepSeconds).round() * restStepSeconds;
}

int nearestRestMs(int milliseconds) =>
    nearestRest((milliseconds / 1000).round()) * 1000;
