import 'package:flutter/widgets.dart';
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

const Map<String, IconData> menuIcons = {
  'airplane': PhosphorIconsRegular.airplaneTilt,
  'hand': PhosphorIconsRegular.hand,
  'firstAid': PhosphorIconsRegular.firstAidKit,
  'briefcase': PhosphorIconsRegular.briefcase,
  'flag': PhosphorIconsRegular.flag,
  'moon': PhosphorIconsRegular.moonStars,
  'house': PhosphorIconsRegular.houseLine,
  'graduationCap': PhosphorIconsRegular.graduationCap,
};

IconData menuIcon(String name) =>
    menuIcons[name] ?? PhosphorIconsRegular.squaresFour;
