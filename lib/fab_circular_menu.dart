library fab_circular_menu;

import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:vector_math/vector_math.dart' as vector;

class FabCircularMenu extends StatefulWidget {

  final Widget child;
  final List<Widget> options;
  final Color ringColor;
  final double ringDiameter;
  final double ringWidth;
  final EdgeInsets fabMargin;
  final Color fabColor;
  final Color fabOpenColor;
  final Color fabCloseColor;
  final Icon fabOpenIcon;
  final Icon fabCloseIcon;
  final Duration animationDuration;
  final Function onDisplayChange;
  final FabCircularMenuController controller;
  
  static _defaultVoidFunc([isOpen]) {}

  FabCircularMenu({
    @required this.options,
    this.ringColor = Colors.white,
    this.ringDiameter,
    this.ringWidth,
    this.fabMargin = const EdgeInsets.all(24.0),
    this.fabColor,
    this.fabOpenColor,
    this.fabCloseColor,
    this.fabOpenIcon = const Icon(Icons.menu),
    this.fabCloseIcon = const Icon(Icons.close),
    this.animationDuration = const Duration(milliseconds: 800),
    this.onDisplayChange = _defaultVoidFunc,
    this.controller,
    @required this.child,
  }) : assert(child != null),
       assert(options != null && options.length > 0);

  @override
  _FabCircularMenuState createState() => _FabCircularMenuState();

}

class _FabCircularMenuState extends State<FabCircularMenu>
  with SingleTickerProviderStateMixin {

  double ringDiameter;
  double ringWidth;
  Color fabColor;
  Color fabOpenColor;
  Color fabCloseColor;

  bool animating = false;
  bool open = false;
  AnimationController animationController;
  Animation<double> scaleAnimation;
  Animation scaleCurve;
  Animation<double> rotateAnimation;
  Animation rotateCurve;
  FabCircularMenuController controller;

  @override
  void initState() {
    super.initState();

    controller = widget.controller ?? FabCircularMenuController();
    controller.addListener(() {
      if (controller.isOpen) {
        _open();
      } else {
        _close();
      }
    });

    animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this
    );

    scaleCurve = CurvedAnimation(
      parent: animationController, curve: Interval(0.0, 0.4, curve: Curves.easeInOutCirc)
    );
    scaleAnimation = Tween<double>(begin: 0.0, end: 1.0)
      .animate(scaleCurve)
      ..addListener(() {
        setState(() {});
      });

    rotateCurve = CurvedAnimation(
      parent: animationController, curve: Interval(0.4, 1.0, curve: Curves.easeInOutCirc)
    );
    rotateAnimation = Tween<double>(begin: 1.0, end: 90.0)
      .animate(rotateCurve)
      ..addListener(() {
        setState(() {});
      });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    ringDiameter = widget.ringDiameter ?? MediaQuery.of(context).size.width * 1.2;
    ringWidth = widget.ringWidth ?? ringDiameter / 3;
    fabColor = widget.fabColor ?? Theme.of(context).primaryColor;
    fabOpenColor = widget.fabOpenColor ?? fabColor ?? Theme.of(context).primaryColor;
    fabCloseColor = widget.fabCloseColor ?? fabColor ?? Theme.of(context).primaryColor;
  }

  @override
  void dispose() {
    animationController?.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double bottom = -(scaleAnimation.value * ringDiameter / 2 - 40.0 - (widget.fabMargin.bottom / 2));
    final double right = -(scaleAnimation.value * ringDiameter / 2 - 40.0 - (widget.fabMargin.right / 2));

    return Stack(
      alignment: Alignment.bottomRight,
      children: <Widget>[
        widget.child,

        // Ring
        Positioned(
          bottom: bottom,
          right: right,
          child: Container(
            width: scaleAnimation.value * ringDiameter,
            height: scaleAnimation.value * ringDiameter,
            child: CustomPaint(
              foregroundPainter: _RingPainter(
                ringColor: widget.ringColor,
                ringWidth: scaleAnimation.value * ringWidth
              ),
            ),
          ),
        ),

        // Options
        Positioned(
          bottom: bottom - (ringWidth * 0.5),
          right: right - (ringWidth * 0.5),
            child: Material(
              child: Container(
                width: scaleAnimation.value * ringDiameter + ringWidth,
                height: scaleAnimation.value * ringDiameter + ringWidth,
                child: Transform.rotate(
                  angle: -(math.pi / rotateAnimation.value),
                  child: Stack(
                    alignment: Alignment.center,
                    children: _applyTranslations(widget.options)
                  ),
                ),
              ),
              color: Colors.transparent,
            ),
        ),

        // FAB
        Padding(
          padding: widget.fabMargin,
          child: FloatingActionButton(
            child: open ? widget.fabCloseIcon : widget.fabOpenIcon,
            backgroundColor: open ? fabOpenColor : fabCloseColor,
            onPressed: () {
              if (!animating && !open) {
                _open();
              } else if (!animating) {
                _close();
              }
            }
          ),
        )
      ],
    );
  }

  List<Widget> _applyTranslations(List<Widget> options) {
    return options.asMap().map((index, option) {
      final double angle = options.length == 1 ? 45.0 : 90.0 / (options.length * 2 - 2) * (index * 2);
      return MapEntry(index, _applyTranslation(angle, option));
    }).values.toList();
  }

  Widget _applyTranslation(double angle, Widget option) {
    final double rad = vector.radians(angle);
    return Transform(
      transform: Matrix4.identity()
        ..translate(
            -(ringDiameter / 2) * math.cos(rad),
            -(ringDiameter / 2) * math.sin(rad)
        ),
      child: Transform(
        child: option,
        transform: Matrix4.rotationZ(math.pi / rotateAnimation.value),
        alignment: FractionalOffset.center,
      ),
    );
  }

  void _open () {
    animating = true;
    animationController.forward().then((_) {
      open = true;
      animating = false;
      widget.onDisplayChange({ 'isOpen': open });
    });
  }

  void _close () {
    animating = true;
    animationController.reverse().then((_) {
      open = false;
      animating = false;
      widget.onDisplayChange({ 'isOpen': open });
    });
  }

}

class FabCircularMenuController extends ValueNotifier<bool> {

  FabCircularMenuController({ bool isOpen })
    : super(isOpen ?? false);

  bool get isOpen => value;

  set isOpen (bool newValue) {
    value = newValue;
    notifyListeners();
  }

}

class _RingPainter extends CustomPainter {

  final Color ringColor;
  final double ringWidth;

  _RingPainter({
    @required this.ringColor,
    @required this.ringWidth
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = ringColor
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = ringWidth;

    Offset center = Offset(size.width / 2, size.height / 2);

    canvas.drawCircle(center, size.width / 2, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;

}