import 'dart:async';
import 'i_life_engine.dart';
import 'bruteforce_engine.dart';
import 'avx2_engine.dart';
import 'sparse_list_engine.dart';

enum EngineType {
  bruteforce,
  avx2,
  sparse,
}

class LifeEngineController {
  ILifeEngine _engine;
  bool _autoSwitchEnabled = true; // Enable auto-switching by default
  int _autoSwitchThreshold = 2500; // Switch to AVX2 for grids larger than 50x50
  bool _isInfiniteGrid = false; // Track if infinite grid mode is enabled
  void Function(String message)? _onEngineSwitch;
  
  // Controller's own streams that never change
  final StreamController<List<List<bool>>> _gridController = StreamController.broadcast();
  final StreamController<int> _generationController = StreamController.broadcast();
  
  // Stream subscriptions to current engine
  StreamSubscription<List<List<bool>>>? _gridSubscription;
  StreamSubscription<int>? _generationSubscription;
  
  LifeEngineController({
    ILifeEngine? engine, 
    bool autoSwitch = true, // Default to true
    void Function(String message)? onEngineSwitch,
  }) : _engine = engine ?? BruteforceEngine(),
       _autoSwitchEnabled = autoSwitch,
       _onEngineSwitch = onEngineSwitch {
    _connectToEngine();
    // Perform initial auto-switch check based on grid size
    if (_autoSwitchEnabled) {
      Future.microtask(() => _checkAndAutoSwitch());
    }
  }
  
  Stream<List<List<bool>>> get gridStream => _gridController.stream;
  Stream<int> get generationStream => _generationController.stream;
  
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
  
  void setInfiniteGrid(bool infinite) {
    _isInfiniteGrid = infinite;
    if (_autoSwitchEnabled) {
      _checkAndAutoSwitch();
    }
  }
  
  bool get isInfiniteGrid => _isInfiniteGrid;
  void dispose() {
    _disconnectFromEngine();
    _engine.dispose();
    _gridController.close();
    _generationController.close();
  }
  
  void _connectToEngine() {
    _disconnectFromEngine();
    
    _gridSubscription = _engine.gridStream.listen((grid) {
      if (!_gridController.isClosed) {
        _gridController.add(grid);
      }
    });
    
    _generationSubscription = _engine.generationStream.listen((generation) {
      if (!_generationController.isClosed) {
        _generationController.add(generation);
      }
    });
  }
  
  void _disconnectFromEngine() {
    _gridSubscription?.cancel();
    _generationSubscription?.cancel();
    _gridSubscription = null;
    _generationSubscription = null;
  }
  
  void switchEngine(ILifeEngine newEngine) {
    final oldGrid = _engine.getCurrentGrid();
    final wasRunning = _engine.isRunning;
    
    _disconnectFromEngine();
    _engine.dispose();
    _engine = newEngine;
    _connectToEngine();
    
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
    } else if (_engine is SparseListEngine) {
      return EngineType.sparse;
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
      case EngineType.sparse:
        return 'Sparse List Engine';
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
    
    final currentType = currentEngineType;
    
    if (_isInfiniteGrid) {
      // Switch to sparse engine for infinite grid
      if (currentType != EngineType.sparse) {
        try {
          final sparseEngine = SparseListEngine(infinite: true);
          switchEngine(sparseEngine);
          final message = 'Switched to sparse engine for infinite grid';
          _onEngineSwitch?.call(message);
        } catch (e) {
          final message = 'Sparse engine not available, keeping current engine';
          _onEngineSwitch?.call(message);
        }
      } else {
        // S'assurer que le mode infini est activé sur l'engine existant
        if (_engine is SparseListEngine) {
          (_engine as SparseListEngine).setInfiniteMode(true);
        }
      }
    } else {
      // Regular grid logic
      final totalCells = width * height;
      
      if (totalCells > _autoSwitchThreshold && currentType == EngineType.bruteforce) {
        // Switch to AVX2 for large grids
        try {
          final avx2Engine = Avx2Engine(width: width, height: height);
          switchEngine(avx2Engine);
          final message = 'Switched to high-performance engine for $width×$height grid';
          _onEngineSwitch?.call(message);
        } catch (e) {
          // AVX2 engine creation failed, inform user and stay with current engine
          final message = 'High-performance engine not available, using standard engine';
          _onEngineSwitch?.call(message);
        }
      } else if (totalCells <= _autoSwitchThreshold && (currentType == EngineType.avx2 || currentType == EngineType.sparse)) {
        // Switch back to bruteforce for small grids
        try {
          final bruteforceEngine = BruteforceEngine(width: width, height: height);
          switchEngine(bruteforceEngine);
          final message = 'Switched to standard engine for $width×$height grid';
          _onEngineSwitch?.call(message);
        } catch (e) {
          // This should rarely fail, but handle gracefully
          final message = 'Engine switch failed, keeping current engine';
          _onEngineSwitch?.call(message);
        }
      } else if (currentType == EngineType.sparse) {
        // S'assurer que le SparseListEngine est en mode grille fixe
        if (_engine is SparseListEngine) {
          (_engine as SparseListEngine).setInfiniteMode(false);
        }
      }
    }
    // If we're already using the correct engine for the grid size, do nothing (no notification)
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
        case EngineType.sparse:
          newEngine = SparseListEngine(width: width, height: height);
          break;
        case EngineType.bruteforce:
          newEngine = BruteforceEngine(width: width, height: height);
          break;
      }
      
      switchEngine(newEngine);
      String engineName;
      switch (engineType) {
        case EngineType.avx2:
          engineName = 'high-performance';
          break;
        case EngineType.sparse:
          engineName = 'sparse';
          break;
        case EngineType.bruteforce:
          engineName = 'standard';
          break;
      }
      final message = 'Switched to $engineName engine';
      _onEngineSwitch?.call(message);
    } catch (e) {
      String engineName;
      switch (engineType) {
        case EngineType.avx2:
          engineName = 'high-performance';
          break;
        case EngineType.sparse:
          engineName = 'sparse';
          break;
        case EngineType.bruteforce:
          engineName = 'standard';
          break;
      }
      final message = '$engineName engine not available';
      _onEngineSwitch?.call(message);
    }
  }
  
  // Check if AVX2 engine is available
  static bool? _avx2Available;
  bool get isAvx2EngineAvailable {
    if (_avx2Available != null) return _avx2Available!;
    
    try {
      final testEngine = Avx2Engine(width: 10, height: 10);
      testEngine.dispose();
      _avx2Available = true;
      return true;
    } catch (e) {
      _avx2Available = false;
      return false;
    }
  }
  
}