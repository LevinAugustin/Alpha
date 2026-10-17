import 'package:flexify/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/test_app.dart';

void main() {
  testWidgets('shell shows four German tabs and the calendar', (tester) async {
    final harness = await FlexifyTestHarness.create();
    await harness.pump(
      tester,
      const HomePage(),
      locale: const Locale('de'),
      surfaceSize: const Size(400, 900),
    );
    await tester.pump();

    expect(find.text('Übungen'), findsWidgets);
    expect(find.text('Profil'), findsWidgets);
    expect(find.byKey(const Key('tab-training')), findsOneWidget);
    expect(find.byKey(const Key('open-calendar')), findsOneWidget);

    await tester.tap(find.byKey(const Key('open-calendar')));
    await tester.pumpAndSettle();
    expect(find.text('Kalender'), findsWidgets);
    expect(find.textContaining('Tage in Folge'), findsOneWidget);
  });
}
