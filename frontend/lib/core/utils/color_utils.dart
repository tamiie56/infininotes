import 'package:flutter/material.dart';

class ColorUtils {
  static Color fromHex(String hexColor) {
    hexColor = hexColor.replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor';
    }
    return Color(int.parse(hexColor, radix: 16));
  }

  static bool isLight(Color color) {
    return color.computeLuminance() > 0.5;
  }

  static Color textColorFor(Color background) {
    return isLight(background) ? Colors.black87 : Colors.white;
  }
}