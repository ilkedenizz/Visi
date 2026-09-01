import 'package:flutter/material.dart';

/// Vişi Brand Color Palette
/// 
/// The visual language of Vişi comes from the Turkish word "vişne" (cherry).
/// Colors are used subtly: warm off-white background, deep plum text, muted cherry crimson accent,
/// soft blush pink secondary accent, and muted sage green supporting color.
class AppColors {
  AppColors._();

  // --- Shared Brand Deep Plum ---
  static const Color deepPlum = Color(0xFF2D1520);   // Deep plum / almost-black burgundy

  // --- Light Theme Colors ---
  static const Color lightBackground = Color(0xFFFDFBF7); // Warm off-white / creamy
  static const Color lightSurface = Color(0xFFF5EFE6);    // Subtle warm elevated surface
  static const Color lightCard = Color(0xFFFFFFFF);       // Clean white card background
  static const Color lightCardBorder = Color(0xFFEFE8E1); // Soft subtle border
  
  static const Color lightTextPrimary = Color(0xFF2D1520);   // Deep plum / almost-black burgundy
  static const Color lightTextSecondary = Color(0xFF6B5861); // Muted plum gray
  static const Color lightTextMuted = Color(0xFFA3929A);     // Soft neutral text

  // --- Dark Theme Colors ---
  static const Color darkBackground = Color(0xFF160E14);  // Deep plum charcoal
  static const Color darkSurface = Color(0xFF221720);     // Muted plum dark surface
  static const Color darkCard = Color(0xFF2C1D29);        // Elevated dark card background
  static const Color darkCardBorder = Color(0xFF3B2A38);  // Subtle dark border
  
  static const Color darkTextPrimary = Color(0xFFF7F3F6);   // Soft off-white light text
  static const Color darkTextSecondary = Color(0xFFC7B7C2); // Soft muted light text
  static const Color darkTextMuted = Color(0xFF8C7987);     // Dim plum text

  // --- Shared Brand Accents ---
  static const Color cherryAccent = Color(0xFFB8324A);     // Muted cherry red / crimson
  static const Color cherryAccentDark = Color(0xFFD94B62); // Slightly vibrant cherry for dark mode
  static const Color blushPink = Color(0xFFF7E5E8);        // Soft blush pink
  static const Color blushPinkDark = Color(0xFF422634);    // Muted blush dark accent container
  static const Color sageGreen = Color(0xFF8A9A86);        // Muted sage green supporting color
  static const Color sageGreenLight = Color(0xFFEFF2EE);   // Very soft sage container
  static const Color sageGreenDark = Color(0xFF293327);    // Dark sage container

  // Priority colors
  static const Color priorityLow = Color(0xFF7A9E9F);
  static const Color priorityMedium = Color(0xFFE29578);
  static const Color priorityHigh = Color(0xFFB8324A);

  // System status & neutrals
  static const Color shadowColor = Color(0x0C2D1520);
  static const Color darkShadowColor = Color(0x28000000);
}
