import 'package:flutter/material.dart';

// Design tokens — the only file with raw values.

abstract final class AppColors {
  static const primary = Color(0xFF3D5AFE);
  static const surface = Color(0xFFFFFFFF);
  static const infoSurface = Color(0xFFEEF1FF);
  static const textPrimary = Color(0xFF0D0D0D);
  static const textSecondary = Color(0xFF4A4A4A);
  static const track = Color(0xFFE0E0E0);
  static const error = Color(0xFFB3261E);
}

abstract final class Spacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
}

abstract final class Radii {
  static const double card = 8;
  static const double pill = 999;
}

abstract final class AppText {
  static const base = TextStyle(fontSize: 16, fontWeight: FontWeight.w400, height: 1.4, color: AppColors.textPrimary);
  static final heading = base.copyWith(fontSize: 18, fontWeight: FontWeight.w700, height: 1.3);
  static final bodySmall = base.copyWith(fontSize: 14, color: AppColors.textSecondary);
}
