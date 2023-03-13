import 'dart:math';

import 'package:flutter/material.dart';
import 'package:scheduler/services/appointment_drag_service.dart';

class ScrollAwareStack extends StatelessWidget {
  final List<Widget> children;
  final ScrollController scrollController;
  const ScrollAwareStack(
      {Key? key, required this.children, required this.scrollController })
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (event) {
        _setActiveScrollController();
      },
      onPointerMove: (event) {
        if (event.down) {
          _scrollPastViewPortWhenNeeded(event);
        }
      },
      child: Stack(
        children: children,
      ),
    );
  }

  void _setActiveScrollController() {
    AppointmentDragService().activeScrollController = scrollController;
  }

  void _scrollPastViewPortWhenNeeded(PointerMoveEvent event) {
    int boundaryOffset = 25;
    double jumpBy = 5;
    double jumpValue = 0;
    double scrollPos = scrollController.position.axis == Axis.vertical ? event.position.dy : event.position.dx;
    double localDelta = scrollController.position.axis == Axis.vertical ? event.localDelta.dy : event.localDelta.dx;
    jumpBy += localDelta;
    if (scrollPos >= scrollController.position.viewportDimension - boundaryOffset) {
      jumpValue = min(scrollController.position.maxScrollExtent, scrollController.offset + jumpBy);
      scrollController.jumpTo(jumpValue);
    }
    if (scrollPos <= boundaryOffset) {
      jumpValue = max(0, scrollController.offset - jumpBy);
      scrollController.jumpTo(jumpValue);
    }
  }
}
