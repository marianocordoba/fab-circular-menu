import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fab_circular_menu/fab_circular_menu.dart';

void main () {
//  debugPaintPointersEnabled = true;
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    final controller = FabCircularMenuController();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: FabCircularMenu(
          child: Container(
            color: Colors.indigo[900],
            child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 256.0),
                  child: Text(
                      'FAB Circle Menu Example',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 36.0)
                  ),
                )
            ),
          ),
          ringColor: Colors.white30,
          controller: controller,
          options: <Widget>[
            IconButton(icon: Icon(Icons.widgets), onPressed: () {
              controller.isOpen = false;
            }, iconSize: 48.0, color: Colors.white),
            IconButton(icon: Icon(Icons.widgets), onPressed: () {}, iconSize: 48.0, color: Colors.white),
            IconButton(icon: Icon(Icons.widgets), onPressed: () {}, iconSize: 48.0, color: Colors.white),
            IconButton(icon: Icon(Icons.widgets), onPressed: () {}, iconSize: 48.0, color: Colors.white),
          ],
        ),
      ),
    );
  }

}
