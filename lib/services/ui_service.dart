import 'package:flutter/widgets.dart';

class UIService {
  static final instance = UIService._internal();

  UIService._internal();

  BuildContext? topMostContext;
  Widget? topMostContainer;
  final ValueNotifier<Widget?> topMostNotifier = ValueNotifier<Widget?>(null);

  Rect getBounds(BuildContext context) {
    RenderObject? renderObject = context.findRenderObject();
    if (renderObject == null) {
      return Rect.zero;
    }

    return renderObject.paintBounds;
   }
}