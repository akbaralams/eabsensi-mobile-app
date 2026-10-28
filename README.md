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
            --dart-define=API_BASE_URL=http://10.0.2.2:8000/api   # backend Laravel lokal
```
`flutter analyze`, `dart format .`, dan `flutter test` harus bersih sebelum commit.

## Keputusan teknis
- **State management: Riverpod** (`flutter_riverpod` 3). Dependensi (repository, layanan lokasi, jam) disuntikkan lewat provider sehingga mock dan implementasi nyata bisa ditukar dan di-override di test tanpa mengubah UI.
- **Routing: `go_router`**. Redirect berbasis sesi (belum login ke `/login`, token dicabut kembali ke login) dan `StatefulShellRoute` untuk navigasi bawah.
- **Struktur**: `lib/core/{config,design,routing,...}` dan `lib/features/<fitur>/{domain,data,presentation}`.
- **Font**: Plus Jakarta Sans dibundel sebagai aset (lisensi OFL di `assets/fonts/OFL.txt`), jadi test dan golden tidak butuh jaringan.
- **Ikon**: `phosphor_flutter`.
- **Peta**: `flutter_map` (tile OpenStreetMap saat jalan di perangkat; test tidak memuat tile).
- **Konfigurasi build**: `API_BASE_URL` dan `USE_MOCK` lewat `--dart-define` (`lib/core/config/app_config.dart`).
