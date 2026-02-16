import 'package:flutter/material.dart';

/// Sistema de Design Centralizado - Built With Science
/// Referência: estilo dark premium fitness (Coach Sandow)
/// Paleta: Preto + Laranja vibrante
class AppTheme {
  // ========================================
  // 🎨 PALETA DE CORES
  // ========================================

  /// Backgrounds
  static const Color backgroundPrimary = Color(0xFF1A1A1A); // Fundo principal
  static const Color backgroundCard = Color(0xFF2D2D2D); // Cards e containers
  static const Color backgroundElevated = Color(0xFF3A3A3A); // Inputs e elementos elevados

  /// Cor de destaque (Brand)
  static const Color primaryOrange = Color(0xFFFF6B00); // CTA, botões principais
  static const Color primaryOrangeHover = Color(0xFFFF8C00); // Hover/Active state

  /// Textos
  static const Color textPrimary = Color(0xFFFFFFFF); // Texto principal
  static const Color textSecondary = Color(0xFF9CA3AF); // Texto secundário/hints

  /// Status e Feedback
  static const Color success = Color(0xFF22C55E); // Sucesso (verde)
  static const Color error = Color(0xFFEF4444); // Erro (vermelho)
  static const Color warning = Color(0xFFF59E0B); // Aviso (amarelo)
  static const Color info = Color(0xFF3B82F6); // Informação (azul)

  /// Bordas e Divisores
  static const Color borderColor = Color(0xFF4A4A4A); // Bordas sutis
  static const Color dividerColor = Color(0xFF333333); // Divisores

  // ========================================
  // 📐 ESPAÇAMENTOS E RAIOS
  // ========================================

  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 24.0;

  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;

  // ========================================
  // 📝 THEMEDATA DARK
  // ========================================

  static ThemeData get darkTheme {
    return ThemeData(
      // Modo escuro
      brightness: Brightness.dark,
      useMaterial3: true,

      // Esquema de cores
      colorScheme: ColorScheme.dark(
        primary: primaryOrange,
        secondary: primaryOrangeHover,
        surface: backgroundCard,
        error: error,
        onPrimary: textPrimary,
        onSecondary: textPrimary,
        onSurface: textPrimary,
        onError: textPrimary,
      ),

      // Cor de fundo global
      scaffoldBackgroundColor: backgroundPrimary,

      // ========================================
      // 🔤 TIPOGRAFIA
      // ========================================
      textTheme: const TextTheme(
        // Headlines (títulos grandes)
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textPrimary,
          height: 1.2,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: textPrimary,
          height: 1.2,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: textPrimary,
          height: 1.2,
        ),

        // Títulos de seção
        headlineLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: textPrimary,
          height: 1.3,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          height: 1.3,
        ),
        headlineSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          height: 1.3,
        ),

        // Títulos de cards e componentes
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          height: 1.4,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          height: 1.4,
        ),
        titleSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          height: 1.4,
        ),

        // Corpo de texto
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: textPrimary,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: textPrimary,
          height: 1.5,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: textSecondary,
          height: 1.5,
        ),

        // Labels (textos pequenos)
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textPrimary,
          height: 1.4,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textSecondary,
          height: 1.4,
        ),
        labelSmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: textSecondary,
          height: 1.4,
        ),
      ),

      // ========================================
      // 🎯 COMPONENTES - BOTÕES
      // ========================================
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryOrange,
          foregroundColor: textPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryOrange,
          side: const BorderSide(color: primaryOrange, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryOrange,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // ========================================
      // 📝 COMPONENTES - INPUTS
      // ========================================
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: backgroundElevated,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: borderColor, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: borderColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: primaryOrange, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: const TextStyle(color: textSecondary, fontSize: 14),
        labelStyle: const TextStyle(color: textSecondary, fontSize: 14),
        floatingLabelStyle: const TextStyle(color: primaryOrange, fontSize: 14),
        prefixIconColor: textSecondary,
        suffixIconColor: textSecondary,
      ),

      // ========================================
      // 📦 COMPONENTES - CARDS
      // ========================================
      cardTheme: CardThemeData(
        color: backgroundCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
          side: const BorderSide(color: borderColor, width: 0.5),
        ),
        margin: const EdgeInsets.symmetric(vertical: spacingS),
      ),

      // ========================================
      // 📱 COMPONENTES - APP BAR
      // ========================================
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundPrimary,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: textPrimary, size: 24),
      ),

      // ========================================
      // 🔘 COMPONENTES - FLOATING ACTION BUTTON
      // ========================================
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryOrange,
        foregroundColor: textPrimary,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(radiusLarge)),
        ),
      ),

      // ========================================
      // 🎚️ COMPONENTES - SWITCHES E SLIDERS
      // ========================================
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryOrange;
          }
          return textSecondary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryOrange.withOpacity(0.5);
          }
          return backgroundElevated;
        }),
      ),

      sliderTheme: const SliderThemeData(
        activeTrackColor: primaryOrange,
        inactiveTrackColor: backgroundElevated,
        thumbColor: primaryOrange,
        overlayColor: Color(0x29FF6B00), // primaryOrange com 16% opacidade
      ),

      // ========================================
      // 📋 COMPONENTES - LISTAS
      // ========================================
      listTileTheme: const ListTileThemeData(
        tileColor: backgroundCard,
        textColor: textPrimary,
        iconColor: textSecondary,
        contentPadding: EdgeInsets.symmetric(horizontal: spacingM, vertical: spacingS),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(radiusMedium)),
        ),
      ),

      // ========================================
      // ➖ COMPONENTES - DIVISORES
      // ========================================
      dividerTheme: const DividerThemeData(
        color: dividerColor,
        thickness: 1,
        space: 1,
      ),

      // ========================================
      // 🎪 COMPONENTES - DIALOGS
      // ========================================
      dialogTheme: DialogThemeData(
        backgroundColor: backgroundCard,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
        ),
        titleTextStyle: const TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        contentTextStyle: const TextStyle(
          color: textPrimary,
          fontSize: 14,
          height: 1.5,
        ),
      ),

      // ========================================
      // 🍿 COMPONENTES - SNACKBAR
      // ========================================
      snackBarTheme: SnackBarThemeData(
        backgroundColor: backgroundCard,
        contentTextStyle: const TextStyle(color: textPrimary, fontSize: 14),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
        actionTextColor: primaryOrange,
      ),

      // ========================================
      // 🎨 COMPONENTES - PROGRESS INDICATORS
      // ========================================
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primaryOrange,
        circularTrackColor: backgroundElevated,
        linearTrackColor: backgroundElevated,
      ),

      // ========================================
      // 🏷️ COMPONENTES - CHIPS
      // ========================================
      chipTheme: ChipThemeData(
        backgroundColor: backgroundElevated,
        selectedColor: primaryOrange,
        disabledColor: backgroundElevated.withOpacity(0.5),
        labelStyle: const TextStyle(color: textPrimary, fontSize: 14),
        secondaryLabelStyle: const TextStyle(color: textPrimary, fontSize: 14),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSmall),
        ),
      ),

      // ========================================
      // 📅 COMPONENTES - BOTTOM NAVIGATION BAR
      // ========================================
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: backgroundCard,
        selectedItemColor: primaryOrange,
        unselectedItemColor: textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
      ),

      // ========================================
      // 🎯 ÍCONES
      // ========================================
      iconTheme: const IconThemeData(
        color: textSecondary,
        size: 24,
      ),
    );
  }
}
