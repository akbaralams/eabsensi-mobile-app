# Usulan perubahan kontrak API mobile

Aplikasi tidak boleh menambah atau mengubah endpoint dari repo ini (`CLAUDE.md`); daftar berikut untuk diajukan ke repo API (`eabsensi-mobile-api` / `eabsensi-v2`). Semua sudah dibutuhkan oleh layar yang dibangun dengan data dummy.

| Kebutuhan | Layar | Usulan |
|---|---|---|
| Rekap absensi bulanan dengan status harian (hadir, terlambat, tidak hadir, menunggu) dan jam masuk/keluar | Riwayat | `GET /attendance/history?month=YYYY-MM` -> `{ data: [{ date, status, status_label, check_in, check_out }], summary: {...} }`. Hari berjalan harus ikut. Tanpa ini klien merakit satu bulan dari `GET /punches?date=` per hari (sampai 31 permintaan dari batas 120/menit per token, tanpa klasifikasi) |
| Lokasi kantor / geofence dan nama lokasi | Check In, Beranda | Field `work_location: { name, latitude, longitude, radius_m }` di `/me` |
| Jadwal/shift hari ini | Beranda ("Jam Kerja"), klasifikasi terlambat | Field `today_schedule` di `/me` atau endpoint tersendiri |
| Peran atasan | Beranda, Profil | Field `is_supervisor` (atau daftar izin) di `/me` |
| Notifikasi dan persetujuan tim | Notifikasi, Persetujuan | `GET /notifications`, `GET /approvals`, `POST /approvals/{id}/decision` (approve/reject + alasan) |
| Kategori jenis cuti | Cuti | Field `category` di `types[]` pada `GET /leaves` (sekarang dikelompokkan dari awalan `code`) |
| Lampiran pengajuan | Cuti | Dukungan multipart di `POST /leaves` bila lampiran diinginkan |
| Menu beranda dinamis | Beranda | `GET /menus` atau field di `/me` |
| Check-in event dengan QR | Event | Field token QR di `POST /events/{id}/check-in`, bila QR dipakai |
