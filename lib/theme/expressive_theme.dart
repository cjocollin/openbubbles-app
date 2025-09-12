import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ExpressiveTheme {
  static ThemeData build({
    required ColorScheme colorScheme,
    required bool isDark,
  }) {
    // 1. Dimensionality & Shapes: The "Squircle" Mandate
    final squircleBorderLarge = ContinuousRectangleBorder(
      borderRadius: BorderRadius.circular(28.0),
    );
    final squircleBorderSmall = ContinuousRectangleBorder(
      borderRadius: BorderRadius.circular(16.0),
    );

    // 2. Typography & Hierarchy (Expressive Scale)
    final textTheme = TextTheme(
      displayLarge: GoogleFonts.robotoFlex(
        fontSize: 57,
        fontWeight: FontWeight.w900,
        letterSpacing: -0.25,
      ),
      headlineMedium: GoogleFonts.robotoFlex(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
      ),
      bodyLarge: GoogleFonts.robotoFlex(
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      // Add other styles as needed, defaulting to RobotoFlex
      bodyMedium: GoogleFonts.robotoFlex(),
      titleMedium: GoogleFonts.robotoFlex(),
      labelLarge: GoogleFonts.robotoFlex(fontWeight: FontWeight.w600),
    );

    // 3. Color & Vibrancy: Surface Tints
    // All background surfaces must use SurfaceContainerHigh with a 5% opacity tint of the Primary color.
    final surfaceColor = Color.alphaBlend(
      colorScheme.primary.withOpacity(0.05),
      colorScheme.surfaceContainerHigh,
    );

    var themeData = ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: surfaceColor,
      listTileTheme: ListTileThemeData(
        shape: squircleBorderSmall,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16), // Small squircle approximation for inputs if needed, or use ContinuousRectangleBorder if supported by widget
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
      ),
      // 4. Motion Physics (The "Jelly" Effect)
      // This is applied at the ScrollBehavior level usually, but we can define a default here if widgets use it.
    );

    return themeData.copyWith(
      // ignore: argument_type_not_assignable
      cardTheme: CardThemeData(
        shape: squircleBorderLarge,
        elevation: 0,
        color: colorScheme.surfaceContainerHighest,
        margin: EdgeInsets.zero,
      ),
    );
  }

  // Helper to generate the "Vibrant" tonal spot
  static ColorScheme generateColorScheme({
    required Color seedColor,
    required Brightness brightness,
    required bool isDynamic,
  }) {
    if (isDynamic) {
       // Dynamic color logic is handled by dynamic_color builder usually, 
       // but here we can enforce the "Vibrant" strategy if we are generating it manually.
       // For now, we rely on the caller to pass the dynamic scheme, but we can harmonize it.
       return ColorScheme.fromSeed(
         seedColor: seedColor,
         brightness: brightness,
         dynamicSchemeVariant: DynamicSchemeVariant.vibrant, // Force Vibrant
       );
    }
    
    return ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: brightness,
      dynamicSchemeVariant: DynamicSchemeVariant.vibrant,
    );
  }
}
