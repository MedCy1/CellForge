import 'i_life_engine.dart';
import 'bruteforce_engine.dart';
import 'avx2_engine.dart';

enum EngineType {
  bruteforce,
  avx2,
}

class LifeEngineController {
  ILifeEngine _engine;
  bool _autoSwitchEnabled = false;
  int _autoSwitchThreshold = 2500; // Switch to AVX2 for grids larger than 50x50
  void Function(String message)? _onEngineSwitch;
  
  LifeEngineController({
    ILifeEngine? engine, 
    bool autoSwitch = false,
    void Function(String message)? onEngineSwitch,
  }) : _engine = engine ?? BruteforceEngine(),
       _autoSwitchEnabled = autoSwitch,
       _onEngineSwitch = onEngineSwitch;
  
  Stream<List<List<bool>>> get gridStream => _engine.gridStream;
  Stream<int> get generationStream => _engine.generationStream;
  
  bool get isRunning => _engine.isRunning;
  int get width => _engine.width;
  int get height => _engine.height;
  int get generation => _engine.generation;
  Duration get generationInterval => _engine.generationInterval;
  
  bool getCellState(int x, int y) => _engine.getCellState(x, y);
  void setCellState(int x, int y, bool isAlive) => _engine.setCellState(x, y, isAlive);
  void toggleCell(int x, int y) => _engine.toggleCell(x, y);
  void clearGrid() => _engine.clearGrid();
  void randomizeGrid({double probability = 0.3}) => _engine.randomizeGrid(probability: probability);
  void setGenerationInterval(Duration interval) => _engine.setGenerationInterval(interval);
  void start() => _engine.start();
  void stop() => _engine.stop();
  void toggle() => _engine.toggle();
  void nextGeneration() => _engine.nextGeneration();
  void loadPattern(List<List<bool>> pattern, {int? startX, int? startY}) => 
    _engine.loadPattern(pattern, startX: startX, startY: startY);
  List<List<bool>> exportPattern() => _engine.exportPattern();
  List<List<bool>> getCurrentGrid() => _engine.getCurrentGrid();
  void resizeGrid(int newWidth, int newHeight) {
    _engine.resizeGrid(newWidth, newHeight);
    if (_autoSwitchEnabled) {
      _checkAndAutoSwitch();
    }
  }
  void dispose() => _engine.dispose();
  
  void switchEngine(ILifeEngine newEngine) {
    final oldGrid = _engine.getCurrentGrid();
    final wasRunning = _engine.isRunning;
    
    _engine.dispose();
    _engine = newEngine;
    
    _engine.loadPattern(oldGrid);
    
    if (wasRunning) {
      _engine.start();
    }
  }
  
  ILifeEngine get currentEngine => _engine;
  
  // Get the current algorithm type
  EngineType get currentEngineType {
    if (_engine is Avx2Engine) {
      return EngineType.avx2;
    } else if (_engine is BruteforceEngine) {
      return EngineType.bruteforce;
    } else {
      return EngineType.bruteforce; // Default fallback
    }
  }
  
  // Get human-readable engine name
  String get currentEngineName {
    switch (currentEngineType) {
      case EngineType.avx2:
        return 'AVX2 Native Engine';
      case EngineType.bruteforce:
        return 'Brute Force Engine';
    }
  }
  
  // Get performance characteristics
  Map<String, dynamic> get engineInfo {
    return {
      'type': currentEngineType,
      'name': currentEngineName,
      'gridSize': '${width}x$height',
      'totalCells': width * height,
      'autoSwitchEnabled': _autoSwitchEnabled,
      'autoSwitchThreshold': _autoSwitchThreshold,
    };
  }
  
  // Enable/disable automatic switching
  void setAutoSwitch(bool enabled, {int? threshold}) {
    _autoSwitchEnabled = enabled;
    if (threshold != null) {
      _autoSwitchThreshold = threshold;
    }
    
    if (_autoSwitchEnabled) {
      _checkAndAutoSwitch();
    }
  }
  
  // Set the engine switch callback for logging/notifications
  void setOnEngineSwitch(void Function(String message)? callback) {
    _onEngineSwitch = callback;
  }
  
  // Check if we should switch engines based on grid size
  void _checkAndAutoSwitch() {
    if (!_autoSwitchEnabled) return;
    
    final totalCells = width * height;
    final currentType = currentEngineType;
    
    try {
      if (totalCells > _autoSwitchThreshold && currentType == EngineType.bruteforce) {
        // Switch to AVX2 for large grids
        final message = 'Auto-switching to AVX2 engine (grid size: ${width}x$height = $totalCells cells)';
        _onEngineSwitch?.call(message);
        final avx2Engine = Avx2Engine(width: width, height: height);
        switchEngine(avx2Engine);
      } else if (totalCells <= _autoSwitchThreshold && currentType == EngineType.avx2) {
        // Switch back to bruteforce for small grids
        final message = 'Auto-switching to Brute Force engine (grid size: ${width}x$height = $totalCells cells)';
        _onEngineSwitch?.call(message);
        final bruteforceEngine = BruteforceEngine(width: width, height: height);
        switchEngine(bruteforceEngine);
      }
    } catch (e) {
      final message = 'Auto-switch failed: $e. Keeping current engine.';
      _onEngineSwitch?.call(message);
    }
  }
  
  
  // Manual engine switching with type enum
  void switchToEngine(EngineType engineType) {
    if (currentEngineType == engineType) return; // Already using this engine
    
    try {
      ILifeEngine newEngine;
      switch (engineType) {
        case EngineType.avx2:
          newEngine = Avx2Engine(width: width, height: height);
          break;
        case EngineType.bruteforce:
          newEngine = BruteforceEngine(width: width, height: height);
          break;
      }
      
      switchEngine(newEngine);
      final message = 'Manually switched to ${newEngine.runtimeType}';
      _onEngineSwitch?.call(message);
    } catch (e) {
      final message = 'Failed to switch to $engineType: $e';
      _onEngineSwitch?.call(message);
    }
  }
  
  // Get switching recommendations
  String getEngineRecommendation() {
    final totalCells = width * height;
    final currentType = currentEngineType;
    
    if (totalCells > _autoSwitchThreshold && currentType == EngineType.bruteforce) {
      return 'Recommendation: Switch to AVX2 engine for better performance with large grids (${width}x$height)';
    } else if (totalCells <= _autoSwitchThreshold && currentType == EngineType.avx2) {
      return 'Recommendation: Brute Force engine is sufficient for smaller grids (${width}x$height)';
    } else {
      return 'Current engine is optimal for grid size (${width}x$height)';
    }
  }
}