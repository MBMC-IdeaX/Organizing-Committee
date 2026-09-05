import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ideax_judging/app/theme/app_colors.dart';
import 'package:ideax_judging/app/theme/app_dimensions.dart';
import 'package:ideax_judging/app/theme/app_theme.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('AppTheme & Design System Tests', () {
    test('AppColors contains correct brand colors', () {
      expect(AppColors.primaryNavy, const Color(0xFF0B1F4B));
      expect(AppColors.primaryBlue, const Color(0xFF2563EB));
      expect(AppColors.background, const Color(0xFFF4F8FF));
    });

    test('AppDimensions contains standard spacing', () {
      expect(AppDimensions.buttonHeight, 48.0);
      expect(AppDimensions.glassBlur, 10.0);
    });

    test('AppTheme.lightTheme initializes correctly', () {
      final theme = AppTheme.lightTheme;
      expect(theme.brightness, Brightness.light);
      expect(theme.scaffoldBackgroundColor, AppColors.background);
      expect(theme.primaryColor, AppColors.primaryBlue);
    });
  });
}
