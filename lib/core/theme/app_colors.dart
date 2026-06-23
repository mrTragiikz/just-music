import 'package:flutter/material.dart';

enum AccentColor { blue, purple, green, orange, red, dynamic }

extension AccentColorSeed on AccentColor {
  Color get seed {
    switch (this) {
      case AccentColor.blue:
        return const Color(0xFF2979FF);
      case AccentColor.purple:
        return const Color(0xFF8E24AA);
      case AccentColor.green:
        return const Color(0xFF2E7D32);
      case AccentColor.orange:
        return const Color(0xFFEF6C00);
      case AccentColor.red:
        return const Color(0xFFD32F2F);
      case AccentColor.dynamic:
        return const Color(0xFF2979FF);
    }
  }

  String get label {
    switch (this) {
      case AccentColor.blue:
        return 'Blue';
      case AccentColor.purple:
        return 'Purple';
      case AccentColor.green:
        return 'Green';
      case AccentColor.orange:
        return 'Orange';
      case AccentColor.red:
        return 'Red';
      case AccentColor.dynamic:
        return 'Dynamic';
    }
  }
}

const Color amoledBlack = Color(0xFF000000);
