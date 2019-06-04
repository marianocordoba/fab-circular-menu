import 'package:flutter/material.dart';
import 'package:fab_circular_menu/fab_circular_menu.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
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
          options: <Widget>[
            IconButton(icon: Icon(Icons.widgets), onPressed: () {}, iconSize: 48.0, color: Colors.white),
            IconButton(icon: Icon(Icons.widgets), onPressed: () {}, iconSize: 48.0, color: Colors.white),
            IconButton(icon: Icon(Icons.widgets), onPressed: () {}, iconSize: 48.0, color: Colors.white),
            IconButton(icon: Icon(Icons.widgets), onPressed: () {}, iconSize: 48.0, color: Colors.white),
          ],
        ),
      ),
    );
  }

}
