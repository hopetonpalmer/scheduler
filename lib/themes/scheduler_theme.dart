import 'package:flutter/material.dart';

@immutable
class SchedulerTheme extends ThemeExtension<SchedulerTheme> {

  ColorScheme get colorScheme => ColorScheme.fromSeed(seedColor: Colors.red);

  Color get backgroundColor => Colors.black26;

  @override
  ThemeExtension<SchedulerTheme> copyWith() {
    return SchedulerTheme();
  }

  @override
  ThemeExtension<SchedulerTheme> lerp(covariant ThemeExtension<SchedulerTheme>? other, double t) {
    return SchedulerTheme();
  }

}