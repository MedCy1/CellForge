import 'dart:async';

class LifeEngine {
  late List<List<bool>> _grid;
  late int _width;
  late int _height;
  bool _isRunning = false;
  Timer? _timer;
  Duration _generationInterval = const Duration(milliseconds: 200);
  
  final StreamController<List<List<bool>>> _gridController = StreamController.broadcast();
  final StreamController<int> _generationController = StreamController.broadcast();
  
  int _generation = 0;
  
  Stream<List<List<bool>>> get gridStream => _gridController.stream;
  Stream<int> get generationStream => _generationController.stream;
  
  bool get isRunning => _isRunning;
  int get width => _width;
  int get height => _height;
  int get generation => _generation;
  Duration get generationInterval => _generationInterval;
  
  LifeEngine({int width = 50, int height = 30}) {
    _width = width;
    _height = height;
    _initializeGrid();
    // Envoyer l'état initial après un court délai pour s'assurer que les listeners sont prêts
    Future.microtask(() => _notifyGridChanged());
  }
  
  void _initializeGrid() {
    _grid = List.generate(
      _height, 
      (i) => List.generate(_width, (j) => false),
    );
    _generation = 0;
    _notifyGridChanged();
    _notifyGenerationChanged();
  }
  
  void _notifyGridChanged() {
    _gridController.add(_grid.map((row) => List<bool>.from(row)).toList());
  }
  
  void _notifyGenerationChanged() {
    _generationController.add(_generation);
  }
  
  bool getCellState(int x, int y) {
    if (x < 0 || x >= _width || y < 0 || y >= _height) {
      return false;
    }
    return _grid[y][x];
  }
  
  void setCellState(int x, int y, bool isAlive) {
    if (x >= 0 && x < _width && y >= 0 && y < _height) {
      _grid[y][x] = isAlive;
      _notifyGridChanged();
    }
  }
  
  void toggleCell(int x, int y) {
    setCellState(x, y, !getCellState(x, y));
  }
  
  void clearGrid() {
    _initializeGrid();
  }
  
  void randomizeGrid({double probability = 0.3}) {
    for (int y = 0; y < _height; y++) {
      for (int x = 0; x < _width; x++) {
        _grid[y][x] = (DateTime.now().millisecondsSinceEpoch + x + y) % 100 < (probability * 100);
      }
    }
    _notifyGridChanged();
  }
  
  void setGenerationInterval(Duration interval) {
    _generationInterval = interval;
    if (_isRunning) {
      stop();
      start();
    }
  }
  
  void start() {
    if (_isRunning) return;
    
    _isRunning = true;
    _timer = Timer.periodic(_generationInterval, (timer) {
      nextGeneration();
    });
  }
  
  void stop() {
    _isRunning = false;
    _timer?.cancel();
    _timer = null;
  }
  
  void toggle() {
    if (_isRunning) {
      stop();
    } else {
      start();
    }
  }
  
  void nextGeneration() {
    final newGrid = List.generate(
      _height, 
      (i) => List.generate(_width, (j) => false),
    );
    
    for (int y = 0; y < _height; y++) {
      for (int x = 0; x < _width; x++) {
        final neighbors = _countNeighbors(x, y);
        final isAlive = _grid[y][x];
        
        if (isAlive) {
          newGrid[y][x] = neighbors == 2 || neighbors == 3;
        } else {
          newGrid[y][x] = neighbors == 3;
        }
      }
    }
    
    _grid = newGrid;
    _generation++;
    _notifyGridChanged();
    _notifyGenerationChanged();
  }
  
  int _countNeighbors(int x, int y) {
    int count = 0;
    
    for (int dy = -1; dy <= 1; dy++) {
      for (int dx = -1; dx <= 1; dx++) {
        if (dx == 0 && dy == 0) continue;
        
        final nx = x + dx;
        final ny = y + dy;
        
        if (nx >= 0 && nx < _width && ny >= 0 && ny < _height) {
          if (_grid[ny][nx]) count++;
        }
      }
    }
    
    return count;
  }
  
  void loadPattern(List<List<bool>> pattern, {int? startX, int? startY}) {
    if (pattern.isEmpty) return;
    
    final patternHeight = pattern.length;
    final patternWidth = pattern[0].length;
    
    final offsetX = startX ?? (_width - patternWidth) ~/ 2;
    final offsetY = startY ?? (_height - patternHeight) ~/ 2;
    
    clearGrid();
    
    for (int y = 0; y < patternHeight; y++) {
      for (int x = 0; x < patternWidth; x++) {
        final targetX = offsetX + x;
        final targetY = offsetY + y;
        
        if (targetX >= 0 && targetX < _width && targetY >= 0 && targetY < _height) {
          _grid[targetY][targetX] = pattern[y][x];
        }
      }
    }
    
    _notifyGridChanged();
  }
  
  List<List<bool>> exportPattern() {
    return _grid.map((row) => List<bool>.from(row)).toList();
  }
  
  List<List<bool>> getCurrentGrid() {
    return _grid.map((row) => List<bool>.from(row)).toList();
  }
  
  void resizeGrid(int newWidth, int newHeight) {
    final oldGrid = _grid;
    final oldWidth = _width;
    final oldHeight = _height;
    
    _width = newWidth;
    _height = newHeight;
    _grid = List.generate(
      _height, 
      (i) => List.generate(_width, (j) => false),
    );
    
    final copyWidth = oldWidth < newWidth ? oldWidth : newWidth;
    final copyHeight = oldHeight < newHeight ? oldHeight : newHeight;
    
    for (int y = 0; y < copyHeight; y++) {
      for (int x = 0; x < copyWidth; x++) {
        _grid[y][x] = oldGrid[y][x];
      }
    }
    
    _notifyGridChanged();
  }
  
  void dispose() {
    stop();
    _gridController.close();
    _generationController.close();
  }
}