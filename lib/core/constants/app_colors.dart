import 'package:flutter/material.dart';

/// Couleurs et thèmes personnalisés de l'application
class AppColors {
  // Couleur de base
  static const Color primarySeed = Colors.blue;
  
  // Opacités communes
  static const double primaryContainerAlpha = 0.5;
  static const double surfaceContainerAlpha = 0.3;
  static const double outlineAlpha = 0.2;
  static const double surfaceHighAlpha = 0.9;
  static const double shadowAlpha = 0.1;
  
  // Couleurs spécifiques aux fonctionnalités
  static const Color engineSwitchNotificationColor = Colors.blue;
  
  // Gradients
  static LinearGradient backgroundGradient(ColorScheme colorScheme) {
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        colorScheme.surface,
        colorScheme.surfaceContainerLowest,
      ],
    );
  }
  
  static LinearGradient cardGradient(ColorScheme colorScheme) {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        colorScheme.surface,
        colorScheme.surfaceContainerLowest,
      ],
    );
  }
  
  static LinearGradient primaryGradient(ColorScheme colorScheme) {
    return LinearGradient(
      colors: [
        colorScheme.primary,
        colorScheme.secondary,
      ],
    );
  }
  
  static LinearGradient cellGradient(ColorScheme colorScheme) {
    return LinearGradient(
      colors: [
        colorScheme.primary,
        colorScheme.primary.withValues(alpha: 0.8),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }
}