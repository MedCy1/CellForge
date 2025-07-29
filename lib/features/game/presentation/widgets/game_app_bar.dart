import 'package:flutter/material.dart';

class GameAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onPatternsPressed;
  final VoidCallback onWorkshopPressed;

  const GameAppBar({
    super.key,
    required this.onPatternsPressed,
    required this.onWorkshopPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: _buildTitle(context),
      backgroundColor: Theme.of(context).colorScheme.surface,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      bottom: _buildBottomBorder(context),
      actions: [
        _buildActions(context),
      ],
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.secondary,
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            '🧬',
            style: TextStyle(fontSize: 20),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          'CellForge',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }

  PreferredSize _buildBottomBorder(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(1),
      child: Container(
        height: 1,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.transparent,
              Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: onPatternsPressed,
            icon: const Icon(Icons.apps, size: 20),
            tooltip: 'Patterns intégrés',
            style: IconButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
          Container(
            width: 1,
            height: 20,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
          ),
          IconButton(
            onPressed: onWorkshopPressed,
            icon: const Icon(Icons.cloud, size: 20),
            tooltip: 'Workshop en ligne',
            style: IconButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}