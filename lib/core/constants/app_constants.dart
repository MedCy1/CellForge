import 'package:flutter/material.dart';

/// Constantes globales de l'application CellForge
class AppConstants {
  // Informations de l'application
  static const String appName = 'CellForge';
  static const String appEmoji = '🧬';
  
  // Configuration par défaut des grilles
  static const int defaultGridWidth = 80;
  static const int defaultGridHeight = 50;
  
  // Configuration de performance
  static const int autoSwitchThreshold = 2500; // Switch to AVX2 for grids larger than 50x50
  static const Duration defaultGenerationInterval = Duration(milliseconds: 200);
  
  // Configuration de l'interface
  static const double sidebarWidth = 320.0;
  static const double wideScreenBreakpoint = 800.0;
  static const EdgeInsets defaultPadding = EdgeInsets.all(16.0);
  static const EdgeInsets smallPadding = EdgeInsets.all(8.0);
  
  // Configuration de la grille infinie
  static const double defaultCellSize = 20.0;
  static const double minScale = 0.1;
  static const double maxScale = 10.0;
  static const double defaultScale = 1.0;
  
  // Configuration des animations et notifications
  static const Duration snackBarDuration = Duration(seconds: 2);
  static const Duration engineSwitchNotificationDuration = Duration(seconds: 2);
  
  // Configuration de l'InteractiveViewer (grilles limitées)
  static const double interactiveViewerMinScale = 0.5;
  static const double interactiveViewerMaxScale = 5.0;
  static const EdgeInsets interactiveViewerBoundaryMargin = EdgeInsets.all(20);
  
  // Configuration de randomisation
  static const double defaultRandomProbability = 0.3;
  static const int infiniteGridRandomRange = 25; // [-25, 25] pour les grilles infinies
  
  // Configuration des couleurs et styles
  static const double cardElevation = 2.0;
  static const double dialogElevation = 8.0;
  static const double borderRadius = 12.0;
  static const double smallBorderRadius = 8.0;
  static const double iconSize = 20.0;
  static const double smallIconSize = 16.0;
  
  // Configuration de performance de rendu
  static const int maxGridLinesForPerformance = 200;
  static const double gridLineOpacityFactor = 0.15;
  static const double shadowOpacity = 0.1;
  static const double gridCellSpacing = 0.5; // Offset pour l'espacement des cellules
  static const double gridCellSizeReduction = 1.0; // Réduction de taille pour l'espacement
  
  // Configuration de navigation
  static const int rightMouseButton = 2;
  static const int leftMouseButton = 1;
  
  // Limites et contraintes
  static const int maxMemoryUsageBytes = 1024 * 1024 * 100; // 100MB
  static const int minGridSize = 10;
  static const int maxGridSize = 1000;
}