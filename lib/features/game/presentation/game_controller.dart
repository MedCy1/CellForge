import 'package:flutter/material.dart';
import '../../../core/engine/life_engine_controller.dart';
import '../../../core/engine/bruteforce_engine.dart';
import '../../../services/pattern_service.dart';

/// Contrôleur pour gérer l'état et la logique du jeu
class GameController extends ChangeNotifier {
  late LifeEngineController _engine;
  bool _showBuiltInPatterns = false;

  GameController() {
    _initializeEngine();
  }

  // Getters
  LifeEngineController get engine => _engine;
  bool get showBuiltInPatterns => _showBuiltInPatterns;

  void _initializeEngine() {
    _engine = LifeEngineController(
      engine: BruteforceEngine(width: 80, height: 50),
      onEngineSwitch: (message) {
        // Notifier les listeners des changements de moteur
        notifyListeners();
      },
    );
  }

  void toggleBuiltInPatterns() {
    _showBuiltInPatterns = !_showBuiltInPatterns;
    notifyListeners();
  }

  void hideBuiltInPatterns() {
    _showBuiltInPatterns = false;
    notifyListeners();
  }

  void loadPattern(PatternModel pattern) {
    // Convertir vers une grille avec les dimensions du moteur
    final grid = pattern.toGrid(
      width: _engine.width,
      height: _engine.height,
    );
    _engine.loadPattern(grid);
    notifyListeners();
  }

  List<PatternModel> getBuiltInPatterns() {
    return PatternService.getBuiltInPatterns();
  }

  @override
  void dispose() {
    _engine.dispose();
    super.dispose();
  }
}