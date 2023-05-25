import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../constants.dart';


class SchedulerViewHelper {
  /// Determine if the current platform is mobile (android or iOS).
  static bool isMobileLayout(BuildContext context) {
    if (kIsWeb) {
      return false;
    }
    var platform = Theme.of(context).platform;

    return platform == TargetPlatform.iOS || platform == TargetPlatform.android;
  }

  /// Determine if the current platform needs the mobile platform UI.
  static bool isMobileLayoutUI(double width, bool isMobileLayout) {
    return isMobileLayout || width <= kMobileViewWidth;
  }

  static bool isSmallDevice(BuildContext context){
    return MediaQuery.of(context).size.width <= kSmallDevice;
  }

  static bool isLargeDevice(BuildContext context){
    return MediaQuery.of(context).size.width >= kLargeDevice;
  }

  static bool isMediumDevice(BuildContext context){
    var width = MediaQuery.of(context).size.width;

    return  width > kSmallDevice && width <= kMediumDevice;
  }

}