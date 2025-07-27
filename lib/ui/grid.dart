import 'package:flutter/material.dart';
import '../core/life_engine.dart';

class LifeGrid extends StatefulWidget {
  final LifeEngine engine;
  
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
    _grid = [];
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
    if (_grid.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return InteractiveViewer(
      boundaryMargin: const EdgeInsets.all(20),
      minScale: 0.5,
      maxScale: 5.0,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.outline,
            width: 1,
          ),
        ),
        child: AspectRatio(
          aspectRatio: widget.engine.width / widget.engine.height,
          child: CustomPaint(
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
        ),
      ),
    );
  }

  void _handleTap(TapDownDetails details) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final localPosition = renderBox.globalToLocal(details.globalPosition);
    _toggleCellAtPosition(localPosition);
  }

  void _handlePan(DragUpdateDetails details) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final localPosition = renderBox.globalToLocal(details.globalPosition);
    _toggleCellAtPosition(localPosition);
  }

  void _toggleCellAtPosition(Offset position) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
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

    final alivePaint = Paint()
      ..color = colorScheme.primary
      ..style = PaintingStyle.fill;

    final deadPaint = Paint()
      ..color = colorScheme.surface
      ..style = PaintingStyle.fill;

    final gridPaint = Paint()
      ..color = colorScheme.outline.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final rect = Rect.fromLTWH(
          x * cellWidth,
          y * cellHeight,
          cellWidth,
          cellHeight,
        );

        final isAlive = y < grid.length && x < grid[y].length ? grid[y][x] : false;
        canvas.drawRect(rect, isAlive ? alivePaint : deadPaint);
        canvas.drawRect(rect, gridPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant GridPainter oldDelegate) {
    return grid != oldDelegate.grid || 
           colorScheme != oldDelegate.colorScheme;
  }
}