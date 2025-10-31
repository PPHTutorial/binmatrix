import 'package:flutter/material.dart';

/// Application color palette
class AppColors {
  // Primary Colors
  static const Color primaryColor = Color(0xFFE16232);      // Orange
  static const Color secondaryColor = Color(0xFF13A383);    // Teal/Green
  static const Color accentColor = Color(0xFFF7EAE7);       // Light peach/cream
  
  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkCard = Color(0xFF2A2A2A);
  
  // Light Theme Colors
  static const Color lightBackground = Color(0xFFFAFAFA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  
  // Text Colors (Dark Theme)
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color textDisabled = Color(0xFF707070);
  static const Color textHint = Color(0xFF606060);
  
  // Text Colors (Light Theme)
  static const Color lightTextPrimary = Color(0xFF1A1A1A);
  static const Color lightTextSecondary = Color(0xFF606060);
  static const Color lightTextDisabled = Color(0xFF9E9E9E);
  
  // Semantic Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);
  static const Color goldColor = Color(0xFFB4AA16);
  
  // Overlay Colors
  static const Color overlay = Color(0x80000000);           // Semi-transparent black
  static const Color shimmerBase = Color(0xFF2A2A3E);
  static const Color shimmerHighlight = Color(0xFF3A3A4E);
  
  // Border Colors
  static const Color borderColor = Color(0xFF2A2A3E);
  static const Color dividerColor = Color(0xFF2A2A3E);
  
  // Rating Colors
  static const Color ratingGold = Color(0xFFFFD700);
  static const Color ratingBad = Color(0xFFF44336);
  static const Color ratingAverage = Color(0xFFFFC107);
  static const Color ratingGood = Color(0xFF4CAF50);
  static const Color ratingExcellent = Color(0xFF2196F3);
  
  // Special Colors
  static const Color proGradientStart = primaryColor;
  static const Color proGradientEnd = secondaryColor;
  static const Color freeWatermark = Color(0x59FFFFFF);     // Semi-transparent white
  
  // Chip Colors
  static const Color chipBackground = Color(0xFF2A2A2A);
  static const Color chipSelectedBackground = primaryColor;
  
  // Ad Colors
  static const Color adBackground = Color(0xFF2A2A2A);
  static const Color adBorder = Color(0xFF3A3A3A);
  
  /// Get brand color based on card brand
  static Color getBrandColor(String brand) {
    switch (brand.toUpperCase()) {
      case 'VISA':
        return const Color(0xFF1A1F71); // Visa blue
      case 'MASTERCARD':
        return const Color(0xFFEB001B); // Mastercard red
      case 'AMEX':
      case 'AMERICAN EXPRESS':
        return const Color(0xFF006FCF); // Amex blue
      case 'DISCOVER':
        return const Color(0xFFFF6000); // Discover orange
      default:
        return primaryColor;
    }
  }
  
  /// Get type color based on card type
  static Color getTypeColor(String type) {
    switch (type.toUpperCase()) {
      case 'CREDIT':
        return success;
      case 'DEBIT':
        return info;
      case 'PREPAID':
        return warning;
      default:
        return textSecondary;
    }
  }
}

