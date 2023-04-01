import 'package:flutter/widgets.dart';

class VirtualPageController extends PageController {
  VirtualPageController({
    super.initialPage = 0,
    super.keepPage = true,
    super.viewportFraction = 1.0,
  });

  int indexOffset = 0;

}
