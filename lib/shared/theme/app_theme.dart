import 'package:flutter/material.dart';

/// 앱의 시각 규칙을 한 곳에서 정의한다.
///
/// 화면 위젯은 원시 색상 값을 직접 사용하지 않고 [ColorScheme]과 컴포넌트
/// 테마를 통해 의미 기반 색상을 읽는다.
abstract final class AppTheme {
  static const _canvas = Color(0xFF080808);
  static const _surface = Color(0xFF101010);
  static const _foreground = Color(0xFFF6F3EC);
  static const _error = Color(0xFFFFB4AB);

  static ThemeData dark() {
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: _foreground,
          brightness: Brightness.dark,
        ).copyWith(
          primary: _foreground,
          onPrimary: _canvas,
          surface: _surface,
          onSurface: _foreground,
          error: _error,
          onError: _canvas,
          outline: _foreground.withValues(alpha: 0.18),
          outlineVariant: _foreground.withValues(alpha: 0.1),
          surfaceTint: Colors.transparent,
        );

    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: _canvas,
      canvasColor: _canvas,
    );

    return base.copyWith(
      textTheme: base.textTheme.apply(
        bodyColor: colorScheme.onSurface,
        displayColor: colorScheme.onSurface,
      ),
      iconTheme: IconThemeData(color: colorScheme.onSurface),
      appBarTheme: AppBarTheme(
        backgroundColor: _canvas,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surface,
        modalBackgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        clipBehavior: Clip.antiAlias,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          disabledBackgroundColor: colorScheme.primary.withValues(alpha: 0.32),
          disabledForegroundColor: colorScheme.onPrimary.withValues(alpha: 0.5),
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.onSurface,
          disabledForegroundColor: colorScheme.onSurface.withValues(alpha: 0.5),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colorScheme.primary,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.primary,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            color: colorScheme.onSurface.withValues(alpha: selected ? 1 : 0.48),
            fontSize: 12,
            fontWeight: FontWeight.w800,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected
                ? colorScheme.onPrimary
                : colorScheme.onSurface.withValues(alpha: 0.58),
          );
        }),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colorScheme.surface,
        contentTextStyle: TextStyle(color: colorScheme.onSurface),
      ),
    );
  }
}

extension AppThemeContext on BuildContext {
  ColorScheme get colors => Theme.of(this).colorScheme;
}
