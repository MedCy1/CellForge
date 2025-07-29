import 'dart:async';
import 'dart:ui';
import 'dart:math';
import 'i_life_engine.dart';
import '../infinite_grid.dart';

class SparseListEngine implements ILifeEngine {
  final InfiniteGrid _grid = InfiniteGrid();
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
    // En mode grille limitée, retourner false pour les cellules hors limites
    if (!_isInfinite && (x < 0 || x >= _width || y < 0 || y >= _height)) {
      return false;
    }
    return _grid.getCell(Offset(x.toDouble(), y.toDouble()));
  }
  
  @override
  void setCellState(int x, int y, bool isAlive) {
    // En mode grille limitée, ignorer les cellules hors limites
    if (!_isInfinite && (x < 0 || x >= _width || y < 0 || y >= _height)) {
      return;
    }
    _grid.setCell(Offset(x.toDouble(), y.toDouble()), isAlive);
    _notifyGridChanged();
  }
  
  @override
  void toggleCell(int x, int y) {
    // En mode grille limitée, ignorer les cellules hors limites
    if (!_isInfinite && (x < 0 || x >= _width || y < 0 || y >= _height)) {
      return;
    }
    _grid.toggleCell(Offset(x.toDouble(), y.toDouble()));
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
            _grid.setCell(Offset(x.toDouble(), y.toDouble()), true);
          }
        }
      }
    } else {
      // Mode grille limitée : randomiser dans les limites
      for (int y = 0; y < _height; y++) {
        for (int x = 0; x < _width; x++) {
          if (random.nextDouble() < probability) {
            _grid.setCell(Offset(x.toDouble(), y.toDouble()), true);
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
    final liveCells = _grid.getLiveCells();
    if (liveCells.isEmpty) return;
    
    final neighborCounts = <Offset, int>{};
    
    for (final cell in liveCells) {
      for (int dy = -1; dy <= 1; dy++) {
        for (int dx = -1; dx <= 1; dx++) {
          if (dx == 0 && dy == 0) continue;
          
          final neighbor = Offset(cell.dx + dx, cell.dy + dy);
          
          // En mode grille limitée, ignorer les voisins hors limites
          if (!_isInfinite && !_isInBounds(neighbor)) continue;
          
          neighborCounts[neighbor] = (neighborCounts[neighbor] ?? 0) + 1;
        }
      }
    }
    
    final newGrid = InfiniteGrid();
    
    for (final entry in neighborCounts.entries) {
      final pos = entry.key;
      final neighbors = entry.value;
      final isAlive = _grid.getCell(pos);
      
      // En mode grille limitée, ne créer des cellules que dans les limites
      if (!_isInfinite && !_isInBounds(pos)) continue;
      
      if (isAlive) {
        if (neighbors == 2 || neighbors == 3) {
          newGrid.setCell(pos, true);
        }
      } else {
        if (neighbors == 3) {
          newGrid.setCell(pos, true);
        }
      }
    }
    
    _grid.clear();
    for (final cell in newGrid.getLiveCells()) {
      _grid.setCell(cell, true);
    }
    
    _generation++;
    _notifyGridChanged();
    _notifyGenerationChanged();
  }
  
  bool _isInBounds(Offset pos) {
    final x = pos.dx.toInt();
    final y = pos.dy.toInt();
    return x >= 0 && x < _width && y >= 0 && y < _height;
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
          
          // En mode grille limitée, ne placer que les cellules dans les limites
          if (_isInfinite || (cellX >= 0 && cellX < _width && cellY >= 0 && cellY < _height)) {
            _grid.setCell(Offset(cellX.toDouble(), cellY.toDouble()), true);
          }
        }
      }
    }
    
    _notifyGridChanged();
  }
  
  @override
  List<List<bool>> exportPattern() {
    if (_isInfinite) {
      // Mode infini : exporter selon les bounds des cellules vivantes
      final bounds = _grid.getBounds();
      if (bounds == Rect.zero) {
        return [[]];
      }
      
      final minX = bounds.left.toInt();
      final maxX = bounds.right.toInt();
      final minY = bounds.top.toInt();
      final maxY = bounds.bottom.toInt();
      
      final width = maxX - minX + 1;
      final height = maxY - minY + 1;
      
      final result = List.generate(
        height,
        (y) => List.generate(width, (x) => false),
      );
      
      for (final cell in _grid.getLiveCells()) {
        final x = cell.dx.toInt() - minX;
        final y = cell.dy.toInt() - minY;
        if (x >= 0 && x < width && y >= 0 && y < height) {
          result[y][x] = true;
        }
      }
      
      return result;
    } else {
      // Mode grille fixe : exporter selon les dimensions définies
      final result = List.generate(
        _height,
        (y) => List.generate(_width, (x) => false),
      );
      
      for (final cell in _grid.getLiveCells()) {
        final x = cell.dx.toInt();
        final y = cell.dy.toInt();
        if (x >= 0 && x < _width && y >= 0 && y < _height) {
          result[y][x] = true;
        }
      }
      
      return result;
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
    
    // Supprimer les cellules qui sont maintenant hors limites
    final cellsToRemove = <Offset>[];
    for (final cell in _grid.getLiveCells()) {
      final x = cell.dx.toInt();
      final y = cell.dy.toInt();
      if (x < 0 || x >= _width || y < 0 || y >= _height) {
        cellsToRemove.add(cell);
      }
    }
    
    for (final cell in cellsToRemove) {
      _grid.setCell(cell, false);
    }
    
    _notifyGridChanged();
  }
  
  Set<Offset> getLiveCells() {
    return _grid.getLiveCells();
  }
  
  void setInfiniteMode(bool infinite) {
    _isInfinite = infinite;
    if (infinite) {
      _width = 1000; // Valeurs par défaut pour le mode infini
      _height = 1000;
    }
    _notifyGridChanged();
  }
  
  bool get isInfinite => _isInfinite;
  
  @override
  void dispose() {
    stop();
    _gridController.close();
    _generationController.close();
  }
}