import 'package:flutter/foundation.dart';

import '../../../core/design/widgets/menu_tile.dart';

/// Perilaku nonaktif untuk menu `is_active == false`.
enum MenuInactiveMode { locked, hidden }

@immutable
sealed class MenuAction {
  const MenuAction();
}

/// Buka form cuti/izin dengan kategori (dan jenis, bila ada) terpilih.
final class LeaveFormAction extends MenuAction {
  const LeaveFormAction({required this.category, this.typeCode});

  /// Salah satu `LeaveCategory.name`.
  final String category;
  final String? typeCode;
}

final class EventsAction extends MenuAction {
  const EventsAction();
}

/// Toast "{label} segera tersedia".
final class ComingSoonAction extends MenuAction {
  const ComingSoonAction();
}

@immutable
class MenuItemData {
  const MenuItemData({
    required this.id,
    required this.label,
    required this.icon,
    required this.tone,
    required this.isActive,
    required this.action,
    required this.sort,
  });

  final String id;
  final String label;

  /// Nama ikon (lihat `menuIcons`).
  final String icon;
  final MenuTone tone;
  final bool isActive;
  final MenuAction action;
  final int sort;
}

/// Sumber data menu beranda. Kontrak API belum menyediakan `GET /menus`
/// (atau field di `/me`); sampai ada, implementasinya statis.
abstract class MenuRepository {
  Future<List<MenuItemData>> load();
}
