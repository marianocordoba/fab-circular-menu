import 'dart:math';

import 'package:fab_circular_menu/stack_with_all_children_receive_events.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart' as vector;

typedef DisplayChange = void Function(bool isOpen);

class FabCircularMenu extends StatefulWidget {
  /// When used as the floatingActionButton in a Scaffold, there is a default margin
  /// applied that needs to be removed.  If this button is placed manually, this offset
  /// can cause issues.  Set this value to false to _not_ attempt to remove the default
  /// FAB margin
  final bool removeDefaultFabMargin;

  final List<Widget> children;
  final Alignment alignment;
  final Color? ringColor;
  final double? ringDiameter;
  final double? ringWidth;
  final Key? buttonKey;
  final double rangeStartOffset;
  final double rangeEndOffset;
  final double fabSize;
  final double fabElevation;
  final Color? fabColor;
  final Color? fabOpenColor;
  final Color? fabCloseColor;
  final Widget? fabChild;
  final Widget fabOpenIcon;
  final Widget fabCloseIcon;
  final ShapeBorder? fabIconBorder;
  final EdgeInsets fabMargin;
  final Offset menuOffset;
  final Duration animationDuration;
  final Curve animationCurve;
  final DisplayChange? onDisplayChange;

  /// Disables the menu from appearing, in favor of a simple onTap handler
  final VoidCallback? onFabTap;

  FabCircularMenu(
      {Key? key,
      this.buttonKey,
      this.alignment = Alignment.bottomCenter,
      this.ringColor,
      this.ringDiameter,
      this.ringWidth,
      this.onFabTap,
      this.fabSize = 64.0,
      this.menuOffset = Offset.zero,
      this.fabElevation = 8.0,
      this.fabColor,
      this.fabOpenColor,
      this.removeDefaultFabMargin = true,
      this.fabCloseColor,
      this.fabIconBorder,
      this.rangeStartOffset = 0.0,
      this.rangeEndOffset = 0.0,
      this.fabChild,
      this.fabOpenIcon = const Icon(Icons.menu),
      this.fabCloseIcon = const Icon(Icons.close),
      this.fabMargin = const EdgeInsets.all(16.0),
      this.animationDuration = const Duration(milliseconds: 800),
      this.animationCurve = Curves.easeInOutCirc,
      this.onDisplayChange,
      required this.children})
      : assert(children.length >= 1),
        super(key: key);

  @override
  FabCircularMenuState createState() => FabCircularMenuState();
}

class FabCircularMenuState extends State<FabCircularMenu>
    with SingleTickerProviderStateMixin {
  late double _screenWidth;
  late double _screenHeight;
  late double _marginH;
  late double _marginV;
  late double _directionX;
  late double _directionY;
  late double _translationX;
  late double _translationY;

  Color? _ringColor;
  double? _ringDiameter;
  double? _ringWidth;
  Color? _fabColor;
  Color? _fabOpenColor;
  Color? _fabCloseColor;
  late ShapeBorder _fabIconBorder;

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation _scaleCurve;
  late Animation<double> _rotateAnimation;
  late Animation _rotateCurve;
  Animation<Color?>? _colorAnimation;
  late Animation _colorCurve;

  bool _isOpen = false;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();

    _animationController =
        AnimationController(duration: widget.animationDuration, vsync: this);

    _scaleCurve = CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.0, 0.4, curve: widget.animationCurve));
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(_scaleCurve as Animation<double>)
      ..addListener(() {
        setState(() {});
      });

    _rotateCurve = CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.4, 1.0, curve: widget.animationCurve));
    _rotateAnimation = Tween<double>(begin: 0.5, end: 1.0)
        .animate(_rotateCurve as Animation<double>)
      ..addListener(() {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _calculateProps();
  }

  @override
  Widget build(BuildContext context) {
    // This makes the widget able to correctly redraw on
    // hot reload while keeping performance in production
    if (!kReleaseMode) {
      _calculateProps();
    }

    return Container(
      // Removes the default FAB margin
      transform: widget.removeDefaultFabMargin
          ? Matrix4.translationValues(16.0, 16.0, 0.0)
          : null,
      child: StackWithAllChildrenReceiveEvents(
        overflow: Overflow.visible,
        alignment: widget.alignment,
        children: <Widget>[
          // Ring
          Transform(
            transform: Matrix4.translationValues(
              _translationX,
              _translationY,
              0.0,
            )..scale(_scaleAnimation.value),
            alignment: FractionalOffset.center,
            child: OverflowBox(
              maxWidth: _ringDiameter,
              maxHeight: _ringDiameter,
              child: Container(
                width: _ringDiameter,
                height: _ringDiameter,
                child: CustomPaint(
                  painter: _RingPainter(
                    width: _ringWidth,
                    color: _ringColor,
                  ),
                  child: _scaleAnimation.value == 1.0
                      ? Transform.rotate(
                          angle: (2 * pi) *
                              _rotateAnimation.value *
                              _directionX *
                              _directionY,
                          child: Container(
                            child: Stack(
                              alignment: Alignment.center,
                              children: widget.children
                                  .asMap()
                                  .map((index, child) => MapEntry(index,
                                      _applyTransformations(child, index)))
                                  .values
                                  .toList(),
                            ),
                          ),
                        )
                      : Container(),
                ),
              ),
            ),
          ),

          // FAB
          Container(
            margin: widget.fabMargin,
            width: widget.fabSize,
            height: widget.fabSize,
            child: RawMaterialButton(
              key: widget.buttonKey,
              fillColor: _colorAnimation!.value,
              shape: _fabIconBorder,
              elevation: widget.fabElevation,
              onPressed: () {
                if (widget.onFabTap != null) {
                  widget.onFabTap!();
                  return;
                } else {
                  if (_isAnimating) return;

                  if (_isOpen) {
                    close();
                  } else {
                    open();
                  }
                }
              },
              child: Center(
                child: widget.fabChild == null
                    ? (_scaleAnimation.value == 1.0
                        ? widget.fabCloseIcon
                        : widget.fabOpenIcon)
                    : widget.fabChild,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _applyTransformations(Widget child, int index) {
    double angleFix = 0.0;
    if (widget.alignment.x == 0) {
      angleFix = 45.0 * _directionY.abs();
    } else if (widget.alignment.y == 0) {
      angleFix = -45.0 * _directionX.abs();
    }
    angleFix += widget.rangeStartOffset;

    final angle = vector.radians(
        (90.0 - widget.rangeStartOffset - widget.rangeEndOffset) /
                (widget.children.length - 1) *
                index +
            angleFix);

    return Transform(
        transform: Matrix4.translationValues(
            (-(_ringDiameter! / 2) * cos(angle) +
                    (_ringWidth! / 2 * cos(angle))) *
                _directionX,
            (-(_ringDiameter! / 2) * sin(angle) +
                    (_ringWidth! / 2 * sin(angle))) *
                _directionY,
            0.0),
        alignment: FractionalOffset.center,
        child: Material(
          color: Colors.transparent,
          child: child,
        ));
  }

  void _calculateProps() {
    _ringColor = widget.ringColor ?? Theme.of(context).accentColor;
    _fabColor = widget.fabColor ?? Theme.of(context).primaryColor;
    _fabOpenColor = widget.fabOpenColor ?? _fabColor;
    _fabCloseColor = widget.fabCloseColor ?? _fabColor;
    _fabIconBorder = widget.fabIconBorder ?? CircleBorder();
    _screenWidth = MediaQuery.of(context).size.width;
    _screenHeight = MediaQuery.of(context).size.height;
    _ringDiameter =
        widget.ringDiameter ?? min(_screenWidth, _screenHeight) * 1.25;
    _ringWidth = widget.ringWidth ?? _ringDiameter! * 0.3;
    _marginH = (widget.fabMargin.right + widget.fabMargin.left) / 2;
    _marginV = (widget.fabMargin.top + widget.fabMargin.bottom) / 2;
    _directionX = widget.alignment.x == 0 ? 1 : 1 * widget.alignment.x.sign;
    _directionY = widget.alignment.y == 0 ? 1 : 1 * widget.alignment.y.sign;
    _translationX = (((_screenWidth - widget.fabSize) / 2 - _marginH) *
            widget.alignment.x) +
        widget.menuOffset.dx;
    _translationY = (((_screenHeight - widget.fabSize) / 2 - _marginV) *
            widget.alignment.y) +
        widget.menuOffset.dy;

    if (_colorAnimation == null || !kReleaseMode) {
      _colorCurve = CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            0.0,
            0.4,
            curve: widget.animationCurve,
          ));
      _colorAnimation = ColorTween(begin: _fabCloseColor, end: _fabOpenColor)
          .animate(_colorCurve as Animation<double>)
        ..addListener(() {
          setState(() {});
        });
    }
  }

  void open() {
    _isAnimating = true;
    _animationController.forward().then((_) {
      _isAnimating = false;
      _isOpen = true;
      if (widget.onDisplayChange != null) {
        widget.onDisplayChange!(true);
      }
    });
  }

  void close() {
    _isAnimating = true;
    _animationController.reverse().then((_) {
      _isAnimating = false;
      _isOpen = false;
      if (widget.onDisplayChange != null) {
        widget.onDisplayChange!(false);
      }
    });
  }

  bool get isOpen => _isOpen;
}

class _RingPainter extends CustomPainter {
  final double? width;
  final Color? color;

  _RingPainter({
    required this.width,
    this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color ?? Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width < width! ? size.width : width!;

    canvas.drawArc(
      Rect.fromLTWH(
          width! / 2, width! / 2, size.width - width!, size.height - width!),
      0.0,
      2 * pi,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
