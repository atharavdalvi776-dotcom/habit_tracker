import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Navigation item configuration.
class NavItem {
  final IconData icon;
  final String label;

  const NavItem({required this.icon, required this.label});
}

/// A floating glassmorphism custom bottom navigation bar.
///
/// Features:
/// - Floating pill design elevated from screen bottom.
/// - Animated glow indicator behind the currently active tab.
/// - Smooth icon scaling and label transitions.
class ModernBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabSelected;

  const ModernBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
  });

  static const List<NavItem> _items = [
    NavItem(icon: Icons.grid_view_rounded, label: 'Today'),
    NavItem(icon: Icons.insights_rounded, label: 'Analytics'),
    NavItem(icon: Icons.calendar_month_rounded, label: 'Calendar'),
    NavItem(icon: Icons.person_rounded, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 18.0),
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(30.0),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 24.0,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: AppTheme.violetPrimary.withValues(alpha: 0.15),
            blurRadius: 16.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(_items.length, (index) {
          final isSelected = currentIndex == index;
          final item = _items[index];

          return GestureDetector(
            onTap: () => onTabSelected(index),
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutCubic,
              padding: EdgeInsets.symmetric(
                horizontal: isSelected ? 16.0 : 12.0,
                vertical: 8.0,
              ),
              decoration: BoxDecoration(
                gradient: isSelected ? AppTheme.primaryGradient : null,
                borderRadius: BorderRadius.circular(22.0),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppTheme.violetPrimary.withValues(alpha: 0.4),
                          blurRadius: 12.0,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    item.icon,
                    size: 22.0,
                    color: isSelected ? Colors.white : AppTheme.textMuted,
                  ),
                  if (isSelected) ...[
                    const SizedBox(width: 8.0),
                    Text(
                      item.label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

