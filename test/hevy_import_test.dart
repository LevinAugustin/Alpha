import 'package:flexify/import/hevy_import.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Hevy CSV preview counts templates and sets', () {
    const csv = '''
title,start_time,end_time,exercise_title,set_type,weight_kg,reps
Tag 5: Pull B Schmal/Neutral,2026-10-01 18:00:00,2026-10-01 19:00:00,Lat Pulldown,normal,60,10
Tag 5: Pull B Schmal/Neutral,2026-10-01 18:00:00,2026-10-01 19:00:00,Lat Pulldown,warmup,30,12
Tag 3: Beine,2026-10-03 18:00:00,2026-10-03 19:10:00,Beinstrecker,normal,50,8
Tag 2: Pull A Breit/Obergriff,2026-10-06 18:00:00,2026-10-06 19:00:00,Barbell Row,normal,70,6
''';
    final preview = parseWorkoutCsv(csv);
    expect(preview, isNotNull);
    expect(preview!.workoutCount, 3);
    expect(preview.exerciseCount, 3);
    expect(preview.templates.map((row) => row.title), [
      'Tag 5: Pull B Schmal/Neutral',
      'Tag 3: Beine',
      'Tag 2: Pull A Breit/Obergriff',
    ]);
    final pull = preview.templates.first;
    expect(pull.setCounts['Lat Pulldown'], 2);
    expect(pull.lastWeights['Lat Pulldown'], 60);
    expect(preview.sets.firstWhere((set) => set.kg == 30).warmup, isTrue);
    expect(
      preview.first,
      DateTime.parse('2026-10-01 18:00:00'.replaceAll(' ', 'T')),
    );
  });

  test('Hevy equipment maps onto the gear list', () {
    expect(hevyEquipmentGear('barbell'), 'Langhantel');
    expect(hevyEquipmentGear('Dumbbell'), 'Kurzhantel');
    expect(hevyEquipmentGear('ez_bar'), 'SZ-Stange');
    expect(hevyEquipmentGear('cable'), 'Kabelzug');
    expect(hevyEquipmentGear('machine'), 'Maschine');
    expect(hevyEquipmentGear('smith machine'), 'Multipresse');
    expect(hevyEquipmentGear('bodyweight'), 'Körpergewicht');
    expect(hevyEquipmentGear('kettlebell'), 'Kettlebell');
    expect(hevyEquipmentGear('resistance_band'), 'Widerstandsband');
    expect(hevyEquipmentGear('cardio'), 'Cardiogerät');
    expect(hevyEquipmentGear('plate'), 'Hantelscheibe');
    expect(hevyEquipmentGear('Scheibe'), 'Hantelscheibe');
    expect(hevyEquipmentGear('weight_plate'), 'Hantelscheibe');
    expect(hevyEquipmentGear('ab wheel'), 'Bauchroller');
    expect(hevyEquipmentGear('ab_wheel'), 'Bauchroller');
    expect(hevyEquipmentGear('Ab-Wheel'), 'Bauchroller');
    expect(hevyEquipmentGear('battle rope'), 'Battle Rope');
    expect(hevyEquipmentGear('sled'), 'Schlitten');
    expect(hevyEquipmentGear('jump rope'), 'Springseil');
    expect(hevyEquipmentGear('other'), isNull);
    expect(hevyEquipmentGear(''), isNull);

    const csv = '''
title,start_time,exercise_title,equipment,weight_kg,reps
Tag,2026-10-01 18:00:00,Plate Pinch,plate,20,10
Tag,2026-10-01 18:00:00,Ab Wheel,ab wheel,0,8
''';
    final preview = parseWorkoutCsv(csv);
    expect(preview!.sets.map((set) => set.equipment), ['plate', 'ab wheel']);
    expect(preview.sets.map((set) => hevyEquipmentGear(set.equipment)), [
      'Hantelscheibe',
      'Bauchroller',
    ]);
  });

  test('measurement CSV reads date and weight', () {
    const csv = 'datum,gewicht\n01.10.2026,82.5\n';
    final points = parseMeasurementCsv(csv);
    expect(points, hasLength(1));
    expect(points.single.kg, 82.5);
    expect(points.single.at, DateTime(2026, 10, 1));
  });
}
