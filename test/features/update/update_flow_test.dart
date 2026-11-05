import 'dart:async';

import 'package:eabsensi/features/update/data/ota_apk_installer.dart';
import 'package:eabsensi/features/update/domain/app_update.dart';
import 'package:eabsensi/features/update/presentation/update_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ota_update/ota_update.dart';

import '../../helpers/pump_app.dart';

final _info = UpdateInfo(
  versionName: '1.0.3',
  versionCode: 10003,
  apkUrl: Uri.parse('https://github.com/x/y/releases/download/v1.0.3/a.apk'),
  sha256: 'a' * 64,
  notes: 'Perbaikan selfie',
);

class _FakeRepo implements UpdateRepository {
  _FakeRepo(this.result);

  Object? result; // UpdateInfo?, atau UpdateCheckFailure untuk dilempar
  int calls = 0;

  @override
  Future<UpdateInfo?> latest() async {
    calls++;
    final r = result;
    if (r is UpdateCheckFailure) throw r;
    return r as UpdateInfo?;
  }
}

class _FakeInstaller implements ApkInstaller {
  // Siaran: bisa didengarkan lagi saat "Coba lagi" (plugin asli membuat
  // aliran baru tiap pemanggilan).
  final controller = StreamController<InstallEvent>.broadcast();
  UpdateInfo? installed;
  int cancels = 0;

  @override
  Stream<InstallEvent> install(UpdateInfo info) {
    installed = info;
    return controller.stream;
  }

  @override
  Future<void> cancel() async => cancels++;

  void dispose() => controller.close();
}

Future<void> _openProfile(WidgetTester tester) async {
  await tester.tap(find.text('Profil').last);
  await settle(tester);
}

void main() {
  group('baris Pembaruan aplikasi di Profil', () {
    testWidgets('tanpa rilis baru: menampilkan versi terpasang', (t) async {
      await pumpApp(t);
      await _openProfile(t);
      expect(find.text('Pembaruan aplikasi'), findsOneWidget);
      expect(find.text('Versi 1.0.0'), findsOneWidget);
    });

    testWidgets('ketuk saat sudah terbaru: toast, tanpa lembar', (t) async {
      final repo = _FakeRepo(null);
      await pumpApp(t, updates: repo);
      await _openProfile(t);
      await t.tap(find.text('Pembaruan aplikasi'));
      await settle(t);
      expect(find.text('Aplikasi sudah versi terbaru'), findsOneWidget);
      expect(find.text('Pembaruan tersedia'), findsNothing);
      await t.pump(const Duration(seconds: 5));
    });

    testWidgets('rilis baru: "Tersedia 1.0.3", lalu lembar pembaruan', (
      t,
    ) async {
      final repo = _FakeRepo(_info);
      await pumpApp(t, updates: repo);
      await _openProfile(t);
      expect(find.text('Tersedia 1.0.3'), findsOneWidget);
      await t.tap(find.text('Pembaruan aplikasi'));
      await settle(t);
      expect(find.text('Pembaruan tersedia'), findsOneWidget);
      expect(find.byKey(const Key('update-version')), findsOneWidget);
      expect(find.text('Versi 1.0.3 (10003)'), findsOneWidget);
      expect(find.text('Perbaikan selfie'), findsOneWidget);
    });

    testWidgets('gagal memeriksa: pesan jelas, bukan crash', (t) async {
      final repo = _FakeRepo(
        const UpdateCheckFailure('Tidak dapat memeriksa pembaruan.'),
      );
      await pumpApp(t, updates: repo);
      await _openProfile(t);
      await t.tap(find.text('Pembaruan aplikasi'));
      await settle(t);
      expect(find.text('Tidak dapat memeriksa pembaruan.'), findsOneWidget);
      await t.pump(const Duration(seconds: 5));
    });

    testWidgets('rilis sama atau lebih lama dari terpasang: bukan pembaruan', (
      t,
    ) async {
      final older = UpdateInfo(
        versionName: '0.9.0',
        versionCode: 9000,
        apkUrl: _info.apkUrl,
        sha256: _info.sha256,
      );
      await pumpApp(t, updates: _FakeRepo(older));
      await _openProfile(t);
      expect(find.textContaining('Tersedia'), findsNothing);
    });
  });

  group('lembar pembaruan', () {
    Future<_FakeInstaller> openSheet(WidgetTester t) async {
      final installer = _FakeInstaller();
      addTearDown(installer.dispose);
      await pumpApp(t, updates: _FakeRepo(_info), installer: installer);
      await _openProfile(t);
      await t.tap(find.text('Pembaruan aplikasi'));
      await settle(t);
      return installer;
    }

    testWidgets('Perbarui: progres, lalu pemasang Android dibuka', (t) async {
      final installer = await openSheet(t);
      await t.tap(find.byKey(const Key('update-start')));
      await t.pump();
      expect(installer.installed, _info);
      expect(find.text('Mengunduh…'), findsOneWidget);

      installer.controller.add(const InstallDownloading(.42));
      await t.pump();
      expect(find.text('Mengunduh… 42%'), findsOneWidget);

      installer.controller.add(const InstallHandedOff());
      await t.pump();
      expect(find.textContaining('Ketuk "Pasang"'), findsOneWidget);
    });

    testWidgets('gagal (checksum): pesan jelas dan bisa coba lagi', (t) async {
      final installer = await openSheet(t);
      await t.tap(find.byKey(const Key('update-start')));
      await t.pump();
      installer.controller.add(
        const InstallFailed('Berkas pembaruan tidak sesuai (checksum).'),
      );
      await t.pump();
      expect(find.textContaining('checksum'), findsOneWidget);
      await t.tap(find.byKey(const Key('update-retry')));
      await t.pump();
      expect(find.text('Mengunduh…'), findsOneWidget);
    });

    testWidgets('Batal saat mengunduh membatalkan unduhan', (t) async {
      final installer = await openSheet(t);
      await t.tap(find.byKey(const Key('update-start')));
      await t.pump();
      await t.tap(find.text('Batal'));
      await settle(t);
      expect(installer.cancels, 1);
      expect(find.byKey(const Key('update-start')), findsOneWidget);
    });

    testWidgets('Nanti menutup lembar tanpa mengunduh', (t) async {
      final installer = await openSheet(t);
      await t.tap(find.text('Nanti'));
      await settle(t);
      expect(find.text('Pembaruan tersedia'), findsNothing);
      expect(installer.installed, isNull);
    });
  });

  testWidgets(
    'APK per-ABI: lembar menampilkan ukurannya dan itu yang diunduh',
    (t) async {
      final arm64 = ApkPackage(
        url: Uri.parse(
          'https://github.com/x/y/releases/download/v1.0.3/a-arm64.apk',
        ),
        sha256: 'b' * 64,
        size: 33000000,
      );
      final info = UpdateInfo(
        versionName: _info.versionName,
        versionCode: _info.versionCode,
        apkUrl: _info.apkUrl,
        sha256: _info.sha256,
        size: 91130636,
        variants: {'arm64-v8a': arm64},
      );
      final installer = _FakeInstaller();
      addTearDown(installer.dispose);
      // pumpApp menyetel ABI perangkat ke arm64-v8a.
      await pumpApp(t, updates: _FakeRepo(info), installer: installer);
      await _openProfile(t);
      await t.tap(find.text('Pembaruan aplikasi'));
      await settle(t);

      expect(find.text('Ukuran unduhan 31,5 MB'), findsOneWidget);
      await t.tap(find.byKey(const Key('update-start')));
      await t.pump(); // progres tak tentu beranimasi terus: jangan settle
      expect(installer.installed!.apkUrl, arm64.url);
      expect(installer.installed!.sha256, arm64.sha256);
    },
  );

  group('pemetaan status plugin ota_update', () {
    OtaEvent e(OtaStatus s, [String? v]) => OtaEvent(s, v);

    test('progres unduhan menjadi pecahan 0..1', () {
      expect(
        (mapOtaEvent(
          e(OtaStatus.DOWNLOADING, '42'),
        ) as InstallDownloading).fraction,
        .42,
      );
      expect(
        (mapOtaEvent(
          e(OtaStatus.DOWNLOADING, '250'),
        ) as InstallDownloading).fraction,
        1,
      );
      expect(
        (mapOtaEvent(
          e(OtaStatus.DOWNLOADING, 'x'),
        ) as InstallDownloading).fraction,
        isNull,
      );
    });

    test('pemasang dibuka', () {
      expect(mapOtaEvent(e(OtaStatus.INSTALLING)), isA<InstallHandedOff>());
      expect(
        mapOtaEvent(e(OtaStatus.INSTALLATION_DONE)),
        isA<InstallHandedOff>(),
      );
    });

    test('setiap galat menjadi pesan Indonesia', () {
      final cases = {
        OtaStatus.PERMISSION_NOT_GRANTED_ERROR: 'Izin memasang',
        OtaStatus.CHECKSUM_ERROR: 'checksum',
        OtaStatus.DOWNLOAD_ERROR: 'mengunduh',
        OtaStatus.ALREADY_RUNNING_ERROR: 'sedang diunduh',
        OtaStatus.CANCELED: 'dibatalkan',
        OtaStatus.INSTALLATION_ERROR: 'gagal dipasang',
        OtaStatus.INTERNAL_ERROR: 'gagal dipasang',
      };
      for (final entry in cases.entries) {
        final event = mapOtaEvent(e(entry.key));
        expect(event, isA<InstallFailed>(), reason: '${entry.key}');
        expect(
          (event as InstallFailed).message.toLowerCase(),
          contains(entry.value.toLowerCase()),
          reason: '${entry.key}',
        );
      }
    });
  });

  testWidgets('beranda memberi tahu sekali saat ada rilis baru', (t) async {
    final c = await pumpApp(t, updates: _FakeRepo(_info));
    await c.read(availableUpdateProvider.future);
    await t.pump();
    await t.pump(const Duration(milliseconds: 300));
    expect(find.text('Pembaruan 1.0.3 tersedia'), findsOneWidget);
    expect(find.text('Lihat'), findsOneWidget);
    await t.pump(const Duration(seconds: 5));
  });

  test('UpdateController: tidak memulai dua unduhan sekaligus', () async {
    final installer = _FakeInstaller();
    final c = ProviderContainer(
      overrides: [apkInstallerProvider.overrideWithValue(installer)],
    );
    addTearDown(() {
      c.dispose();
      installer.dispose();
    });
    final controller = c.read(updateControllerProvider.notifier);
    controller.start(_info);
    expect(c.read(updateControllerProvider), isA<UpdateDownloading>());
    installer.installed = null;
    controller.start(_info);
    expect(installer.installed, isNull);
  });
}
