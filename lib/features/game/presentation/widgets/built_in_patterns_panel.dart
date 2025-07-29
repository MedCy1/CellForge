import 'package:flutter/material.dart';
import '../../../../services/pattern_service.dart';

class BuiltInPatternsPanel extends StatelessWidget {
  final List<PatternModel> patterns;
  final Function(PatternModel) onPatternSelected;
  final VoidCallback onClose;

  const BuiltInPatternsPanel({
    super.key,
    required this.patterns,
    required this.onPatternSelected,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      elevation: 2,
      child: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: _buildPatternsList(context),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.apps,
              size: 18,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Patterns classiques',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.close, size: 20),
            style: IconButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
              foregroundColor: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatternsList(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: patterns.length,
      itemBuilder: (context, index) {
        final pattern = patterns[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Theme.of(context).colorScheme.surfaceContainerHigh.withValues(alpha: 0.3),
          ),
          child: ListTile(
            dense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            leading: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                Icons.grid_on,
                size: 16,
                color: Theme.of(context).colorScheme.onSecondaryContainer,
              ),
            ),
            title: Text(
              pattern.name,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Text(
              'Par ${pattern.author}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            onTap: () => onPatternSelected(pattern),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      },
    );
  }
}