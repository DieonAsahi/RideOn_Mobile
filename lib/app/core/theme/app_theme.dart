import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Palet Warna Dasar RideOn
class AppColors {
  AppColors._();

  /// Warna Utama
  static const Color primaryBlue = Color(0xFF2196F3);
  static const Color primary = primaryBlue;

  /// Warna Status & Aksen
  static const Color orange = Color(0xFFFF6200);
  static const Color red = Color(0xFFFF0000);
  static const Color green = Color(0xFF09B200);

  /// Warna Border Card & Shadow (0.05)
  static const Color bar = Color(0xFFAEAEAE );
  static const Color cardBorder = Color(0xFFE1E1E1);
  static const BoxShadow cardShadow = BoxShadow(
    color: Color(0x0D000000), // Black with 0.05 opacity
    blurRadius: 10,
    spreadRadius: 0,
    offset: Offset(0, 4),
  );

  /// Warna Netral
  static const Color background = Colors.white;
  static const Color surface = Colors.white;
  static const Color surfaceGrey = Color(0xFFF7F8FA);
  static const Color textPrimary = Color(0xFF1E1E1E);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textMuted = Color(0xFF9E9E9E);
  static const Color divider = Color(0xFFE1E1E1);
}

/// Helper Tipografi Poppins
class AppText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final TextOverflow? overflow;
  final int? maxLines;

  const AppText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.overflow,
    this.maxLines,
  });

  /// Factory constructors untuk berbagai tingkatan teks dengan font Poppins
  factory AppText.heading1(
    String text, {
    Color? color,
    FontWeight? fontWeight,
    TextAlign? textAlign,
  }) {
    return AppText(
      text,
      textAlign: textAlign,
      style: GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: fontWeight ?? FontWeight.bold,
        color: color ?? AppColors.textPrimary,
      ),
    );
  }

  factory AppText.heading2(
    String text, {
    Color? color,
    FontWeight? fontWeight,
    TextAlign? textAlign,
  }) {
    return AppText(
      text,
      textAlign: textAlign,
      style: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: fontWeight ?? FontWeight.bold,
        color: color ?? AppColors.textPrimary,
      ),
    );
  }

  factory AppText.title(
    String text, {
    Color? color,
    FontWeight? fontWeight,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
  }) {
    return AppText(
      text,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      style: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: fontWeight ?? FontWeight.w600,
        color: color ?? AppColors.textPrimary,
      ),
    );
  }

  factory AppText.body(
    String text, {
    Color? color,
    FontWeight? fontWeight,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
    double? height,
  }) {
    return AppText(
      text,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      style: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: fontWeight ?? FontWeight.normal,
        color: color ?? AppColors.textPrimary,
        height: height ?? 1.4,
      ),
    );
  }

  factory AppText.caption(
    String text, {
    Color? color,
    FontWeight? fontWeight,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
  }) {
    return AppText(
      text,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      style: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: fontWeight ?? FontWeight.normal,
        color: color ?? AppColors.textSecondary,
      ),
    );
  }

  /// Helper untuk mengambil TextStyle Poppins secara langsung
  static TextStyle poppins({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.normal,
    Color color = AppColors.textPrimary,
    double? height,
    TextDecoration? decoration,
  }) {
    return GoogleFonts.poppins(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      decoration: decoration,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      overflow: overflow,
      maxLines: maxLines,
      style: style ?? GoogleFonts.poppins(),
    );
  }
}

/// Widget Card Standar RideOn dengan Border 0xFFE1E1E1 dan Shadow 0.05
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final Color backgroundColor;
  final Color borderColor;
  final double borderWidth;
  final VoidCallback? onTap;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.margin,
    this.borderRadius = 16,
    this.backgroundColor = Colors.white,
    this.borderColor = AppColors.cardBorder,
    this.borderWidth = 1.0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget card = Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: borderColor, width: borderWidth),
        boxShadow: const [
          AppColors.cardShadow,
        ],
      ),
      child: child,
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: card,
      );
    }

    return card;
  }
}

/// Konfigurasi Tema Global Aplikasi RideOn
class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    final baseTextTheme = GoogleFonts.poppinsTextTheme();

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.primaryBlue,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryBlue,
        primary: AppColors.primaryBlue,
        secondary: AppColors.orange,
        error: AppColors.red,
        surface: AppColors.background,
      ),
      fontFamily: GoogleFonts.poppins().fontFamily,
      textTheme: baseTextTheme.apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
        fontFamily: GoogleFonts.poppins().fontFamily,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: Colors.white,
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryBlue,
          side: const BorderSide(color: AppColors.primaryBlue, width: 1.5),
          textStyle: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: GoogleFonts.poppins(
          color: AppColors.textSecondary,
          fontSize: 14,
        ),
        labelStyle: GoogleFonts.poppins(
          color: AppColors.textPrimary,
          fontSize: 14,
        ),
        filled: true,
        fillColor: Colors.grey.shade100,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primaryBlue, width: 1.8),
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.cardBorder),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.cardBorder,
        thickness: 1,
      ),
    );
  }
}
