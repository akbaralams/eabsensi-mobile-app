import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_config.dart';
import '../../../core/design/design.dart';
import '../../../core/design/theme_mode_controller.dart';
import '../../auth/domain/user_profile.dart';
import '../../auth/presentation/session_controller.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final profile = ref.watch(sessionProvider).value;
    final mode = ref.watch(themeModeProvider);
    if (profile == null) return const SizedBox.shrink();

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpace.screenH,
        6,
        AppSpace.screenH,
        AppSpace.contentBottom,
      ),
      children: [
        Row(
          children: [
            Expanded(
              child: Semantics(
                header: true,
                child: Text(
                  'Profil',
                  style: AppType.title.copyWith(color: c.textPrimary),
                ),
              ),
            ),
            IconCircleButton(
              icon: PhosphorIconsRegular.gearSix,
              semanticLabel: 'Mode tampilan',
              onPressed: () => _pickTheme(context, ref, mode),
            ),
          ],
        ),
        const SizedBox(height: AppSpace.block),
        _IdentityCard(profile: profile),
        const SizedBox(height: AppSpace.block),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              _MenuRow(
                icon: PhosphorIconsRegular.user,
                label: 'Data Pribadi',
                onTap: () => _soon(context, 'Data Pribadi'),
              ),
              _MenuRow(
                icon: PhosphorIconsRegular.calendarCheck,
                label: 'Jadwal & Shift',
                onTap: () => _soon(context, 'Jadwal & Shift'),
              ),
              _MenuRow(
                icon: PhosphorIconsRegular.clockCounterClockwise,
                label: 'Riwayat Absensi',
                onTap: () => context.go('/history'),
              ),
              _MenuRow(
                icon: PhosphorIconsRegular.files,
                label: 'Pengajuan Cuti/Izin',
                onTap: () => context.go('/leaves'),
              ),
              if (profile.isSupervisor)
                _MenuRow(
                  icon: PhosphorIconsRegular.stamp,
                  label: 'Persetujuan Tim',
                  onTap: () => context.push('/approvals'),
                ),
              _MenuRow(
                icon: PhosphorIconsRegular.deviceMobile,
                label: 'Perangkat Absensi',
                onTap: () => _soon(context, 'Perangkat Absensi'),
              ),
              _MenuRow(
                icon: PhosphorIconsRegular.bell,
                label: 'Notifikasi',
                onTap: () => context.push('/notifications'),
              ),
              _MenuRow(
                icon: PhosphorIconsRegular.moon,
                label: 'Mode Gelap',
                trailing: switch (mode) {
                  ThemeMode.system => 'Ikuti sistem',
                  ThemeMode.light => 'Terang',
                  ThemeMode.dark => 'Gelap',
                },
                last: !AppConfig.useMock,
                onTap: () => _pickTheme(context, ref, mode),
              ),
              if (AppConfig.useMock) ...[
                _MenuRow(
                  icon: PhosphorIconsRegular.flask,
                  label: 'Skenario uji (data contoh)',
                  onTap: () => context.push('/debug/skenario'),
                ),
                _MenuRow(
                  icon: PhosphorIconsRegular.squaresFour,
                  label: 'Galeri komponen',
                  last: true,
                  onTap: () => context.push('/debug/galeri'),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpace.block),
        _LogoutButton(onTap: () => _confirmLogout(context, ref)),
      ],
    );
  }

  static void _soon(BuildContext context, String label) =>
      AppToast.show(context, '$label segera tersedia');

  Future<void> _pickTheme(
    BuildContext context,
    WidgetRef ref,
    ThemeMode current,
  ) async {
    final c = context.colors;
    final selected = await showModalBottomSheet<ThemeMode>(
      context: context,
      backgroundColor: c.surface,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.sheetTop),
        ),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 0, 22, 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mode tampilan',
                style: AppType.cardTitle.copyWith(color: c.textPrimary),
              ),
              const SizedBox(height: 12),
              PillSegmented<ThemeMode>(
                value: current,
                onChanged: (m) => Navigator.pop(context, m),
                items: const [
                  SegmentItem(value: ThemeMode.system, label: 'Ikuti sistem'),
                  SegmentItem(value: ThemeMode.light, label: 'Terang'),
                  SegmentItem(value: ThemeMode.dark, label: 'Gelap'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    if (selected != null) {
      await ref.read(themeModeProvider.notifier).set(selected);
    }
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final c = context.colors;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Keluar dari aplikasi?',
          style: AppType.cardTitle.copyWith(color: c.textPrimary),
        ),
        content: Text(
          'Kamu perlu masuk lagi untuk melakukan absensi.',
          style: AppType.body.copyWith(color: c.textSecondary),
        ),
        actions: [
          TextButton(
            autofocus: true,
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: c.errorText),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
    if (ok ?? false) await ref.read(sessionProvider.notifier).logout();
  }
}

class _IdentityCard extends StatelessWidget {
  const _IdentityCard({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final employee = profile.employee;
    return AppCard(
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: c.badgeGradient,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              _initials(profile.name),
              style: AppType.title.copyWith(color: Colors.white),
              semanticsLabel: '',
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.name,
                  style: AppType.cardTitle.copyWith(
                    color: c.textPrimary,
                    fontSize: 16,
                  ),
                ),
                if (employee != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Nomor pegawai ${employee.employeeNumber}',
                    style: AppType.caption.copyWith(color: c.textMuted),
                  ),
                  if (employee.department != null)
                    Text(
                      employee.department!,
                      style: AppType.caption.copyWith(color: c.textMuted),
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    return parts.take(2).map((p) => p[0].toUpperCase()).join();
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailing,
    this.last = false,
  });

  final IconData icon;
  final String label;
  final String? trailing;
  final bool last;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      button: true,
      label: trailing == null ? label : '$label, $trailing',
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: AppSpace.menuItemHeight),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            border: last
                ? null
                : Border(bottom: BorderSide(color: c.rowDivider)),
          ),
          child: Row(
            children: [
              PhosphorIcon(icon, size: 20, color: c.accent),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: AppType.bodyBold.copyWith(
                    color: c.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (trailing != null)
                Text(
                  trailing!,
                  style: AppType.caption.copyWith(color: c.textMuted),
                ),
              const SizedBox(width: 6),
              PhosphorIcon(
                PhosphorIconsRegular.caretRight,
                size: 16,
                color: c.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  const _LogoutButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return AppCard(
      padding: EdgeInsets.zero,
      onTap: onTap,
      semanticLabel: 'Keluar',
      child: Container(
        constraints: const BoxConstraints(minHeight: 56),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            PhosphorIcon(
              PhosphorIconsRegular.signOut,
              size: 20,
              color: c.errorText,
            ),
            const SizedBox(width: 8),
            Text(
              'Keluar',
              style: AppType.cardTitle.copyWith(color: c.errorText),
            ),
          ],
        ),
      ),
    );
  }
}
