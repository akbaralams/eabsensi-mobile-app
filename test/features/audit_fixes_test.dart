import 'dart:async';
import 'dart:ui' show Tristate;

import 'package:eabsensi/core/design/design.dart';
import 'package:eabsensi/core/mock/mock_env.dart';
import 'package:eabsensi/features/auth/data/token_store.dart';
import 'package:eabsensi/features/history/data/mock_history_repository.dart';
import 'package:eabsensi/features/history/domain/history.dart';
import 'package:eabsensi/features/history/presentation/history_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/pump_app.dart';

MockEnv _env() => MockEnv(
  tokens: MemoryTokenStore('t'),
  scenario: () => const MockScenario(),
  now: () => testNow,
  latency: Duration.zero,
);

/// Repo yang bulan keduanya baru selesai bila dilepas, untuk menguji pemuatan.
class _SlowSecondMonth implements HistoryRepository {
  _SlowSecondMonth() : _inner = MockHistoryRepository(_env());

  final MockHistoryRepository _inner;
  int calls = 0;
  final gate = Completer<void>();

  @override
  bool get supportsClassification => true;

  @override
  Future<MonthHistory> month(int year, int month) async {
    calls++;
    if (calls > 1) await gate.future;
    return _inner.month(year, month);
  }
}

class _NoClassification implements HistoryRepository {
  final _inner = MockHistoryRepository(_env());

  @override
  bool get supportsClassification => false;

  /// Server tanpa klasifikasi tidak pernah mengirim Terlambat/Tidak Hadir.
  @override
  Future<MonthHistory> month(int year, int month) async {
    final h = await _inner.month(year, month);
    return MonthHistory(
      year: h.year,
      month: h.month,
      days: [
        for (final d in h.days)
          if (d.status == DayStatus.present || d.status == DayStatus.pending) d,
      ],
    );
  }
}

Future<void> _openHistory(WidgetTester t) async {
  await t.tap(find.text('Riwayat'));
  await settle(t);
}

void main() {
  group('Riwayat', () {
    testWidgets(
      'hari ini tampil: Belum absen, lalu Menunggu setelah Check In',
      (t) async {
        await pumpApp(t);
        await _openHistory(t);
        expect(find.text('Hari ini'), findsOneWidget);
        expect(find.text('Belum absen'), findsOneWidget);

        await t.tap(find.text('Beranda'));
        await settle(t);
        await t.tap(find.text('Check In').first);
        await settle(t);
        await t.tap(find.text('Konfirmasi Check In'));
        await settle(t);
        await t.tap(find.byKey(const Key('shutter')));
        await settle(t);
        await t.tap(find.text('Kembali ke Beranda'));
        await settle(t);
        await _openHistory(t);

        expect(find.text('Hari ini'), findsOneWidget);
        expect(find.text('Belum absen'), findsNothing);
        expect(find.text('09:41'), findsOneWidget);
      },
    );

    testWidgets(
      'tombol bulan: nonaktif diumumkan, batas 12 bulan ke belakang',
      (t) async {
        final h = t.ensureSemantics();
        await pumpApp(t);
        await _openHistory(t);

        final next = t.getSemantics(find.bySemanticsLabel('Bulan berikutnya'));
        expect(next.flagsCollection.isButton, isTrue);
        expect(next.getSemanticsData().hasAction(SemanticsAction.tap), isFalse);
        expect(next.flagsCollection.isEnabled, isNot(Tristate.isTrue));

        for (var i = 0; i < 14; i++) {
          await t.tap(
            find.bySemanticsLabel('Bulan sebelumnya'),
            warnIfMissed: false,
          );
          await settle(t);
        }
        expect(find.text('Oktober 2025'), findsOneWidget);
        h.dispose();
      },
    );

    testWidgets('pemilih bulan dan detail hari lewat bottom sheet', (t) async {
      await pumpApp(t);
      await _openHistory(t);
      await t.tap(find.text('Oktober 2026'));
      await settle(t);
      expect(find.text('Pilih bulan'), findsOneWidget);
      await t.tap(find.text('September 2026'));
      await settle(t);
      expect(find.text('September 2026'), findsOneWidget);

      await t.tap(find.text('Tidak Hadir').last);
      await settle(t);
      // Tile pertama dan baris sama-sama bernama Tidak Hadir: ketuk baris.
      final row = find.bySemanticsLabel(
        RegExp('Tidak Hadir, tidak ada catatan jam'),
      );
      expect(row, findsWidgets);
    });

    testWidgets('tile menyaring daftar; Tampilkan semua menghapus saringan', (
      t,
    ) async {
      await pumpApp(t);
      await _openHistory(t);
      await t.tap(find.text('Terlambat').first);
      await settle(t);
      expect(find.text('Tampilkan semua hari'), findsOneWidget);
      expect(find.text('Tidak Hadir'), findsOneWidget); // hanya label tile
      await t.tap(find.text('Tampilkan semua hari'));
      await settle(t);
      expect(find.text('Tampilkan semua hari'), findsNothing);
    });

    testWidgets('detail hari: ketuk baris membuka sheet', (t) async {
      await pumpApp(t);
      await _openHistory(t);
      await t.tap(find.text('Belum absen'));
      await settle(t);
      expect(find.text('Belum ada punch hari ini.'), findsOneWidget);
      expect(find.text('Senin, 26 Oktober 2026'), findsWidgets);
    });

    testWidgets(
      'ganti bulan: data lama tetap tampil saat memuat (tanpa kedip)',
      (t) async {
        final repo = _SlowSecondMonth();
        await pumpApp(
          t,
          overrides: [historyRepositoryProvider.overrideWithValue(repo)],
        );
        await _openHistory(t);
        expect(find.text('Hadir'), findsWidgets);

        await t.tap(find.byIcon(PhosphorIconsRegular.caretLeft));
        await t.pump();
        await t.pump(const Duration(milliseconds: 50));
        expect(find.byType(LinearProgressIndicator), findsOneWidget);
        expect(find.text('Hadir'), findsWidgets); // masih tampil, diredupkan

        repo.gate.complete();
        await settle(t);
        expect(find.byType(LinearProgressIndicator), findsNothing);
        expect(find.text('September 2026'), findsOneWidget);
      },
    );

    testWidgets(
      'tanpa klasifikasi server: tile Terlambat/Tidak Hadir disembunyikan',
      (t) async {
        await pumpApp(
          t,
          overrides: [
            historyRepositoryProvider.overrideWithValue(_NoClassification()),
          ],
        );
        await _openHistory(t);
        expect(find.text('Terlambat'), findsNothing);
        expect(find.text('Tidak Hadir'), findsNothing);
        expect(find.text('Menunggu'), findsWidgets);
      },
    );
  });

  group('teks sistem besar dan layar sempit tidak overflow', () {
    Future<void> scan(
      WidgetTester t, {
      required Size size,
      required double scale,
    }) async {
      await pumpApp(t, size: size, textScale: scale);
      Future<void> check(String screen) async {
        await settle(t);
        expect(
          t.takeException(),
          isNull,
          reason: '$screen @${size.width}dp x$scale',
        );
      }

      await check('beranda');
      for (final tab in ['Absensi', 'Cuti/Izin', 'Riwayat', 'Profil']) {
        await t.tap(find.text(tab).last);
        await check(tab);
      }
      await t.tap(find.text('Beranda').last);
      await settle(t);
      await t.tap(find.text('Check In').first);
      await check('lokasi');
    }

    testWidgets(
      '360dp x2.0',
      (t) => scan(t, size: const Size(360, 740), scale: 2),
    );
    testWidgets(
      '320dp x1.3',
      (t) => scan(t, size: const Size(320, 640), scale: 1.3),
    );
    testWidgets('tablet 800x1280: rail dan lebar konten dibatasi', (t) async {
      await pumpApp(t, size: const Size(800, 1280));
      expect(find.byType(NavigationRail), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
      await t.tap(find.text('Riwayat'));
      await settle(t);
      final card = t.getSize(find.byType(AppCard).first);
      expect(card.width, lessThanOrEqualTo(640));
      expect(t.takeException(), isNull);
    });
  });

  group('persetujuan: konfirmasi dan urungkan', () {
    Future<void> open(WidgetTester t) async {
      await pumpApp(t);
      await t.scrollUntilVisible(
        find.text('3 menunggu persetujuanmu'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await t.tap(find.text('3 menunggu persetujuanmu'));
      await settle(t);
    }

    testWidgets('Tolak meminta konfirmasi; Batal tidak mengubah apa pun', (
      t,
    ) async {
      await open(t);
      await t.tap(
        find.descendant(
          of: find.byKey(const Key('approval-1')),
          matching: find.text('Tolak'),
        ),
      );
      await settle(t);
      expect(
        find.textContaining('Tolak pengajuan Rina Maharani?'),
        findsOneWidget,
      );
      await t.tap(find.text('Batal'));
      await settle(t);
      expect(find.text('Rina Maharani'), findsOneWidget);
    });

    testWidgets('Setujui lalu Urungkan mengembalikan kartu', (t) async {
      await open(t);
      await t.tap(
        find.descendant(
          of: find.byKey(const Key('approval-1')),
          matching: find.text('Setujui'),
        ),
      );
      await t.pump(const Duration(milliseconds: 400));
      expect(find.text('Rina Maharani'), findsNothing);
      expect(find.text('Urungkan'), findsOneWidget);
      // Harness tidak bisa menekan tombol Snackbar (hit test di luar layar uji);
      // menutupnya dengan alasan `action` sama dengan menekan "Urungkan".
      t
          .state<ScaffoldMessengerState>(find.byType(ScaffoldMessenger))
          .hideCurrentSnackBar(reason: SnackBarClosedReason.action);
      await settle(t);
      expect(find.text('Rina Maharani'), findsOneWidget);
    });

    testWidgets('tanpa Urungkan, keputusan dikirim setelah Snackbar selesai', (
      t,
    ) async {
      await open(t);
      await t.tap(
        find.descendant(
          of: find.byKey(const Key('approval-1')),
          matching: find.text('Setujui'),
        ),
      );
      await t.pump(const Duration(milliseconds: 400));
      await t.pump(const Duration(seconds: 6));
      await settle(t);
      expect(find.text('Rina Maharani'), findsNothing);
    });
  });

  testWidgets('login: label terlihat, bukan hanya placeholder', (t) async {
    await pumpApp(t, signedIn: false);
    expect(find.text('NIP / Username'), findsOneWidget);
    expect(find.text('Masukkan NIP atau username'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
  });

  testWidgets('event: hanya satu tombol utama', (t) async {
    await pumpApp(t);
    await t.tap(find.text('Upacara'));
    await settle(t);
    expect(find.widgetWithText(PrimaryButton, 'Check-in'), findsOneWidget);
    expect(find.widgetWithText(OutlineButton, 'Check-in'), findsOneWidget);
  });
}
