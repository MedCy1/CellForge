import 'dart:async';
import 'dart:ffi' as ffi;
import 'dart:typed_data';
import 'i_life_engine.dart';
import 'ffi/avx2_engine.dart';

class Avx2Engine implements ILifeEngine {
  late Uint8List _grid;
  late Uint8List _bufferGrid;
  late int _width;
  late int _height;
  bool _isRunning = false;
  Timer? _timer;
  Duration _generationInterval = const Duration(milliseconds: 200);
  
  final StreamController<List<List<bool>>> _gridController = StreamController.broadcast();
  final StreamController<int> _generationController = StreamController.broadcast();
  
  int _generation = 0;
  bool _useNativeEngine = false;

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

  Avx2Engine({int width = 50, int height = 30}) {
    // Initialize FFI library
    try {
      Avx2EngineFFI.initialize();
      _useNativeEngine = true;
    } catch (e) {
      // Native engine fallback - will use Dart implementation
      _useNativeEngine = false;
    }
    
    _width = width;
    _height = height;
    _initializeGrid();
    Future.microtask(() => _notifyGridChanged());
  }

  void _initializeGrid() {
    final size = _width * _height;
    _grid = Uint8List(size);
    _bufferGrid = Uint8List(size);
    // Initialize all cells to 0 (dead)
    _grid.fillRange(0, size, 0);
    _bufferGrid.fillRange(0, size, 0);
    _generation = 0;
    _notifyGridChanged();
    _notifyGenerationChanged();
  }

  void _notifyGridChanged() {
    if (!_gridController.isClosed) {
      _gridController.add(_flatToGrid(_grid));
    }
  }

  void _notifyGenerationChanged() {
    if (!_generationController.isClosed) {
      _generationController.add(_generation);
    }
  }

  // Convert flat Uint8List to 2D List<List<bool>> with better performance
  List<List<bool>> _flatToGrid(Uint8List flat) {
    final grid = List<List<bool>>.generate(
      _height, 
      (y) => List<bool>.generate(
        _width, 
        (x) => flat[y * _width + x] != 0,
      ),
    );
    return grid;
  }

  // Get 1D index from 2D coordinates
  int _getIndex(int x, int y) {
    if (x < 0 || x >= _width || y < 0 || y >= _height) {
      return -1;
    }
    return y * _width + x;
  }

  @override
  bool getCellState(int x, int y) {
    final index = _getIndex(x, y);
    if (index == -1) return false;
    return _grid[index] != 0;
  }

  @override
  void setCellState(int x, int y, bool isAlive) {
    final index = _getIndex(x, y);
    if (index != -1) {
      _grid[index] = isAlive ? 1 : 0;
      _notifyGridChanged();
    }
  }

  @override
  void toggleCell(int x, int y) {
    setCellState(x, y, !getCellState(x, y));
  }

  @override
  void clearGrid() {
    _initializeGrid();
  }

  @override
  void randomizeGrid({double probability = 0.3}) {
    final random = DateTime.now().millisecondsSinceEpoch;
    for (int i = 0; i < _grid.length; i++) {
      // Simple pseudo-random number generator
      final seed = (random + i) * 1664525 + 1013904223;
      _grid[i] = ((seed % 100) / 100.0 < probability) ? 1 : 0;
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
    if (_useNativeEngine) {
      _nextGenerationNative();
    } else {
      _nextGenerationDart();
    }
    
    _generation++;
    _notifyGridChanged();
    _notifyGenerationChanged();
  }
  
  void _nextGenerationNative() {
    // Convert Uint8List to FFI pointer
    final pointer = Avx2FFIHelper.uint8ListToPointer(_grid);
    
    try {
      // Call native avxStep function
      avxStep(pointer, _width, _height);
      
      // Copy result back to our Uint8List
      for (int i = 0; i < _grid.length; i++) {
        _grid[i] = pointer[i];
      }
    } finally {
      // Always free the pointer
      Avx2FFIHelper.freePointer(pointer);
    }
  }
  
  void _nextGenerationDart() {
    // Dart fallback with double-buffering optimization
    final width = _width;
    final height = _height;
    
    // Process each cell with better memory access patterns
    for (int y = 0; y < height; y++) {
      final rowOffset = y * width;
      for (int x = 0; x < width; x++) {
        final index = rowOffset + x;
        final neighbors = _countNeighborsFast(x, y);
        final currentCell = _grid[index];
        
        // Apply Conway's Game of Life rules
        if (currentCell != 0) {
          // Live cell: survives with 2 or 3 neighbors
          _bufferGrid[index] = (neighbors == 2 || neighbors == 3) ? 1 : 0;
        } else {
          // Dead cell: becomes alive with exactly 3 neighbors
          _bufferGrid[index] = (neighbors == 3) ? 1 : 0;
        }
      }
    }
    
    // Swap grids using references (no copying)
    final temp = _grid;
    _grid = _bufferGrid;
    _bufferGrid = temp;
  }
  
  // Optimized neighbor counting with bounds checking
  int _countNeighborsFast(int x, int y) {
    int count = 0;
    final width = _width;
    final height = _height;
    
    // Calculate bounds to avoid repeated checks
    final minX = x > 0 ? x - 1 : 0;
    final maxX = x < width - 1 ? x + 1 : width - 1;
    final minY = y > 0 ? y - 1 : 0;
    final maxY = y < height - 1 ? y + 1 : height - 1;
    
    // Count neighbors with unrolled loop for better performance
    for (int ny = minY; ny <= maxY; ny++) {
      final rowOffset = ny * width;
      for (int nx = minX; nx <= maxX; nx++) {
        if (nx == x && ny == y) continue; // Skip center cell
        count += _grid[rowOffset + nx];
      }
    }
    
    return count;
  }

  @override
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
          final index = targetY * _width + targetX;
          _grid[index] = pattern[y][x] ? 1 : 0;
        }
      }
    }

    _notifyGridChanged();
  }

  @override
  List<List<bool>> exportPattern() {
    return _flatToGrid(_grid);
  }

  @override
  List<List<bool>> getCurrentGrid() {
    return _flatToGrid(_grid);
  }

  @override
  void resizeGrid(int newWidth, int newHeight) {
    final oldGrid = Uint8List.fromList(_grid);
    final oldWidth = _width;
    final oldHeight = _height;

    _width = newWidth;
    _height = newHeight;
    final newSize = _width * _height;
    _grid = Uint8List(newSize);
    _bufferGrid = Uint8List(newSize);
    _grid.fillRange(0, newSize, 0);
    _bufferGrid.fillRange(0, newSize, 0);

    final copyWidth = oldWidth < newWidth ? oldWidth : newWidth;
    final copyHeight = oldHeight < newHeight ? oldHeight : newHeight;

    // Optimized copying with better memory access patterns
    for (int y = 0; y < copyHeight; y++) {
      final oldRowOffset = y * oldWidth;
      final newRowOffset = y * newWidth;
      for (int x = 0; x < copyWidth; x++) {
        _grid[newRowOffset + x] = oldGrid[oldRowOffset + x];
      }
    }

    _notifyGridChanged();
  }

  @override
  void dispose() {
    stop();
    _gridController.close();
    _generationController.close();
  }
}