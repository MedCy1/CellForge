import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'dart:ui' as ui;
import 'dart:math' as math;
import '../core/engine/life_engine_controller.dart';
import '../core/engine/sparse_list_engine.dart';

class InfiniteLifeGrid extends StatefulWidget {
  final LifeEngineController engine;
  
  const InfiniteLifeGrid({
    super.key,
    required this.engine,
  });

  @override
  State<InfiniteLifeGrid> createState() => _InfiniteLifeGridState();
}

class _InfiniteLifeGridState extends State<InfiniteLifeGrid> {
  Set<Offset> _liveCells = {};
  
  // Système de viewport infini
  double _viewportX = 0.0; // Position X du viewport dans la grille infinie
  double _viewportY = 0.0; // Position Y du viewport dans la grille infinie
  double _scale = 1.0; // Niveau de zoom
  final double _cellSize = 20.0; // Taille d'une cellule en pixels
  
  // Gestion des gestures
  Offset? _lastPanPoint;
  double _lastScale = 1.0;
  
  @override
  void initState() {
    super.initState();
    
    // Écouter les changements de la grille
    widget.engine.gridStream.listen((grid) {
      if (mounted && widget.engine.currentEngine is SparseListEngine) {
        final sparseEngine = widget.engine.currentEngine as SparseListEngine;
        setState(() {
          _liveCells = sparseEngine.getLiveCells();
        });
      }
    });
    
    // Initialiser avec les cellules actuelles
    if (widget.engine.currentEngine is SparseListEngine) {
      final sparseEngine = widget.engine.currentEngine as SparseListEngine;
      _liveCells = sparseEngine.getLiveCells();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.surface,
              Theme.of(context).colorScheme.surfaceContainerLowest,
            ],
          ),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Stack(
          children: [
            // Grille interactive infinie
            Positioned.fill(
              child: Listener(
                onPointerSignal: _handlePointerSignal,
                child: GestureDetector(
                  onTapDown: _handleTapDown,
                  onScaleStart: _handleScaleStart,
                  onScaleUpdate: _handleScaleUpdate,
                  onScaleEnd: _handleScaleEnd,
                  child: CustomPaint(
                    painter: InfiniteGridPainter(
                      liveCells: _liveCells,
                      colorScheme: Theme.of(context).colorScheme,
                      viewportX: _viewportX,
                      viewportY: _viewportY,
                      scale: _scale,
                      cellSize: _cellSize,
                    ),
                    size: Size.infinite,
                  ),
                ),
              ),
            ),
          
            // Indicateur de coordonnées  
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Grille infinie • ${_liveCells.length} cellules',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      'Position: (${_viewportX.toStringAsFixed(0)}, ${_viewportY.toStringAsFixed(0)}) • Zoom: ${_scale.toStringAsFixed(1)}x',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
          ],
        ),
      ),
    );
  }

  void _handlePointerSignal(PointerSignalEvent event) {
    if (event is PointerScrollEvent) {
      final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
      if (renderBox == null) return;
      
      final localPosition = renderBox.globalToLocal(event.position);
      final zoomDelta = event.scrollDelta.dy > 0 ? 0.9 : 1.1;
      
      // Zoomer vers le point sous la souris
      final worldPoint = _screenToWorld(localPosition);
      
      setState(() {
        _scale = (_scale * zoomDelta).clamp(0.1, 10.0);
      });
      
      // Ajuster la position pour garder le point sous la souris
      final newScreenPoint = _worldToScreen(worldPoint);
      final offset = localPosition - newScreenPoint;
      
      setState(() {
        _viewportX += offset.dx / (_cellSize * _scale);
        _viewportY += offset.dy / (_cellSize * _scale);
      });
    }
  }

  void _handleTapDown(TapDownDetails details) {
    final worldPos = _screenToWorld(details.localPosition);
    final cellX = worldPos.dx.round();
    final cellY = worldPos.dy.round();
    
    if (widget.engine.currentEngine is SparseListEngine) {
      widget.engine.toggleCell(cellX, cellY);
    }
  }

  void _handleScaleStart(ScaleStartDetails details) {
    _lastPanPoint = details.localFocalPoint;
    _lastScale = _scale;
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    if (details.pointerCount == 1) {
      // Pan uniquement
      if (_lastPanPoint != null) {
        final delta = details.localFocalPoint - _lastPanPoint!;
        setState(() {
          _viewportX -= delta.dx / (_cellSize * _scale);
          _viewportY -= delta.dy / (_cellSize * _scale);
        });
        _lastPanPoint = details.localFocalPoint;
      }
    } else {
      // Zoom avec pinch
      final newScale = (_lastScale * details.scale).clamp(0.1, 10.0);
      if (newScale != _scale) {
        final worldPoint = _screenToWorld(details.localFocalPoint);
        
        setState(() {
          _scale = newScale;
        });
        
        final newScreenPoint = _worldToScreen(worldPoint);
        final offset = details.localFocalPoint - newScreenPoint;
        
        setState(() {
          _viewportX += offset.dx / (_cellSize * _scale);
          _viewportY += offset.dy / (_cellSize * _scale);
        });
      }
    }
  }

  void _handleScaleEnd(ScaleEndDetails details) {
    _lastPanPoint = null;
  }

  // Convertir coordonnées écran vers monde infini
  Offset _screenToWorld(Offset screenPos) {
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return Offset.zero;
    
    final size = renderBox.size;
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    
    final worldX = _viewportX + (screenPos.dx - centerX) / (_cellSize * _scale);
    final worldY = _viewportY + (screenPos.dy - centerY) / (_cellSize * _scale);
    
    return Offset(worldX, worldY);
  }

  // Convertir coordonnées monde vers écran
  Offset _worldToScreen(Offset worldPos) {
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return Offset.zero;
    
    final size = renderBox.size;
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    
    final screenX = centerX + (worldPos.dx - _viewportX) * _cellSize * _scale;
    final screenY = centerY + (worldPos.dy - _viewportY) * _cellSize * _scale;
    
    return Offset(screenX, screenY);
  }
}

class InfiniteGridPainter extends CustomPainter {
  final Set<Offset> liveCells;
  final ColorScheme colorScheme;
  final double viewportX;
  final double viewportY;
  final double scale;
  final double cellSize;

  InfiniteGridPainter({
    required this.liveCells,
    required this.colorScheme,
    required this.viewportX,
    required this.viewportY,
    required this.scale,
    required this.cellSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final effectiveCellSize = cellSize * scale;
    
    // Pinceau pour les cellules vivantes avec gradient
    final alivePaint = Paint()
      ..shader = ui.Gradient.linear(
        const Offset(0, 0),
        Offset(effectiveCellSize, effectiveCellSize),
        [
          colorScheme.primary,
          colorScheme.primary.withValues(alpha: 0.8),
        ],
      );

    // Pinceau pour l'ombre des cellules
    final shadowPaint = Paint()
      ..color = colorScheme.shadow.withValues(alpha: 0.1)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1);


    // Dessiner le fond
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = Colors.transparent,
    );

    // Dessiner les lignes de grille si le zoom est suffisant
    if (effectiveCellSize > 4) {
      _drawGridLines(canvas, size);
    }

    // Dessiner les cellules vivantes visibles
    _drawLiveCells(canvas, size, alivePaint, shadowPaint);
    
    // Dessiner l'origine si elle est visible
    _drawOrigin(canvas, size);
  }
  
  void _drawGridLines(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = colorScheme.outline.withValues(alpha: math.min(0.3, scale * 0.15))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;
    
    final effectiveCellSize = cellSize * scale;
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    
    // Calculer les limites visibles de la grille
    final leftWorld = viewportX - (centerX / effectiveCellSize);
    final rightWorld = viewportX + (centerX / effectiveCellSize);
    final topWorld = viewportY - (centerY / effectiveCellSize);
    final bottomWorld = viewportY + (centerY / effectiveCellSize);
    
    final startX = leftWorld.floor();
    final endX = rightWorld.ceil();
    final startY = topWorld.floor();
    final endY = bottomWorld.ceil();
    
    // Limiter le nombre de lignes pour les performances
    final maxLines = 200;
    final stepX = math.max(1, ((endX - startX) / maxLines).ceil());
    final stepY = math.max(1, ((endY - startY) / maxLines).ceil());
    
    // Lignes verticales
    for (int x = startX; x <= endX; x += stepX) {
      final screenX = centerX + (x - viewportX) * effectiveCellSize;
      if (screenX >= -1 && screenX <= size.width + 1) {
        canvas.drawLine(
          Offset(screenX, 0),
          Offset(screenX, size.height),
          gridPaint,
        );
      }
    }
    
    // Lignes horizontales
    for (int y = startY; y <= endY; y += stepY) {
      final screenY = centerY + (y - viewportY) * effectiveCellSize;
      if (screenY >= -1 && screenY <= size.height + 1) {
        canvas.drawLine(
          Offset(0, screenY),
          Offset(size.width, screenY),
          gridPaint,
        );
      }
    }
  }
  
  void _drawLiveCells(Canvas canvas, Size size, Paint alivePaint, Paint shadowPaint) {
    final effectiveCellSize = cellSize * scale;
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    
    for (final cell in liveCells) {
      final screenX = centerX + (cell.dx - viewportX) * effectiveCellSize;
      final screenY = centerY + (cell.dy - viewportY) * effectiveCellSize;
      
      // Vérifier si la cellule est visible à l'écran
      if (screenX >= -effectiveCellSize && screenX <= size.width + effectiveCellSize &&
          screenY >= -effectiveCellSize && screenY <= size.height + effectiveCellSize) {
        
        final rect = Rect.fromLTWH(
          screenX + 0.5,
          screenY + 0.5,
          effectiveCellSize - 1,
          effectiveCellSize - 1,
        );
        
        // Dessiner l'ombre si suffisamment zoomé
        if (effectiveCellSize > 6) {
          final shadowRect = rect.translate(0.5, 0.5);
          canvas.drawRRect(
            RRect.fromRectAndRadius(shadowRect, Radius.circular(effectiveCellSize * 0.05)),
            shadowPaint,
          );
        }
        
        // Dessiner la cellule principale
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, Radius.circular(effectiveCellSize * 0.1)),
          alivePaint,
        );
      }
    }
  }
  
  void _drawOrigin(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    
    final originScreenX = centerX + (0 - viewportX) * cellSize * scale;
    final originScreenY = centerY + (0 - viewportY) * cellSize * scale;
    
    // Dessiner l'origine seulement si elle est proche de l'écran
    if (originScreenX >= -50 && originScreenX <= size.width + 50 &&
        originScreenY >= -50 && originScreenY <= size.height + 50) {
      
      final originPaint = Paint()
        ..color = colorScheme.primary.withValues(alpha: 0.4)
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke;
      
      // Croix pour marquer l'origine (0,0)
      final size = 10.0 * scale;
      canvas.drawLine(
        Offset(originScreenX - size, originScreenY),
        Offset(originScreenX + size, originScreenY),
        originPaint,
      );
      canvas.drawLine(
        Offset(originScreenX, originScreenY - size),
        Offset(originScreenX, originScreenY + size),
        originPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant InfiniteGridPainter oldDelegate) {
    return liveCells != oldDelegate.liveCells ||
           colorScheme != oldDelegate.colorScheme ||
           viewportX != oldDelegate.viewportX ||
           viewportY != oldDelegate.viewportY ||
           scale != oldDelegate.scale;
  }
}