import 'package:flutter/material.dart';

// ─── COLOR PALETTE ───────────────────────────────────────────────────────────
class AppColors {
  // Primarios
  static const Color primary = Color(0xFF7C3AED);       // Violeta principal
  static const Color primaryLight = Color(0xFFA78BFA);  // Violeta claro
  static const Color primaryDark = Color(0xFF5B21B6);   // Violeta oscuro

  // Fondos
  static const Color background = Color(0xFFF5F3FF);    // Lavanda suave
  static const Color surface = Color(0xFFFFFFFF);       // Blanco para cards
  static const Color surfaceVariant = Color(0xFFEDE9FE);// Lavanda cards

  // Texto
  static const Color textPrimary = Color(0xFF1E1B4B);   // Casi negro violeta
  static const Color textSecondary = Color(0xFF6B7280);  // Gris medio
  static const Color textLight = Color(0xFF9CA3AF);      // Gris claro

  // Badges / Estado
  static const Color badgeHigh = Color(0xFFEF4444);      // Rojo — Alta prioridad
  static const Color badgeMedium = Color(0xFFF59E0B);    // Amarillo — Media
  static const Color badgeLow = Color(0xFF10B981);       // Verde — Baja
  static const Color badgeStatus = Color(0xFF7C3AED);    // Violeta — Status

  // Ciclo menstrual
  static const Color phaseMenstrual = Color(0xFFEF4444);
  static const Color phaseFolicular = Color(0xFFF59E0B);
  static const Color phaseOvulacion = Color(0xFF10B981);
  static const Color phaseLutea = Color(0xFF7C3AED);

  // Gradiente principal
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF7C3AED), Color(0xFFA78BFA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFFEDE9FE), Color(0xFFF5F3FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFFF5F3FF), Color(0xFFEDE9FE), Color(0xFFF5F3FF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

// ─── TIPOGRAFÍA ───────────────────────────────────────────────────────────────
class AppTextStyles {
  static const TextStyle heading1 = TextStyle(
    fontSize: 28, fontWeight: FontWeight.bold,
    color: AppColors.textPrimary, letterSpacing: -0.5,
  );
  static const TextStyle heading2 = TextStyle(
    fontSize: 22, fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );
  static const TextStyle heading3 = TextStyle(
    fontSize: 18, fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
  static const TextStyle body = TextStyle(
    fontSize: 14, fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );
  static const TextStyle bodySecondary = TextStyle(
    fontSize: 13, color: AppColors.textSecondary,
  );
  static const TextStyle caption = TextStyle(
    fontSize: 12, color: AppColors.textLight,
  );
  static const TextStyle buttonText = TextStyle(
    fontSize: 15, fontWeight: FontWeight.w600,
    color: Colors.white, letterSpacing: 0.3,
  );
  static const TextStyle buttonTextDark = TextStyle(
    fontSize: 15, fontWeight: FontWeight.w600,
    color: AppColors.primary,
  );
}

// ─── TEMA GLOBAL ──────────────────────────────────────────────────────────────
ThemeData appTheme() {
  return ThemeData(
    useMaterial3: true,
    fontFamily: 'Poppins',
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
      background: AppColors.background,
      surface: AppColors.surface,
      primary: AppColors.primary,
    ),
    scaffoldBackgroundColor: AppColors.background,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: AppTextStyles.heading2,
      iconTheme: IconThemeData(color: AppColors.textPrimary),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        textStyle: AppTextStyles.buttonText,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceVariant,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.primaryLight.withOpacity(0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: AppTextStyles.bodySecondary,
    ),
    cardTheme: CardTheme(
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textLight,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      elevation: 12,
    ),
  );
}

// ─── DECORACIONES REUTILIZABLES ───────────────────────────────────────────────
class AppDecorations {
  static BoxDecoration card = BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: AppColors.primary.withOpacity(0.07),
        blurRadius: 12, offset: const Offset(0, 4),
      ),
    ],
  );

  static BoxDecoration surfaceCard = BoxDecoration(
    color: AppColors.surfaceVariant,
    borderRadius: BorderRadius.circular(16),
  );

  static BoxDecoration gradientCard = BoxDecoration(
    gradient: AppColors.cardGradient,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: AppColors.primary.withOpacity(0.1),
        blurRadius: 16, offset: const Offset(0, 6),
      ),
    ],
  );

  static BoxDecoration primaryContainer = BoxDecoration(
    gradient: AppColors.primaryGradient,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: AppColors.primary.withOpacity(0.3),
        blurRadius: 16, offset: const Offset(0, 6),
      ),
    ],
  );
}
