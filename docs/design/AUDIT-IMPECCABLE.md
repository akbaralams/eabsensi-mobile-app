# Audit Impeccable: eAbsensi mobile (native Android / Flutter)

Playbook: `audit.native.md` + `android.md` dari skill Impeccable 4.8.0. Audit dari kode (tidak ada `impeccable detect` untuk Dart) dan dari render test di VM. Konteks proyek dibaca dari `CLAUDE.md`, `docs/design/README.md`, dan kode; launcher binary Impeccable (`impeccable context`) sengaja tidak dijalankan.

**Batas bukti.** Belum ada yang diuji di perangkat atau dengan TalkBack. Bukti: (1) render widget test di Linux pada 360 dan 390 dp, teks 1,3x dan 2,0x, mode terang/gelap, tablet 800x1280; (2) ukuran dan semantik node diukur lewat test; (3) pembacaan kode. Yang hanya dari kode ditandai *[kode]*, dugaan ditandai *[dugaan]*.

## Skor kesehatan

| # | Dimensi | Skor | Temuan kunci |
|---|---|---|---|
| 1 | Aksesibilitas | 2/4 | Label, kontras, dan target 48dp bagus, tapi tata letak rusak pada teks besar (2,0x) di Riwayat, Beranda, navigasi bawah |
| 2 | Performa | 3/4 | Blur di navigasi bawah, Beranda dibangun ulang tiap detik *[kode]* |
| 3 | Tampilan & tema | 3/4 | Token dan mode gelap kuat; 14 literal hex di luar token; tanpa Dynamic Color |
| 4 | Kesesuaian platform | 2/4 | Navigasi bawah, toast, header, dan tombol berbentuk non-Material |
| 5 | Adaptivitas | 1/4 | Hanya satu ukuran layar: di tablet jadi UI ponsel yang melar |
| | **Total** | **11/20** | **Acceptable: butuh kerja signifikan** |

### Putusan kesesuaian platform
**Lulus sebagian.** Bukan situs web yang dibungkus: dialog, bottom sheet, date picker, dan switch memakai komponen Material, dan bilah sistem transparan (edge-to-edge). Tapi tampilannya lebih dekat gaya iOS: navigasi bawah buram kustom, tombol kembali berbentuk chevron bulat dengan judul di tengah, toast kustom, tombol gradien dengan bayangan berwarna, dan tab "Absensi" yang bukan tujuan melainkan aksi.

## Halaman Riwayat Absensi (fokus)

Bukti: `riwayat` pada 360 dp x 1,3 (tanpa overflow), x 2,0 (15 pengecualian overflow), 320 dp x 1,3 (2 pengecualian), gelap x 1,3, tablet.

### [P1] Hari ini tidak pernah muncul di Riwayat
- **Lokasi:** `lib/features/history/data/mock_history_repository.dart` (`if (!date.isBefore(today)) continue;`) *[kode]*.
- **Dampak:** pegawai Check In lalu membuka Riwayat dan tidak melihat catatannya, padahal baru muncul besok. Terasa seperti absen gagal.
- **Rekomendasi:** sertakan hari ini (dari `GET /punches?date=hari ini`) dengan status Menunggu/Hadir sementara. Saat kontrak rekap bulanan dibuat, pastikan hari berjalan termasuk.
- **Perintah:** `/impeccable harden`

### [P1] Tata letak rusak pada teks sistem besar (WCAG 1.4.4)
Pada teks 2,0x di 360 dp:
- Judul header pecah dua baris, label bulan menabrak tombol "bulan berikutnya" (overflow).
- Tile statistik tinggi tidak sama dan kata terpotong di tengah ("Terlamb|at", "Tidak|Hadir").
- Kolom tanggal 40 dp tetap memotong nama hari ("Ju|m", "Ka|m"); baris melimpah sehingga jam terpotong.
- Label navigasi bawah terpotong menjadi "Bera…", "Abse…", "Cuti/…", "Lap…".
- Pada 320 dp x 1,3 masih ada 2 overflow.
- Pada 1,3x di 360 dp tampilannya bersih (lihat screenshot).
- **Lokasi:** `history_page.dart` (`_DayRow`: `SizedBox(width: 40)` + `Spacer` + jam; `_Content`: `Row` tile tanpa `IntrinsicHeight`), `bottom_nav.dart` (`maxLines: 1`, ellipsis).
- **Rekomendasi:** baris menjadi dua lapis saat skala teks > 1,3 (tanggal+chip di atas, jam di bawah); kolom tanggal fleksibel; tile statistik bertumpuk vertikal; label navigasi dibatasi skala 1,3 seperti `NavigationBar` Material.
- **Perintah:** `/impeccable adapt`

### [P1] Angka Terlambat dan Tidak Hadir tidak bisa dihitung dari kontrak
- Kontrak hanya punya `GET /punches?date=`; tidak ada rekap bulanan atau klasifikasi terlambat/tidak hadir. Sekarang angka itu berasal dari data dummy, tapi tampil seperti fakta.
- **Rekomendasi:** minta endpoint rekap di repo API sebelum layar ini terhubung ke backend; sampai itu ada, jangan tampilkan angka klasifikasi dari klien.
- **Perintah:** `/impeccable clarify`

### [P2] Konten diganti spinner tiap ganti bulan *[kode, dugaan runtime]*
`data.when(loading: ...)` mengganti tile dan daftar dengan spinner setiap bulan berubah (`skipLoadingOnReload` tidak diset), sehingga layar berkedip dan tinggi loncat. Pertahankan data bulan sebelumnya atau pakai kerangka (skeleton).
`/impeccable harden`

### [P2] Semantik pembaca layar
- Tombol "Bulan berikutnya" saat dinonaktifkan: node tombol tanpa aksi ketuk dan status enabled tidak diset, jadi TalkBack tidak menyebut "nonaktif" *[terukur lewat test]*.
- Baris hari tanpa jam dibacakan "..., jam -" *[kode]*; ganti dengan "tidak ada catatan jam".
`/impeccable clarify`

### [P2] Baris tidak bisa dibuka
Hari berstatus Menunggu tidak bisa dilihat detailnya (punch mana, lokasi, siapa yang menyetujui). Tidak ada tarik-untuk-muat-ulang (Beranda punya). Tidak ada batas bawah atau pemilih bulan: bisa mundur tanpa ujung ke bulan kosong.
`/impeccable shape`

### [P2] Tiga nama untuk satu layar
Tab bernama "Laporan", judul "Riwayat Absensi", menu Profil "Riwayat Absensi". Pilih satu ("Riwayat").
`/impeccable clarify`

### [P2] Lebar tablet
Di 800 dp baris melebar penuh: chip status di kiri dan jam di kanan terpisah sekitar 600 dp, sulit dibaca satu baris. Batasi lebar konten (~600 dp) atau tampilkan dua kolom.
`/impeccable adapt`

### [P3] Tile statistik
Pola "angka besar + label" (craft-floor: hero-metric template) dengan latar tint yang nyaris tak terlihat (amber 1,04:1 terhadap putih; aman karena teks di dalamnya 4,5:1+). Jadikan filter yang bisa diketuk (Terlambat -> hanya hari terlambat); itu juga mengurangi 20+ baris yang harus dipindai.
`/impeccable distill`

### Yang sudah baik di Riwayat
- Status selalu ikon + teks, bukan hanya warna.
- Kontras teks terukur >= 4,5:1 di kedua mode (`test/design/contrast_test.dart`); mode gelap sepadan.
- Tombol bulan 48x48 dp; label bulan `liveRegion`; angka jam tabular.
- Terbaru di atas; state kosong, galat + "Coba lagi", dan pemuatan tersedia.

## Temuan lintas halaman

### [P1] Teks besar merusak navigasi bawah, Beranda, dan segmented (semua layar)
- Navigasi bawah memotong label di semua halaman (lihat atas).
- Beranda pada 2,0x: overflow 34 px; jam "09:4|1" pecah baris dan bertabrakan dengan lencana jam.
- `PillSegmented` (Cuti/Izin/Dinas Luar/Lainnya) memotong label menjadi "Din…", "Lain…" sehingga kategori tak terbaca.
- Pindai ulang di 2,0x: Cuti, Profil, dan Lokasi tidak overflow.
`/impeccable adapt`

### [P2] Batas field terlalu pucat (WCAG 1.4.11)
Border input dan tombol outline `#D5E6DE` terhadap putih hanya 1,30:1 (butuh 3:1). Mode gelap 3,07:1 lolos. Nilai pucat ini mengikuti spesifikasi desain, tetapi `CLAUDE.md` mewajibkan kontras memadai dan aturan itu menang atas desain. Gelapkan border mode terang sampai >= 3:1 dan catat di `DEVIATIONS.md`.
`/impeccable colorize`

### [P2] Field login hanya berplaceholder
Label hilang saat mengetik (WCAG 3.3.2; M3 menganjurkan label mengambang). Cuti sudah punya label terlihat.
`/impeccable clarify`

### [P2] Komponen non-Material (kesesuaian platform)
- **Toast kustom** (`AppToast`) menggantikan Snackbar: tidak bisa ditutup/diberi aksi, posisi tetap 96 dp.
- **Navigasi bawah kustom** dengan blur dan tab "Absensi" yang berupa aksi, bukan tujuan.
- **Header** chevron bulat + judul tengah menggantikan top app bar dengan panah kembali.
- **Segmented kustom** menggantikan `SegmentedButton`; **tombol gradien** dengan bayangan berwarna menggantikan elevasi tonal.
- **Back sistem:** `PopScope(canPop: false)` di layar Hasil dan Galat menonaktifkan animasi predictive back.
`/impeccable polish`

### [P2] Performa
- `BackdropFilter` selalu aktif di atas konten yang digulir (navigasi bawah) dan di sheet login: biaya `saveLayer` per frame di ponsel kelas bawah, dan "blur sebagai dekorasi" menurut craft-floor *[dugaan, belum diukur]*.
- Beranda memantau `tickingClockProvider` di `build()` sehingga seluruh halaman, termasuk grid, dibangun ulang tiap detik *[kode]*.
`/impeccable optimize`

### [P2] Adaptivitas
Layar dikunci potret lewat `setPreferredOrientations`. Di tablet (render 800x1280) hasilnya UI ponsel yang melar, tanpa navigation rail. *[dugaan]* Android 16 mengabaikan kunci orientasi pada layar >= 600 dp, jadi kuncinya tidak akan menahan. Lipat/foldable dan multi-window belum diuji.
`/impeccable adapt`

### [P2] Notifikasi/Persetujuan (data contoh)
"Setujui" dan "Tolak" langsung bekerja dengan satu ketukan, tanpa konfirmasi atau urungkan, dan Tolak tanpa alasan.
`/impeccable harden`

### [P2] Menu debug ikut di APK release
Karena `USE_MOCK` bawaan `true`, baris "Skenario uji" dan "Galeri komponen" tampil di Profil pada build release. Sembunyikan di build yang bukan debug.
`/impeccable polish`

### [P3]
- 14 literal hex di luar token (orb Hasil, gradien shutter, mask kamera, lencana jam, latar tile) -> pindah ke `AppColors`.
- Tiga animasi melayang tanpa henti (logo, lencana jam, orb hasil): craft-floor meminta satu momen, bukan efek tersebar. Semuanya menghormati "Hapus animasi".
- Ikon Phosphor, bukan Material Symbols (diwajibkan desain); ukuran huruf dipilih tangan, tidak dipetakan ke peran skala tipe Material.
- Layar Galat menjadikan "Coba lagi" tombol outline dan "Kembali ke Beranda" tombol utama: urutan prioritas terbalik.
- Tombol shutter: bingkai putih tidak terlihat di latar terang (1,05:1).
- Event: tiga tombol "Check-in" gradien identik menjadikan hierarki datar.

## Pola sistemik
1. **Geometri tetap vs skala teks:** lebar 40 dp, tinggi tile, `maxLines: 1`, dan bilah navigasi tanpa batas skala. Satu strategi (mis. `TextScaler.clamp` untuk elemen geometri tetap + tata letak bertumpuk untuk baris) menyelesaikan sebagian besar P1.
2. **Gaya iOS di atas Android:** blur, chevron, tombol gradien, toast.
3. **Satu ukuran layar.**

## Hal baik yang dipertahankan
- Sistem token + palet gelap penuh; kontras teks diuji otomatis.
- Target sentuh >= 48 dp diuji otomatis (`test/design/accessibility_test.dart`).
- Status tidak hanya lewat warna; pesan server ditampilkan apa adanya; galat per field.
- Semua animasi menghormati "Hapus animasi".
- Alur izin kamera, offline, dan 401 punya state yang jelas.

## Tindakan yang disarankan (berurutan)
1. **[P1] `/impeccable adapt`:** skala teks besar (navigasi bawah, Riwayat, Beranda, segmented), lalu tablet.
2. **[P1] `/impeccable harden`:** hari ini di Riwayat; pemuatan tanpa kedip.
3. **[P1] `/impeccable clarify`:** minta endpoint rekap bulanan; nama layar tunggal; label baris tanpa jam.
4. **[P2] `/impeccable colorize`:** kontras batas field.
5. **[P2] `/impeccable optimize`:** blur dan rebuild per detik.
6. **[P2] `/impeccable polish`:** Snackbar, top app bar, menu debug, predictive back.
7. **`/impeccable polish`** sebagai langkah terakhir; jalankan ulang audit setelahnya.
