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
  final Icon fabOpenIcon;
  final Icon fabCloseIcon;
  final Duration animationDuration;

  FabCircularMenu({
    @required this.child,
    @required this.options,
    this.ringColor = Colors.white,
    this.ringDiameter,
    this.ringWidth,
    this.fabMargin = const EdgeInsets.all(24.0),
    this.fabColor,
    this.fabOpenIcon = const Icon(Icons.menu),
    this.fabCloseIcon = const Icon(Icons.close),
    this.animationDuration = const Duration(milliseconds: 800)
  }) : assert(options != null && options.length > 0);

  @override
  _FabCircularMenuState createState() => _FabCircularMenuState();

}

class _FabCircularMenuState extends State<FabCircularMenu>
  with SingleTickerProviderStateMixin {

  double ringDiameter;
  double ringWidth;
  Color fabColor;

  bool animating = false;
  bool open = false;
  AnimationController animationController;
  Animation<double> scaleAnimation;
  Animation scaleCurve;
  Animation<double> rotateAnimation;
  Animation rotateCurve;

  @override
  void initState() {
    super.initState();

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

        Positioned(
          bottom: bottom,
          right: right,
            child: Container(
              width: scaleAnimation.value * ringDiameter,
              height: scaleAnimation.value * ringDiameter,
              child: Transform.rotate(
                angle: -(math.pi / rotateAnimation.value),
                child: Stack(
                  alignment: Alignment.center,
                  children: _applyTranslations(widget.options)
                ),
              ),
            ),
        ),

        Padding(
          padding: widget.fabMargin,
          child: FloatingActionButton(
            child: open ? widget.fabCloseIcon : widget.fabOpenIcon,
            backgroundColor: fabColor,
            onPressed: () {
              if (!animating && !open) {
                animating = true;
                open = true;
                animationController.forward().then((_) {
                  animating = false;
                });
              } else if (!animating) {
                animating = true;
                open = false;
                animationController.reverse().then((_) {
                  animating = false;
                });
              }
            }
          ),
        )
      ],
    );
  }

  List<Widget> _applyTranslations(List<Widget> widgets) {
    return widgets.asMap().map((index, widget) {
      final double angle = 90.0 / (widgets.length * 2 - 2) * (index * 2);
      return MapEntry(index, _applyTranslation(angle, widget));
    }).values.toList();
  }

  Widget _applyTranslation(double angle, Widget widget) {
    final double rad = vector.radians(angle);
    return Transform(
      transform: Matrix4.identity()
        ..translate(
            -(ringDiameter / 2) * math.cos(rad),
            -(ringDiameter / 2) * math.sin(rad)
        ),
      child: widget,
    );
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