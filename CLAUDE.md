# eabsensi-mobile-app

Aplikasi pegawai eAbsensi (Flutter): login, punch dengan foto dan lokasi, riwayat punch, check-in event (mis. upacara), dan pengajuan cuti. Klien murni dari kontrak API mobile; tidak ada aturan bisnis yang diputuskan di aplikasi.

Pekerjaan berurutan ada di [TASKS.md](TASKS.md); integrasi API sungguhan di [TASKS-API.md](TASKS-API.md) (menggantikan Task 3). Kerjakan satu task sampai kriteria selesainya terpenuhi, commit, lalu lanjut.

## Sistem empat repo
| Repo | Folder lokal | Peran |
|---|---|---|
| `eabsensi-v2` | `../eabsensi-v2` | Web operator (Laravel). Masih melayani API mobile v1 (`/api/*`). |
| `eabsensi-mobile-api` | `../eabsensi-mobile-api` | API mobile Rust, **pemilik kontrak**. v1 identik dengan Laravel; `/api/v2/*` hanya di sini. |
| `eabsensi-adms` | `../eabsensi-adms` | Server mesin absensi. Tidak berhubungan langsung dengan aplikasi. |
| `eabsensi-mobile-app` | repo ini | Aplikasi pegawai. |

## Kontrak API (satu-satunya sumber)
- Pemilik: `../eabsensi-mobile-api`. Spesifikasi mesin `docs/openapi.yaml` (OpenAPI 3.1), penjelasan dan aturan `docs/api.md`, rancangan berikutnya `docs/api-v2-design.md` di repo itu.
- Salinan ter-pin di repo ini: `api/openapi.yaml`, asalnya di `api/CONTRACT_VERSION`. Perbarui dengan `dart run tool/sync_contract.dart`, lalu bangkitkan ulang client (`dart run tool/generate_api.dart`). Build tidak membaca folder tetangga.
- `/api/*` (v1) jalan di Laravel dan Rust; `/api/v2/*` hanya di Rust (Laravel 404), jadi aplikasi jatuh ke v1 bila v2 tidak ada.
- Jangan menambah atau mengubah endpoint dari sini. Butuh data baru: minta perubahan kontrak di repo API dulu (daftar di [docs/usulan-kontrak-api.md](docs/usulan-kontrak-api.md)).

## Aturan aplikasi
- Selalu kirim `Accept: application/json`. Token dari login disimpan di penyimpanan aman (Keychain/Keystore), bukan shared preferences biasa. Respons 401 di endpoint mana pun = token dicabut/kedaluwarsa: hapus token dan kembali ke login.
- `device_name` saat login stabil per instalasi (satu token per perangkat; login ulang menggantikan token lama).
- **Waktu punch dari server.** Aplikasi tidak mengirim waktu dan tidak punya antrean punch offline; tanpa jaringan, punch gagal dengan pesan yang jelas.
- Foto wajib bila `/me` `requires_photo`; status punch `pending` berarti menunggu persetujuan atasan (tampilkan apa adanya). Ikuti flag dari `/me`, jangan di-hardcode.
- Pesan penolakan aturan (422 dengan `message` saja) ditampilkan apa adanya; galat validasi (422 dengan `errors`) ditampilkan per field.
- Lokasi dikirim bila izin diberikan (`latitude`, `longitude` berpasangan, `accuracy` meter).
- Bahasa antarmuka Indonesia; istilah netral (Department, nomor pegawai), tanpa SKPD/NRK.
- Aksesibilitas: target sentuh minimal 48dp, kontras teks memadai, status tidak hanya lewat warna, dukung ukuran teks sistem dan mode gelap. Arah visual boleh mengikuti `../eabsensi-v2/DESIGN.md` (desain "Soft").

## Versi (wajib terbaru)
Flutter dan Dart **stable terbaru**, dan setiap paket pub pada rilis stabil terbaru saat ditambahkan (cek pub.dev, bukan dari ingatan). `pubspec.lock` di-commit. Saat mulai sesi baru, cek `flutter upgrade` (dengan izin user) dan `flutter pub outdated`.

## Environment (Windows)
- Flutter terpasang di `C:\tools\flutter` (saat repo dibuat: 3.29.3 / Dart 3.7.2, sudah tertinggal; Task 0 menaikkannya). Android SDK di `%LOCALAPPDATA%\Android\Sdk`, Android Studio terpasang.
- Backend lokal untuk uji:
  - Rust (utama): di `../eabsensi-mobile-api` jalankan `cargo run` (port 8080). `API_BASE_URL=http://10.0.2.2:8080/api`.
  - Laravel (pembanding, v1 saja): di `../eabsensi-v2` jalankan `php artisan serve --host=0.0.0.0 --port=8000` (PHP `C:\laragon\bin\php\php-8.5.11`). `API_BASE_URL=http://10.0.2.2:8000/api`.
  - Emulator Android menjangkau host lewat `10.0.2.2`. Data uji: `bash scripts/contract-test.sh` atau `tests/contract/fixtures.sql` di repo API (akun `kontrak`, `kontrak.tanpa-pegawai`, `kontrak.akun-nonaktif`, `kontrak.pegawai-nonaktif`; sandi di `TASKS-API.md`).

## Standar kode
- `dart format`, `flutter analyze` tanpa isu, `flutter test` hijau sebelum commit.
- Model dan client API dibangkitkan dari `api/openapi.yaml` (TASKS-API API-1), tidak ditulis tangan; skrip pembangkitnya di-commit agar bisa diulang.
- Base URL lewat konfigurasi build (`--dart-define`), bukan di-hardcode.

## Git
- Conventional Commits, satu commit per task/perubahan utuh beserta test-nya.
- Jangan `git push` kecuali diminta. Jangan commit keystore, file signing, atau kredensial.
