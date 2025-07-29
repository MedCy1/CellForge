import 'package:flutter/material.dart';
import '../core/engine/life_engine_controller.dart';

enum InteractionMode {
  none,
  drawing,  // Clic maintenu pour tracer
  panning,  // Pan pour déplacer la vue (grille infinie)
}

class GridInteractionController {
  final LifeEngineController engine;
  final bool isInfiniteGrid;
  
  // Callbacks pour conversion de coordonnées
  final Offset Function(Offset screenPos)? screenToWorld;
  final Offset Function(Offset screenPos)? screenToGrid;
  
  // État interne
  InteractionMode _currentMode = InteractionMode.none;
  Offset? _lastDrawPosition;
  bool _isDrawing = false;
  
  GridInteractionController({
    required this.engine,
    required this.isInfiniteGrid,
    this.screenToWorld,
    this.screenToGrid,
  });
  
  InteractionMode get currentMode => _currentMode;
  bool get isDrawing => _isDrawing;
  
  // Gestion des événements de tap
  void handleTapDown(TapDownDetails details) {
    _currentMode = InteractionMode.drawing;
    _isDrawing = true;
    _lastDrawPosition = details.localPosition;
    _toggleCellAtPosition(details.localPosition);
  }
  
  void handleTapUp(TapUpDetails details) {
    _currentMode = InteractionMode.none;
    _isDrawing = false;
    _lastDrawPosition = null;
  }
  
  void handleTapCancel() {
    _currentMode = InteractionMode.none;
    _isDrawing = false;
    _lastDrawPosition = null;
  }
  
  // Gestion du pan/drag
  void handlePanStart(DragStartDetails details) {
    _currentMode = InteractionMode.drawing;
    _isDrawing = true;
    _lastDrawPosition = details.localPosition;
    _toggleCellAtPosition(details.localPosition);
  }
  
  void handlePanUpdate(DragUpdateDetails details) {
    if (_currentMode == InteractionMode.drawing || _isDrawing) {
      _drawLine(_lastDrawPosition, details.localPosition);
      _lastDrawPosition = details.localPosition;
    }
  }
  
  void handlePanEnd(DragEndDetails details) {
    if (_currentMode == InteractionMode.drawing) {
      _isDrawing = false;
    }
    _currentMode = InteractionMode.none;
    _lastDrawPosition = null;
  }
  
  // Dessiner une ligne entre deux points
  void _drawLine(Offset? start, Offset end) {
    if (start == null) {
      _toggleCellAtPosition(end);
      return;
    }
    
    // Algorithme de Bresenham pour tracer une ligne
    final startCell = _positionToCell(start);
    final endCell = _positionToCell(end);
    
    if (startCell == null || endCell == null) return;
    
    final cells = _getLineCells(startCell, endCell);
    for (final cell in cells) {
      engine.setCellState(cell.dx.toInt(), cell.dy.toInt(), true);
    }
  }
  
  // Convertir position écran en cellule
  Offset? _positionToCell(Offset screenPos) {
    if (isInfiniteGrid && screenToWorld != null) {
      final worldPos = screenToWorld!(screenPos);
      return Offset(worldPos.dx.roundToDouble(), worldPos.dy.roundToDouble());
    } else if (!isInfiniteGrid && screenToGrid != null) {
      return screenToGrid!(screenPos);
    }
    return null;
  }
  
  // Obtenir toutes les cellules sur une ligne (Bresenham)
  List<Offset> _getLineCells(Offset start, Offset end) {
    final cells = <Offset>[];
    
    int x0 = start.dx.toInt();
    int y0 = start.dy.toInt();
    int x1 = end.dx.toInt();
    int y1 = end.dy.toInt();
    
    final dx = (x1 - x0).abs();
    final dy = (y1 - y0).abs();
    final sx = x0 < x1 ? 1 : -1;
    final sy = y0 < y1 ? 1 : -1;
    var err = dx - dy;
    
    while (true) {
      cells.add(Offset(x0.toDouble(), y0.toDouble()));
      
      if (x0 == x1 && y0 == y1) break;
      
      final e2 = 2 * err;
      if (e2 > -dy) {
        err -= dy;
        x0 += sx;
      }
      if (e2 < dx) {
        err += dx;
        y0 += sy;
      }
    }
    
    return cells;
  }
  
  // Toggle cellule à une position
  void _toggleCellAtPosition(Offset position) {
    final cell = _positionToCell(position);
    if (cell != null) {
      engine.toggleCell(cell.dx.toInt(), cell.dy.toInt());
    }
  }
  
  // Nettoyer les ressources
  void dispose() {
    _currentMode = InteractionMode.none;
    _isDrawing = false;
    _lastDrawPosition = null;
  }
}