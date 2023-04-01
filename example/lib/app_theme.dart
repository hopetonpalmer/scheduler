import 'package:flutter/material.dart';
import 'package:scheduler/themes/scheduler_theme.dart';

class AppTheme extends SchedulerTheme {
  @override
  Color get backgroundColor => const Color.fromARGB(255, 26, 35, 17);

  @override
  ThemeExtension<SchedulerTheme> copyWith() {
    return AppTheme();
  }

  @override
  ThemeExtension<SchedulerTheme> lerp(covariant ThemeExtension<SchedulerTheme>? other, double t) {
    return AppTheme();
  }
}