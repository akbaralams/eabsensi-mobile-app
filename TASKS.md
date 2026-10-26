# Task eabsensi-mobile-app

Urutan wajib. Tiap task selesai bila kriteria "Selesai bila" terpenuhi dan sudah di-commit. Tandai `[x]` saat selesai.

**Acuan tampilan:** `docs/design/README.md` (token, komponen, spesifikasi per layar), screenshot `docs/design/screens/`, dan prototipe `docs/design/prototype/eAbsensi-prototype.dc.html`. Setiap layar dibangun semirip mungkin dengan prototipe (high-fidelity, kanvas 390×844). Bila spesifikasi desain bertentangan dengan kontrak API atau `CLAUDE.md`, kontrak yang menang. Catat perbedaannya di `docs/design/DEVIATIONS.md`.

## [ ] Task 0. Toolchain terbaru
- Minta izin user lalu naikkan Flutter ke stable terbaru (`flutter upgrade`), jalankan `flutter doctor` dan bereskan isu Android.
- **Selesai bila**: versi Flutter/Dart tercatat di README dan `flutter doctor` bersih untuk Android.

## [ ] Task 1. Kerangka aplikasi
- Tanyakan ke user: nama aplikasi, application ID/bundle ID (mis. `id.<organisasi>.eabsensi`), platform target (Android saja atau juga iOS), dan minimal versi Android.
- `flutter create` dengan nilai itu; struktur folder per fitur (auth, punch, events, leaves, home, history, profile) + `core/design`; lint ketat; base URL lewat `--dart-define`; state management dan routing memakai paket stabil terbaru yang umum dipakai (putuskan dan catat alasannya di README).
- **Selesai bila**: aplikasi kosong berjalan di emulator; `flutter analyze` dan `flutter test` hijau.

## [ ] Task 2. Sistem desain (tema + komponen)
- `core/design/tokens.dart`: semua warna, gradien, radius, bayangan, jarak, dan skala tipe dari README desain. Jangan menulis nilai warna atau ukuran langsung di widget fitur.
- `ThemeData` light dan dark (palet gelap dari bagian *Mode gelap*), font Plus Jakarta Sans (`google_fonts` atau aset lokal), ikon `phosphor_flutter`.
- Widget bersama: `AppScaffold` (latar gradien), `PageHeader`, `AppCard`, `PrimaryButton`, `OutlineButton`, `AppTextField`, `PillSegmented`, `StatusChip`, `MenuTile` (aktif/terkunci), `IconCircleButton`, `BottomNav`, `AppToast`.
- Halaman galeri komponen (route debug) yang menampilkan semua varian, light dan dark.
- Golden test untuk tiap komponen (light + dark, text scale 1.0 dan 1.3).
- **Selesai bila**: galeri cocok secara visual dengan prototipe; golden test hijau; target sentuh ≥ 48dp; kontras teks ≥ 4.5:1 di kedua mode.

## [ ] Task 3. Client API dari OpenAPI
- Bangkitkan client Dart dari `../eabsensi-v2/docs/openapi/mobile-api.yaml` dengan generator stabil terbaru; skrip `tool/generate_api.*` di-commit.
- Lapisan tipis di atasnya: header `Accept`, Bearer token, pemetaan galat (401 → logout, 422 aturan → pesan, 422 validasi → per field, 429 → coba lagi nanti).
- **Selesai bila**: test unit pemetaan galat lulus dengan contoh respons dari kontrak.

## [ ] Task 4. Login dan profil
- Layar **Login** (README desain §1): logo, sheet blur, field username/email + password (tombol mata), tombol Masuk. Tab SSO, tombol SSO, dan "Ingat saya" **disembunyikan** sampai kontrak mendukung (catat di DEVIATIONS).
- Simpan token aman, `device_name` stabil, `/me` saat start, logout.
- Layar **Profil** (§12): kartu identitas (nomor pegawai, Department dari `/me`), daftar menu, tombol Keluar. Tambahkan item "Mode Gelap" (ikuti sistem / terang / gelap).
- **Selesai bila**: login dengan akun `kontrak` ke Laravel lokal berhasil; akun `kontrak.tanpa-pegawai` dan `kontrak.akun-nonaktif` menampilkan pesan kontrak apa adanya; token yang dicabut membawa ke layar login; tampilan Login & Profil cocok dengan prototipe.

## [ ] Task 5. Beranda dan navigasi
- `BottomNav` 5 tab (§Navigasi bawah). Tab Laporan → Riwayat sampai ada layar laporan.
- Layar **Beranda** (§2): header + salam per jam, kartu absen (hero jam, Masuk/Keluar, tombol Check In/Check Out), Status Kehadiran Hari Ini, grid menu dinamis, banner event, kartu persetujuan (hanya peran atasan, bila kontrak ada).
- **Menu dinamis** (§Menu dinamis): `MenuRepository` dengan model `id, label, icon, tone, is_active, action, sort`; implementasi statis dulu. Mode nonaktif terkunci/sembunyi lewat konfigurasi. Ajukan kontrak `GET /menus` (atau field `/me`) di repo API; jangan menambah endpoint dari sini.
- **Selesai bila**: Beranda cocok dengan prototipe; menu nonaktif tidak bisa ditekan dan terbaca "nonaktif" oleh screen reader; mengganti data statis mengubah grid tanpa ubah kode UI; test widget untuk kedua mode nonaktif.

## [ ] Task 6. Punch (Check In / Check Out)
- Alur §3–§6: layar lokasi dengan peta + geofence + akurasi, kartu informasi, Konfirmasi/Batal → foto (bila `requires_photo`) → kirim multipart → layar hasil dengan **waktu dari server** dan status `approved`/`pending` → atau layar galat.
- Lokasi dikirim bila izin diberikan (`latitude`, `longitude`, `accuracy`). Tanpa jaringan: layar galat offline, tanpa antrean.
- Kartu absen dan Status Kehadiran di Beranda diperbarui dari data server.
- **Selesai bila**: punch berhasil dan muncul di halaman persetujuan punch web v2; pesan "Tunggu 60 detik..." tampil apa adanya saat punch terlalu cepat; status `pending` tampil sebagai "Menunggu atasan"; tampilan cocok dengan prototipe.

## [ ] Task 7. Riwayat absensi
- Layar §7: navigasi bulan, tile Hadir/Terlambat/Tidak Hadir, list per hari dengan `StatusChip` dan jam masuk–pulang.
- **Selesai bila**: data per tanggal dari API tampil benar; status tidak hanya lewat warna; tampilan cocok dengan prototipe.

## [ ] Task 8. Event (Upacara)
- Layar §9: daftar event hari ini, check-in (QR bila kontrak mendukung, jika tidak: foto/lokasi sesuai kontrak), status sudah check-in. Menu "Upacara" di beranda membuka layar ini.
- **Selesai bila**: check-in ke "Apel Kontrak" (data seeder) berhasil, check-in kedua ditolak dengan pesan kontrak; tampilan cocok dengan prototipe.

## [ ] Task 9. Cuti / Izin / Dinas Luar
- Layar §8: segmented kategori, dropdown jenis dari API, tanggal mulai/selesai, alasan, lampiran opsional, info jumlah hari, kotak pesan aturan, daftar "Pengajuan terakhir". Menu Cuti/Izin/Sakit/Dinas Luar di beranda membuka form dengan kategori/jenis terpilih.
- Validasi per field dari 422 `errors`; pesan aturan (batas 62 hari, tumpang tindih) dari 422 `message` apa adanya.
- **Selesai bila**: pengajuan muncul di halaman cuti web v2 dengan status menunggu; kedua pesan aturan tampil; tampilan cocok dengan prototipe.

## [ ] Task 10. Notifikasi dan persetujuan (menunggu kontrak)
- Kerjakan hanya bila kontrak API sudah menyediakan endpoint. Layar §10 dan §11.
- **Selesai bila**: data dari API tampil; tombol Setujui/Tolak memanggil endpoint kontrak; tampilan cocok dengan prototipe.

## [ ] Task 11. Rilis
- Ikon dan nama aplikasi (logo 4 lingkaran mint), konfigurasi signing (file signing tidak di-commit), build release, catatan instalasi untuk uji internal.
- **Selesai bila**: APK/AAB release terpasang di perangkat fisik dan seluruh alur Task 4–9 lulus terhadap backend staging, dalam mode terang dan gelap.
