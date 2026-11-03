# Usulan perubahan kontrak API mobile

Aplikasi tidak boleh menambah atau mengubah endpoint dari repo ini (`CLAUDE.md`). Pemilik kontrak adalah repo `eabsensi-mobile-api`: daftar ini diajukan ke sana. Semua sudah dibutuhkan oleh layar yang dibangun dengan data dummy.

Status per 30 Oktober 2026, dibandingkan dengan `../eabsensi-mobile-api/docs/api-v2-design.md` (rancangan, belum dikerjakan) dan kontrak ter-pin `api/openapi.yaml`.

## Sudah masuk rancangan API v2

| Kebutuhan | Layar | Rancangan di repo API | Fase |
|---|---|---|---|
| Rekap absensi bulanan dengan status harian (hadir, terlambat, tidak hadir, menunggu) dan jam masuk/keluar | Riwayat | `GET /api/v2/attendance/monthly?month=YYYY-MM` (`summary`, `days[]` dengan `status`, `late_minutes`, `pending_punches`) | 1 |
| Peran atasan | Beranda, Profil | `GET /api/v2/me` dengan `abilities` (`approve_punches`, `approve_leaves`), menggantikan `isSupervisor` | 1 |
| Menu beranda dinamis | Beranda | `GET /api/v2/menus` (bawaan di fase 1, tabel `mobile_menus` di fase 2) | 1 → 2 |
| Check-in event dengan QR | Event | `requires_qr` di `GET /api/events`, `qr_code` di `POST /api/events/{id}/check-in` | 2 |
| Lampiran pengajuan | Cuti | `POST /api/v2/leaves` multipart (`attachment`), `has_attachment`, `GET /api/v2/leaves/{id}/attachment` | 2 |
| Persetujuan tim | Persetujuan | `GET /api/v2/approvals`, `POST /api/v2/approvals/punches/{id}`, `.../leaves/{id}` (cara eksekusi persetujuan cuti belum diputuskan) | 3 |
| Notifikasi | Notifikasi | `GET /api/v2/notifications`, tandai dibaca (push FCM di luar rancangan) | 3 |

Refresh token (`/api/v2/auth/login`, `/refresh`, `/logout`) sudah ada di kontrak (Rust saja).

## Belum ada di rancangan (masih perlu diajukan)

| Kebutuhan | Layar | Usulan |
|---|---|---|
| Lokasi kantor / geofence dan nama lokasi | Check In, Beranda | Field `work_location: { name, latitude, longitude, radius_m }` di `/me` |
| Jadwal/shift hari ini | Beranda ("Jam Kerja"), klasifikasi terlambat hari ini | Field `today_schedule` di `/me` atau endpoint tersendiri. Rekap bulanan v2 punya `shift` per hari, tetapi bukan jam kerja untuk kartu beranda |
| Kategori jenis cuti | Cuti | Field `category` di `types[]` pada `GET /leaves`. Sementara aplikasi memetakan kode bawaan (`CUTI`, `IZIN`, `SAKIT`, `DINAS`) di `LeaveCategory` |
| Status harian (Terlambat, Tidak Hadir) di kartu Status Kehadiran | Beranda | Field `attendance_flag` (`late`/`absent`/null) di `/me` atau `GET /api/v2/attendance/today`. Tanpa ini klien tidak menampilkan Terlambat/Tidak Hadir (kartu sudah siap lewat `AttendanceSummary.flag`) |
| Kategori persetujuan di kartu Menunggu Persetujuan | Beranda | Field `category` (`out_of_area`/`team_leave`) di item `GET /api/v2/approvals` (sekarang `ApprovalRequest.category` hanya data contoh) |
