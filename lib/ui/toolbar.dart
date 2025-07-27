import 'package:flutter/material.dart';
import '../core/life_engine.dart';

class LifeToolbar extends StatefulWidget {
  final LifeEngine engine;
  
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
          ],
        ),
      ),
    );
  }
}