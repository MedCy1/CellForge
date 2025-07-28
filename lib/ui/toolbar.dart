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
      elevation: 2,
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Titre de section avec une ligne de séparation élégante
            Row(
              children: [
                Icon(
                  Icons.tune,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Contrôles',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    height: 1,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Boutons principaux avec design amélioré
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Play/Pause principal
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: (_isRunning ? Colors.orange : Theme.of(context).colorScheme.primary)
                            .withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton.filled(
                    onPressed: () {
                      widget.engine.toggle();
                      setState(() {
                        _isRunning = widget.engine.isRunning;
                      });
                    },
                    icon: Icon(
                      _isRunning ? Icons.pause : Icons.play_arrow,
                      size: 28,
                    ),
                    tooltip: _isRunning ? 'Pause' : 'Démarrer',
                    style: IconButton.styleFrom(
                      backgroundColor: _isRunning ? Colors.orange : Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
                
                // Autres contrôles avec style uniforme
                _buildControlButton(
                  onPressed: _isRunning ? null : () => widget.engine.nextGeneration(),
                  icon: Icons.skip_next,
                  tooltip: 'Génération suivante',
                  enabled: !_isRunning,
                ),
                _buildControlButton(
                  onPressed: () => widget.engine.clearGrid(),
                  icon: Icons.clear_all,
                  tooltip: 'Effacer',
                ),
                _buildControlButton(
                  onPressed: () => widget.engine.randomizeGrid(),
                  icon: Icons.shuffle,
                  tooltip: 'Aléatoire',
                ),
                _buildControlButton(
                  onPressed: () => _showGridConfigDialog(),
                  icon: Icons.aspect_ratio,
                  tooltip: 'Configurer la grille',
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Section vitesse avec design amélioré
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.speed,
                        size: 18,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Vitesse',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${_speed.round()}ms',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Slider(
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
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Statistiques avec design amélioré
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHigh.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatItem(
                        icon: Icons.refresh,
                        label: 'Génération',
                        value: '$_generation',
                        context: context,
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                      ),
                      _buildStatItem(
                        icon: Icons.grid_on,
                        label: 'Grille',
                        value: '${widget.engine.width}×${widget.engine.height}',
                        context: context,
                      ),
                    ],
                  ),
                  // Engine status et memory info intégrés
                  _buildEngineStatus(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildControlButton({
    required VoidCallback? onPressed,
    required IconData icon,
    required String tooltip,
    bool enabled = true,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: enabled && onPressed != null ? [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ] : null,
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
        tooltip: tooltip,
        style: IconButton.styleFrom(
          backgroundColor: enabled && onPressed != null 
              ? Theme.of(context).colorScheme.primaryContainer
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          foregroundColor: enabled && onPressed != null
              ? Theme.of(context).colorScheme.onPrimaryContainer
              : Theme.of(context).colorScheme.onSurfaceVariant,
          padding: const EdgeInsets.all(12),
        ),
      ),
    );
  }
  
  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required BuildContext context,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          size: 20,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
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
        Divider(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
          height: 24,
        ),
        
        // Engine type et memory usage
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Engine status
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: (widget.engine.currentEngineType == EngineType.avx2
                        ? Colors.blue
                        : (widget.engine.isAvx2EngineAvailable ? Colors.grey : Colors.orange))
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    widget.engine.currentEngineType == EngineType.avx2
                        ? Icons.speed
                        : Icons.calculate,
                    size: 14,
                    color: widget.engine.currentEngineType == EngineType.avx2
                        ? Colors.blue
                        : (widget.engine.isAvx2EngineAvailable ? Colors.grey : Colors.orange),
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Moteur',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 10,
                      ),
                    ),
                    Text(
                      widget.engine.currentEngineType == EngineType.avx2
                          ? 'High-Perf'
                          : (widget.engine.isAvx2EngineAvailable ? 'Standard' : 'Standard*'),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: widget.engine.currentEngineType == EngineType.avx2
                            ? Colors.blue
                            : (widget.engine.isAvx2EngineAvailable ? Colors.grey : Colors.orange),
                        fontWeight: FontWeight.w500,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            // Memory usage
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    Icons.memory,
                    size: 14,
                    color: statusColor,
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mémoire',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 10,
                      ),
                    ),
                    Text(
                      memoryUsage.formattedTotal,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w500,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        
        // Show help text when AVX2 is not available
        if (!widget.engine.isAvx2EngineAvailable) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.orange.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 14,
                  color: Colors.orange,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Compilez la bibliothèque native pour le mode haute performance',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.orange.shade700,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
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