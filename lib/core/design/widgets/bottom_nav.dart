import 'package:flutter/material.dart';

import '../phosphor.dart';
import '../tokens.dart';

class BottomNavItem {
  const BottomNavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
  });

  final String label;
  final IconData icon;
  final IconData activeIcon;
}

/// Navigasi bawah: `NavigationBar` Material 3 yang ditema. Skala teks label
/// dibatasi 1,3x oleh komponen (label tidak terpotong), target sentuh dan
/// semantik "tab N dari M" ditangani Material.
class BottomNav extends StatelessWidget {
  const BottomNav({
    required this.items,
    required this.currentIndex,
    required this.onTap,
    super.key,
  });

  final List<BottomNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return NavigationBarTheme(
      data: NavigationBarThemeData(
        height: 72,
        elevation: 3,
        backgroundColor: c.surface,
        surfaceTintColor: Colors.transparent,
        shadowColor: c.shadow,
        indicatorColor: c.mintTint,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return AppType.micro.copyWith(
            color: selected ? c.accentText : c.textMuted,
            fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
          );
        }),
      ),
      child: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: onTap,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: [
          for (final item in items)
            NavigationDestination(
              label: item.label,
              icon: PhosphorIcon(item.icon, size: 23, color: c.textMuted),
              selectedIcon: PhosphorIcon(
                item.activeIcon,
                size: 23,
                color: c.accent,
              ),
            ),
        ],
      ),
    );
  }
}
