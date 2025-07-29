import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../utils/memory_estimator.dart';
import '../core/engine/life_engine_controller.dart';

class GridConfigDialog extends StatefulWidget {
  final LifeEngineController engine;

  const GridConfigDialog({super.key, required this.engine});

  @override
  State<GridConfigDialog> createState() => _GridConfigDialogState();
}

class _GridConfigDialogState extends State<GridConfigDialog> {
  late TextEditingController _widthController;
  late TextEditingController _heightController;
  late MemoryUsage _currentEstimate;
  bool _showAdvanced = false;
  bool _isInfiniteGrid = false;

  @override
  void initState() {
    super.initState();
    _widthController = TextEditingController(
      text: widget.engine.width.toString(),
    );
    _heightController = TextEditingController(
      text: widget.engine.height.toString(),
    );
    _isInfiniteGrid = widget.engine.isInfiniteGrid;
    _updateEstimate();
  }

  @override
  void dispose() {
    _widthController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  void _updateEstimate() {
    if (_isInfiniteGrid) {
      setState(() {
        _currentEstimate = _InfiniteGridMemoryUsage();
      });
    } else {
      final width = int.tryParse(_widthController.text) ?? widget.engine.width;
      final height = int.tryParse(_heightController.text) ?? widget.engine.height;
      setState(() {
        _currentEstimate = MemoryEstimator.calculateMemoryUsage(width, height);
      });
    }
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
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 480,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.surface,
              Theme.of(context).colorScheme.surfaceContainerLowest,
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Theme.of(
                context,
              ).colorScheme.shadow.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header avec design moderne
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.1),
                    Theme.of(
                      context,
                    ).colorScheme.secondary.withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.secondary,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.aspect_ratio,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Configuration de la grille',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                        Text(
                          'Ajustez la taille de votre espace de simulation',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    style: IconButton.styleFrom(
                      backgroundColor: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest
                          .withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),

            // Contenu principal scrollable
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Grille actuelle avec design amélioré
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHigh
                            .withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).colorScheme.outline.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.grid_on,
                                color: Theme.of(context).colorScheme.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Grille actuelle',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildInfoItem(
                                  'Dimensions',
                                  '${widget.engine.width} × ${widget.engine.height}',
                                  Icons.straighten,
                                  context,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildInfoItem(
                                  'Cellules',
                                  NumberFormat('#,###').format(
                                    widget.engine.width * widget.engine.height,
                                  ),
                                  Icons.apps,
                                  context,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildInfoItem(
                            'Moteur',
                            widget.engine.currentEngineName,
                            widget.engine.currentEngineType == EngineType.avx2
                                ? Icons.speed
                                : widget.engine.currentEngineType == EngineType.sparse
                                    ? Icons.all_out
                                    : Icons.calculate,
                            context,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Section de configuration
                    Text(
                      'Nouvelle configuration',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Toggle pour grille infinie
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .primaryContainer
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.all_out,
                              color: Theme.of(context).colorScheme.primary,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Grille infinie',
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                                Text(
                                  'Espace illimité avec moteur optimisé sparse',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: _isInfiniteGrid,
                            onChanged: (value) {
                              setState(() {
                                _isInfiniteGrid = value;
                              });
                              _updateEstimate();
                            },
                            activeColor: Theme.of(context).colorScheme.primary,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Champs de saisie avec design moderne
                    if (!_isInfiniteGrid) Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: TextField(
                              controller: _widthController,
                              decoration: InputDecoration(
                                labelText: 'Largeur',
                                prefixIcon: const Icon(Icons.width_normal),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: Colors.transparent,
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              onChanged: (_) => _updateEstimate(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: TextField(
                              controller: _heightController,
                              decoration: InputDecoration(
                                labelText: 'Hauteur',
                                prefixIcon: const Icon(Icons.height),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: Colors.transparent,
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              onChanged: (_) => _updateEstimate(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (!_isInfiniteGrid) const SizedBox(height: 20),

                    // Présets avec design moderne
                    if (!_isInfiniteGrid) Text(
                      'Tailles recommandées',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (!_isInfiniteGrid) const SizedBox(height: 12),
                    if (!_isInfiniteGrid) Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: MemoryEstimator.getRecommendedSizes().map((
                        gridSize,
                      ) {
                        return Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(
                                  context,
                                ).colorScheme.primary.withValues(alpha: 0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ActionChip(
                            label: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  gridSize.label,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  '${gridSize.width}×${gridSize.height}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                            backgroundColor: Theme.of(context)
                                .colorScheme
                                .primaryContainer
                                .withValues(alpha: 0.3),
                            onPressed: () {
                              _widthController.text = gridSize.width.toString();
                              _heightController.text = gridSize.height
                                  .toString();
                              _updateEstimate();
                            },
                            elevation: 0,
                            pressElevation: 2,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),

                    // Estimation mémoire avec design moderne
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: _getWarningColor(
                          _currentEstimate.warningLevel,
                        ).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _getWarningColor(
                            _currentEstimate.warningLevel,
                          ).withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: _getWarningColor(
                                    _currentEstimate.warningLevel,
                                  ).withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  _getWarningIcon(
                                    _currentEstimate.warningLevel,
                                  ),
                                  color: _getWarningColor(
                                    _currentEstimate.warningLevel,
                                  ),
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Estimation mémoire',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: _getWarningColor(
                                        _currentEstimate.warningLevel,
                                      ),
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildMemoryDetail(
                            'Grille',
                            '${_currentEstimate.width} × ${_currentEstimate.height}',
                            '${NumberFormat('#,###').format(_currentEstimate.totalCells)} cellules',
                            context,
                          ),
                          const SizedBox(height: 8),
                          _buildMemoryDetail(
                            'RAM estimée',
                            _currentEstimate.formattedTotal,
                            _getWarningMessage(_currentEstimate.warningLevel),
                            context,
                            isWarning: true,
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest
                                  .withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  size: 16,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _currentEstimate.performanceEstimate,
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurfaceVariant,
                                          fontStyle: FontStyle.italic,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Détails avancés avec design moderne
                    const SizedBox(height: 16),
                    Center(
                      child: TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _showAdvanced = !_showAdvanced;
                          });
                        },
                        icon: Icon(
                          _showAdvanced ? Icons.expand_less : Icons.expand_more,
                        ),
                        label: Text(
                          _showAdvanced
                              ? 'Masquer les détails'
                              : 'Voir les détails',
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                        ),
                      ),
                    ),

                    // Breakdown mémoire avancé
                    if (_showAdvanced) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHigh
                              .withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Theme.of(
                              context,
                            ).colorScheme.outline.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.analytics,
                                  color: Theme.of(context).colorScheme.primary,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Détail de la mémoire',
                                  style: Theme.of(context).textTheme.titleSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                      ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildMemoryRow(
                              'Grille principale:',
                              _currentEstimate.coreGridBytes,
                            ),
                            _buildMemoryRow(
                              'Interface:',
                              _currentEstimate.uiGridBytes,
                            ),
                            _buildMemoryRow(
                              'Flux de données:',
                              _currentEstimate.streamBytes,
                            ),
                            _buildMemoryRow(
                              'Rendu:',
                              _currentEstimate.renderingBytes,
                            ),
                            _buildMemoryRow(
                              'Buffer natif:',
                              _currentEstimate.nativeBufferBytes,
                            ),
                            Container(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              height: 1,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.transparent,
                                    Theme.of(context).colorScheme.outline
                                        .withValues(alpha: 0.3),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                            _buildMemoryRow(
                              'Total (avec marge):',
                              _currentEstimate.totalBytesWithSafety,
                              isTotal: true,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Actions avec design moderne
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Annuler'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed:
                          _currentEstimate.warningLevel == WarningLevel.danger
                          ? null
                          : () {
                              if (_isInfiniteGrid) {
                                widget.engine.setInfiniteGrid(true);
                                Navigator.of(context).pop();

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text(
                                      'Mode grille infinie activé',
                                    ),
                                    backgroundColor: Theme.of(context).colorScheme.primary,
                                  ),
                                );
                              } else {
                                final width = int.tryParse(_widthController.text);
                                final height = int.tryParse(
                                  _heightController.text,
                                );

                                if (width != null &&
                                    height != null &&
                                    width > 0 &&
                                    height > 0) {
                                  widget.engine.setInfiniteGrid(false);
                                  widget.engine.resizeGrid(width, height);
                                  Navigator.of(context).pop();

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Grille redimensionnée : $width × $height',
                                      ),
                                      backgroundColor: _getWarningColor(
                                        _currentEstimate.warningLevel,
                                      ),
                                    ),
                                  );
                                }
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(
                          context,
                        ).colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Appliquer',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(
    String label,
    String value,
    IconData icon,
    BuildContext context,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildMemoryDetail(
    String label,
    String value,
    String subtitle,
    BuildContext context, {
    bool isWarning = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isWarning
                      ? _getWarningColor(_currentEstimate.warningLevel)
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: isWarning
                ? _getWarningColor(_currentEstimate.warningLevel)
                : null,
          ),
        ),
      ],
    );
  }

  Widget _buildMemoryRow(String label, int bytes, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: isTotal ? Theme.of(context).colorScheme.primary : null,
            ),
          ),
          Text(
            MemoryEstimator.formatBytes(bytes),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: isTotal ? Theme.of(context).colorScheme.primary : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfiniteGridMemoryUsage extends MemoryUsage {
  _InfiniteGridMemoryUsage() : super(
    width: 0,
    height: 0,
    totalCells: 0,
    coreGridBytes: 1024,
    uiGridBytes: 512,
    streamBytes: 256,
    renderingBytes: 2048,
    nativeBufferBytes: 0,
    rawTotalBytes: 3840,
    totalBytesWithSafety: 5760,
  );
  
  @override
  WarningLevel get warningLevel => WarningLevel.safe;
  
  @override
  String get performanceEstimate => 'Grille infinie - utilisation mémoire dynamique basée sur les cellules actives';
}
