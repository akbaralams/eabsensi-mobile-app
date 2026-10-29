# Task integrasi REST API (eabsensi-mobile-api)

Menyambungkan aplikasi ke API mobile sungguhan, menggantikan repository dummy (`lib/features/*/data/mock_*`). Urutan wajib. Tiap task selesai bila kriteria "Selesai bila" terpenuhi dan sudah di-commit (Conventional Commits, beserta test-nya). Tandai `[x]` saat selesai.

File ini menggantikan **Task 3** di [TASKS.md](TASKS.md) dan bagian "diuji terhadap backend" di Task 4-9. Tampilan tidak diubah kecuali disebut.

## Kontrak dan backend

- **Pemilik kontrak**: repo `../eabsensi-mobile-api` (service Rust).
  - Spesifikasi mesin: `../eabsensi-mobile-api/docs/openapi.yaml` (OpenAPI 3.1).
  - Penjelasan dan aturan: `../eabsensi-mobile-api/docs/api.md`.
  - Rancangan fitur berikutnya: `../eabsensi-mobile-api/docs/api-v2-design.md`.
- **`/api/*` (v1)**: identik di Laravel (`../eabsensi-v2`) dan Rust. Aplikasi yang memakai v1 jalan di kedua backend.
- **`/api/v2/*`**: versi 2 API mobile, saat ini hanya refresh token (`/api/v2/auth/login`, `/refresh`, `/logout`). **Hanya ada di Rust.** Laravel membalas 404, jadi aplikasi wajib jatuh ke v1 selama backend belum dialihkan ke Rust.
- **Backend lokal untuk uji**:
  - Rust: di `../eabsensi-mobile-api` jalankan `cargo run` (`:8080`, database dev PG18 `eabsensi_v2`).
  - Laravel: `php artisan serve --host=0.0.0.0 --port=8000` di `../eabsensi-v2` (pembanding).
  - Emulator Android menjangkau host lewat `http://10.0.2.2:<port>/api`.
- **Data uji**: muat dengan `bash scripts/contract-test.sh` di repo API, atau `psql ... -f tests/contract/fixtures.sql` di sana.
  - Akun: `kontrak` (normal), `kontrak.tanpa-pegawai` (403), `kontrak.akun-nonaktif` (sandi dianggap salah), `kontrak.pegawai-nonaktif` (punch ditolak).
  - Sandi semua akun: `kontrak-uji-2026`.
  - Event hari ini: "Apel Kontrak".

## Hal yang harus diketahui sebelum mulai

- **Zona waktu bisnis, bukan zona perangkat.** Semua waktu dari server ISO 8601 dengan offset zona bisnis (`timezone` di `/me`, default `Asia/Jakarta`, mis. `2026-10-29T01:00:13+07:00`).
  - Pegawai di WITA/WIT harus tetap melihat jam punch dan "hari ini" menurut zona bisnis.
  - `DateTime.parse` mengubah ke UTC/lokal perangkat; tampilkan jam dari offset di string (atau paket zona waktu), jangan dari `toLocal()`.
  - Tanggal `?date=` di `GET /punches` juga dihitung di zona bisnis.
- **Kode jenis cuti nyata** adalah `CUTI`, `IZIN`, `SAKIT`, `DINAS` (bukan berawalan `C-`/`I-`/`D-`). `LeaveCategory.forCode` sekarang memasukkan semuanya ke "Lainnya".
- **`username` bisa `null`** di kontrak (akun lama yang login dengan email). Web kini mewajibkannya untuk akun pegawai, tetapi model hasil generator tetap `String?`; domain memakai cadangan (email atau nama) agar aplikasi tidak pernah crash.
- **Pesan penolakan aturan** (422/403 dengan `message` saja) ditampilkan apa adanya. **Galat validasi** (422 dengan `errors`) per field.
- **Batas laju**: 429 dengan header `Retry-After` (login juga 429 saat server sibuk memverifikasi sandi). Batas aksi 20/menit per pengguna; jangan mengirim ulang otomatis berulang-ulang.
- **Ukuran body** maks 5 MB (413). Foto maks 4 MB; target unggahan ±50-100 KB (lihat API-3) karena memengaruhi biaya server dan bandwidth (`../eabsensi-mobile-api/docs/kebutuhan-infrastruktur.md`).

## [x] API-0. Sumber kontrak dan konfigurasi

- Salin `../eabsensi-mobile-api/docs/openapi.yaml` ke `api/openapi.yaml` dan catat commit asalnya di `api/CONTRACT_VERSION`, agar build tidak bergantung pada folder tetangga. Skrip `tool/sync_contract.*` untuk memperbarui keduanya.
- Perbarui `CLAUDE.md` dan `README.md`: sumber kontrak pindah ke `eabsensi-mobile-api`; `API_BASE_URL` contoh untuk Rust (`http://10.0.2.2:8080/api`) dan Laravel (`:8000`).
- Perbarui `docs/usulan-kontrak-api.md`: tandai usulan yang sudah masuk rancangan `../eabsensi-mobile-api/docs/api-v2-design.md` (rekap bulanan, menu, peran atasan, notifikasi, persetujuan, QR, lampiran) dan yang belum (lokasi kantor/geofence, jadwal hari ini, kategori jenis cuti).
- **Selesai bila**: berkas kontrak ter-pin di repo; dokumen menunjuk ke repo API.

## [x] API-1. Client API dari OpenAPI dan pemetaan galat

- Bangkitkan model dan client Dart dari `api/openapi.yaml` dengan generator stabil terbaru. Syarat: mendukung OpenAPI 3.1 (tipe nullable `type: [string, 'null']`, `oneOf` null), `multipart/form-data` dengan berkas, dan tidak butuh Java bila ada pilihan setara. Catat pilihan dan alasannya di README. Skrip `tool/generate_api.*` di-commit, hasil generator di folder tersendiri (mis. `lib/core/api/generated/`) dan tidak diedit tangan.
- Lapisan HTTP tipis di atas client hasil generator:
  - `Accept: application/json` di setiap request;
  - `Authorization: Bearer` dari `TokenStore`;
  - base URL dari `AppConfig.baseUrl`;
  - timeout: sambung 10 dtk, kirim/terima 60 dtk (unggah foto di jaringan lambat; server memutus di 60 dtk).
- Pemetaan galat ke `ApiFailure` (`lib/core/network/api_failure.dart`):

  | Respons | Galat |
  |---|---|
  | 401 | `UnauthenticatedFailure` |
  | 403 dengan `message` | `ForbiddenFailure(message)` |
  | 404 | `UnknownFailure` dengan pesan umum |
  | 413 | pesan "Ukuran foto terlalu besar." |
  | 422 dengan `errors` | `ValidationFailure` |
  | 422 `message` saja | `RuleRejectedFailure` |
  | 429 | `TooManyRequestsFailure` (simpan `Retry-After`) |
  | 503 | "Server sedang sibuk. Coba lagi sebentar lagi." |
  | tanpa jaringan / timeout | `OfflineFailure` |
  | body bukan JSON | `UnknownFailure` |

- Pemetaan model hasil generator ke model domain yang sudah ada (`*/domain/*.dart`); UI tidak menyentuh model hasil generator.
- **Selesai bila**: test unit pemetaan galat lulus memakai contoh respons persis dari kontrak:
  - `{"message":"Unauthenticated."}` (401);
  - `{"message":"Username atau kata sandi salah."}` (422);
  - `{"message":"Akun ini belum terhubung ke data pegawai."}` (403);
  - 422 dengan `errors.photo`;
  - `{"message":"Too Many Attempts."}` dengan `Retry-After: 42`;
  - 413 dan 503.

## [x] API-2. Login, refresh token, profil, keluar

- `AuthRepository` nyata, dengan alur login berurutan:
  - `POST /api/v2/auth/login` lebih dulu;
  - bila 404 (backend masih Laravel), pakai `POST /api/auth/login` (v1, tanpa refresh token).
  - Pesan galat dan `device_name` stabil sama dengan sekarang.
- `TokenStore` menyimpan `token`, `token_expires_at`, `refresh_token`, `refresh_expires_at` di penyimpanan aman (Keystore). Token v1 disimpan tanpa refresh token.
- Refresh token:
  - saat aplikasi dibuka, bila sisa masa berlaku token akses < 1 hari, panggil `POST /api/v2/auth/refresh`;
  - interceptor: respons 401 di endpoint mana pun -> refresh **satu kali**, lalu ulangi request itu;
  - refresh dijalankan **satu per satu** (request lain menunggu hasil refresh yang sedang berjalan, karena dua refresh serentak hanya satu yang berhasil);
  - refresh 401 -> `SessionController.expire()` (kembali ke login);
  - refresh 403 -> tampilkan pesan apa adanya lalu ke login.
- `fetchMe` dari `GET /api/me`. `username` `null` -> cadangan email/nama di domain. `requires_photo`, `requires_approval`, `timezone` diikuti apa adanya.
- Keluar: `POST /api/v2/auth/logout` (mencabut token akses + refresh token perangkat), atau `/api/auth/logout` untuk token v1. Token di perangkat tetap dihapus walau server tidak terjangkau.
- **Selesai bila**:
  - login `kontrak` ke Rust lokal berhasil dan profil tampil;
  - `kontrak.tanpa-pegawai` dan `kontrak.akun-nonaktif` menampilkan pesan kontrak apa adanya;
  - dengan backend Rust ber-`MOBILE_ACCESS_TOKEN_TTL_MINUTES=2`, aplikasi tetap masuk setelah 3 menit (refresh berjalan diam-diam);
  - token yang dicabut dari web (ubah sandi/nonaktifkan akun) membawa ke layar login;
  - login terhadap Laravel (`:8000`) tetap berhasil lewat fallback v1;
  - test unit untuk interceptor refresh (sekali, satu per satu, 401 kedua -> logout).
- **Verifikasi (30 Okt 2026, `test/live/live_auth_test.dart`, repository nyata tanpa emulator):**
  - Rust lokal (`eabsensi-mobile-api` f6853ba, `:8081`, `MOBILE_ACCESS_TOKEN_TTL_MINUTES=2`): login `kontrak` + `/me`, pesan `kontrak.tanpa-pegawai` dan `kontrak.akun-nonaktif` apa adanya, refresh diam-diam setelah 3 menit (satu refresh), token dicabut -> sesi berakhir, keluar mencabut token. Lulus.
  - Laravel lokal (`eabsensi-v2` 16d9f68, `:8000`): login lewat fallback v1 (v2 dibalas 404), pesan galat sama, token dicabut -> sesi berakhir. Lulus.
  - Pencabutan token diuji dengan login ulang `device_name` yang sama (mencabut pasangan lama). **Belum**: ubah sandi/nonaktifkan akun dari web dan alur layar di emulator/HP (lihat API-8).

## [x] API-3. Punch dan riwayat hari ini

- `PunchRepository` nyata:
  - `POST /api/punches` multipart: `photo` berkas, `latitude`/`longitude` berpasangan, `accuracy` bilangan bulat meter. Tanpa field waktu.
  - `GET /api/punches?date=YYYY-MM-DD` dengan tanggal zona bisnis.
- Kompres foto sebelum kirim, mis. sisi terpanjang 720 px, JPEG kualitas ±80. Target ±50-100 KB, maks jauh di bawah 4 MB.
- Status `pending` tampil "Menunggu atasan" (sesuai `status_label` atau pemetaan yang sudah ada); jam dari `punched_at` dalam zona bisnis.
- Kartu absen dan Status Kehadiran di Beranda serta tab Absensi memakai `todayPunchesProvider` dari server.
- **Selesai bila**:
  - punch `kontrak` berhasil dan fotonya tampil di halaman persetujuan punch web (`../eabsensi-v2`, menu Persetujuan punch);
  - punch kedua dalam 60 detik menampilkan "Tunggu 60 detik sebelum melakukan punch lagi." apa adanya;
  - `kontrak.pegawai-nonaktif` menampilkan "Pegawai tidak aktif.";
  - mode pesawat menampilkan layar galat offline;
  - ukuran foto terkirim tercatat di log debug.
- **Verifikasi (30 Okt 2026, `test/live/live_punch_test.dart` terhadap Rust lokal `:8081`):** punch `kontrak` 201 `pending` dengan foto; berkas foto tersimpan identik di `eabsensi-v2/storage/app/private/mobile-punches/...` beserta lat/long/akurasi; punch kedua menampilkan "Tunggu 60 detik sebelum melakukan punch lagi."; `kontrak.pegawai-nonaktif` menampilkan "Pegawai tidak aktif."; `GET /punches?date=` memuat punch itu dengan jam zona bisnis; log debug mencatat ukuran foto (`Foto bukti terkirim: 19.9 KB`, `[photo=19.9 KB]`). Bukti kosong (foto tidak wajib + lokasi ditolak) tetap terkirim (Tonik menolak multipart kosong; `ApiClient.postEmptyMultipart`).
  - **Belum**: melihat foto di halaman Persetujuan punch web, mode pesawat di HP, dan ukuran hasil kompresi kamera sungguhan (JPEG 80, sisi pendek maks 480) di perangkat.

## [ ] API-4. Event (upacara)

- `EventRepository` nyata:
  - `GET /api/events` (event hari ini, `checked_in`);
  - `POST /api/events/{id}/check-in` multipart dengan bukti yang sama dengan punch (kompresi foto sama).
- 404 (event dihapus) -> muat ulang daftar dengan pesan singkat.
- **Selesai bila**: check-in "Apel Kontrak" berhasil dan status berubah menjadi sudah check-in; check-in kedua menampilkan "Anda sudah check-in di event ini."; event di luar jam menampilkan "Check-in dibuka pukul HH:MM sampai HH:MM." apa adanya.

## [ ] API-5. Cuti

- `LeaveRepository` nyata:
  - `GET /api/leaves`: `data` + `types`, urut tanggal mulai terbaru;
  - `POST /api/leaves` JSON: `attendance_status_id`, `start_date`/`end_date` `YYYY-MM-DD`, `reason` opsional.
- Perbaiki pengelompokan jenis cuti untuk kode nyata. Sampai kontrak punya field kategori: `CUTI` -> Cuti, `IZIN` dan `SAKIT` -> Izin, `DINAS` -> Dinas Luar, lainnya -> Lainnya. Pemetaan di satu tempat (`LeaveCategory`) dengan test. Menu beranda Cuti/Izin/Sakit/Dinas Luar membuka jenis yang benar.
- Galat validasi per field (`errors.end_date`, dst.); pesan aturan apa adanya.
- **Selesai bila**:
  - pengajuan `kontrak` muncul di halaman cuti web dengan status menunggu;
  - rentang > 62 hari menampilkan "Rentang cuti maksimal 62 hari.";
  - tumpang tindih menampilkan "Pegawai sudah punya pengajuan yang menunggu atau disetujui pada tanggal tersebut.";
  - keempat jenis bawaan masuk kategori yang benar.

## [ ] API-6. Riwayat

- Kontrak saat ini hanya punya `GET /api/punches?date=`, tanpa rekap bulanan dan klasifikasi terlambat/tidak hadir.
- Repository nyata:
  - hari ini dan detail hari (bottom sheet) dari `?date=`;
  - daftar bulan menampilkan hari yang punya punch, **tanpa** mengarang Terlambat/Tidak Hadir (`supportsClassification == false`, tile disembunyikan seperti sekarang).
- Jangan memanggil `?date=` untuk setiap hari dalam sebulan sekaligus (30 request per buka layar). Muat per hari saat dibuka, atau tunggu endpoint rekap.
- Setelah `GET /api/v2/attendance/monthly` tersedia di repo API (rancangan fase 1), ganti sumber bulan ke endpoint itu dan aktifkan klasifikasi.
- **Selesai bila**: hari ini dan detail hari tampil dari server dengan jam zona bisnis; tidak ada status yang dikarang klien.

## [ ] API-7. Fitur yang menunggu API v2

Tetap memakai data contoh/statis sampai endpoint-nya ada di repo API. Jangan menambah endpoint dari sini. Begitu tersedia, masing-masing jadi task sendiri dengan model dari OpenAPI terbaru:

- Peran atasan: `GET /api/v2/me` `abilities` (menggantikan `isSupervisor`).
- Menu dinamis: `GET /api/v2/menus` (menggantikan `StaticMenuRepository`).
- Notifikasi dan persetujuan: `/api/v2/notifications`, `/api/v2/approvals`.
- QR check-in: field `requires_qr` di event, `qr_code` di check-in (layar pindai QR).
- Lampiran cuti: `POST /api/v2/leaves` multipart.
- **Selesai bila**: daftar ini tercermin di `docs/design/DEVIATIONS.md` dengan rujukan ke rancangan API, dan pita "menunggu kontrak API" tetap tampil di layar terkait.

## [ ] API-8. Uji ujung ke ujung dan mode rilis

- Build rilis default `USE_MOCK=false` (mock hanya lewat `--dart-define=USE_MOCK=true` atau build debug). Semua `UnimplementedError` di provider hilang.
- Uji di emulator dan perangkat fisik terhadap Rust lokal, lalu staging (base URL HTTPS):
  - login, refresh;
  - punch dengan foto dan lokasi;
  - riwayat;
  - event;
  - cuti;
  - keluar;
  - 401 (token dicabut);
  - 429 (punch beruntun cepat);
  - offline.
- Jalankan juga terhadap Laravel `:8000` untuk memastikan fallback v1 dan kontrak identik.
- **Selesai bila**: seluruh alur di atas lulus di perangkat fisik terhadap Rust (mode terang dan gelap); hasilnya dicatat di README (versi backend, tanggal, perangkat).
