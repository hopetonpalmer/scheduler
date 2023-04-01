import 'package:flutter/material.dart';

import 'scheduler_theme.dart';

@immutable
class ChristmasTheme extends SchedulerTheme {

  @override
  Color get backgroundColor => Colors.red;

  @override
  ThemeExtension<SchedulerTheme> copyWith() {
      return ChristmasTheme();
  }

  @override
  ThemeExtension<SchedulerTheme> lerp(covariant ThemeExtension<SchedulerTheme>? other, double t) {
      return ChristmasTheme();
  }

}