import 'package:material_ui/material_ui.dart';

// Brand colours from the Figma file (Farmerzz, core/* variables).
const _background = Color(0xFFE6F0DC); // core/bg
const _text = Color(0xFF125133); // core/text
const _surface = Color(0xFFFBFDFB); // core/surface (cards, bars)
const _primary = Color(0xFF21C37E); // core/primary
const _muted = Color(0xFF386C5F); // core/muted
const _border = Color(0xFFC9DFCB); // core/line
const _activePill = Color(0xFFD9EDDF); // core/hover
const _danger = Color(0xFFB5452F);

/// Colours the Material [ColorScheme] has no slot for.
class AppColors {
  const AppColors._();

  // Background of each module's rounded-square icon.
  static const gardens = Color(0xFFD9EDDF);
  static const journal = Color(0xFFFBEFD9);
  static const care = Color(0xFFDCEDF5);
  static const market = Color(0xFFFBE4D4);
  static const forum = Color(0xFFE8E2F6);
  static const explore = Color(0xFFFBF0BF);

  /// Top of the home greeting card gradient (fades into secondaryContainer).
  static const greetingTop = Color(0xFFFBEFD9);
}

/// The single app theme. Screens read colours from
/// `Theme.of(context).colorScheme`:
/// - surface / onSurface: page background / main text
/// - surfaceContainerLowest: cards and the floating bars
/// - onSurfaceVariant: muted text
/// - outlineVariant: borders
/// - secondaryContainer: pale active pill (main bar)
/// - secondary / onSecondary: dark green active pill (grower tools bar)
/// - error: danger actions such as "Log out"
ThemeData appTheme() {
  final colorScheme = ColorScheme.fromSeed(seedColor: _primary).copyWith(
    primary: _primary,
    onPrimary: _surface,
    secondary: _text,
    onSecondary: _surface,
    secondaryContainer: _activePill,
    onSecondaryContainer: _text,
    surface: _background,
    onSurface: _text,
    surfaceContainerLowest: _surface,
    onSurfaceVariant: _muted,
    outline: _border,
    outlineVariant: _border,
    error: _danger,
    onError: _surface,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: _background,
    // TODO: bundle Poppins as an asset font (pubspec `fonts:`) and set
    // fontFamily: 'Poppins' here. Default font for Checkpoint 1.
    appBarTheme: const AppBarTheme(
      backgroundColor: _background,
      foregroundColor: _text,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
    cardTheme: const CardThemeData(
      color: _surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
        side: BorderSide(color: _border),
      ),
    ),
    snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
  );
}
