import 'package:flutter/widgets.dart';

class UIService {
  static final instance = UIService._internal();

  UIService._internal();

  BuildContext? topMostContext;
  Widget? topMostContainer;
  final ValueNotifier<Widget?> topMostNotifier = ValueNotifier<Widget?>(null);
}