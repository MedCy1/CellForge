import 'dart:ui';

/// Optimized integer point class for sparse grid operations
/// More efficient than Offset for integer coordinates
class IntPoint {
  final int x;
  final int y;
  
  const IntPoint(this.x, this.y);
  
  @override
  int get hashCode => x.hashCode ^ (y.hashCode << 16);
  
  @override
  bool operator ==(Object other) {
    return identical(this, other) || 
           (other is IntPoint && other.x == x && other.y == y);
  }
  
  /// Get all 8 neighbors efficiently
  List<IntPoint> get neighbors {
    return [
      IntPoint(x - 1, y - 1), IntPoint(x, y - 1), IntPoint(x + 1, y - 1),
      IntPoint(x - 1, y),                         IntPoint(x + 1, y),
      IntPoint(x - 1, y + 1), IntPoint(x, y + 1), IntPoint(x + 1, y + 1),
    ];
  }
  
  /// Convert to Offset for UI operations
  Offset toOffset() => Offset(x.toDouble(), y.toDouble());
  
  /// Create from Offset
  factory IntPoint.fromOffset(Offset offset) {
    return IntPoint(offset.dx.toInt(), offset.dy.toInt());
  }
  
  @override
  String toString() => 'IntPoint($x, $y)';
}

/// Optimized sparse grid using integer coordinates
class OptimizedSparseGrid {
  final Set<IntPoint> _liveCells = <IntPoint>{};
  final Map<IntPoint, int> _neighborCountCache = <IntPoint, int>{};
  bool _cacheValid = false;
  
  bool getCell(IntPoint pos) => _liveCells.contains(pos);
  
  void setCell(IntPoint pos, bool alive) {
    if (alive) {
      if (_liveCells.add(pos)) {
        _invalidateCache();
      }
    } else {
      if (_liveCells.remove(pos)) {
        _invalidateCache();
      }
    }
  }
  
  void toggleCell(IntPoint pos) {
    setCell(pos, !getCell(pos));
  }
  
  void clear() {
    _liveCells.clear();
    _invalidateCache();
  }
  
  Set<IntPoint> get liveCells => _liveCells;
  
  int get population => _liveCells.length;
  
  void _invalidateCache() {
    _cacheValid = false;
    _neighborCountCache.clear();
  }
  
  /// Get all candidate cells for next generation (live cells + their neighbors)
  Set<IntPoint> getCandidateCells() {
    final candidates = <IntPoint>{};
    
    for (final cell in _liveCells) {
      candidates.add(cell);
      candidates.addAll(cell.neighbors);
    }
    
    return candidates;
  }
  
  /// Count live neighbors for a position
  int countLiveNeighbors(IntPoint pos) {
    if (_cacheValid && _neighborCountCache.containsKey(pos)) {
      return _neighborCountCache[pos]!;
    }
    
    int count = 0;
    for (final neighbor in pos.neighbors) {
      if (_liveCells.contains(neighbor)) {
        count++;
      }
    }
    
    _neighborCountCache[pos] = count;
    return count;
  }
  
  /// Get bounds of live cells
  ({int minX, int maxX, int minY, int maxY})? getBounds() {
    if (_liveCells.isEmpty) return null;
    
    final first = _liveCells.first;
    int minX = first.x, maxX = first.x;
    int minY = first.y, maxY = first.y;
    
    for (final cell in _liveCells) {
      if (cell.x < minX) {
        minX = cell.x;
      } else if (cell.x > maxX) {
        maxX = cell.x;
      }
      if (cell.y < minY) {
        minY = cell.y;
      } else if (cell.y > maxY) {
        maxY = cell.y;
      }
    }
    
    return (minX: minX, maxX: maxX, minY: minY, maxY: maxY);
  }
  
  /// Convert to 2D grid for display
  List<List<bool>> toGrid({required int width, required int height, int offsetX = 0, int offsetY = 0}) {
    final result = List.generate(
      height,
      (y) => List.filled(width, false),
    );
    
    for (final cell in _liveCells) {
      final x = cell.x - offsetX;
      final y = cell.y - offsetY;
      if (x >= 0 && x < width && y >= 0 && y < height) {
        result[y][x] = true;
      }
    }
    
    return result;
  }
  
  /// Performance statistics
  Map<String, dynamic> getStats() {
    return {
      'liveCells': _liveCells.length,
      'cachedNeighborCounts': _neighborCountCache.length,
      'cacheValid': _cacheValid,
    };
  }
}