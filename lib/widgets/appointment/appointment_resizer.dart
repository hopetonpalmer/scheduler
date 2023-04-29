import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../draggable_cursor.dart';
import '../../models/appointment_item.dart';
import '../../scheduler.dart';
import '../../services/appointment_drag_service.dart';
import '../../services/ui_service.dart';

class AppointmentResizer extends StatefulWidget {
  final Widget child;
  final AppointmentItem appointmentItem;
  final FlowOrientation orientation;
  final bool hovered;
  const AppointmentResizer({
    Key? key,
    required this.child,
    required this.orientation,
    required this.appointmentItem,
    required this.hovered,
  }) : super(key: key);

  @override
  State<AppointmentResizer> createState() => _AppointmentResizerState();
}

class _AppointmentResizerState extends State<AppointmentResizer> {
  late Rect rect;
  ValueNotifier<Offset> sizeChangeNotifier = ValueNotifier<Offset>(Offset.zero);

  bool _sizing = false;
  bool get sizing => _sizing;

  set sizing(bool value){
    if (value != _sizing){
      _sizing = value;
      //setState(()=>{});
    }
  }

  @override
  initState() {
    rect = widget.appointmentItem.geometry.rect;
    super.initState();
  }

  Widget buildFeedback(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: AppointmentDragService.instance.appointmentDragUpdate,
      builder: (BuildContext context, AppointmentDragUpdateDetails? dragDetails, Widget? child) {
        if (sizing) {
          if (dragDetails != null){
            Offset delta = dragDetails!.change;
            rect = Rect.fromLTWH(rect.left, rect.top, widget.appointmentItem.geometry.rect.width, widget.appointmentItem.geometry.rect.height + delta.dy);
          }
          var sizerFeedback = Container(
            color: Colors.white.withOpacity(0.2),
            height: rect.height,
            width: rect.width,
          );
          return sizerFeedback;
        } else {
          return Container();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
            children: [
              widget.child,
              buildFeedback(context),
              SizingHandle(appointmentItem: widget.appointmentItem, onSizing: (isSizing) => sizing = isSizing,
                  sizeChangeNotifier: sizeChangeNotifier,
                  orientation: widget.orientation, index: 0),
              SizingHandle(appointmentItem: widget.appointmentItem, onSizing: (isSizing) => sizing = isSizing,
                  sizeChangeNotifier: sizeChangeNotifier,
                  orientation: widget.orientation, index: 1),
            ]
          );
  }
}


class SizingHandle extends StatefulWidget {
  final Function(bool isSizing) onSizing;
  final AppointmentItem appointmentItem;
  final FlowOrientation orientation;
  final int index;
  final ValueNotifier<Offset> sizeChangeNotifier;
  const SizingHandle({
    super.key,
    required this.onSizing,
    required this.appointmentItem,
    required this.sizeChangeNotifier,
    required this.orientation,
    required this.index,
  });

  @override
  _SizingHandleState createState() => _SizingHandleState();
}

class _SizingHandleState extends State<SizingHandle> {
  double initX = 0;
  double initY = 0;
  double handleDiameter = 0;

  late double height;
  late double width;
  late double top;
  late double left;
  late SizingDirection sizingDirection;
  late MouseCursor cursor;
  late AlignmentDirectional alignment;

  ValueNotifier<Offset> sizeChangeNotifier = ValueNotifier<Offset>(Offset.zero);

  _handleDrag(Offset initialPos) {
      initX = initialPos.dx;
      initY = initialPos.dy;
      AppointmentDragService.instance.prepareDragSize(sizingDirection);
  }

  _handleUpdate(Offset position) {
    var dx = position.dx - initX;
    var dy = position.dy - initY;
    widget.sizeChangeNotifier.value = Offset(dx, dy);
    sizeChangeNotifier.value = Offset(dx, dy);
  }

  @override
  initState() {
     initSizing();
     super.initState();
  }

  initSizing() {
    double size = 8;
    Rect rect = widget.appointmentItem.geometry.rect;
    width = rect.width;
    height = rect.height;
    if (widget.orientation == FlowOrientation.vertical) {
      height = size;
      left = 0;
      top = 0;
      sizingDirection = SizingDirection.up;
      if (widget.index == 1){
        top = rect.height - height;
        sizingDirection = SizingDirection.down;
      }
      cursor = SystemMouseCursors.resizeUpDown;
    } else {
      width = size;
      top = 0;
      left = 0 ;
      sizingDirection = SizingDirection.left;
      if (widget.index == 1){
        left = rect.width - width;
        sizingDirection = SizingDirection.right;
      }
      cursor = SystemMouseCursors.resizeLeftRight;
    }
  }

  @override
  Widget build(BuildContext context) {
    initSizing();
    return ValueListenableBuilder(
      valueListenable: sizeChangeNotifier,
      builder: (BuildContext context, Offset change, Widget? child) {
      return Positioned(
          top: top + change.dy,
          left: left,
          child: Listener(
            onPointerDown: (event) {
              _handleDrag(event.position);
            },
            onPointerMove: (event) {
              widget.onSizing(event.down);
              if (event.down){
                _handleUpdate(event.position);
              }
            },
            onPointerUp: (event) {
              widget.onSizing(false);
              sizeChangeNotifier.value = Offset.zero;
            },
            child: MouseRegion(
              //hitTestBehavior: HitTestBehavior.opaque,
              cursor: cursor,
              child: Container(
                width: width,
                height: height,
                color: Colors.transparent,
              ),
            ),
          ),
        );
      }
    );
  }
}