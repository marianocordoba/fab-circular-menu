import 'package:flutter/material.dart';
import 'package:fab_circular_menu/fab_circular_menu.dart';

void main () {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  final GlobalKey<FabCircularMenuState> fabKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Container(
          color: const Color(0xFF192A56),
          child: Center(
            child: RaisedButton(
              onPressed: () {
                // The menu can be handled programatically using a key
                if (fabKey.currentState.isOpen) {
                  fabKey.currentState.close();
                } else {
                  fabKey.currentState.open();
                }
              },
              color: Colors.white,
              child: Text('Toggle menu programatically', style: TextStyle(color: primaryColor)),
            ),
          ),
        ),
        floatingActionButton: Builder(
          builder: (context) => FabCircularMenu(
            key: fabKey,
            // Cannot be `Alignment.center`
            alignment: Alignment.bottomRight,
            ringColor: Colors.white.withAlpha(25),
            ringDiameter: 500.0,
            ringWidth: 150.0,
            fabSize: 64.0,
            fabElevation: 8.0,
            
            // Also can use specific color based on wether
            // the menu is open or not:
            // fabOpenColor: Colors.white
            // fabCloseColor: Colors.white
            // These properties take precedence over fabColor
            fabColor: Colors.white,
            fabOpenIcon: Icon(Icons.menu, color: primaryColor),
            fabCloseIcon: Icon(Icons.close, color: primaryColor),
            fabMargin: const EdgeInsets.all(16.0),
            animationDuration: const Duration(milliseconds: 800),
            animationCurve: Curves.easeInOutCirc,
            onDisplayChange: (isOpen) {
              _showSnackBar(context, "The menu is ${isOpen ? "open" : "closed"}");
            },
            children: <Widget>[
              RawMaterialButton(
                onPressed: () {
                  _showSnackBar(context, "You pressed 1");
                },
                shape: CircleBorder(),
                padding: const EdgeInsets.all(24.0),
                child: Icon(Icons.looks_one, color: Colors.white),
              ),
              RawMaterialButton(
                onPressed: () {
                  _showSnackBar(context, "You pressed 2");
                },
                shape: CircleBorder(),
                padding: const EdgeInsets.all(24.0),
                child: Icon(Icons.looks_two, color: Colors.white),
              ),
              RawMaterialButton(
                onPressed: () {
                  _showSnackBar(context, "You pressed 3");
                },
                shape: CircleBorder(),
                padding: const EdgeInsets.all(24.0),
                child: Icon(Icons.looks_3, color: Colors.white),
              ),
              RawMaterialButton(
                onPressed: () {
                  _showSnackBar(context, "You pressed 4. This one closes the menu on tap");
                  fabKey.currentState.close();
                },
                shape: CircleBorder(),
                padding: const EdgeInsets.all(24.0),
                child: Icon(Icons.looks_4, color: Colors.white),
              )
            ],
          ),
        ),
      ),
    );
  }
  
  void _showSnackBar (BuildContext context, String message) {
    Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(milliseconds: 1000),
        )
    );
  }

}