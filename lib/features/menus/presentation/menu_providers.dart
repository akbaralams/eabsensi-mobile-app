import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/phosphor.dart';

import '../data/static_menu_repository.dart';
import '../domain/menu_item.dart';

final menuRepositoryProvider = Provider<MenuRepository>(
  (ref) => const StaticMenuRepository(),
);

final menusProvider = FutureProvider<List<MenuItemData>>(
  (ref) => ref.watch(menuRepositoryProvider).load(),
);

/// Menu nonaktif: terkunci (default) atau disembunyikan.
final menuInactiveModeProvider = Provider<MenuInactiveMode>(
  (ref) => MenuInactiveMode.locked,
);

/// Ikon menu beranda: gaya Duotone, satu aksen hijau (lihat docs/design).
const Map<String, DuotoneIconData> menuIcons = {
  'airplane': PhosphorIconsDuotone.airplaneTilt,
  'hand': PhosphorIconsDuotone.hand,
  'firstAid': PhosphorIconsDuotone.firstAidKit,
  'briefcase': PhosphorIconsDuotone.briefcase,
  'flag': PhosphorIconsDuotone.flag,
  'moon': PhosphorIconsDuotone.moonStars,
  'house': PhosphorIconsDuotone.houseLine,
  'graduationCap': PhosphorIconsDuotone.graduationCap,
};

DuotoneIconData menuIcon(String name) =>
    menuIcons[name] ?? PhosphorIconsDuotone.squaresFour;
