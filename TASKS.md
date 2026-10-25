# Task eabsensi-mobile-app

Urutan wajib. Tiap task selesai bila kriteria "Selesai bila" terpenuhi dan sudah di-commit. Tandai `[x]` saat selesai.

## [ ] Task 0. Toolchain terbaru
- Minta izin user lalu naikkan Flutter ke stable terbaru (`flutter upgrade`), jalankan `flutter doctor` dan bereskan isu Android.
- **Selesai bila**: versi Flutter/Dart tercatat di README dan `flutter doctor` bersih untuk Android.

## [ ] Task 1. Kerangka aplikasi
- Tanyakan ke user: nama aplikasi, application ID/bundle ID (mis. `id.<organisasi>.eabsensi`), platform target (Android saja atau juga iOS), dan minimal versi Android.
- `flutter create` dengan nilai itu; struktur folder per fitur (auth, punch, events, leaves); lint ketat; konfigurasi base URL lewat `--dart-define`; state management dan routing memakai paket stabil terbaru yang umum dipakai (putuskan dan catat alasannya di README).
- **Selesai bila**: aplikasi kosong berjalan di emulator; `flutter analyze` dan `flutter test` hijau.

## [ ] Task 2. Client API dari OpenAPI
- Bangkitkan client Dart dari `../eabsensi-v2/docs/openapi/mobile-api.yaml` dengan generator stabil terbaru; skrip `tool/generate_api.*` di-commit.
- Lapisan tipis di atasnya: header `Accept`, Bearer token, pemetaan galat (401 → logout, 422 aturan → pesan, 422 validasi → per field, 429 → coba lagi nanti).
- **Selesai bila**: test unit pemetaan galat lulus dengan contoh respons dari kontrak.

## [ ] Task 3. Login dan profil
- Layar login (username atau email, sandi), simpan token aman, `device_name` stabil, `/me` saat start, logout.
- **Selesai bila**: login dengan akun `kontrak` ke Laravel lokal berhasil; akun `kontrak.tanpa-pegawai` dan `kontrak.akun-nonaktif` menampilkan pesan kontrak apa adanya; token yang dicabut membawa ke layar login.

## [ ] Task 4. Punch
- Kamera (foto wajib bila `requires_photo`), lokasi (izin, akurasi), kirim multipart, tampilkan hasil (`pending`/`approved`, waktu server), riwayat hari ini dan per tanggal.
- **Selesai bila**: punch berhasil dan muncul di halaman persetujuan punch web v2; pesan "Tunggu 60 detik..." tampil saat punch terlalu cepat.

## [ ] Task 5. Event
- Daftar event hari ini, check-in dengan foto/lokasi, status sudah check-in.
- **Selesai bila**: check-in ke "Apel Kontrak" (data seeder) berhasil, check-in kedua ditolak dengan pesan kontrak.

## [ ] Task 6. Cuti
- Daftar pengajuan dan jenis, form pengajuan (tanggal mulai/selesai, jenis, alasan), pesan batas 62 hari dan tumpang tindih.
- **Selesai bila**: pengajuan muncul di halaman cuti web v2 dengan status menunggu.

## [ ] Task 7. Rilis
- Ikon dan nama aplikasi, konfigurasi signing (file signing tidak di-commit), build release, catatan instalasi untuk uji internal.
- **Selesai bila**: APK/AAB release terpasang di perangkat fisik dan seluruh alur Task 3-6 lulus terhadap backend staging.
