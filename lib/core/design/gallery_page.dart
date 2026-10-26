import 'package:flutter/material.dart';

import 'design.dart';

/// Galeri komponen (route debug `/debug/galeri`): semua varian widget bersama.
class GalleryPage extends StatefulWidget {
  const GalleryPage({super.key});

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  String _segment = 'login';
  String _category = 'cuti';
  int _nav = 0;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return AppScaffold(
      bottomNavigationBar: BottomNav(
        currentIndex: _nav,
        onTap: (i) => setState(() => _nav = i),
        items: const [
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
        ],
      ),
      body: Column(
        children: [
          const PageHeader(title: 'Galeri Komponen'),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpace.screenH,
                8,
                AppSpace.screenH,
                AppSpace.contentBottom,
              ),
              children: [
                _section('Logo dan ikon bulat'),
                Row(
                  children: [
                    const LogoMark(size: 17),
                    const SizedBox(width: 16),
                    IconCircleButton(
                      icon: PhosphorIconsRegular.bell,
                      semanticLabel: 'Notifikasi',
                      showBadge: true,
                      onPressed: () {},
                    ),
                    IconCircleButton(
                      icon: PhosphorIconsRegular.gearSix,
                      semanticLabel: 'Pengaturan',
                      onPressed: () {},
                    ),
                  ],
                ),
                _section('Tombol'),
                PrimaryButton(
                  label: 'Masuk',
                  icon: PhosphorIconsBold.arrowRight,
                  onPressed: () => AppToast.show(context, 'Tombol ditekan'),
                ),
                const SizedBox(height: 10),
                const PrimaryButton(label: 'Menunggu lokasi…', onPressed: null),
                const SizedBox(height: 10),
                PrimaryButton(
                  label: 'Memproses',
                  loading: true,
                  onPressed: () {},
                ),
                const SizedBox(height: 10),
                OutlineButton(
                  label: 'SSO Perusahaan',
                  icon: PhosphorIconsRegular.buildings,
                  onPressed: () {},
                ),
                const SizedBox(height: 10),
                const OutlineButton(label: 'Batal', onPressed: null),
                _section('Field'),
                const AppTextField(
                  hint: 'NIP / Username',
                  icon: PhosphorIconsRegular.user,
                ),
                const SizedBox(height: 10),
                const AppTextField(
                  hint: 'Password',
                  icon: PhosphorIconsRegular.lock,
                  obscure: true,
                ),
                const SizedBox(height: 10),
                const AppTextField(
                  hint: 'Password',
                  icon: PhosphorIconsRegular.lock,
                  errorText: 'Password wajib diisi.',
                ),
                const SizedBox(height: 10),
                const AppTextField(
                  label: 'Alasan',
                  hint: 'Tulis alasan pengajuan',
                  maxLines: 4,
                  minLines: 3,
                ),
                _section('Segmented'),
                PillSegmented<String>(
                  value: _segment,
                  onChanged: (v) => setState(() => _segment = v),
                  items: const [
                    SegmentItem(value: 'login', label: 'Login'),
                    SegmentItem(value: 'sso', label: 'SSO'),
                  ],
                ),
                const SizedBox(height: 10),
                PillSegmented<String>(
                  gradient: true,
                  value: _category,
                  onChanged: (v) => setState(() => _category = v),
                  items: const [
                    SegmentItem(value: 'cuti', label: 'Cuti'),
                    SegmentItem(value: 'izin', label: 'Izin'),
                    SegmentItem(value: 'dinas', label: 'Dinas Luar'),
                    SegmentItem(value: 'lain', label: 'Lainnya'),
                  ],
                ),
                _section('Status chip'),
                const Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    StatusChip(label: 'Hadir', variant: StatusVariant.success),
                    StatusChip(label: 'Terlambat', variant: StatusVariant.late),
                    StatusChip(
                      label: 'Menunggu atasan',
                      variant: StatusVariant.pending,
                    ),
                    StatusChip(
                      label: 'Tidak hadir',
                      variant: StatusVariant.absent,
                    ),
                    StatusChip(
                      label: 'Belum check-in',
                      variant: StatusVariant.neutral,
                    ),
                  ],
                ),
                _section('Kartu'),
                AppCard(
                  child: Text(
                    'Kartu utama',
                    style: AppType.cardTitle.copyWith(color: c.textPrimary),
                  ),
                ),
                const SizedBox(height: 10),
                AppCard(
                  secondary: true,
                  child: Text(
                    'Kartu sekunder',
                    style: AppType.cardTitle.copyWith(color: c.textPrimary),
                  ),
                ),
                _section('Menu tile'),
                GridView(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: AppSpace.grid,
                    crossAxisSpacing: AppSpace.grid,
                    mainAxisExtent: menuTileExtent(context),
                  ),
                  children: [
                    MenuTile(
                      icon: PhosphorIconsRegular.umbrella,
                      label: 'Cuti',
                      tone: MenuTone.mint,
                      onTap: () {},
                    ),
                    MenuTile(
                      icon: PhosphorIconsRegular.heartbeat,
                      label: 'Sakit',
                      tone: MenuTone.teal,
                      onTap: () {},
                    ),
                    MenuTile(
                      icon: PhosphorIconsRegular.briefcase,
                      label: 'Dinas Luar',
                      tone: MenuTone.amber,
                      onTap: () {},
                    ),
                    const MenuTile(
                      icon: PhosphorIconsRegular.clockCountdown,
                      label: 'Lembur',
                      tone: MenuTone.amber,
                      enabled: false,
                      onTap: null,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(String title) => Padding(
    padding: const EdgeInsets.only(top: 22, bottom: 10),
    child: Semantics(
      header: true,
      child: Text(
        title,
        style: AppType.cardTitle.copyWith(color: context.colors.textPrimary),
      ),
    ),
  );
}
