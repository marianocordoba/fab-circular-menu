import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';

/// Passes all events to all children of the stack.  The FAB was having issues
/// where the padding on the button was blocking the circular items on the edge
class StackWithAllChildrenReceiveEvents extends Stack {

  StackWithAllChildrenReceiveEvents({
    Key key,
    AlignmentGeometry alignment = AlignmentDirectional.topStart,
    TextDirection textDirection = TextDirection.ltr,
    StackFit fit = StackFit.loose,
    Overflow overflow = Overflow.clip,
    List<Widget> children = const <Widget>[],
    Clip clipBehavior = Clip.hardEdge,
  }) : super(
    key: key,
    alignment: alignment,
    textDirection: textDirection,
    fit: fit,
    overflow: overflow,
    clipBehavior: clipBehavior,
    children: children,
  );


  @override
  RenderStackWithAllChildrenReceiveEvents createRenderObject(BuildContext context) {
    return RenderStackWithAllChildrenReceiveEvents(
      alignment: alignment,
      textDirection: textDirection ?? Directionality.of(context),
      fit: fit,
      clipBehavior: overflow == Overflow.visible ? Clip.none : clipBehavior,
    );
    // return RenderStackWithAllChildrenReceiveEvents(
    //   alignment: alignment,
    //   textDirection: textDirection ?? Directionality.of(context),
    //   fit: fit,
    //   overflow: overflow,
    // );
  }

  @override
  void updateRenderObject(BuildContext context, RenderStackWithAllChildrenReceiveEvents renderObject) {
    renderObject
      ..alignment = alignment
      ..textDirection = textDirection ?? Directionality.of(context)
      ..fit = fit
      ..clipBehavior = overflow == Overflow.visible ? Clip.none : clipBehavior;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<AlignmentGeometry>('alignment', alignment));
    properties.add(EnumProperty<TextDirection>('textDirection', textDirection, defaultValue: null));
    properties.add(EnumProperty<StackFit>('fit', fit));
    properties.add(EnumProperty<Overflow>('overflow', overflow));
  }

}

class RenderStackWithAllChildrenReceiveEvents extends RenderStack {
  RenderStackWithAllChildrenReceiveEvents({
    List<RenderBox> children,
    AlignmentGeometry alignment = AlignmentDirectional.topStart,
    TextDirection textDirection,
    StackFit fit = StackFit.loose,
    Clip clipBehavior = Clip.hardEdge,
  }): super(
    alignment: alignment,
    textDirection: textDirection,
    fit: fit,
    clipBehavior: clipBehavior,
  );

  bool allCdefaultHitTestChildren(HitTestResult result, { Offset position }) {
    // the x, y parameters have the top left of the node's box as the origin
    RenderBox child = lastChild;
    while (child != null) {
      final StackParentData childParentData = child.parentData;
      child.hitTest(result, position: position - childParentData.offset);
      child = childParentData.previousSibling;
    }
    return false;
  }

  @override
  bool hitTestChildren(HitTestResult result, { Offset position }) {
    return allCdefaultHitTestChildren(result, position: position);
  }
}