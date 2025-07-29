import 'package:flutter/material.dart';
import 'grid_interaction_controller.dart';
import '../core/engine/life_engine_controller.dart';

class InteractiveGridWidget extends StatefulWidget {
  final LifeEngineController engine;
  final bool isInfiniteGrid;
  final Widget child;
  final Offset Function(Offset screenPos)? screenToWorld;
  final Offset Function(Offset screenPos)? screenToGrid;
  const InteractiveGridWidget({
    super.key,
    required this.engine,
    required this.isInfiniteGrid,
    required this.child,
    this.screenToWorld,
    this.screenToGrid,
  });

  @override
  State<InteractiveGridWidget> createState() => _InteractiveGridWidgetState();
}

class _InteractiveGridWidgetState extends State<InteractiveGridWidget> {
  late GridInteractionController _controller;

  @override
  void initState() {
    super.initState();
    _controller = GridInteractionController(
      engine: widget.engine,
      isInfiniteGrid: widget.isInfiniteGrid,
      screenToWorld: widget.screenToWorld,
      screenToGrid: widget.screenToGrid,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: _controller.handleTapDown,
      onTapUp: _controller.handleTapUp,
      onTapCancel: _controller.handleTapCancel,
      onPanStart: _controller.handlePanStart,
      onPanUpdate: _controller.handlePanUpdate,
      onPanEnd: _controller.handlePanEnd,
      child: widget.child,
    );
  }
}