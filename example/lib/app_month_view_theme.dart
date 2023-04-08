import 'package:flutter/material.dart';
import 'package:scheduler/themes/month_view_theme.dart';

class AppMonthViewTheme extends MonthViewTheme {

  @override
  Color get backgroundColor => getBackgroundColor();

  bool get showBackgroundForGamelist => shouldShow();

  shouldShow() {
    return true;
  }

  getBackgroundColor() {
    return const Color.fromARGB(100, 100, 25, 100);
  }

  @override
  ColorScheme get colorScheme => ColorScheme.fromSeed(seedColor: Colors.red);

  @override
  ThemeExtension<MonthViewTheme> copyWith() {
    return AppMonthViewTheme();
  }

  @override
  ThemeExtension<MonthViewTheme> lerp(covariant ThemeExtension<MonthViewTheme>? other, double t) {
    return AppMonthViewTheme();
  }

}