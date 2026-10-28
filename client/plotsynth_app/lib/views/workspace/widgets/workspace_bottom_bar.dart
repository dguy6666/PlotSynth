import 'package:flutter/material.dart';

class WorkspaceBottomBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabSelected;

  const WorkspaceBottomBar({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
  });

  // The 5 tabs with their icons and names:
  static const List<_TabItem> _tabs = [
    _TabItem(icon: Icons.hourglass_bottom_rounded, label: 'Timeline'),
    _TabItem(icon: Icons.public_rounded, label: 'World'),
    _TabItem(icon: Icons.lightbulb_rounded, label: 'Outline'),
    _TabItem(icon: Icons.menu_book_rounded, label: 'Write'),
    _TabItem(icon: Icons.spellcheck_rounded, label: 'Dictionary'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Warm Readest palette:
    final activeColor = isDark ? Colors.amber.shade300 : Colors.amber.shade900;
    final inactiveColor = isDark ? Colors.grey.shade500 : Colors.brown.shade300;
    final barBgColor = isDark ? const Color(0xFF1E1E1E) : const Color(0xFFFFF9EE);

    return Container(
      decoration: BoxDecoration(
        color: barBgColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 72,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_tabs.length, (index) {
              final isSelected = (currentIndex == index);
              final tab = _tabs[index];

              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onTabSelected(index),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Smooth 50% scale-up animation on the active icon:
                      AnimatedScale(
                        scale: isSelected ? 1.45 : 1.0, // 45-50% larger when active!
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOutBack, // Subtle, pleasant spring bounce
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            // Warm pill background behind active icon:
                            color: isSelected
                                ? (isDark ? Colors.amber.shade900.withValues(alpha: 0.3) : Colors.amber.shade100)
                                : Colors.transparent,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            tab.icon,
                            size: 22,
                            color: isSelected ? activeColor : inactiveColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 3),
                      // Tab label:
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 200),
                        style: TextStyle(
                          fontSize: isSelected ? 11.5 : 10.5,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? activeColor : inactiveColor,
                        ),
                        child: Text(
                          tab.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

// Simple helper class for tab metadata:
class _TabItem {
  final IconData icon;
  final String label;
  const _TabItem({required this.icon, required this.label});
}