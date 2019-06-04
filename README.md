# FAB Circular Menu 
![Pub](https://img.shields.io/pub/v/fab_circular_menu.svg)

A Flutter package to create a nice circular menu using a Floating Action Button.

Inspired by [Mayur Kshirsagar](https://dribbble.com/mayurksgr)'s great [FAB Microinteraction](https://dribbble.com/shots/4354100-Daily-UI-Challenge-Day-75-FAB-Microinteraction) design.

##### WARNING! This package is under development and should not be used in production apps.

![Showcase](https://i.imgur.com/vjAvdoR.gif)

## Getting started

Wrap your content with `FabCircularMenu` and set your desired `options`:


```dart
FabCircularMenu(
  child: Placeholder(), // Replace this with your content
  options: <Widget>[
    IconButton(icon: Icon(Icons.home), onPressed: () {
      print('Pressed!');
    })
  ]
)
```

### Options

| Property | Type | Description | Default |
|----------|------|-------------|---------|
| <font color="ff0000">`required`</font> child | Widget | The child of this widget | - 
| <font color="ff0000">`required`</font> options | List<Widget> | The available options of the menu | -
| ringColor | Color | The color of the ring | `Colors.white`
| ringDiameter | double | The diameter of the ring | `screenWidth * 1.2`
| ringWidth | double | The width of the ring | `ringDiameter / 3`
| fabMargin | EdgeInsets | The margin around the FAB | `EdgeInsets.all(24.0)`
| fabColor | Color | The color of the FAB | `primaryColor`
| fabOpenIcon | Icon | The open icon | `Icon(Icons.menu)`
| fabCloseIcon | Icon | The close icon | `Icon(Icons.close)`
| animationDuration | Duration | The animation duration | `Duration(milliseconds: 800)`

## To Do

- [ ] Improve documentation
- [ ] Add tests
- [ ] Add examples