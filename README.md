# eabsensi-mobile-app

Aplikasi pegawai eAbsensi (Flutter, Android). Lihat [CLAUDE.md](CLAUDE.md) untuk konteks dan aturan, [TASKS.md](TASKS.md) untuk urutan pekerjaan, dan [docs/design/README.md](docs/design/README.md) untuk acuan tampilan.

## Toolchain
| Komponen | Versi |
|---|---|
| Flutter (stable) | 3.47.8 |
| Dart | 3.13.7 |
| Android | `applicationId` `id.eabsensi.app`, `minSdk` 24, platform target Android saja |

`flutter doctor` bersih untuk Android (SDK platform 36, build-tools 36.0.0). Chrome dan Linux desktop tidak dipakai. Di VM cloud, `tool/cloud-setup.sh` memasang Flutter dan Android SDK.

## Menjalankan
Build **debug** memakai data dummy secara default; build **rilis/profil** memakai API sungguhan (`USE_MOCK=false`). `API_BASE_URL` default `http://10.0.2.2:8080/api` (Rust lokal dari emulator).
```bash
flutter pub get
flutter run                                             # debug, data dummy
flutter run --dart-define=USE_MOCK=false                # debug, API Rust lokal (cargo run, :8080)
flutter run --dart-define=USE_MOCK=false \
            --dart-define=API_BASE_URL=http://10.0.2.2:8000/api   # Laravel lokal (v1 saja)
flutter build apk --release \
            --dart-define=API_BASE_URL=https://<staging>/api      # rilis: wajib HTTPS
```
- HTTP biasa (backend lokal) hanya diizinkan di build debug/profil (`android/app/src/{debug,profile}/AndroidManifest.xml`); build rilis menolak cleartext.
- HP fisik: pakai IP LAN komputer (`http://192.168.x.x:8080/api`) dan jalankan backend dengan `LISTEN_ADDR=0.0.0.0:8080` (Rust) atau `--host=0.0.0.0` (Laravel).

`flutter analyze`, `dart format .`, dan `flutter test` harus bersih sebelum commit.

## Kontrak API
Pemilik kontrak: repo `eabsensi-mobile-api` (`docs/openapi.yaml`, `docs/api.md`, rancangan `docs/api-v2-design.md`). Salinan ter-pin ada di `api/openapi.yaml`, asal commit-nya di `api/CONTRACT_VERSION`, sehingga build tidak bergantung pada folder tetangga.
```bash
dart run tool/sync_contract.dart
```
Skrip itu menyalin ulang dari `../eabsensi-mobile-api` (atau path yang diberikan sebagai argumen). `/api/v2/*` (refresh token) hanya ada di Rust; terhadap Laravel aplikasi memakai v1.

### Client hasil generator
```bash
dart run tool/generate_api.dart       # api/openapi.yaml -> packages/eabsensi_api
```
- **Generator: [Tonik](https://pub.dev/packages/tonik) 0.11.1** (versi dipin di skrip, runtime `tonik_util` di `pubspec.yaml`). Dipilih karena pure Dart (tanpa Java/JVM, tanpa `build_runner`), mendukung OpenAPI 3.1 (`type: [string, 'null']`, `oneOf` dengan `null` jadi tipe nullable), `multipart/form-data` dengan berkas (`TonikFilePath`), dan backend Dio. Setiap respons membawa `Response` Dio mentah, sehingga satu pemeta galat bisa dipakai untuk semua status, termasuk yang tidak tercantum di kontrak (413, 503).
  - Pembanding: `openapi-generator` (butuh Java), `swagger_parser` (butuh `retrofit` + `json_serializable`/`freezed` + `build_runner`), `space_gen` (dukungan multipart berkas tidak terdokumentasi).
- Hasil generator adalah paket tersendiri `packages/eabsensi_api` (path dependency), **tidak diedit tangan**, dan dikecualikan dari `flutter analyze`.
- Penyesuaian satu-satunya: Tonik 0.11 menyalin `encoding.contentType` `image/jpeg, image/png` apa adanya ke header bagian multipart dan Dio menolaknya. Skrip memberi Tonik salinan spesifikasi yang memakai jenis pertama (`image/jpeg`; aplikasi selalu mengirim JPEG). `api/openapi.yaml` tetap salinan persis kontrak.
- Lapisan tipis di atasnya: `lib/core/api/api_client.dart` (header `Accept`/`Authorization`, timeout sambung 10 dtk dan kirim/terima 60 dtk, refresh token sekali saat 401, pemetaan galat ke `ApiFailure`), `lib/core/api/mappers.dart` (model hasil generator ke model domain; UI tidak menyentuh model hasil generator).

## Uji terhadap backend sungguhan
`test/live/` memanggil repository nyata ke backend yang sedang berjalan (data uji dari `tests/contract/fixtures.sql` di repo API). Dilewati tanpa `LIVE_API`, jadi `flutter test` biasa tetap tanpa jaringan.
```bash
flutter test test/live --dart-define=LIVE_API=http://127.0.0.1:8080/api        # Rust
flutter test test/live --dart-define=LIVE_API=http://127.0.0.1:8000/api        # Laravel (fallback v1)
flutter test test/live/live_auth_test.dart --dart-define=LIVE_API=http://127.0.0.1:8081/api \
            --dart-define=LIVE_SLOW=true   # Rust dengan MOBILE_ACCESS_TOKEN_TTL_MINUTES=2: refresh diam-diam setelah 3 menit
```
Batas login 5/menit per akun: jalankan file satu per satu bila muncul 429. Muat ulang fixture sebelum `live_event_test` dan `live_leave_test` (check-in dan pengajuan hanya sekali per pegawai/tanggal).

### Hasil uji ujung ke ujung
Status 30 Oktober 2026 (`api/CONTRACT_VERSION`: `eabsensi-mobile-api` f6853ba).

| Alur | Rust lokal (f6853ba, `cargo run`) | Laravel lokal (`eabsensi-v2` 16d9f68) | Emulator | HP fisik |
|---|---|---|---|---|
| Login, profil, pesan galat kontrak | lulus (live) | lulus, fallback v1 (live) | belum | belum |
| Refresh token diam-diam (TTL 2 menit, cek setelah 3 menit) | lulus (live) | tidak berlaku (v1) | belum | belum |
| Punch foto + lokasi, aturan 60 detik, pegawai nonaktif | lulus (live) | lulus (live) | belum | belum |
| Riwayat hari ini / detail hari (`?date=`, jam zona bisnis) | lulus (live + widget) | lulus (live) | belum | belum |
| Event: check-in, check-in kedua, 404 | lulus (live) | lulus (live) | belum | belum |
| Cuti: ajukan, tumpang tindih, > 62 hari, kategori jenis | lulus (live) | lulus (live) | belum | belum |
| Keluar (token dicabut di server) | lulus (live) | lulus (live) | belum | belum |
| 401 token dicabut -> login | lulus (live, login ulang perangkat sama) | lulus (live) | belum | belum |
| 429 | lulus (live: login > 5/menit, `Retry-After` dibaca) | lulus (live) | belum | belum |
| Offline | test unit/widget saja | test unit/widget saja | belum | belum |
| Mode terang dan gelap | - | - | belum | belum |

"live" = `test/live` (repository nyata, tanpa UI). Alur layar mode nyata (login -> beranda -> Check In -> keluar, token dicabut -> login) diuji dengan HTTP palsu di `test/features/real_mode_test.dart`. Belum dijalankan di emulator/HP: di mesin ini tidak ada AVD maupun perangkat terhubung, dan sebagian lisensi Android SDK belum diterima (`flutter doctor --android-licenses`). Staging HTTPS belum diuji.

## Rilis dan pembaruan dalam aplikasi
Tag `vMAJOR.MINOR.PATCH` memicu CI yang membangun APK bertanda tangan dan menerbitkannya sebagai GitHub Release; aplikasi memeriksa `version.json` dan memasang pembaruan lewat **Profil → Pembaruan aplikasi** (pengguna tetap mengetuk "Pasang"). Persiapan keystore, GitHub Secrets, dan batasannya: [docs/rilis-dan-pembaruan.md](docs/rilis-dan-pembaruan.md).

## Keputusan teknis
- **State management: Riverpod** (`flutter_riverpod` 3). Dependensi (repository, layanan lokasi, jam) disuntikkan lewat provider sehingga mock dan implementasi nyata bisa ditukar dan di-override di test tanpa mengubah UI.
- **Routing: `go_router`**. Redirect berbasis sesi (belum login ke `/login`, token dicabut kembali ke login) dan `StatefulShellRoute` untuk navigasi bawah.
- **Struktur**: `lib/core/{config,design,routing,...}` dan `lib/features/<fitur>/{domain,data,presentation}`.
- **Font**: Plus Jakarta Sans dibundel sebagai aset (lisensi OFL di `assets/fonts/OFL.txt`), jadi test dan golden tidak butuh jaringan.
- **Ikon**: `phosphor_flutter`.
- **Peta**: `flutter_map` (tile OpenStreetMap saat jalan di perangkat; test tidak memuat tile).
- **Konfigurasi build**: `API_BASE_URL` dan `USE_MOCK` lewat `--dart-define` (`lib/core/config/app_config.dart`).
