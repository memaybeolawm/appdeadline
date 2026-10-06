import 'package:flutter/material.dart';

class ColorUtils {
  static Color fromHex(String hexString) {
    try {
      // Handle '0xFFRRGGBB' format (stored as int string)
      if (hexString.startsWith('0x') || hexString.startsWith('0X')) {
        return Color(int.parse(hexString));
      }
      // Handle '#RRGGBB' or 'RRGGBB'
      final buffer = StringBuffer();
      if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
      buffer.write(hexString.replaceFirst('#', ''));
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (e) {
      return const Color(0xFF1976D2); // Fallback color
    }
  }

  static String toHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2, 8).toUpperCase()}';
  }
}
