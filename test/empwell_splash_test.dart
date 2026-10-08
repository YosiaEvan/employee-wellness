import 'package:employee_wellness/components/empwell_splash.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('EmpWell splash completes its logo reveal without errors', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: EmpWellSplash()));
    await tester.pumpAndSettle(const Duration(milliseconds: 50));

    expect(find.byType(EmpWellSplash), findsOneWidget);
    expect(find.byType(Image), findsNWidgets(5));
    expect(tester.takeException(), isNull);
  });
}
