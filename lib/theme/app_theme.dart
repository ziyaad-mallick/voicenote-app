import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Semantic colors for the retro-minimalist theme.
/// Access via: `Theme.of(context).extension<RetroColors>()!`
@immutable
class RetroColors extends ThemeExtension<RetroColors> {
  final Color paper; // background
  final Color ink; // primary text
  final Color inkSoft; // secondary text
  final Color accent; // amber accent
  final Color record; // record red
  final Color border; // hairline borders
  final Color surface; // raised surfaces (cards)

  const RetroColors({
    required this.paper,
    required this.ink,
    required this.inkSoft,
    required this.accent,
    required this.record,
    required this.border,
    required this.surface,
  });

  @override
  RetroColors copyWith({
    Color? paper,
    Color? ink,
    Color? inkSoft,
    Color? accent,
    Color? record,
    Color? border,
    Color? surface,
  }) =>
      RetroColors(
        paper: paper ?? this.paper,
        ink: ink ?? this.ink,
        inkSoft: inkSoft ?? this.inkSoft,
        accent: accent ?? this.accent,
        record: record ?? this.record,
        border: border ?? this.border,
        surface: surface ?? this.surface,
      );

  @override
  RetroColors lerp(ThemeExtension<RetroColors>? other, double t) {
    if (other is! RetroColors) return this;
    return RetroColors(
      paper: Color.lerp(paper, other.paper, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      inkSoft: Color.lerp(inkSoft, other.inkSoft, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      record: Color.lerp(record, other.record, t)!,
      border: Color.lerp(border, other.border, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
    );
  }
}

class AppTheme {
  // ── Light (warm paper) ──────────────────────────────────────────────
  static const _lightColors = RetroColors(
    paper: Color(0xFFF2EEE3),
    ink: Color(0xFF1C1B18),
    inkSoft: Color(0xFF6B675E),
    accent: Color(0xFFC4571E),
    record: Color(0xFFB3261E),
    border: Color(0xFFD8D2C4),
    surface: Color(0xFFFBF9F2),
  );

  // ── Dark (amber phosphor terminal) ──────────────────────────────────
  static const _darkColors = RetroColors(
    paper: Color(0xFF14130F),
    ink: Color(0xFFECE6D6),
    inkSoft: Color(0xFF8E897A),
    accent: Color(0xFFE8913C),
    record: Color(0xFFE5564B),
    border: Color(0xFF2E2C25),
    surface: Color(0xFF1D1B16),
  );

  // Spacing scale
  static const double s1 = 4;
  static const double s2 = 8;
  static const double s3 = 12;
  static const double s4 = 16;
  static const double s5 = 24;
  static const double s6 = 32;
  static const double s7 = 48;

  static const double radius = 4; // sharp, retro corners
  static const double borderWidth = 1.2;

  static ThemeData light() => _build(_lightColors, Brightness.light);
  static ThemeData dark() => _build(_darkColors, Brightness.dark);

  static ThemeData _build(RetroColors c, Brightness brightness) {
    final base = brightness == Brightness.light
        ? ThemeData.light()
        : ThemeData.dark();

    final mono = GoogleFonts.jetBrainsMonoTextTheme(base.textTheme).apply(
      bodyColor: c.ink,
      displayColor: c.ink,
    );

    return base.copyWith(
      scaffoldBackgroundColor: c.paper,
      canvasColor: c.paper,
      colorScheme: base.colorScheme.copyWith(
        brightness: brightness,
        primary: c.accent,
        secondary: c.accent,
        surface: c.surface,
        onSurface: c.ink,
        error: c.record,
      ),
      textTheme: mono.copyWith(
        displayLarge: GoogleFonts.jetBrainsMono(
          textStyle: mono.displayLarge,
          fontWeight: FontWeight.w700,
          letterSpacing: 2,
          color: c.ink,
        ),
        titleLarge: GoogleFonts.jetBrainsMono(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: 1,
          color: c.ink,
        ),
        labelLarge: GoogleFonts.jetBrainsMono(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.5,
          color: c.ink,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: c.paper,
        foregroundColor: c.ink,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.jetBrainsMono(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          letterSpacing: 2,
          color: c.ink,
        ),
      ),
      dividerColor: c.border,
      iconTheme: IconThemeData(color: c.ink),
      extensions: [c],
    );
  }
}

/// Convenience getter used across screens.
extension RetroContext on BuildContext {
  RetroColors get retro => Theme.of(this).extension<RetroColors>()!;
}
