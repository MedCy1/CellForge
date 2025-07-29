import 'dart:ui';

class InfiniteGrid {
  final Set<Offset> _liveCells = <Offset>{};

  bool getCell(Offset pos) {
    return _liveCells.contains(pos);
  }

  void setCell(Offset pos, bool alive) {
    if (alive) {
      _liveCells.add(pos);
    } else {
      _liveCells.remove(pos);
    }
  }

  void toggleCell(Offset pos) {
    if (_liveCells.contains(pos)) {
      _liveCells.remove(pos);
    } else {
      _liveCells.add(pos);
    }
  }

  void clear() {
    _liveCells.clear();
  }

  Set<Offset> getLiveCells() {
    return Set<Offset>.from(_liveCells);
  }

  Rect getBounds() {
    if (_liveCells.isEmpty) {
      return Rect.zero;
    }

    double minX = double.infinity;
    double maxX = double.negativeInfinity;
    double minY = double.infinity;
    double maxY = double.negativeInfinity;

    for (final cell in _liveCells) {
      if (cell.dx < minX) minX = cell.dx;
      if (cell.dx > maxX) maxX = cell.dx;
      if (cell.dy < minY) minY = cell.dy;
      if (cell.dy > maxY) maxY = cell.dy;
    }

    return Rect.fromLTRB(minX, minY, maxX, maxY);
  }

  int getPopulation() {
    return _liveCells.length;
  }
}