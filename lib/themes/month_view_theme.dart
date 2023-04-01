import 'package:flutter/material.dart';

@immutable
class MonthViewTheme extends ThemeExtension<MonthViewTheme> {

  ColorScheme get colorScheme => ColorScheme.fromSeed(seedColor: Colors.deepPurple);

  Color get backgroundColor => Colors.deepPurple;
  Color get anotherBackgroundColor => Colors.green;

  @override
  ThemeExtension<MonthViewTheme> copyWith() {
    return MonthViewTheme();
  }

  @override
  ThemeExtension<MonthViewTheme> lerp(covariant ThemeExtension<MonthViewTheme>? other, double t) {
    return MonthViewTheme();
  }

}