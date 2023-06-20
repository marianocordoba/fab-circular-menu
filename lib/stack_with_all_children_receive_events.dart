import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';

/// Passes all events to all children of the stack.  The FAB was having issues
/// where the padding on the button was blocking the circular items on the edge
class StackWithAllChildrenReceiveEvents extends Stack {
  StackWithAllChildrenReceiveEvents({
    Key? key,
    AlignmentGeometry alignment = AlignmentDirectional.topStart,
    TextDirection textDirection = TextDirection.ltr,
    StackFit fit = StackFit.loose,
    List<Widget> children = const <Widget>[],
    Clip clipBehavior = Clip.hardEdge,
  }) : super(
          key: key,
          alignment: alignment,
          textDirection: textDirection,
          fit: fit,
          clipBehavior: clipBehavior,
          children: children,
        );

  @override
  RenderStackWithAllChildrenReceiveEvents createRenderObject(
      BuildContext context) {
    return RenderStackWithAllChildrenReceiveEvents(
      alignment: alignment,
      textDirection: textDirection ?? Directionality.of(context),
      fit: fit,
      clipBehavior: clipBehavior,
    );
    // return RenderStackWithAllChildrenReceiveEvents(
    //   alignment: alignment,
    //   textDirection: textDirection ?? Directionality.of(context),
    //   fit: fit,
    //   overflow: overflow,
    // );
  }

  @override
  void updateRenderObject(BuildContext context,
      RenderStackWithAllChildrenReceiveEvents renderObject) {
    renderObject
      ..alignment = alignment
      ..textDirection = textDirection ?? Directionality.of(context)
      ..fit = fit
      ..clipBehavior = clipBehavior;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
        .add(DiagnosticsProperty<AlignmentGeometry>('alignment', alignment));
    properties.add(EnumProperty<TextDirection>('textDirection', textDirection,
        defaultValue: null));
    properties.add(EnumProperty<StackFit>('fit', fit));
    properties.add(EnumProperty<Clip>('clipBehavior', clipBehavior));
  }
}

class RenderStackWithAllChildrenReceiveEvents extends RenderStack {
  RenderStackWithAllChildrenReceiveEvents({
    List<RenderBox> children = const [],
    AlignmentGeometry alignment = AlignmentDirectional.topStart,
    TextDirection? textDirection,
    StackFit fit = StackFit.loose,
    Clip clipBehavior = Clip.hardEdge,
  }) : super(
          alignment: alignment,
          textDirection: textDirection,
          fit: fit,
          clipBehavior: clipBehavior,
        );

  @override
  bool defaultHitTestChildren(HitTestResult result,
      {required Offset position}) {
    // the x, y parameters have the top left of the node's box as the origin
    var child = lastChild;
    while (child != null) {
      StackParentData childParentData = child.parentData as StackParentData;
      child.hitTest(result as BoxHitTestResult,
          position: position - childParentData.offset);
      child = childParentData.previousSibling;
    }
    return false;
  }

  @override
  bool hitTestChildren(HitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }
}
