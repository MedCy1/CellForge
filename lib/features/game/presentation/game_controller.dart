import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/engine/life_engine_controller.dart';
import '../../../core/engine/bruteforce_engine.dart';
import '../../../services/pattern_service.dart';

/// Contrôleur pour gérer l'état et la logique du jeu
class GameController extends ChangeNotifier {
  late LifeEngineController _engine;
  bool _showBuiltInPatterns = false;
  String? _lastEngineMessage;

  GameController() {
    _initializeEngine();
  }

  // Getters
  LifeEngineController get engine => _engine;
  bool get showBuiltInPatterns => _showBuiltInPatterns;
  String? get lastEngineMessage => _lastEngineMessage;

  void _initializeEngine() {
    _engine = LifeEngineController(
      engine: BruteforceEngine(
        width: AppConstants.defaultGridWidth, 
        height: AppConstants.defaultGridHeight,
      ),
      onEngineSwitch: (message) {
        // Stocker le message et notifier les listeners
        _lastEngineMessage = message;
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

  /// Consommer le dernier message d'engine (marquer comme lu)
  void clearEngineMessage() {
    _lastEngineMessage = null;
  }

  @override
  void dispose() {
    _engine.dispose();
    super.dispose();
  }
}