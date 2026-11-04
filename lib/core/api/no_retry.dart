/// Riverpod 3 mengulang otomatis provider yang gagal (sampai 10 kali dengan
/// jeda 0,2-6,4 detik), termasuk galat jaringan, 401, 422, dan 429. Untuk
/// aplikasi ini itu berbahaya: permintaan terkirim berulang tanpa
/// sepengetahuan pengguna (batas laju, CLAUDE.md melarang kirim ulang otomatis
/// berulang-ulang) dan galat baru tampil setelah semua percobaan habis.
/// Pengguna mengulang lewat tombol "Coba lagi" atau tarik-untuk-muat-ulang.
Duration? noAutomaticRetry(int retryCount, Object error) => null;
