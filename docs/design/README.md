# Handoff Desain: eAbsensi Mobile (Mint)

## Overview
Spesifikasi tampilan aplikasi pegawai eAbsensi (Flutter): login, beranda, check in/out dengan lokasi + foto, riwayat absensi, pengajuan cuti/izin/dinas luar, event (upacara) dengan QR, notifikasi, persetujuan tim, dan profil. Dokumen ini adalah sumber kebenaran visual; aturan bisnis tetap mengikuti `CLAUDE.md` dan kontrak API.

## Tentang file desain
File di `docs/design/prototype/` adalah **referensi desain dalam HTML**, bukan kode produksi. Tugasnya adalah **membangun ulang tampilan ini di Flutter** memakai pola repo (struktur per fitur, state management dan routing yang dipilih di Task 1). Jangan menyalin HTML/JS.

Cara membuka prototipe: buka `docs/design/prototype/eAbsensi-prototype.dc.html` di browser (file `support.js` harus satu folder). Panel di kanan ponsel berisi tombol lompat layar, skenario uji (di area, di luar area, offline) dan simulasi menu dinamis.

## Fidelity
**High-fidelity.** Warna, tipografi, radius, bayangan, jarak, dan teks sudah final. Bangun semirip mungkin (pixel-close) dengan widget Flutter. Kanvas acuan: 390 × 844 logical px (iPhone 14/15). Layout harus tetap rapi di lebar 360–430.

## Design tokens

### Font
- **Plus Jakarta Sans** (paket `google_fonts` atau aset lokal), weight 400/500/600/700/800.
- Ikon: **Phosphor** (paket `phosphor_flutter`), gaya *regular*; gaya *fill* untuk tab aktif, ikon status, dan ikon status bar.

### Skala tipe (size / weight)
| Token | Size | Weight | Pemakaian |
|---|---|---|---|
| brand | 32 | 800, letter-spacing −0.02em | "eAbsensi" di login |
| clock | 38 | 800, −0.02em, tabular figures | jam di kartu beranda |
| resultTime | 60 | 800, −0.03em | jam di layar berhasil |
| title | 22 | 800 | judul halaman Profil, "Ambil foto" |
| header | 17 | 800 | judul header layar, nama user |
| cardTitle | 15 | 800 | judul kartu/section |
| body | 14 | 500–700 | isi, input, menu |
| small | 13 | 400–700 | label field, sub-teks |
| caption | 12 | 400–600 | meta, helper, error |
| micro | 11 | 600–700 | chip status, label tile, label tab |

### Warna
| Token | Hex | Pemakaian |
|---|---|---|
| textPrimary | `#053B2C` | teks utama, ikon |
| textSecondary | `#3F5F53` | sub-teks di atas tint |
| textMuted | `#4B6B5F` | label, meta, ikon nonaktif |
| primary | `#10B981` | aksen, checkbox, dot geofence |
| primaryDark | `#059669` | gradien tombol (awal), tab aktif, ikon hijau |
| primary700 | `#047857` | teks di atas tint mint |
| teal | `#14B8A6` | logo, gradien |
| tealDark | `#0D9488` | gradien tombol (akhir), ikon teal |
| mint300 | `#6EE7B7` | gradien badge/avatar |
| mint400 | `#34D399` | logo, highlight scan |
| mint200 | `#A7F3D0` | blob gradien |
| mint100 | `#D1FAE5` | tint chip sukses, tile ikon |
| teal100 | `#CCFBF1` | tint tile ikon teal |
| mint50 | `#ECFDF5` | tile statistik Hadir |
| bgMint | `#F0FDF4` | segmented track, tombol sekunder, ikon bulat |
| surface | `#FFFFFF` | kartu, input, nav |
| border | `#D5E6DE` | border input & tombol outline |
| divider | `#E3EFE9` | garis pemisah, separator |
| rowDivider | `#F0F5F2` | garis antar baris list |
| warning | `#F59E0B` | dot notifikasi, dot di luar area |
| warningIcon | `#D97706` | ikon amber |
| warningTint | `#FEF3C7` | chip Terlambat/Menunggu, kotak pesan aturan |
| warningText | `#B45309` / `#92400E` | teks di atas tint amber |
| warning50 | `#FFFBEB` | tile statistik Terlambat |
| error | `#B91C1C` | teks error, tombol Keluar |
| errorStrong | `#DC2626` | angka Tidak Hadir |
| errorTint | `#FEE2E2` / `#FEF2F2` | chip/tile Tidak Hadir |
| errorBorder | `#F87171` | border input invalid |

### Gradien
- **Latar layar**: tumpukan `radial(90%×40% di kanan-atas, #D1FAE5 → transparan 70%)` + `radial(80%×35% di kiri 5%, #CCFBF1 → transparan 70%)` + `linear(atas→bawah, #F0FDF4 0% → #FFFFFF 60%)`.
- **Tombol utama**: `linear(90°, #059669 → #0D9488)`, teks putih 15/700, shadow `0 10 24 rgba(5,150,105,.28)`.
- **Kartu jam (hero)**: `radial(60%×90% di kanan 30%, #A7F3D0 → transparan 70%)` di atas `#F0FDF4`.
- **Badge jam**: `linear(145°, #6EE7B7 → #14B8A6)`, radius 26, rotasi −8°, shadow `0 14 28 rgba(13,148,136,.3)`, berisi lingkaran putih 58 dengan ikon `clock` 34 `#059669`. Animasi naik-turun 6px, 5s ease-in-out, loop.
- **Banner event**: `linear(100°, #D1FAE5 → #CCFBF1)`.
- **Avatar**: `linear(135°, #6EE7B7 → #14B8A6)`, inisial putih 800.
- **Kamera/QR**: `linear(160°, #064E3B → #0F766E 60% → #14B8A6)`.

### Radius
kartu 24 (kartu sekunder 22, list item 16) · tile menu 18 · tombol 16 · input 14 · segmented track 14 / segmen 11 · ikon kotak 12–13 · chip 999 · nav bawah 26 (atas saja) · tombol ikon bulat 999.

### Bayangan
- kartu: `0 8 28 rgba(6,78,59,.07)` (sekunder `.06`)
- tile/list: `0 6 20 rgba(6,78,59,.06)` / `0 4 14 rgba(6,78,59,.05)`
- tombol ikon bulat: `0 4 14 rgba(6,78,59,.08)`
- nav bawah: `0 -6 24 rgba(6,78,59,.06)`
- toast: `0 10 30 rgba(6,78,59,.3)`

### Jarak
Padding horizontal layar 18 · jarak antar blok 14 · padding kartu 16 · gap grid 10 · tinggi target sentuh minimal 48 (tombol utama 54, input 50, item menu 54) · tinggi nav bawah 88 (termasuk 20 inset bawah) · padding bawah konten 110 agar tidak tertutup nav.

### Mode gelap
`CLAUDE.md` mewajibkan mode gelap; prototipe hanya light. Turunkan palet gelap dengan peran yang sama: background `#0F172A`, surface `#1E293B`, surface alt/border `#334155`, teks `#F8FAFC` / `#CBD5E1` / `#94A3B8`, tint sukses `#064E3B` + teks `#6EE7B7`, tint amber `rgba(245,158,11,.18)` + `#FBBF24`, tint error `rgba(239,68,68,.18)` + `#FCA5A5`. Gradien latar diganti radial `#064E3B` tipis di atas `#0F172A`. Primary & gradien tombol tetap.

## Komponen (buat sebagai widget bersama)
| Widget | Spesifikasi |
|---|---|
| `AppScaffold` | latar gradien layar, status bar terang, konten scroll tanpa scrollbar |
| `PageHeader` | grid 46 / judul tengah 17/800 / 46. Tombol kembali bulat 46 putih + shadow, ikon `caret-left` 18 |
| `AppCard` | putih, radius 24, shadow kartu, padding 16 |
| `PrimaryButton` | gradien utama, radius 16, tinggi 54, ikon opsional di kanan; `disabled` = opacity .5; pressed = scale .98 |
| `OutlineButton` | putih, border 1 `#D5E6DE`, radius 16, tinggi 50–52, teks 14/700 |
| `AppTextField` | tinggi 50, radius 14, border `#D5E6DE` (error `#F87171`), ikon kiri 18 `#4B6B5F`, placeholder 14; pesan error 12 `#B91C1C` dengan ikon `warning-circle` |
| `PillSegmented` | track `#F0FDF4` (atau putih + shadow tipis), padding 4, radius 14; segmen aktif = putih + shadow `0 3 10 rgba(6,78,59,.1)` teks `#047857` (Login/SSO) atau gradien utama teks putih (kategori cuti) |
| `StatusChip` | radius 999, padding 4–6 × 9–12, teks 11–12/700, ikon di kiri. Varian: sukses (`#D1FAE5`/`#047857`), terlambat (`#FEF3C7`/`#B45309`), menunggu (`#FEF3C7`/`#92400E`), tidak hadir (`#FEE2E2`/`#B91C1C`), netral (`#F0F5F2`/`#4B6B5F`). Status tidak boleh hanya dari warna: selalu ikon + teks |
| `MenuTile` | putih, radius 18, shadow tile, tinggi min 92, ikon kotak 42 radius 13 berwarna tint, label 11/600 tengah. Nonaktif: opacity .5, grayscale, badge gembok 20 di kanan atas, tidak bisa ditekan |
| `IconCircleButton` | 46, putih, shadow; badge notifikasi dot 8 `#F59E0B` border putih 2 |
| `BottomNav` | putih 94% + blur 16, radius atas 26, 5 item sama lebar; ikon 23, label 11. Aktif: ikon *fill* `#059669` + label 800; nonaktif `#4B6B5F` 500 |
| `AppToast` | `#053B2C`, teks putih 13/600, radius 16, ikon `check-circle` fill `#34D399`, muncul 2,6 dtk di atas nav, animasi naik 8px + fade .3s |

## Layar

### 1. Login
- Atas (padding 48/24/36): logo 4 lingkaran 40 (grid 2×2, gap 4: `#34D399`, `#14B8A6` / `#14B8A6`, `#10B981`, masing-masing gradien radial dari tint terang), animasi melayang. "eAbsensi" brand. Sub "Kehadiran lebih mudah,\nsetiap hari." 14 `#4B6B5F`.
- Latar tambahan: blob radial `#A7F3D0` (kanan 30%) dan `#CCFBF1` (kiri 20%).
- Sheet bawah: putih 88% + blur 16, radius atas 28, padding 20/22/28, gap 14:
  1. `PillSegmented` Login | SSO
  2. Field "NIP / Username" (ikon `user`)
  3. Field "Password" (ikon `lock`, tombol mata tampil/sembunyi)
  4. Baris: checkbox "Ingat saya" (18, radius 5, aktif `#10B981`) ↔ "Lupa password?" 13/600 `#059669`
  5. `PrimaryButton` "Masuk →"
  6. Pemisah "atau masuk dengan" (garis `#E3EFE9`)
  7. `OutlineButton` ikon `buildings` "SSO Perusahaan"
- Validasi: kosong → "NIP atau username wajib diisi." / "Password wajib diisi." (per field). Pesan 422 dari server ditampilkan apa adanya.
- Catatan kontrak: login API = username atau email + password. **SSO dan "Ingat saya" hanya tampil bila kontrak mendukung**; sampai ada, sembunyikan tab SSO/tombol SSO dan checkbox (token selalu disimpan aman).

### 2. Beranda
Urutan vertikal, gap 14, padding 6/18/110:
1. **Header**: logo mini 2×2 (17px) · kolom ("Selamat pagi," 12 muted / "Andi Setiawan" 17/800 / "Tetap semangat hari ini!" 12 muted) · `IconCircleButton` bel. Salam: <11 pagi, <15 siang, <18 sore, selain itu malam.
2. **Kartu absen** (`AppCard`, gap 14):
   - Hero (radius 18, padding 16): tanggal panjang 13 muted ("Senin, 26 Oktober 2026"), jam `clock`, `StatusChip` status hari ini ("Belum Check In" netral / "Sudah Check In" sukses / "Menunggu persetujuan" menunggu / "Sudah Check Out" sukses). Badge jam di kanan.
   - Baris Masuk | Keluar (grid 1fr 1px 1fr): ikon kotak 40 radius 12 (`sign-in` tint mint, `sign-out` tint `#F0FDF4`), label 12, waktu 16/800 (atau "-").
   - Dua tombol tinggi 72, radius 18, ikon 22 di atas label 14/700: **Check In** dan **Check Out**. Tombol yang relevan = gradien utama + teks putih; yang lain = `#F0FDF4` teks gelap.
3. **Status Kehadiran Hari Ini** (`AppCard` sekunder): judul 15/800 + `StatusChip` (Belum absen / Hadir / Terlambat / Menunggu). Dua kolom: ikon bulat 38 amber `timer` "Jam Kerja" `8j 0m`; ikon bulat mint `map-pin` fill "Lokasi" `Kantor Pusat`.
4. **Menu dinamis** (grid 4 kolom, gap 10) — lihat bagian *Menu dinamis*.
5. **Banner event**: gradien banner, radius 20, ikon `qr-code` di kotak putih 40, "Apel Pagi · 07.30" 14/800, sub "Lapangan Utama · check-in pakai QR", caret kanan → layar Event.
6. **Kartu persetujuan** (hanya bila user atasan): ikon `stamp` amber, "3 menunggu persetujuanmu", sub "Absen di luar area & cuti tim" → layar Persetujuan.

### 3. Check In / Check Out (lokasi)
Header "Check In" / "Check Out". Tanpa nav bawah.
- Kartu peta (padding 8): peta tinggi 230 radius 18 (pakai peta asli, mis. `flutter_map`, dengan gaya terang). Lingkaran geofence (fill `rgba(16,185,129,.16)`, garis `rgba(16,185,129,.4)`), label "Kantor Pusat" dengan pin teal, titik posisi user 20 (hijau `#10B981`, atau amber `#F59E0B` bila di luar area) berborder putih 3 + efek pulse, tombol `crosshair` 44 di kanan bawah.
- Di bawah peta: ikon bulat 42 (sukses `check` / luar area `warning` amber / mencari `circle-notch` netral), "Lokasi Anda" 13 muted, status 16/800 berwarna ("Di dalam area kantor" / "Di luar area kantor" / "Mencari lokasi…"). Kotak `#F0FDF4` radius 12: ikon `navigation-arrow` + "Akurasi lokasi: 8 meter".
- Kartu "Informasi Check In": baris (ikon 18 muted · label · nilai 700), pemisah `#F0F5F2`: tanggal, Waktu (`09:41 · server`), Lokasi, Perangkat.
- Bawah: `PrimaryButton` "Konfirmasi Check In" (disabled + teks "Menunggu lokasi…" selama GPS belum didapat), `OutlineButton` "Batal".
- Jika `/me.requires_photo` = true → lanjut ke langkah foto; jika false → langsung kirim.

### 4. Ambil foto
Judul "Ambil foto" 22/800 + sub 13. Preview kamera depan tinggi 400 radius 26, bingkai oval 200×260 garis putih 3 dengan area luar digelapkan `rgba(6,78,59,.3)`. Chip putih di bawah: "Wajah terdeteksi" / "Mengirim…". Tombol shutter 78 bulat (gradien `#10B981 → #0D9488`, border putih 5).

### 5. Hasil absen
Orb 112 (sukses: radial putih → `#34D399` → `#059669`, ikon `check`; menunggu: amber `#FBBF24 → #D97706`, ikon `hourglass-medium`), animasi melayang. "Check In tercatat · waktu server" 13, waktu 60/800 dari **respons server**, `StatusChip` "Disetujui" / "Menunggu atasan", paragraf 14 (`#3F5F53`). `PrimaryButton` "Kembali ke Beranda".

### 6. Galat absen
Kartu dengan ikon bulat amber 46, judul 20/800, pesan 14. Tombol outline "Coba lagi". Kasus:
- Offline: "Tidak ada koneksi" — "Absen membutuhkan jaringan karena waktu dicatat oleh server. Sambungkan internet lalu coba lagi." (tidak ada antrean offline).
- 422 aturan (mis. punch < 60 dtk): tampilkan `message` dari server apa adanya (contoh: "Tunggu 60 detik sebelum melakukan punch lagi.").

### 7. Riwayat Absensi
Header "Riwayat Absensi". Satu `AppCard` berisi:
- Navigasi bulan: tombol bulat 40 `#F0FDF4` kiri/kanan (kanan redup bila bulan berjalan), label "Oktober 2026" 15/800.
- Tiga tile statistik (radius 14, tengah): Hadir (`#ECFDF5`, angka 22/800 `#059669`), Terlambat (`#FFFBEB`, `#D97706`), Tidak Hadir (`#FEF2F2`, `#DC2626`).
- Baris per hari (grid 40 / chip / waktu / caret): tanggal 16/800 + hari 11, `StatusChip`, "07:55 - 16:12" 13 tabular, garis `#F0F5F2`.

### 8. Ajukan Cuti / Izin
Header "Ajukan Cuti / Izin". Gap 14:
- `PillSegmented` gradien: Cuti | Izin | Dinas Luar | Lainnya.
- "Jenis {kategori}": dropdown (ikon `umbrella` teal, caret). Opsi dari **daftar jenis di API**; contoh di prototipe: Cuti → Cuti Tahunan/Melahirkan/Besar; Izin → Sakit/Keperluan Pribadi; Dinas Luar → Dalam Kota/Luar Kota.
- "Tanggal Mulai", "Tanggal Selesai": field dengan ikon `calendar-blank`, date picker.
- "Alasan": textarea tinggi min 80.
- "Lampiran (opsional)": kartu file (ikon `file-pdf` di tint mint, nama 13/700, ukuran 11, tombol hapus bulat 36) atau tombol dashed `#A7D9C4` "Tambah lampiran".
- Info 12: "{n} hari · batas satu pengajuan 62 hari".
- Kotak aturan (tint amber, ikon `prohibit`) untuk 422 `message`: ">62 hari" dan "bertumpuk".
- `PrimaryButton` "Ajukan {kategori}". Sukses → toast "Pengajuan terkirim, menunggu atasan" dan item baru di "Pengajuan terakhir" (list kartu dengan `StatusChip` Menunggu/Disetujui).
- Validasi lokal per field: selesai < mulai, alasan kosong.

### 9. Event (Upacara)
Header "Event Hari Ini". Kartu per event: nama 15/800, meta 12, `StatusChip` (Belum check-in / Sudah check-in / Belum dibuka), tombol gradien "Pindai QR untuk check-in". Pindai: layar kamera gradien gelap radius 26, bingkai 220 radius 26 garis putih, garis scan `#34D399` bergerak naik-turun 1,8 dtk. Sukses → toast. Check-in kedua → kotak amber dengan pesan kontrak ("Anda sudah check-in di event ini.").

### 10. Notifikasi
Header "Notifikasi". Kartu list radius 18: ikon kotak 40 bertint (mint/teal/amber), judul 14 (800 belum dibaca, 600 sudah), meta 12. *Belum ada di kontrak API — tandai sebagai fitur menunggu kontrak.*

### 11. Persetujuan Tim (atasan)
Header "Persetujuan Tim". Kartu: avatar inisial 40, jenis 11/700 amber, nama 15/800, detail 12, waktu 11; tombol "Setujui" (gradien) dan "Tolak" (outline) tinggi 46. *Belum ada di kontrak API.*

### 12. Profil
Judul "Profil" 22/800 + tombol `gear-six`. Kartu identitas: avatar 64, nama 16/800, nomor pegawai 12, Department 12, caret. Kartu menu (item 54, ikon 20, label 14/600, badge kanan 12 muted, caret, pemisah `#F0F5F2`): Data Pribadi, Jadwal & Shift, Riwayat Absensi, Pengajuan Cuti/Izin, Persetujuan Tim (atasan saja), Perangkat Absensi, Notifikasi. Tombol "Keluar" kartu putih, teks 15/800 `#B91C1C`, ikon `sign-out`.

## Navigasi bawah
5 tab: Beranda (`house`), Absensi (`clipboard-text` → mulai Check In/Out sesuai status), Cuti/Izin (`files`), Laporan (`file-text` → Riwayat sampai ada layar laporan), Profil (`user`). Disembunyikan di Login, alur absen, dan layar pindai QR.

## Menu dinamis (beranda)
Grid 4 kolom. Isi dari data, bukan hardcode. Model:
```json
{ "id": "dinas", "label": "Dinas Luar", "icon": "briefcase", "tone": "mint|teal|amber",
  "is_active": true, "action": { "type": "leave_form", "category": "Dinas Luar", "leave_type_id": null },
  "sort": 4 }
```
- `action.type`: `leave_form` (buka form dengan kategori/jenis terpilih), `events` (layar event/upacara), `coming_soon` (toast "{label} segera tersedia").
- Item contoh: Cuti, Izin, Sakit, Dinas Luar, Upacara, Lembur, WFH, Tugas Belajar.
- Nonaktif (`is_active=false`): mode **terkunci** (tampil abu-abu + gembok, tidak bisa ditekan, `Semantics(enabled:false)`) atau **sembunyi**. Mode dikendalikan konfigurasi (default terkunci).
- Tone → warna: mint = tint `#D1FAE5` ikon `#059669`; teal = `#CCFBF1` / `#0D9488`; amber = `#FEF3C7` / `#D97706`.
- **Sumber data butuh kontrak API baru** (mis. `GET /menus` atau field di `/me`). Sesuai aturan repo, ajukan dulu di repo API. Sementara, sediakan `MenuRepository` dengan implementasi statis yang mudah diganti.

## Interaksi & animasi
- Masuk layar: fade + naik 8px, 300–350ms ease.
- Tombol: pressed scale .98; tombol shutter .94.
- Pulse lokasi: lingkaran membesar 0.6→2.6 dan memudar, 1,6 dtk loop.
- Orb hasil & badge jam: melayang 6–8px, 4–5 dtk loop.
- Toast: 2,6 dtk.
- Semua animasi patuhi `MediaQuery.disableAnimations`.

## State
- Sesi: token (secure storage), `/me` (nama, nomor pegawai, Department, `requires_photo`, peran atasan).
- Absen hari ini: daftar punch dari server (waktu server, status `approved`/`pending`); status kartu diturunkan dari punch pertama/terakhir.
- Alur absen: `locating → located(inside|outside) → photo? → submitting → result | error`.
- Riwayat: bulan terpilih + data per tanggal.
- Cuti: kategori, jenis, tanggal, alasan, lampiran, galat per field, galat aturan.
- Event: daftar hari ini, status check-in.
- Menu beranda: daftar dari `MenuRepository`, mode nonaktif.

## Aset
- Font Plus Jakarta Sans (Google Fonts, OFL).
- Ikon Phosphor (MIT) via `phosphor_flutter`.
- Logo = 4 lingkaran (dibuat dengan widget, tidak perlu gambar).
- Tidak ada foto/ilustrasi bitmap.

## File
- `docs/design/prototype/eAbsensi-prototype.dc.html` — prototipe interaktif (buka di browser bersama `support.js`).
- `docs/design/README.md` — dokumen ini.
- `docs/design/screens/` — screenshot acuan tiap layar (390×844, mode terang): `01-login`, `02-beranda`, `03-checkin-lokasi`, `04-ambil-foto`, `05-hasil-absen`, `06-riwayat`, `07-cuti-izin`, `08-event`, `09-persetujuan`, `10-notifikasi`, `11-profil`, `12-beranda-bawah`. Pakai sebagai pembanding golden test. Jam dan tanggal di screenshot hanya contoh.
