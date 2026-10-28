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
```bash
flutter pub get
flutter run --dart-define=USE_MOCK=true                 # data dummy (default selama backend belum ada)
flutter run --dart-define=USE_MOCK=false \
            --dart-define=API_BASE_URL=http://10.0.2.2:8000/api   # server API (emulator -> host)
```
Mode nyata (`USE_MOCK=false`) memakai server untuk login, punch, event, cuti, dan riwayat; inbox (notifikasi/persetujuan) dan menu tetap statis karena belum ada di kontrak. Build APK ke server HTTP lokal: `ALLOW_CLEARTEXT=true flutter build apk --release --dart-define=USE_MOCK=false --dart-define=API_BASE_URL=http://<ip-lan>:8000/api` (build debug otomatis boleh HTTP; produksi wajib HTTPS).

## Client API (dibangkitkan)
Model dan client Dio + Retrofit **dibangkitkan** dari kontrak OpenAPI, tidak ditulis tangan:
```bash
dart run tool/generate_api.dart [path/ke/mobile-api.yaml]   # hasil: lib/core/network/generated (di-commit)
```
Sumber kontrak berurutan: argumen, `../eabsensi-mobile-api/docs/openapi/`, `../eabsensi-v2/docs/openapi/`, lalu salinan `api/mobile-api.yaml` (di-commit, persis kontrak). Pembangkitnya `swagger_parser` (Dart murni, tanpa Java) + `retrofit_generator`/`json_serializable`; konfigurasi di `swagger_parser.yaml`. Sebelum membangkitkan, skrip membuat salinan turunan di `.dart_tool` yang membuat `format: date` dan `date-time` menjadi `String` (lihat alasannya di `tool/generate_api.dart`); konversi ke `DateTime` ada di `lib/core/network/api_time.dart`.

Lapisan tipis di atasnya (`lib/core/network`): `api_providers.dart` (Dio, `Accept: application/json`, Bearer dari penyimpanan aman, timeout), `api_error_mapper.dart` (galat Dio -> `ApiFailure`), dan repository `Remote*` per fitur yang memetakan DTO ke model domain. 401 ditangani `withSession` (hapus token, ke login).
`flutter analyze`, `dart format .`, dan `flutter test` harus bersih sebelum commit.

## Keputusan teknis
- **State management: Riverpod** (`flutter_riverpod` 3). Dependensi (repository, layanan lokasi, jam) disuntikkan lewat provider sehingga mock dan implementasi nyata bisa ditukar dan di-override di test tanpa mengubah UI.
- **Routing: `go_router`**. Redirect berbasis sesi (belum login ke `/login`, token dicabut kembali ke login) dan `StatefulShellRoute` untuk navigasi bawah.
- **Struktur**: `lib/core/{config,design,routing,...}` dan `lib/features/<fitur>/{domain,data,presentation}`.
- **Font**: Plus Jakarta Sans dibundel sebagai aset (lisensi OFL di `assets/fonts/OFL.txt`), jadi test dan golden tidak butuh jaringan.
- **Ikon**: `phosphor_flutter`.
- **Peta**: `flutter_map` (tile OpenStreetMap saat jalan di perangkat; test tidak memuat tile).
- **Konfigurasi build**: `API_BASE_URL` dan `USE_MOCK` lewat `--dart-define` (`lib/core/config/app_config.dart`).
- **HTTP**: Dio 5 + Retrofit (client dibangkitkan dari OpenAPI). Test memakai adapter HTTP palsu (`test/helpers/stub_api.dart`), tanpa server.
