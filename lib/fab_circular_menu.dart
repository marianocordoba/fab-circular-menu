import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart' as vector;

typedef DisplayChange = void Function (bool isOpen);

class FabCircularMenu extends StatefulWidget {

  final List<Widget> children;
  final Alignment alignment;
  final Color ringColor;
  final double ringDiameter;
  final double ringWidth;
  final double fabSize;
  final double fabElevation;
  final Color fabColor;
  final Color fabOpenColor;
  final Color fabCloseColor;
  final Icon fabOpenIcon;
  final Icon fabCloseIcon;
  final EdgeInsets fabMargin;
  final Duration animationDuration;
  final Curve animationCurve;
  final DisplayChange onDisplayChange;

  FabCircularMenu({
    Key key,
    this.alignment = Alignment.bottomRight,
    this.ringColor,
    this.ringDiameter,
    this.ringWidth,
    this.fabSize = 64.0,
    this.fabElevation = 8.0,
    this.fabColor,
    this.fabOpenColor,
    this.fabCloseColor,
    this.fabOpenIcon = const Icon(Icons.menu),
    this.fabCloseIcon = const Icon(Icons.close),
    this.fabMargin = const EdgeInsets.all(16.0),
    this.animationDuration = const Duration(milliseconds: 800),
    this.animationCurve = Curves.easeInOutCirc,
    this.onDisplayChange,
    @required this.children
  }) :  assert(alignment != Alignment.center),
        assert(children != null),
        assert(children.length >= 2),
        super(key: key);

  @override
  FabCircularMenuState createState() => FabCircularMenuState();
}

class FabCircularMenuState extends State<FabCircularMenu>
    with SingleTickerProviderStateMixin {

  double _screenWidth;
  double _screenHeight;
  double _marginH;
  double _marginV;
  double _directionX;
  double _directionY;
  double _translationX;
  double _translationY;

  Color _ringColor;
  double _ringDiameter;
  double _ringWidth;
  Color _fabColor;
  Color _fabOpenColor;
  Color _fabCloseColor;

  AnimationController _animationController;
  Animation<double> _scaleAnimation;
  Animation _scaleCurve;
  Animation<double> _rotateAnimation;
  Animation _rotateCurve;
  Animation<Color> _colorAnimation;
  Animation _colorCurve;

  bool _isOpen = false;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
        duration: widget.animationDuration,
        vsync: this
    );

    _scaleCurve = CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.0, 0.4, curve: widget.animationCurve)
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0)
      .animate(_scaleCurve)
      ..addListener(() {
        setState(() {});
      });

    _rotateCurve = CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.4, 1.0, curve: widget.animationCurve)
    );
    _rotateAnimation = Tween<double>(begin: 0.5, end: 1.0)
      .animate(_rotateCurve)
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
      margin: widget.fabMargin,
      // Removes the default FAB margin
      transform: Matrix4.translationValues(16.0, 16.0, 0.0),
      child: Stack(
        alignment: widget.alignment,
        children: <Widget>[
          // Ring
          Transform(
            transform: Matrix4
                .translationValues(_translationX, _translationY, 0.0)
              ..scale(_scaleAnimation.value),
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
                      color: _ringColor
                  ),
                  child: _scaleAnimation.value == 1.0 ? Transform.rotate(
                    angle: (2 * pi) * _rotateAnimation.value * _directionX * _directionY,
                    child: Container(
                      child: Stack(
                        alignment: Alignment.center,
                        children: widget.children.asMap().map((index, child) =>
                            MapEntry(index, _applyTransformations(child, index))
                        ).values.toList(),
                      ),
                    ),
                  ) : Container(),
                ),
              ),
            ),
          ),

          // FAB
          Container(
            width: widget.fabSize,
            height: widget.fabSize,
            child: RawMaterialButton(
              fillColor: _colorAnimation.value,
              shape: CircleBorder(),
              elevation: widget.fabElevation,
              onPressed: () {
                if (_isAnimating) return;

                if (_isOpen) {
                  close();
                } else {
                  open();
                }
              },
              child: Center(
                  child: _scaleAnimation.value == 1.0 ? widget.fabCloseIcon : widget.fabOpenIcon
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _applyTransformations (Widget child, int index) {
    double angleFix = 0.0;
    if (widget.alignment.x == 0) {
      angleFix = 45.0 * _directionY.abs();
    } else if (widget.alignment.y == 0) {
      angleFix = -45.0 * _directionX.abs();
    }

    final angle = vector.radians(90.0 / (widget.children.length - 1) * index + angleFix);

    return Transform(
        transform: Matrix4
            .translationValues(
            (-(_ringDiameter / 2) * cos(angle) + (_ringWidth / 2 * cos(angle))) * _directionX,
            (-(_ringDiameter / 2) * sin(angle) + (_ringWidth / 2 * sin(angle))) * _directionY,
            0.0
        ),
        alignment: FractionalOffset.center,
        child: Material(
          color: Colors.transparent,
          child: child,
        )
    );
  }

  void _calculateProps () {
    _ringColor = widget.ringColor ?? Theme.of(context).accentColor;
    _fabColor = widget.fabColor ?? Theme.of(context).primaryColor;
    _fabOpenColor = widget.fabOpenColor ?? _fabColor;
    _fabCloseColor = widget.fabCloseColor ?? _fabColor;
    _screenWidth = MediaQuery.of(context).size.width;
    _screenHeight = MediaQuery.of(context).size.height;
    _ringDiameter = widget.ringDiameter ?? min(_screenWidth, _screenHeight) * 1.25;
    _ringWidth = widget.ringWidth ?? _ringDiameter * 0.3;
    _marginH = (widget.fabMargin.right + widget.fabMargin.left) / 2;
    _marginV = (widget.fabMargin.top + widget.fabMargin.bottom) / 2;
    _directionX = widget.alignment.x == 0 ? 1 : widget.alignment.x;
    _directionY = widget.alignment.y == 0 ? 1 : widget.alignment.y;
    _translationX = ((_screenWidth - widget.fabSize) / 2 - _marginH) * widget.alignment.x;
    _translationY = ((_screenHeight - widget.fabSize) / 2 - _marginV) * widget.alignment.y;

    if (_colorAnimation == null || !kReleaseMode) {
      _colorCurve = CurvedAnimation(
          parent: _animationController,
          curve: Interval(0.0, 0.4, curve: widget.animationCurve)
      );
      _colorAnimation = ColorTween(begin: _fabCloseColor, end: _fabOpenColor)
          .animate(_colorCurve)
        ..addListener(() {
          setState(() {});
        });
    }
  }

  void open () {
    _isAnimating = true;
    _animationController.forward().then((_) {
      _isAnimating = false;
      _isOpen = true;
      if (widget.onDisplayChange != null) {
        widget.onDisplayChange(true);
      }
    });
  }

  void close () {
    _isAnimating = true;
    _animationController.reverse().then((_) {
      _isAnimating = false;
      _isOpen = false;
      if (widget.onDisplayChange != null) {
        widget.onDisplayChange(false);
      }
    });
  }

  bool get isOpen => _isOpen;
}

class _RingPainter extends CustomPainter {

  final double width;
  final Color color;

  _RingPainter({
    @required this.width,
    this.color
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color ?? Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width < width ? size.width : width;

    canvas.drawArc(
        Rect.fromLTWH(width / 2, width / 2, size.width - width, size.height - width),
        0.0,
        2 * pi,
        false,
        paint
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;

}