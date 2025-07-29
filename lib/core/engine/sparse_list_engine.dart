import 'dart:async';
import 'dart:math';
import 'i_life_engine.dart';
import '../data_structures/int_point.dart';

/// High-performance sparse engine using optimized data structures
class SparseListEngine implements ILifeEngine {
  final OptimizedSparseGrid _grid = OptimizedSparseGrid();
  bool _isRunning = false;
  Timer? _timer;
  Duration _generationInterval = const Duration(milliseconds: 200);
  int _generation = 0;
  int _width = 1000;
  int _height = 1000;
  bool _isInfinite = false;
  
  final StreamController<List<List<bool>>> _gridController = StreamController.broadcast();
  final StreamController<int> _generationController = StreamController.broadcast();
  
  @override
  Stream<List<List<bool>>> get gridStream => _gridController.stream;
  @override
  Stream<int> get generationStream => _generationController.stream;
  
  @override
  bool get isRunning => _isRunning;
  @override
  int get width => _width;
  @override
  int get height => _height;
  @override
  int get generation => _generation;
  @override
  Duration get generationInterval => _generationInterval;
  
  SparseListEngine({int? width, int? height, bool infinite = false}) {
    if (width != null) _width = width;
    if (height != null) _height = height;
    _isInfinite = infinite;
    Future.microtask(() => _notifyGridChanged());
  }
  
  void _notifyGridChanged() {
    if (!_gridController.isClosed) {
      _gridController.add(getCurrentGrid());
    }
  }
  
  void _notifyGenerationChanged() {
    if (!_generationController.isClosed) {
      _generationController.add(_generation);
    }
  }
  
  @override
  bool getCellState(int x, int y) {
    if (!_isInfinite && (x < 0 || x >= _width || y < 0 || y >= _height)) {
      return false;
    }
    return _grid.getCell(IntPoint(x, y));
  }
  
  @override
  void setCellState(int x, int y, bool isAlive) {
    if (!_isInfinite && (x < 0 || x >= _width || y < 0 || y >= _height)) {
      return;
    }
    _grid.setCell(IntPoint(x, y), isAlive);
    _notifyGridChanged();
  }
  
  @override
  void toggleCell(int x, int y) {
    if (!_isInfinite && (x < 0 || x >= _width || y < 0 || y >= _height)) {
      return;
    }
    _grid.toggleCell(IntPoint(x, y));
    _notifyGridChanged();
  }
  
  @override
  void clearGrid() {
    _grid.clear();
    _generation = 0;
    _notifyGridChanged();
    _notifyGenerationChanged();
  }
  
  @override
  void randomizeGrid({double probability = 0.3}) {
    clearGrid();
    final random = Random();
    
    if (_isInfinite) {
      // Mode infini : randomiser dans une zone centrale
      for (int y = -25; y < 25; y++) {
        for (int x = -25; x < 25; x++) {
          if (random.nextDouble() < probability) {
            _grid.setCell(IntPoint(x, y), true);
          }
        }
      }
    } else {
      // Mode grille limitée : randomiser dans les limites
      for (int y = 0; y < _height; y++) {
        for (int x = 0; x < _width; x++) {
          if (random.nextDouble() < probability) {
            _grid.setCell(IntPoint(x, y), true);
          }
        }
      }
    }
    _notifyGridChanged();
  }
  
  @override
  void setGenerationInterval(Duration interval) {
    _generationInterval = interval;
    if (_isRunning) {
      stop();
      start();
    }
  }
  
  @override
  void start() {
    if (_isRunning) return;
    
    _isRunning = true;
    _timer = Timer.periodic(_generationInterval, (timer) {
      nextGeneration();
    });
  }
  
  @override
  void stop() {
    _isRunning = false;
    _timer?.cancel();
    _timer = null;
  }
  
  @override
  void toggle() {
    if (_isRunning) {
      stop();
    } else {
      start();
    }
  }
  
  @override
  void nextGeneration() {
    if (_grid.population == 0) return;
    
    // Optimisation ultra-rapide : une seule passe sur tous les candidats
    final candidates = _grid.getCandidateCells();
    final newGrid = OptimizedSparseGrid();
    
    for (final pos in candidates) {
      // Mode grille limitée : ignorer les positions hors limites
      if (!_isInfinite && !_isInBounds(pos)) continue;
      
      final neighbors = _grid.countLiveNeighbors(pos);
      final isAlive = _grid.getCell(pos);
      
      // Règles de Conway optimisées
      if ((isAlive && (neighbors == 2 || neighbors == 3)) ||
          (!isAlive && neighbors == 3)) {
        newGrid.setCell(pos, true);
      }
    }
    
    // Remplacement ultra-rapide de la grille
    _grid.clear();
    for (final cell in newGrid.liveCells) {
      _grid.setCell(cell, true);
    }
    
    _generation++;
    _notifyGridChanged();
    _notifyGenerationChanged();
  }
  
  bool _isInBounds(IntPoint pos) {
    return pos.x >= 0 && pos.x < _width && pos.y >= 0 && pos.y < _height;
  }
  
  @override
  void loadPattern(List<List<bool>> pattern, {int? startX, int? startY}) {
    if (pattern.isEmpty) return;
    
    final patternHeight = pattern.length;
    final patternWidth = pattern[0].length;
    
    final offsetX = startX ?? -patternWidth ~/ 2;
    final offsetY = startY ?? -patternHeight ~/ 2;
    
    clearGrid();
    
    for (int y = 0; y < patternHeight; y++) {
      for (int x = 0; x < patternWidth; x++) {
        if (pattern[y][x]) {
          final cellX = offsetX + x;
          final cellY = offsetY + y;
          
          if (_isInfinite || (cellX >= 0 && cellX < _width && cellY >= 0 && cellY < _height)) {
            _grid.setCell(IntPoint(cellX, cellY), true);
          }
        }
      }
    }
    
    _notifyGridChanged();
  }
  
  @override
  List<List<bool>> exportPattern() {
    if (_isInfinite) {
      final bounds = _grid.getBounds();
      if (bounds == null) {
        return [[]];
      }
      
      final width = bounds.maxX - bounds.minX + 1;
      final height = bounds.maxY - bounds.minY + 1;
      
      return _grid.toGrid(
        width: width,
        height: height,
        offsetX: bounds.minX,
        offsetY: bounds.minY,
      );
    } else {
      return _grid.toGrid(width: _width, height: _height);
    }
  }
  
  @override
  List<List<bool>> getCurrentGrid() {
    return exportPattern();
  }
  
  @override
  void resizeGrid(int newWidth, int newHeight) {
    _width = newWidth;
    _height = newHeight;
    _isInfinite = false;
    
    // Supprimer les cellules hors limites de manière optimisée
    final cellsToRemove = <IntPoint>[];
    
    for (final cell in _grid.liveCells) {
      if (cell.x < 0 || cell.x >= _width || cell.y < 0 || cell.y >= _height) {
        cellsToRemove.add(cell);
      }
    }
    
    for (final cell in cellsToRemove) {
      _grid.setCell(cell, false);
    }
    
    _notifyGridChanged();
  }
  
  Set<IntPoint> getLiveCells() {
    return _grid.liveCells;
  }
  
  void setInfiniteMode(bool infinite) {
    _isInfinite = infinite;
    if (infinite) {
      _width = 1000;
      _height = 1000;
    }
    _notifyGridChanged();
  }
  
  bool get isInfinite => _isInfinite;
  
  /// Obtenir les statistiques de performance
  Map<String, dynamic> getPerformanceStats() {
    return _grid.getStats();
  }
  
  @override
  void dispose() {
    stop();
    _gridController.close();
    _generationController.close();
  }
}