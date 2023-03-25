import 'package:flutter/material.dart';
import 'dart:math';

extension ColorExtension on Color {


  Color darken([double amount = .1]) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));

    return hslDark.toColor();
  }

  Color lighten([double amount = .1]) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(this);
    final hslLight = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));

    return hslLight.toColor();
  }

  double calculateContrastRatio(Color other) {
    final luminance1 = computeLuminance();
    final luminance2 = other.computeLuminance();
    final lighterColor = max(luminance1, luminance2);
    final darkerColor = min(luminance1, luminance2);
    return (lighterColor + 0.05) / (darkerColor + 0.05);
  }

  Color computeContrastColor(Color other) {
    const double minContrastRatio = 4.5;
    const double maxIterations = 100;
    double iterations = 0;

    // Calculate the initial contrast ratio between the two colors
    double contrastRatio = calculateContrastRatio(other);

    var makeLighter = true;

    // Adjust the text color until the contrast ratio is high enough
    while (contrastRatio < minContrastRatio && iterations < maxIterations) {
      // Increase the color with the lowest value
      final colorValues = [other.red, other.green, other.blue];
      final minIndex = colorValues.indexOf(colorValues.reduce(min));
      colorValues[minIndex] += 10;
      if (colorValues[minIndex] > 255) {
        colorValues[minIndex] = 255;
      }
      if (makeLighter) {
        other = other.lighten(0.1);
      } else {
        other = other.darken(0.1);
      }
     //  Color.fromARGB(255, colorValues[0], colorValues[1], colorValues[2]);

      // Calculate the new contrast ratio
      var newContrastRatio = calculateContrastRatio(other);
      if (newContrastRatio <= contrastRatio) {
        makeLighter = false;
      } else {
        contrastRatio = newContrastRatio;
      }
      iterations++;
    }

    // Return the text color as a Color object
    return other;
  }
}