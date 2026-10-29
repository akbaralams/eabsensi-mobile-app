# Deviasi dari spesifikasi desain

Kontrak API dan `CLAUDE.md` menang atas `docs/design/README.md`. Setiap perbedaan dicatat di sini.

## Karena kontrak API (`api/openapi.yaml`, dari `../eabsensi-mobile-api/docs/openapi.yaml`)
| Layar | Desain | Yang dibangun | Butuh dari repo API |
|---|---|---|---|
| Login | Tab SSO, tombol SSO, "Ingat saya", "Lupa password?" | Disembunyikan. Token selalu disimpan aman. | Endpoint SSO / reset password bila diinginkan |
| Event (§9) | Pindai QR | Check-in lewat foto + lokasi (field kontrak). Layar pindai tidak dibuat; teks banner "check-in dengan foto dan lokasi". Chip "Belum dibuka" tidak ada (server yang menolak di luar jam, pesan ditampilkan apa adanya). | Field QR/token di check-in, bila QR dipakai |
| Riwayat (§7) | Tile Hadir/Terlambat/Tidak Hadir dan status per hari | Kontrak hanya punya `GET /punches?date=`: tidak ada rekap bulanan dan tidak ada klasifikasi terlambat/tidak hadir. UI sesuai desain, **data dummy**. | `GET` rekap bulanan dengan status harian |
| Cuti (§8) | Lampiran opsional | Tidak ditampilkan: `POST /leaves` hanya JSON, tanpa lampiran. | Upload lampiran |
| Cuti (§8) | Alasan wajib (validasi lokal) | Alasan **opsional** (kontrak: `reason` nullable). | - |
| Cuti (§8) | Kategori Cuti/Izin/Dinas Luar/Lainnya | `types[]` hanya punya `id`, `code`, `name`. Pengelompokan memakai awalan `code` (`C-`, `I-`, `D-`, selain itu Lainnya) di `LeaveCategory`. | Field `category` di `types[]` |
| Beranda / Punch | Status "Terlambat", geofence, nama kantor | Klien tidak punya jadwal maupun koordinat kantor. Status hari ini hanya Belum absen / Hadir / Menunggu. Peta menampilkan area kantor hanya pada mode dummy; mode nyata menampilkan akurasi saja. | Jadwal/shift dan lokasi kantor di `/me` |
| Beranda / Profil | Kartu persetujuan atasan | Ditampilkan hanya bila `UserProfile.isSupervisor` (selalu `false` pada implementasi nyata; hanya mock yang mengisinya). | Peran atasan di `/me` |
| Notifikasi (§10), Persetujuan (§11) | Layar penuh | Dibangun dengan **data contoh** dan pita "menunggu kontrak API". Tidak memanggil backend. | Endpoint notifikasi dan persetujuan |
| Menu dinamis | `GET /menus` | `StaticMenuRepository`. | `GET /menus` atau field di `/me` |
| Check-in lokasi | Info "Waktu `09:41 · server`" | "Dicatat oleh server": waktu punch ditentukan server, jam perangkat tidak ditampilkan sebagai waktu punch. | - |

## Karena aksesibilitas (kontras teks >= 4,5:1, `CLAUDE.md`)
- Gradien tombol utama `#059669 -> #0D9488` (putih di atasnya hanya 3,7:1) diganti `#047857 -> #0F766E` (>= 5,4:1).
- Teks aksen hijau di atas surface (label tab aktif, teks segmen aktif) memakai `#047857`, bukan `#059669` (3,8:1). Ikon tetap `#059669`.
- Ikon amber pada tint amber memakai `#B45309` (bukan `#D97706`, 2,9:1) agar >= 3:1. Teks chip Terlambat/Menunggu memakai `#92400E`.
- Mode gelap: `textMuted` `#A3B1C6` (bukan `#94A3B8`, 4,0:1 di atas `#334155`).
- Tes kontras: `test/design/contrast_test.dart`.

## Karena teknis
- **`phosphor_flutter` 2.1.0 (rilis terbaru) tidak bisa dikompilasi di Flutter 3.47**: kelasnya memperluas `IconData`, yang kini `final class`. Paket tetap dipakai untuk berkas font-nya; `lib/core/design/phosphor.dart` dibangkitkan oleh `tool/generate_phosphor_icons.py` (kode titik ikon yang dipakai saja). Jalankan ulang skrip itu bila menambah ikon. Ganti ke paket resmi bila rilis baru yang kompatibel muncul.
- **Kamera** (model dari aplikasi absenq-mobile, `lib/features/attendance/attendance_wizard_screen.dart`, warna tetap token eAbsensi): kamera layar penuh dengan bingkai wajah 3:4 bersudut (maks 288x384, mengecil di layar pendek) menggantikan pratinjau 400 tinggi dengan oval; tombol jepret 104 px menggantikan 78 px; ada "LANGKAH 2 DARI 3", tombol tutup, senter, dan balik kamera. Deteksi wajah ML Kit (`google_mlkit_face_detection`) berjalan di perangkat, tanpa data wajah dikirim. Status "WAJAH TERDETEKSI" / "SEJAJARKAN WAJAH KE BINGKAI" / "WAJAH TIDAK TERDETEKSI" menggantikan chip "Kamera siap". Tombol jepret aktif hanya saat wajah di bingkai: titik tengah di dalam dan >= 60% luas wajah tumpang tindih. Foto juga diambil otomatis setelah wajah 1 detik stabil di bingkai. Setelah jepret ada langkah konfirmasi (pratinjau foto, jenis, lokasi, "Kirim" / "Foto Ulang"); dari absenq sengaja tidak ditiru badge "Identitas Terverifikasi" (tidak ada pencocokan), kolom catatan (tidak ada di kontrak), dan stempel waktu perangkat (waktu dari server). Foto dikompres sekali sebelum unggah: JPEG kualitas 80, sisi pendek maks 480 px (pratinjau `medium` ≈ 480x720, target ±50-100 KB; `flutter_image_compress`) dan dihapus setelah terkirim atau saat Foto Ulang. Teks di layar kamera dibatasi skala 1,3x agar bingkai tetap terlihat; layar konfirmasi mengikuti ukuran teks sistem penuh. Izin ditolak atau kamera gagal -> pesan dan "Coba lagi". Layar dikunci potret. **Belum diuji di perangkat**; test memakai `FakeCameraService`. Dalam mode dummy foto tidak diunggah ke mana pun.
- **Peta**: `flutter_map` dengan tile OpenStreetMap; tile tidak dimuat di test. Tile OSM publik tidak untuk lalu lintas produksi besar; ganti penyedia tile sebelum rilis.
- **Tab "Absensi"** di navigasi bawah adalah aksi (membuka Check In atau Check Out sesuai punch hari ini), bukan layar tab.
- **Golden test** dibangkitkan di Linux; `test/flutter_test_config.dart` menoleransi selisih piksel sampai 0,5% agar render font di Windows tidak menggagalkan test. Bangkitkan ulang dengan `flutter test --update-goldens`.
- **Task 3 (client dari OpenAPI) belum dikerjakan**: model domain ditulis tangan dan repository dummy ada di `lib/features/*/data/mock_*`. `USE_MOCK=false` melempar `UnimplementedError` sampai client ada. `CLAUDE.md` mewajibkan model dibangkitkan dari OpenAPI; model tangan di `*/domain/` harus dipetakan dari model hasil generator.

## Hasil audit Impeccable (lihat `AUDIT-IMPECCABLE.md`)
Diubah dari spesifikasi desain karena aksesibilitas dan konvensi Android:
- **Border field dan tombol outline (mode terang)** `#7A9A8D` (3,07:1 terhadap putih, WCAG 1.4.11) menggantikan `#D5E6DE` (1,30:1).
- **Navigasi bawah** memakai `NavigationBar` Material 3 (tanpa blur) dan di layar >= 720 dp memakai `NavigationRail` dengan lebar konten dibatasi 640 dp. Tab "Absensi" menjadi tujuan tersendiri (status hari ini, tombol Check In/Out, daftar punch hari ini), bukan aksi. Tab dan judul memakai "Riwayat" menggantikan "Laporan".
- **Toast** diganti Snackbar Material (bisa ditutup, bisa memuat "Urungkan").
- **Header** memakai panah kembali (arrow-left) menggantikan chevron.
- **Field login** punya label terlihat; placeholder hanya contoh isi.
- **Layar hasil dan galat** menumpuk di atas Beranda sehingga Back sistem (dan predictive back) bekerja; tombol utama layar Galat adalah "Coba lagi".
- **Satu animasi melayang** saja (orb layar hasil); logo dan lencana jam statis.
- **Orientasi**: potret hanya di layar < 600 dp.
- **Riwayat**: baris hari ini dari punch server, tile statistik menjadi filter, pemilih bulan (12 bulan), detail hari lewat bottom sheet, data bulan sebelumnya tetap tampil saat memuat. Tile Terlambat/Tidak Hadir disembunyikan bila repository tidak mengklasifikasikan (`supportsClassification == false`).
- **Teks sistem besar**: baris dan tile Riwayat, kartu absen Beranda, dan segmented berganti ke tata letak bertumpuk di atas 1,3x.
- **Menu debug** (galeri komponen, skenario uji) hanya di build debug atau `--dart-define=DEBUG_TOOLS=true`.

Sengaja **tidak** diubah (keputusan desain, bukan cacat): tombol bergradien dan bayangan berwarna, ikon Phosphor, segmented berbentuk pil, skala tipe kustom (bukan peran tipe Material), dan tanpa Dynamic Color.
