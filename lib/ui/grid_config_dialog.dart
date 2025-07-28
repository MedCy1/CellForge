import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../utils/memory_estimator.dart';
import '../core/engine/life_engine_controller.dart';

class GridConfigDialog extends StatefulWidget {
  final LifeEngineController engine;
  
  const GridConfigDialog({
    super.key,
    required this.engine,
  });

  @override
  State<GridConfigDialog> createState() => _GridConfigDialogState();
}

class _GridConfigDialogState extends State<GridConfigDialog> {
  late TextEditingController _widthController;
  late TextEditingController _heightController;
  late MemoryUsage _currentEstimate;
  bool _showAdvanced = false;
  
  @override
  void initState() {
    super.initState();
    _widthController = TextEditingController(text: widget.engine.width.toString());
    _heightController = TextEditingController(text: widget.engine.height.toString());
    _updateEstimate();
  }
  
  @override
  void dispose() {
    _widthController.dispose();
    _heightController.dispose();
    super.dispose();
  }
  
  void _updateEstimate() {
    final width = int.tryParse(_widthController.text) ?? widget.engine.width;
    final height = int.tryParse(_heightController.text) ?? widget.engine.height;
    setState(() {
      _currentEstimate = MemoryEstimator.calculateMemoryUsage(width, height);
    });
  }

  Color _getWarningColor(WarningLevel level) {
    switch (level) {
      case WarningLevel.safe:
        return Colors.green;
      case WarningLevel.caution:
        return Colors.orange;
      case WarningLevel.warning:
        return Colors.red.shade300;
      case WarningLevel.danger:
        return Colors.red.shade700;
    }
  }
  
  IconData _getWarningIcon(WarningLevel level) {
    switch (level) {
      case WarningLevel.safe:
        return Icons.check_circle;
      case WarningLevel.caution:
        return Icons.warning_amber;
      case WarningLevel.warning:
        return Icons.warning;
      case WarningLevel.danger:
        return Icons.dangerous;
    }
  }
  
  String _getWarningMessage(WarningLevel level) {
    switch (level) {
      case WarningLevel.safe:
        return 'Safe memory usage';
      case WarningLevel.caution:
        return 'Moderate memory usage - monitor performance';
      case WarningLevel.warning:
        return 'High memory usage - may cause lag on some devices';
      case WarningLevel.danger:
        return 'Very high memory usage - risk of crashes or freezes';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Configure Grid Size'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current grid info
            Card(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Grid: ${widget.engine.width} × ${widget.engine.height}',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    Text(
                      'Cells: ${NumberFormat('#,###').format(widget.engine.width * widget.engine.height)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      'Engine: ${widget.engine.currentEngineName}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Size input fields
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _widthController,
                    decoration: const InputDecoration(
                      labelText: 'Width',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (_) => _updateEstimate(),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _heightController,
                    decoration: const InputDecoration(
                      labelText: 'Height',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (_) => _updateEstimate(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Quick preset buttons
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: MemoryEstimator.getRecommendedSizes().map((gridSize) {
                return ActionChip(
                  label: Text('${gridSize.label}\n${gridSize.width}×${gridSize.height}'),
                  onPressed: () {
                    _widthController.text = gridSize.width.toString();
                    _heightController.text = gridSize.height.toString();
                    _updateEstimate();
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            
            // Memory usage estimation
            Card(
              color: _getWarningColor(_currentEstimate.warningLevel).withValues(alpha: 0.1),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _getWarningIcon(_currentEstimate.warningLevel),
                          color: _getWarningColor(_currentEstimate.warningLevel),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Memory Estimation',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Grid: ${_currentEstimate.width} × ${_currentEstimate.height} (${NumberFormat('#,###').format(_currentEstimate.totalCells)} cells)',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      'Estimated RAM: ${_currentEstimate.formattedTotal}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _getWarningColor(_currentEstimate.warningLevel),
                      ),
                    ),
                    Text(
                      _getWarningMessage(_currentEstimate.warningLevel),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      _currentEstimate.performanceEstimate,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Advanced details toggle
            TextButton(
              onPressed: () {
                setState(() {
                  _showAdvanced = !_showAdvanced;
                });
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_showAdvanced ? 'Hide Details' : 'Show Details'),
                  Icon(_showAdvanced ? Icons.expand_less : Icons.expand_more),
                ],
              ),
            ),
            
            // Advanced memory breakdown
            if (_showAdvanced) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Memory Breakdown',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      _buildMemoryRow('Core Grid:', _currentEstimate.coreGridBytes),
                      _buildMemoryRow('UI Grid:', _currentEstimate.uiGridBytes),
                      _buildMemoryRow('Streams:', _currentEstimate.streamBytes),
                      _buildMemoryRow('Rendering:', _currentEstimate.renderingBytes),
                      _buildMemoryRow('Native Buffer:', _currentEstimate.nativeBufferBytes),
                      const Divider(),
                      _buildMemoryRow(
                        'Total (with safety margin):',
                        _currentEstimate.totalBytesWithSafety,
                        isTotal: true,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _currentEstimate.warningLevel == WarningLevel.danger
              ? null
              : () {
                  final width = int.tryParse(_widthController.text);
                  final height = int.tryParse(_heightController.text);
                  
                  if (width != null && height != null && width > 0 && height > 0) {
                    widget.engine.resizeGrid(width, height);
                    Navigator.of(context).pop();
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Grid resized to $width × $height'),
                        backgroundColor: _getWarningColor(_currentEstimate.warningLevel),
                      ),
                    );
                  }
                },
          child: const Text('Apply'),
        ),
      ],
    );
  }
  
  Widget _buildMemoryRow(String label, int bytes, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: isTotal ? FontWeight.bold : null,
            ),
          ),
          Text(
            MemoryEstimator.formatBytes(bytes),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: isTotal ? FontWeight.bold : null,
            ),
          ),
        ],
      ),
    );
  }
}