import 'package:fab_circular_menu/fab_circular_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets("Should show it's options while opened",
      (WidgetTester tester) async {
    final widgetUnderTest = MaterialApp(
      home: Scaffold(
        floatingActionButton: FabCircularMenu(
          alignment: Alignment.bottomCenter,
          animationDuration: Duration.zero,
          children: const <Widget>[Icon(Icons.add), Icon(Icons.add)],
        ),
      ),
    );
    await tester.pumpWidget(widgetUnderTest);

    expect(find.byIcon(Icons.menu), findsOneWidget);
    expect(find.byIcon(Icons.close), findsNothing);
    expect(find.byIcon(Icons.add), findsNothing);

    await tester.tap(find.byType(RawMaterialButton));
    await tester.pump();

    expect(find.byIcon(Icons.menu), findsNothing);
    expect(find.byIcon(Icons.close), findsOneWidget);
    expect(find.byIcon(Icons.add), findsNWidgets(2));
  });

  testWidgets(
      'Should be able to be opened by tapping the FAB or programatically',
      (WidgetTester tester) async {
    final GlobalKey<FabCircularMenuState> fab = GlobalKey();
    bool isOpen = false;

    final widgetUnderTest = MaterialApp(
      home: Scaffold(
        floatingActionButton: FabCircularMenu(
          key: fab,
          alignment: Alignment.centerRight,
          animationDuration: Duration.zero,
          onDisplayChange: (val) {
            isOpen = val;
          },
          children: const <Widget>[Placeholder(), Placeholder()],
        ),
      ),
    );
    await tester.pumpWidget(widgetUnderTest);

    expect(isOpen, false);

    await tester.tap(find.byType(RawMaterialButton));
    await tester.pump();

    expect(isOpen, true);

    await tester.tap(find.byType(RawMaterialButton));
    await tester.pump();

    expect(isOpen, false);

    fab.currentState!.open();
    await tester.pump();

    expect(isOpen, true);
    expect(fab.currentState!.isOpen, true);

    fab.currentState!.close();
    await tester.pump();

    expect(isOpen, false);
    expect(fab.currentState!.isOpen, false);
  });
}
