import 'package:flutter/material.dart';
import '../core/engine/life_engine_controller.dart';
import '../core/engine/sparse_list_engine.dart';
import 'infinite_grid.dart';

class LifeGrid extends StatefulWidget {
  final LifeEngineController engine;
  
  const LifeGrid({
    super.key,
    required this.engine,
  });

  @override
  State<LifeGrid> createState() => _LifeGridState();
}

class _LifeGridState extends State<LifeGrid> {
  late List<List<bool>> _grid;
  
  @override
  void initState() {
    super.initState();
    // Initialiser avec la grille actuelle du moteur
    _grid = widget.engine.getCurrentGrid();
    
    widget.engine.gridStream.listen((grid) {
      if (mounted) {
        setState(() {
          _grid = grid;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Utiliser InfiniteLifeGrid seulement si le mode grille infinie est activé
    if (widget.engine.currentEngine is SparseListEngine && widget.engine.isInfiniteGrid) {
      return InfiniteLifeGrid(engine: widget.engine);
    }

    if (_grid.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InteractiveViewer(
        boundaryMargin: const EdgeInsets.all(20),
        minScale: 0.5,
        maxScale: 5.0,
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
          child: AspectRatio(
            aspectRatio: widget.engine.width / widget.engine.height,
            child: Stack(
              children: [
                CustomPaint(
                  painter: GridPainter(
                    grid: _grid,
                    width: widget.engine.width,
                    height: widget.engine.height,
                    colorScheme: Theme.of(context).colorScheme,
                  ),
                  child: GestureDetector(
                    onTapDown: (details) => _handleTap(details),
                    onPanUpdate: (details) => _handlePan(details),
                  ),
                ),
                
                // Overlay de coordonnées (optionnel)
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
                    child: Text(
                      '${widget.engine.width} × ${widget.engine.height}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleTap(TapDownDetails details) {
    _toggleCellAtPosition(details.localPosition);
  }

  void _handlePan(DragUpdateDetails details) {
    _toggleCellAtPosition(details.localPosition);
  }

  void _toggleCellAtPosition(Offset position) {
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    
    final size = renderBox.size;
    
    final cellWidth = size.width / widget.engine.width;
    final cellHeight = size.height / widget.engine.height;
    
    final x = (position.dx / cellWidth).floor();
    final y = (position.dy / cellHeight).floor();
    
    if (x >= 0 && x < widget.engine.width && y >= 0 && y < widget.engine.height) {
      widget.engine.setCellState(x, y, true);
    }
  }
}

class GridPainter extends CustomPainter {
  final List<List<bool>> grid;
  final int width;
  final int height;
  final ColorScheme colorScheme;

  GridPainter({
    required this.grid,
    required this.width,
    required this.height,
    required this.colorScheme,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cellWidth = size.width / width;
    final cellHeight = size.height / height;

    // Pinceau pour les cellules vivantes avec gradient
    final alivePaint = Paint()
      ..shader = LinearGradient(
        colors: [
          colorScheme.primary,
          colorScheme.primary.withValues(alpha: 0.8),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    // Pinceau pour l'ombre des cellules
    final shadowPaint = Paint()
      ..color = colorScheme.shadow.withValues(alpha: 0.1)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1);

    final backgroundPaint = Paint()
      ..color = Colors.transparent;

    final gridPaint = Paint()
      ..color = colorScheme.outline.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.3;

    // Draw background
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), backgroundPaint);

    // Draw alive cells with modern styling
    for (int y = 0; y < height && y < grid.length; y++) {
      for (int x = 0; x < width && x < grid[y].length; x++) {
        if (grid[y][x]) {
          final rect = Rect.fromLTWH(
            x * cellWidth + 0.5,
            y * cellHeight + 0.5,
            cellWidth - 1,
            cellHeight - 1,
          );
          
          // Draw shadow first (slightly offset)
          final shadowRect = rect.translate(0.5, 0.5);
          canvas.drawRRect(
            RRect.fromRectAndRadius(shadowRect, const Radius.circular(1)),
            shadowPaint,
          );
          
          // Draw main cell with rounded corners
          canvas.drawRRect(
            RRect.fromRectAndRadius(rect, const Radius.circular(1.5)),
            alivePaint,
          );
        }
      }
    }

    // Draw grid lines only if cells are reasonably large
    if (cellWidth > 3 && cellHeight > 3) {
      // Draw vertical lines
      for (int x = 0; x <= width; x++) {
        final xPos = x * cellWidth;
        canvas.drawLine(
          Offset(xPos, 0),
          Offset(xPos, size.height),
          gridPaint,
        );
      }

      // Draw horizontal lines
      for (int y = 0; y <= height; y++) {
        final yPos = y * cellHeight;
        canvas.drawLine(
          Offset(0, yPos),
          Offset(size.width, yPos),
          gridPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant GridPainter oldDelegate) {
    return grid != oldDelegate.grid || 
           colorScheme != oldDelegate.colorScheme;
  }
}