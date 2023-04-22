import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../draggable_cursor.dart';
import '../../scheduler.dart';
import '../../services/appointment_drag_service.dart';

class AppointmentResizer extends StatefulWidget {
  final Widget child;
  final double height;
  final double width;
  final FlowOrientation orientation;
  final bool hovered;
  const AppointmentResizer({
    Key? key,
    required this.child,
    required this.orientation,
    required this.height,
    required this.width,
    required this.hovered,
  }) : super(key: key);

  @override
  State<AppointmentResizer> createState() => _AppointmentResizerState();
}

class _AppointmentResizerState extends State<AppointmentResizer> {
  MouseCursor _cursor = DraggableCursor();
  SizingDirection _sizingDirection = SizingDirection.none;
  bool _isPressed = false;
  MouseCursor get cursor => _cursor;

  get canSize => _sizingDirection != SizingDirection.none && _isPressed;
  set cursor(MouseCursor value) {
    if (value != _cursor) {
      setState(() {
        _cursor = value;
      });
    }
  }

  prepareToSize(Offset position) {
    if (!widget.hovered || AppointmentDragService.instance.isDragging) {
      _sizingDirection = SizingDirection.none;
      cursor = DraggableCursor();
      return;
    }
    var sizeMousePos = 8;
    if (widget.orientation == FlowOrientation.vertical) {
      if (position.dy <= sizeMousePos) {
        _sizingDirection = SizingDirection.up;
        cursor = SystemMouseCursors.resizeUpDown;
      } else if (position.dy >= widget.height - sizeMousePos) {
        _sizingDirection = SizingDirection.down;
        cursor = SystemMouseCursors.resizeUpDown;
      } else {
        _sizingDirection = SizingDirection.none;
        cursor = SystemMouseCursors.click;
      }
    } else {
      if (position.dx <= sizeMousePos) {
        _sizingDirection = SizingDirection.left;
        cursor = SystemMouseCursors.resizeLeftRight;
      } else if (position.dx >= widget.width - sizeMousePos) {
        _sizingDirection = SizingDirection.right;
        cursor = SystemMouseCursors.resizeLeftRight;
      } else {
        _sizingDirection = SizingDirection.none;
        cursor = SystemMouseCursors.click;
      }
    }
    AppointmentDragService.instance.prepareDragSize(_sizingDirection);
  }


  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerMove: (event) {
        if (event.down){

        }
      },
      child: MouseRegion(
        cursor: cursor,
        onHover: (event) {
          prepareToSize(event.localPosition);
          if (event.down != _isPressed) {
            _isPressed = event.down;
            //setState(() => {_isPressed = event.down});
          }
        },
        child: widget.child,
      ),
    );
  }
}
