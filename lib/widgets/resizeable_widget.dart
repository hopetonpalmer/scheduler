import 'package:flutter/material.dart';

class ResizableWidget extends StatefulWidget {
  final Widget child;
  final double height;
  final double width;
  const ResizableWidget({Key? key, required this.child, required this.height, required this.width}) : super(key: key);

  @override
  _ResizableWidgetState createState() => _ResizableWidgetState();
}

const handleDiameter = 30.0;

class _ResizableWidgetState extends State<ResizableWidget> {
  late double height;
  late double width;
  double top = 0;
  double left = 0;

  @override
  initState() {
    height = widget.height;
    width = widget.width;
    super.initState();
  }

  void onDrag(double dx, double dy) {
    var newHeight = height + dy;
    var newWidth = width + dx;

    setState(() {
      height = newHeight > 0 ? newHeight : 0;
      width = newWidth > 0 ? newWidth : 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: Stack(
        children: <Widget>[
          Positioned(
            top: top,
            left: left,
            child: widget.child,
          ),
          // top left
          Positioned(
            top: top - handleDiameter / 2,
            left: left - handleDiameter / 2,
            child: SizingHandle(
              onDrag: (dx, dy) {
                var mid = (dx + dy) / 2;
                var newHeight = height - 2 * mid;
                var newWidth = width - 2 * mid;

                setState(() {
                  height = newHeight > 0 ? newHeight : 0;
                  width = newWidth > 0 ? newWidth : 0;
                  top = top + mid;
                  left = left + mid;
                });
              },
            ),
          ),
          // top middle
          Positioned(
            top: top - handleDiameter / 2,
            left: left + width / 2 - handleDiameter / 2,
            child: SizingHandle(
              onDrag: (dx, dy) {
                var newHeight = height - dy;

                setState(() {
                  height = newHeight > 0 ? newHeight : 0;
                  top = top + dy;
                });
              },
            ),
          ),
          // top right
          Positioned(
            top: top - handleDiameter / 2,
            left: left + width - handleDiameter / 2,
            child: SizingHandle(
              onDrag: (dx, dy) {
                var mid = (dx + (dy * -1)) / 2;

                var newHeight = height + 2 * mid;
                var newWidth = width + 2 * mid;

                setState(() {
                  height = newHeight > 0 ? newHeight : 0;
                  width = newWidth > 0 ? newWidth : 0;
                  top = top - mid;
                  left = left - mid;
                });
              },
            ),
          ),
          // center right
          Positioned(
            top: top + height / 2 - handleDiameter / 2,
            left: left + width - handleDiameter / 2,
            child: SizingHandle(
              onDrag: (dx, dy) {
                var newWidth = width + dx;

                setState(() {
                  width = newWidth > 0 ? newWidth : 0;
                });
              },
            ),
          ),
          // bottom right
          Positioned(
            top: top + height - handleDiameter / 2,
            left: left + width - handleDiameter / 2,
            child: SizingHandle(
              onDrag: (dx, dy) {
                var mid = (dx + dy) / 2;

                var newHeight = height + 2 * mid;
                var newWidth = width + 2 * mid;

                setState(() {
                  height = newHeight > 0 ? newHeight : 0;
                  width = newWidth > 0 ? newWidth : 0;
                  top = top - mid;
                  left = left - mid;
                });
              },
            ),
          ),
          // bottom center
          Positioned(
            top: top + height - handleDiameter / 2,
            left: left + width / 2 - handleDiameter / 2,
            child: SizingHandle(
              onDrag: (dx, dy) {
                var newHeight = height + dy;

                setState(() {
                  height = newHeight > 0 ? newHeight : 0;
                });
              },
            ),
          ),
          // bottom left
          Positioned(
            top: top + height - handleDiameter / 2,
            left: left - handleDiameter / 2,
            child: SizingHandle(
              onDrag: (dx, dy) {
                var mid = ((dx * -1) + dy) / 2;

                var newHeight = height + 2 * mid;
                var newWidth = width + 2 * mid;

                setState(() {
                  height = newHeight > 0 ? newHeight : 0;
                  width = newWidth > 0 ? newWidth : 0;
                  top = top - mid;
                  left = left - mid;
                });
              },
            ),
          ),
          //left center
          Positioned(
            top: top + height / 2 - handleDiameter / 2,
            left: left - handleDiameter / 2,
            child: SizingHandle(
              onDrag: (dx, dy) {
                var newWidth = width - dx;

                setState(() {
                  width = newWidth > 0 ? newWidth : 0;
                  left = left + dx;
                });
              },
            ),
          ),
          // center center
          Positioned(
            top: top + height / 2 - handleDiameter / 2,
            left: left + width / 2 - handleDiameter / 2,
            child: SizingHandle(
              onDrag: (dx, dy) {
                setState(() {
                  top = top + dy;
                  left = left + dx;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}

class SizingHandle extends StatefulWidget {
  final Function onDrag;
  const SizingHandle({super.key, required this.onDrag});

  @override
  _SizingHandleState createState() => _SizingHandleState();
}

class _SizingHandleState extends State<SizingHandle> {
  double initX = 0;
  double initY = 0;

  _handleDrag(details) {
    setState(() {
      initX = details.globalPosition.dx;
      initY = details.globalPosition.dy;
    });
  }

  _handleUpdate(details) {
    var dx = details.globalPosition.dx - initX;
    var dy = details.globalPosition.dy - initY;
    initX = details.globalPosition.dx;
    initY = details.globalPosition.dy;
    widget.onDrag(dx, dy);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: _handleDrag,
      onPanUpdate: _handleUpdate,
      child: Container(
        width: handleDiameter,
        height: handleDiameter,
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.5),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}