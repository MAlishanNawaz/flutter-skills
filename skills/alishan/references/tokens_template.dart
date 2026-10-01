// Starter design-token file for a Flutter app.
// Rename the classes to suit your project, replace the placeholder values with your design
// system's, and keep this the ONLY place raw colours / sizes appear.

import 'package:flutter/material.dart';

/// Colours, named by what they do, not how they look.
abstract final class AppColors {
  // Brand
  static const primary = Color(0xFF3D5AFE);
  static const onPrimary = Color(0xFFFFFFFF);
  static const secondary = Color(0xFF7C4DFF);

  // Surfaces
  static const background = Color(0xFFF6F6F6);
  static const surface = Color(0xFFFFFFFF);
  static const infoSurface = Color(0xFFEEF1FF);
  static const warningSurface = Color(0xFFFFF7D6);

  // Text
  static const textPrimary = Color(0xFF0D0D0D);
  static const textSecondary = Color(0xFF4A4A4A);
  static const textDisabled = Color(0xFFACACAC);

  // Status
  static const success = Color(0xFF2E7D32);
  static const error = Color(0xFFB3261E);
  static const warning = Color(0xFFB26A00);

  // Neutral ramp: AppColors.grey[700]
  static const grey = <int, Color>{
    100: Color(0xFFF5F5F5),
    300: Color(0xFFE0E0E0),
    600: Color(0xFFACACAC),
    700: Color(0xFF888888),
    800: Color(0xFF5F5F5F),
    900: Color(0xFF323232),
  };
}

/// 4-point spacing scale.
abstract final class Spacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 40;

  static const pagePadding = EdgeInsets.symmetric(horizontal: xl);
}

abstract final class Radii {
  static const double sm = 4;
  static const double card = 8;
  static const double sheet = 16;
  static const double pill = 999;
}

/// Base text style. Always `AppText.base.copyWith(...)`, never a bare `TextStyle()`.
abstract final class AppText {
  static const fontFamily = 'Inter'; // must match the family in pubspec.yaml

  static const base = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: AppColors.textPrimary,
  );

  static final title = base.copyWith(fontSize: 24, fontWeight: FontWeight.w700, height: 1.25);
  static final heading = base.copyWith(fontSize: 18, fontWeight: FontWeight.w700, height: 1.3);
  static final body = base;
  static final bodySmall = base.copyWith(fontSize: 14);
  static final caption = base.copyWith(fontSize: 12, color: AppColors.textSecondary);
}
