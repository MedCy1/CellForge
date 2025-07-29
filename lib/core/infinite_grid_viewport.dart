import 'dart:ui';
import 'dart:math' as math;

class InfiniteGridViewport {
  double _centerX = 0.0;
  double _centerY = 0.0;
  double _zoom = 20.0; // Pixels per cell
  
  static const double minZoom = 2.0;
  static const double maxZoom = 100.0;
  static const double defaultZoom = 20.0;
  
  double get centerX => _centerX;
  double get centerY => _centerY;
  double get zoom => _zoom;
  
  void setCenter(double x, double y) {
    _centerX = x;
    _centerY = y;
  }
  
  void moveBy(double deltaX, double deltaY) {
    _centerX += deltaX / _zoom;
    _centerY += deltaY / _zoom;
  }
  
  void setZoom(double newZoom) {
    _zoom = math.max(minZoom, math.min(maxZoom, newZoom));
  }
  
  void zoomBy(double factor, [Offset? focalPoint]) {
    if (focalPoint != null) {
      final worldFocal = screenToWorld(focalPoint);
      setZoom(_zoom * factor);
      final newScreenFocal = worldToScreen(worldFocal);
      final offset = focalPoint - newScreenFocal;
      moveBy(offset.dx, offset.dy);
    } else {
      setZoom(_zoom * factor);
    }
  }
  
  Offset worldToScreen(Offset worldPoint) {
    final screenX = (worldPoint.dx - _centerX) * _zoom;
    final screenY = (worldPoint.dy - _centerY) * _zoom;
    return Offset(screenX, screenY);
  }
  
  Offset screenToWorld(Offset screenPoint) {
    final worldX = screenPoint.dx / _zoom + _centerX;
    final worldY = screenPoint.dy / _zoom + _centerY;
    return Offset(worldX, worldY);
  }
  
  Rect getVisibleWorldBounds(Size screenSize) {
    final halfWidth = screenSize.width / (2 * _zoom);
    final halfHeight = screenSize.height / (2 * _zoom);
    
    return Rect.fromLTRB(
      _centerX - halfWidth,
      _centerY - halfHeight,
      _centerX + halfWidth,
      _centerY + halfHeight,
    );
  }
  
  List<Offset> getVisibleCells(Size screenSize, Set<Offset> liveCells) {
    final bounds = getVisibleWorldBounds(screenSize);
    
    return liveCells.where((cell) {
      return cell.dx >= bounds.left.floor() &&
             cell.dx <= bounds.right.ceil() &&
             cell.dy >= bounds.top.floor() &&
             cell.dy <= bounds.bottom.ceil();
    }).toList();
  }
  
  void resetToDefault() {
    _centerX = 0.0;
    _centerY = 0.0;
    _zoom = defaultZoom;
  }
  
  void fitToContent(Set<Offset> liveCells, Size screenSize, {double padding = 0.1}) {
    if (liveCells.isEmpty) {
      resetToDefault();
      return;
    }
    
    double minX = double.infinity;
    double maxX = double.negativeInfinity;
    double minY = double.infinity;
    double maxY = double.negativeInfinity;
    
    for (final cell in liveCells) {
      minX = math.min(minX, cell.dx);
      maxX = math.max(maxX, cell.dx);
      minY = math.min(minY, cell.dy);
      maxY = math.max(maxY, cell.dy);
    }
    
    final contentWidth = maxX - minX + 1;
    final contentHeight = maxY - minY + 1;
    
    final zoomX = screenSize.width / (contentWidth * (1 + padding));
    final zoomY = screenSize.height / (contentHeight * (1 + padding));
    
    setZoom(math.min(zoomX, zoomY));
    setCenter((minX + maxX) / 2, (minY + maxY) / 2);
  }
  
  Map<String, dynamic> toJson() {
    return {
      'centerX': _centerX,
      'centerY': _centerY,
      'zoom': _zoom,
    };
  }
  
  void fromJson(Map<String, dynamic> json) {
    _centerX = json['centerX']?.toDouble() ?? 0.0;
    _centerY = json['centerY']?.toDouble() ?? 0.0;
    _zoom = json['zoom']?.toDouble() ?? defaultZoom;
    setZoom(_zoom); // Apply constraints
  }
}