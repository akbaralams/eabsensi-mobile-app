import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/home/presentation/attendance_summary.dart';
import '../../features/punch/presentation/punch_providers.dart';
import '../design/design.dart';

/// Kerangka navigasi bawah. Tab "Absensi" membuka alur Check In / Check Out
/// sesuai status hari ini, bukan layar tab.
class AppShell extends ConsumerWidget {
  const AppShell({required this.shell, super.key});

  final StatefulNavigationShell shell;

  // Urutan tab: Beranda, Absensi (aksi), Cuti/Izin, Laporan, Profil.
  static const _branchOfTab = {0: 0, 2: 1, 3: 2, 4: 3};
  static const _tabOfBranch = {0: 0, 1: 2, 2: 3, 3: 4};

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
      label: 'Laporan',
      icon: PhosphorIconsRegular.fileText,
      activeIcon: PhosphorIconsFill.fileText,
    ),
    BottomNavItem(
      label: 'Profil',
      icon: PhosphorIconsRegular.user,
      activeIcon: PhosphorIconsFill.user,
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppScaffold(
      bottomNavigationBar: BottomNav(
        items: _items,
        currentIndex: _tabOfBranch[shell.currentIndex] ?? 0,
        onTap: (tab) {
          if (tab == 1) {
            final punches = ref.read(todayPunchesProvider).value ?? const [];
            final next = AttendanceSummary.from(punches).nextIsCheckOut
                ? '/punch/out'
                : '/punch/in';
            context.push(next);
            return;
          }
          final branch = _branchOfTab[tab]!;
          shell.goBranch(branch, initialLocation: branch == shell.currentIndex);
        },
      ),
      body: shell,
    );
  }
}
