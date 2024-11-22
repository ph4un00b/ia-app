import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

sealed class AppTheme {
  // The defined light theme.
  static ThemeData light = FlexThemeData.light(
  scheme: FlexScheme.materialBaseline,
  subThemesData: const FlexSubThemesData(
    inputDecoratorIsFilled: true,
    alignedDropdown: true,
    tooltipRadius: 4.0,
    tooltipSchemeColor: SchemeColor.inverseSurface,
    tooltipOpacity: 0.9,
    snackBarElevation: 6.0,
    snackBarBackgroundSchemeColor: SchemeColor.inverseSurface,
    navigationRailUseIndicator: true,
    navigationRailLabelType: NavigationRailLabelType.all,
  ),
  keyColors: const FlexKeyColors(
    useSecondary: true,
    useTertiary: true,
    useError: true,
  ),
  visualDensity: FlexColorScheme.comfortablePlatformDensity,
  cupertinoOverrideTheme: const CupertinoThemeData(applyThemeToAll: true),
  );
  // The defined dark theme.
  static ThemeData dark = FlexThemeData.dark(
  scheme: FlexScheme.materialBaseline,
  darkIsTrueBlack: true,
  subThemesData: const FlexSubThemesData(
    blendOnColors: true,
    inputDecoratorIsFilled: true,
    alignedDropdown: true,
    tooltipRadius: 4.0,
    tooltipSchemeColor: SchemeColor.inverseSurface,
    tooltipOpacity: 0.9,
    snackBarElevation: 6.0,
    snackBarBackgroundSchemeColor: SchemeColor.inverseSurface,
    navigationRailUseIndicator: true,
    navigationRailLabelType: NavigationRailLabelType.all,
  ),
  keyColors: const FlexKeyColors(
    useSecondary: true,
    useTertiary: true,
    useError: true,
  ),
  visualDensity: FlexColorScheme.comfortablePlatformDensity,
  cupertinoOverrideTheme: const CupertinoThemeData(applyThemeToAll: true),
  );
}
