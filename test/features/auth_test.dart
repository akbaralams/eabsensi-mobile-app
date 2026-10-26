import 'package:eabsensi/core/mock/mock_env.dart';
import 'package:eabsensi/features/auth/data/mock_auth_repository.dart';
import 'package:eabsensi/features/auth/presentation/session_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/pump_app.dart';

Future<void> _login(WidgetTester tester, String user, String pass) async {
  await tester.enterText(find.byKey(const Key('login-field')), user);
  await tester.enterText(find.byKey(const Key('password-field')), pass);
  await tester.tap(find.text('Masuk'));
  await settle(tester);
}

void main() {
  testWidgets('belum login: tampil layar login tanpa SSO dan "Ingat saya"', (
    tester,
  ) async {
    await pumpApp(tester, signedIn: false);
    expect(find.text('NIP / Username'), findsOneWidget);
    expect(find.text('Masuk'), findsOneWidget);
    expect(find.text('SSO'), findsNothing);
    expect(find.textContaining('SSO Perusahaan'), findsNothing);
    expect(find.text('Ingat saya'), findsNothing);
  });

  testWidgets('field kosong: pesan per field', (tester) async {
    await pumpApp(tester, signedIn: false);
    await tester.tap(find.text('Masuk'));
    await settle(tester);
    expect(find.text('NIP atau username wajib diisi.'), findsOneWidget);
    expect(find.text('Password wajib diisi.'), findsOneWidget);
  });

  testWidgets('akun kontrak masuk ke beranda dan token tersimpan', (
    tester,
  ) async {
    final container = await pumpApp(tester, signedIn: false);
    await _login(tester, 'kontrak', mockPassword);
    expect(find.text('Andi Setiawan'), findsOneWidget);
    expect(find.text('Check In'), findsWidgets);
    expect(container.read(sessionProvider).value?.username, 'kontrak');
  });

  testWidgets('akun tanpa pegawai: pesan kontrak apa adanya (403)', (
    tester,
  ) async {
    await pumpApp(tester, signedIn: false);
    await _login(tester, 'kontrak.tanpa-pegawai', mockPassword);
    expect(
      find.text('Akun ini belum terhubung ke data pegawai.'),
      findsOneWidget,
    );
    expect(find.text('Masuk'), findsOneWidget);
  });

  testWidgets('akun nonaktif / sandi salah: pesan kontrak apa adanya (422)', (
    tester,
  ) async {
    await pumpApp(tester, signedIn: false);
    await _login(tester, 'kontrak.akun-nonaktif', mockPassword);
    expect(find.text('Username atau kata sandi salah.'), findsOneWidget);
  });

  testWidgets('offline saat login: pesan jelas', (tester) async {
    await pumpApp(
      tester,
      signedIn: false,
      scenario: const MockScenario(offline: true),
    );
    await _login(tester, 'kontrak', mockPassword);
    expect(find.textContaining('membutuhkan jaringan'), findsOneWidget);
  });

  testWidgets('token dicabut (401) membawa kembali ke layar login', (
    tester,
  ) async {
    final container = await pumpApp(tester);
    expect(find.text('Andi Setiawan'), findsOneWidget);

    container
        .read(mockScenarioProvider.notifier)
        .update((s) => s.copyWith(tokenRevoked: true));
    await container.read(sessionProvider.notifier).refresh();
    await settle(tester);

    expect(find.text('NIP / Username'), findsOneWidget);
    expect(container.read(sessionProvider).value, isNull);
  });

  testWidgets('mulai dengan token yang sudah dicabut: layar login', (
    tester,
  ) async {
    await pumpApp(tester, scenario: const MockScenario(tokenRevoked: true));
    expect(find.text('NIP / Username'), findsOneWidget);
  });
}
