# FAB Circular Menu 
[![Pub](https://img.shields.io/pub/v/fab_circular_menu.svg)](https://pub.dev/packages/fab_circular_menu)
[![Pull Requests are welcome](https://img.shields.io/badge/license-MIT-blue)](https://github.com/marianocordoba/fab-circular-menu/blob/master/LICENSE)
[![Codemagic build status](https://api.codemagic.io/apps/5cf6ad31434563000a9534d5/5cf6ad31434563000a9534d4/status_badge.svg)](https://codemagic.io/apps/5cf6ad31434563000a9534d5/5cf6ad31434563000a9534d4/latest_build)
![Null safety](https://img.shields.io/badge/null%20safety-true-brightgreen)

A Flutter package to create a nice circular menu using a Floating Action Button.

Inspired by [Mayur Kshirsagar](https://dribbble.com/mayurksgr)'s great [FAB Microinteraction](https://dribbble.com/shots/4354100-Daily-UI-Challenge-Day-75-FAB-Microinteraction) design.

![Showcase](https://i.imgur.com/ErrNnAw.gif)

## Installation

Just add `fab_circular_menu` to your [pubspec.yml](https://flutter.io/using-packages/) file

```yml
dependencies:
  fab_circular_menu: ^1.0.0
```

## Example

```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Placeholder(),
        floatingActionButton: FabCircularMenu(
          children: <Widget>[
            IconButton(icon: Icon(Icons.home), onPressed: () {
              print('Home');
            }),
            IconButton(icon: Icon(Icons.favorite), onPressed: () {
              print('Favorite');
            })
          ]
        )
      )
    );
  }
}
```

You can check for a more complete example in the [example](https://github.com/marianocordoba/fab-circular-menu/tree/master/example) directory.

## Customize

You can customize the widget appareance using the following properties:

| Property  | Description | Default |
|----------|-------------|---------|
| alignment | Sets the widget alignment | `Alignment.bottomRight` |
| ringColor | Sets the ring color | `accentColor` |
| ringDiameter | Sets de ring diameter | `screenWidth * 1.25` (portrait) <br> `screenHeight * 1.25` (landscape) |
| ringWidth | Sets the ring width | `ringDiameter * 0.3` |
| fabSize | Sets the FAB size | `64.0` |
| fabElevation | Sets the elevation for the FAB | `8.0` |
| fabColor | Sets the FAB color | `primaryColor` |
| fabOpenColor | Sets the FAB color while the menu is open. This property takes precedence over `fabColor` | - |
| fabCloseColor | Sets the FAB color while the menu is closed. This property takes precedence over `fabColor` | - |
| fabChild | Sets the child inside the FAB. This property takes precedence over `fabOpenicon` and `fabCloseIcon` | - |
| fabOpenIcon | Sets the FAB icon while the menu is open | `Icon(Icons.menu)` |
| fabCloseIcon | Sets the FAB icon while the menu is closed | `Icon(Icons.close)` |
| fabMargin | Sets the widget margin | `EdgeInsets.all(16.0)` |
| animationDuration | Changes the animation duration | `Duration(milliseconds: 800)` |
| animationCurve | Allows you to modify de animation curve | `Curves.easeInOutCirc` |
| onDisplayChange | This callback is called every time the menu is opened or closed, passing the current state as a parameter. | - |

## Handling the menu programmatically

It is possible to handle the menu programatically by using a [key](https://api.flutter.dev/flutter/foundation/Key-class.html). Just create a key and set it in the `key` property of the `FabCircularMenu`, then use the key to get the current state and open, close or check the status of the menu.

```dart
class MyApp extends StatelessWidget {
  final GlobalKey<FabCircularMenuState> fabKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: RaisedButton(
          onPressed: () {
            if (fabKey.currentState.isOpen) {
              fabKey.currentState.close();
            } else {
              fabKey.currentState.open();
            }
          },
          child: Text('Toggle menu')
        ),
        floatingActionButton: FabCircularMenu(
          key: fabKey,
          children: <Widget>[
            // ...
          ]
        )
      )
    );
  }
}
```

## Contributing

I will be very happy if you contribute to this project, please submit a PR 😁
