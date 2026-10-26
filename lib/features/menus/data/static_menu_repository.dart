import '../../../core/design/widgets/menu_tile.dart';
import '../domain/menu_item.dart';

class StaticMenuRepository implements MenuRepository {
  const StaticMenuRepository([this.items = defaultItems]);

  final List<MenuItemData> items;

  static const defaultItems = [
    MenuItemData(
      id: 'cuti',
      label: 'Cuti',
      icon: 'airplane',
      tone: MenuTone.mint,
      isActive: true,
      action: LeaveFormAction(category: 'cuti'),
      sort: 1,
    ),
    MenuItemData(
      id: 'izin',
      label: 'Izin',
      icon: 'hand',
      tone: MenuTone.teal,
      isActive: true,
      action: LeaveFormAction(category: 'izin'),
      sort: 2,
    ),
    MenuItemData(
      id: 'sakit',
      label: 'Sakit',
      icon: 'firstAid',
      tone: MenuTone.amber,
      isActive: true,
      action: LeaveFormAction(category: 'izin', typeCode: 'I-SAKIT'),
      sort: 3,
    ),
    MenuItemData(
      id: 'dinas',
      label: 'Dinas Luar',
      icon: 'briefcase',
      tone: MenuTone.mint,
      isActive: true,
      action: LeaveFormAction(category: 'dinas'),
      sort: 4,
    ),
    MenuItemData(
      id: 'upacara',
      label: 'Upacara',
      icon: 'flag',
      tone: MenuTone.teal,
      isActive: true,
      action: EventsAction(),
      sort: 5,
    ),
    MenuItemData(
      id: 'lembur',
      label: 'Lembur',
      icon: 'moon',
      tone: MenuTone.amber,
      isActive: false,
      action: ComingSoonAction(),
      sort: 6,
    ),
    MenuItemData(
      id: 'wfh',
      label: 'WFH',
      icon: 'house',
      tone: MenuTone.mint,
      isActive: false,
      action: ComingSoonAction(),
      sort: 7,
    ),
    MenuItemData(
      id: 'belajar',
      label: 'Tugas Belajar',
      icon: 'graduationCap',
      tone: MenuTone.teal,
      isActive: true,
      action: ComingSoonAction(),
      sort: 8,
    ),
  ];

  @override
  Future<List<MenuItemData>> load() async =>
      [...items]..sort((a, b) => a.sort.compareTo(b.sort));
}
