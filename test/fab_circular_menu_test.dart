import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fab_circular_menu/fab_circular_menu.dart';

void main() {

  testWidgets('FabCircularMenu', (WidgetTester tester) async {
    Widget widgetUnderTest = Directionality(
      child: MediaQuery(
        data: MediaQueryData(),
        child: Material(
          child: FabCircularMenu(
            child: Container(),
            options: <Widget>[
              IconButton(icon: Icon(Icons.widgets), onPressed: () {}, iconSize: 48.0, color: Colors.white),
              IconButton(icon: Icon(Icons.widgets), onPressed: () {}, iconSize: 48.0, color: Colors.white),
              IconButton(icon: Icon(Icons.widgets), onPressed: () {}, iconSize: 48.0, color: Colors.white),
              IconButton(icon: Icon(Icons.widgets), onPressed: () {}, iconSize: 48.0, color: Colors.white)
            ],
            animationDuration: Duration(milliseconds: 1),
          ),
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    await tester.pumpWidget(widgetUnderTest);

    expect(find.byIcon(Icons.widgets), findsNWidgets(4));
    expect(find.byIcon(Icons.menu), findsOneWidget);
    expect(find.byIcon(Icons.close), findsNothing);

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pump(Duration(milliseconds: 10));

    expect(find.byIcon(Icons.menu), findsNothing);
    expect(find.byIcon(Icons.close), findsOneWidget);

    await tester.pump(Duration(milliseconds: 10));
    
    await tester.tap(find.byIcon(Icons.close));
    await tester.pump(Duration(milliseconds: 10));

    expect(find.byIcon(Icons.menu), findsOneWidget);
    expect(find.byIcon(Icons.close), findsNothing);
  });

}