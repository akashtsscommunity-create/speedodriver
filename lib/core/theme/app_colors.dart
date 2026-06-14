import 'package:flutter/material.dart';

@immutable
class AppColors {
  const AppColors._();
  // Brand / Main Theme
  static const Color primaryOrange = Color(0xFFFF6600);
  static const Color buttonOrange = Color(0xFFFF6600);
  static const Color appBackground = Colors.white;
  static const Color cardBackground = Color(0xFFFFFFFF);

  static const Color sectionHeading = Color(0xFF1A237E);
  static const Color surfaceLight = Color(0xFFF8F9FB);
  static const Color categorySelectedBg = Color(0xFFFFF7F2);

  static const Color authTextDark = Color(0xFF1F2430);
  static const Color authTextGrey = Color(0xFF6B7280);
  static const Color authFieldBorder = Color(0xFFE1E5EA);
  static const Color authTabBg = Color(0xFFF0F1F4);

  static const Color authHint = Color(0xFF8E96A3);
  static const Color authIcon = Color(0xFF9AA3AF);
  static const Color authDisabledBg = Color(0xFFF3F4F6);
  static const Color authDisabledButton = Color(0xFFE5E7EB);
  static const Color authDisabledText = Color(0xFF9CA3AF);

 // Existing App Colors

  static const grayDark = Color(0xFF404E57);
  static const grayLight = Color(0xFF8D8D94);
  static const white = Color(0xFFFFFFFF);
  static const black = Color(0xFF000000);
  static const gray = Color(0xFFA4A4A4);
  static const red = Color(0xFFB40303);
  static const transparent = Color(0x0054546E);

  static const btnStartColor = Color(0xFF54546E);
  static const btnEndColor = Color(0xFFA8A8C5);
  static const btnCenterColor = Color(0xFF8F7B7B);

  static const green = Color(0xC515A40E);
  static const transparentForImage = Color(0x9ED6DBDD);
  static const allow = Color(0xFFE7CA0F);

  static const backgroundColorPrimary = Color(0xFFF5F5F5);
  static const btnColor = Color(0xFF0E1635);
  static const grayLightForBC = Color(0xFFF1F6FE);
  static const textColor = Color(0xFF0E1635);

  static const Color lightBlue = Color(0xFFF2F4F5);
  static const Color blue = Color(0xFF67A4FD);
  static const Color darkBlue = Color(0xFF1C64CC);
  static const Color darkNavy = Color(0xFF0E1635);

  static const Color refreshTextColor = Color(0xFFE67450);

 // Modern UI Palette

  static const primary = Color(0xFF6366F1);
  static const primaryLight = Color(0xFFEEF2FF);
  static const primaryDark = Color(0xFF4338CA);

  static const surface = Color(0xFFF8FAFC);
  static const surfaceAlt = Color(0xFFF1F5F9);

  static const border = Color(0xFFE2E8F0);
  static const borderLight = Color(0xFFF1F5F9);

  static const text = Color(0xFF1E293B);
  static const textSecondary = Color(0xFF64748B);
  static const textTertiary = Color(0xFF94A3B8);

  static const success = Color(0xFF10B981);
  static const warning = Color(0xFFF59E0B);
  static const error = Color(0xFFEF4444);
  static const info = Color(0xFF3B82F6);

 // Material Swatches

  static const Map<int, Color> primaryOrangeSwatch = {
    50: Color(0xFFFFF1EC),
    100: Color(0xFFFFDED2),
    200: Color(0xFFFFBFA7),
    300: Color(0xFFFF9B76),
    400: Color(0xFFFF7645),
    500: Color(0xFFFF5A1F),
    600: Color(0xFFE94E18),
    700: Color(0xFFC93F12),
    800: Color(0xFFA9340F),
    900: Color(0xFF7A240A),
  };

  static const MaterialColor primaryOrangeMaterialColor =
  MaterialColor(0xFFFF5A1F, primaryOrangeSwatch);

  static const Map<int, Color> darkBlueSwatch = {
    50: Color(0xFFE8EAF0),
    100: Color(0xFFC5CAD8),
    200: Color(0xFF9EA6BE),
    300: Color(0xFF7682A3),
    400: Color(0xFF586891),
    500: Color(0xFF0E1635),
    600: Color(0xFF0B122C),
    700: Color(0xFF090F25),
    800: Color(0xFF070B1D),
    900: Color(0xFF040713),
  };

  static const MaterialColor darkBlueMaterialColor =
  MaterialColor(0xFF0E1635, darkBlueSwatch);

}