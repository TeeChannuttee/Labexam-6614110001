import 'package:flutter/material.dart';

class DesktopLayout extends StatelessWidget {
  final Widget child;
  final int currentIndex;
  final Function(int) onNavigationChanged;

  const DesktopLayout({
    super.key,
    required this.child,
    required this.currentIndex,
    required this.onNavigationChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Sidebar Navigation
        Container(
          width: 200,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            border: Border(
              right: BorderSide(
                color: Theme.of(context).dividerColor,
                width: 1,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // App Title
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Outfit',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    Text(
                      'Tinder',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(),
              const SizedBox(height: 16),
              // Navigation Items
              _buildNavItem(
                context,
                icon: Icons.checkroom,
                label: 'All Looks',
                index: 0,
              ),
              _buildNavItem(
                context,
                icon: Icons.add_circle_outline,
                label: 'Add Look',
                index: 1,
              ),
              _buildNavItem(
                context,
                icon: Icons.swipe,
                label: 'Swipe Mode',
                index: 2,
              ),
              const Spacer(),
              // Bottom section
              const Divider(),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Desktop v1.0',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
        ),
        // Main Content
        Expanded(
          child: child,
        ),
      ],
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = currentIndex == index;
    
    return InkWell(
      onTap: () => onNavigationChanged(index),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primaryContainer
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey[600],
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey[800],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
