import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../design/design.dart';

/// Kerangka navigasi. Lima tujuan: Beranda, Absensi, Cuti/Izin, Riwayat, Profil.
/// Ponsel: navigasi bawah. Layar >= 720 dp: navigation rail di kiri dan konten
/// dibatasi lebarnya, bukan UI ponsel yang melar.
class AppShell extends StatelessWidget {
  const AppShell({required this.shell, super.key});

  final StatefulNavigationShell shell;

  static const _items = [
    BottomNavItem(
      label: 'Beranda',
      icon: PhosphorIconsRegular.house,
      activeIcon: PhosphorIconsFill.house,
    ),
    BottomNavItem(
      label: 'Absensi',
      icon: PhosphorIconsRegular.clipboardText,
      activeIcon: PhosphorIconsFill.clipboardText,
    ),
    BottomNavItem(
      label: 'Cuti/Izin',
      icon: PhosphorIconsRegular.files,
      activeIcon: PhosphorIconsFill.files,
    ),
    BottomNavItem(
      label: 'Riwayat',
      icon: PhosphorIconsRegular.clockCounterClockwise,
      activeIcon: PhosphorIconsFill.clockCounterClockwise,
    ),
    BottomNavItem(
      label: 'Profil',
      icon: PhosphorIconsRegular.user,
      activeIcon: PhosphorIconsFill.user,
    ),
  ];

  void _go(int index) =>
      shell.goBranch(index, initialLocation: index == shell.currentIndex);

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 720;
    if (!wide) {
      return AppScaffold(
        bottomNavigationBar: BottomNav(
          items: _items,
          currentIndex: shell.currentIndex,
          onTap: _go,
        ),
        body: shell,
      );
    }
    final c = context.colors;
    return AppScaffold(
      constrainBody: false,
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: shell.currentIndex,
            onDestinationSelected: _go,
            labelType: NavigationRailLabelType.all,
            backgroundColor: c.surface,
            indicatorColor: c.mintTint,
            unselectedLabelTextStyle: AppType.micro.copyWith(
              color: c.textMuted,
            ),
            selectedLabelTextStyle: AppType.microBold.copyWith(
              color: c.accentText,
            ),
            destinations: [
              for (final item in _items)
                NavigationRailDestination(
                  label: Text(item.label),
                  icon: PhosphorIcon(item.icon, size: 23, color: c.textMuted),
                  selectedIcon: PhosphorIcon(
                    item.activeIcon,
                    size: 23,
                    color: c.accent,
                  ),
                ),
            ],
          ),
          Expanded(child: ContentWidth(child: shell)),
        ],
      ),
    );
  }
}
