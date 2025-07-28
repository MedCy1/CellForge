import 'package:flutter/material.dart';
import '../core/engine/life_engine_controller.dart';
import '../utils/memory_estimator.dart';
import 'grid_config_dialog.dart';

class LifeToolbar extends StatefulWidget {
  final LifeEngineController engine;
  
  const LifeToolbar({
    super.key,
    required this.engine,
  });

  @override
  State<LifeToolbar> createState() => _LifeToolbarState();
}

class _LifeToolbarState extends State<LifeToolbar> {
  bool _isRunning = false;
  int _generation = 0;
  double _speed = 200;

  @override
  void initState() {
    super.initState();
    widget.engine.generationStream.listen((generation) {
      if (mounted) {
        setState(() {
          _generation = generation;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _isRunning = widget.engine.isRunning;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton.filled(
                  onPressed: () {
                    widget.engine.toggle();
                    setState(() {
                      _isRunning = widget.engine.isRunning;
                    });
                  },
                  icon: Icon(_isRunning ? Icons.pause : Icons.play_arrow),
                  tooltip: _isRunning ? 'Pause' : 'Démarrer',
                ),
                IconButton(
                  onPressed: _isRunning ? null : () => widget.engine.nextGeneration(),
                  icon: const Icon(Icons.skip_next),
                  tooltip: 'Génération suivante',
                ),
                IconButton(
                  onPressed: () => widget.engine.clearGrid(),
                  icon: const Icon(Icons.clear_all),
                  tooltip: 'Effacer',
                ),
                IconButton(
                  onPressed: () => widget.engine.randomizeGrid(),
                  icon: const Icon(Icons.shuffle),
                  tooltip: 'Aléatoire',
                ),
                IconButton(
                  onPressed: () => _showGridConfigDialog(),
                  icon: const Icon(Icons.aspect_ratio),
                  tooltip: 'Configure Grid Size',
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.speed, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Slider(
                    value: _speed,
                    min: 50,
                    max: 1000,
                    divisions: 19,
                    label: '${_speed.round()}ms',
                    onChanged: (value) {
                      setState(() {
                        _speed = value;
                      });
                      widget.engine.setGenerationInterval(
                        Duration(milliseconds: value.round()),
                      );
                    },
                  ),
                ),
                Text('${_speed.round()}ms'),
              ],
            ),
            const SizedBox(height: 8),
            // Generation and grid info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Génération: $_generation',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Row(
                  children: [
                    const Icon(Icons.grid_on, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${widget.engine.width}×${widget.engine.height}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // Engine status and memory info
            _buildEngineStatus(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildEngineStatus() {
    final memoryUsage = MemoryEstimator.calculateMemoryUsage(
      widget.engine.width, 
      widget.engine.height,
    );
    
    Color statusColor;
    switch (memoryUsage.warningLevel) {
      case WarningLevel.safe:
        statusColor = Colors.green;
        break;
      case WarningLevel.caution:
        statusColor = Colors.orange;
        break;
      case WarningLevel.warning:
        statusColor = Colors.red.shade300;
        break;
      case WarningLevel.danger:
        statusColor = Colors.red.shade700;
        break;
    }
    
    return Column(
      children: [
        // Engine type
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  widget.engine.currentEngineType == EngineType.avx2
                      ? Icons.speed
                      : Icons.calculate,
                  size: 16,
                  color: widget.engine.currentEngineType == EngineType.avx2
                      ? Colors.blue
                      : (widget.engine.isAvx2EngineAvailable ? Colors.grey : Colors.orange),
                ),
                const SizedBox(width: 4),
                Text(
                  widget.engine.currentEngineType == EngineType.avx2
                      ? 'High-Perf'
                      : (widget.engine.isAvx2EngineAvailable ? 'Standard' : 'Standard*'),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: widget.engine.currentEngineType == EngineType.avx2
                        ? Colors.blue
                        : (widget.engine.isAvx2EngineAvailable ? Colors.grey : Colors.orange),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            // Memory usage
            Row(
              children: [
                Icon(
                  Icons.memory,
                  size: 16,
                  color: statusColor,
                ),
                const SizedBox(width: 4),
                Text(
                  memoryUsage.formattedTotal,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        
        // Show help text when AVX2 is not available
        if (!widget.engine.isAvx2EngineAvailable) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 12,
                color: Colors.orange,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '* Compile native library for high-performance mode',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.orange,
                    fontSize: 10,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
        
      ],
    );
  }
  
  void _showGridConfigDialog() {
    showDialog(
      context: context,
      builder: (context) => GridConfigDialog(engine: widget.engine),
    );
  }
}