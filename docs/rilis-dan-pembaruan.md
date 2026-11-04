# Rilis APK dan pembaruan dalam aplikasi

Alur untuk masa uji coba (Android saja): CI membangun APK bertanda tangan saat tag rilis dibuat, menerbitkannya sebagai GitHub Release, dan aplikasi di HP mengunduh pembaruan sendiri. Untuk peluncuran ke banyak pegawai, pindah ke Google Play (jalur uji internal/tertutup); lihat "Batasan".

## Cara kerja

1. Kamu membuat tag `vMAJOR.MINOR.PATCH` (mis. `v1.0.3`).
2. `.github/workflows/release.yml` menjalankan analisis dan test, membangun APK bertanda tangan, lalu menerbitkan **GitHub Release** berisi `eabsensi-v1.0.3.apk` dan `version.json`.
3. Di HP, aplikasi membaca `https://github.com/akbaralams/eabsensi-mobile-app/releases/latest/download/version.json` (`UPDATE_MANIFEST_URL`). Bila `version_code` lebih besar dari yang terpasang, beranda memberi tahu dan **Profil → Pembaruan aplikasi** menampilkan "Tersedia x.y.z".
4. Pengguna mengetuk **Perbarui sekarang**. Aplikasi mengunduh APK, memeriksa SHA-256 terhadap `version.json`, lalu membuka pemasang Android. Pengguna mengetuk **Pasang**.

Android tidak mengizinkan aplikasi biasa memasang pembaruan tanpa sentuhan pengguna. Pada pemakaian pertama, Android juga meminta izin "pasang aplikasi dari sumber ini" untuk eAbsensi.

## Persiapan satu kali

### 1. Buat keystore (di komputermu, bukan di repo)

```bash
keytool -genkeypair -v -keystore upload-keystore.jks -alias eabsensi \
  -keyalg RSA -keysize 2048 -validity 10000
```

Simpan `upload-keystore.jks` dan kedua kata sandinya di tempat aman (pengelola kata sandi). **Jangan di-commit** dan jangan dikirim lewat chat.

> Kehilangan keystore = tidak ada lagi pembaruan yang bisa dipasang di atas aplikasi yang sudah terpasang; semua pengguna harus mencopot dan memasang ulang. Cadangkan di dua tempat.

### 2. Isi GitHub Secrets dan Variables

Repo → Settings → Secrets and variables → Actions:

| Jenis | Nama | Isi |
|---|---|---|
| Secret | `ANDROID_KEYSTORE_BASE64` | `base64 -w0 upload-keystore.jks` (di Windows: `[Convert]::ToBase64String([IO.File]::ReadAllBytes("upload-keystore.jks"))`) |
| Secret | `ANDROID_KEYSTORE_PASSWORD` | kata sandi keystore |
| Secret | `ANDROID_KEY_ALIAS` | `eabsensi` |
| Secret | `ANDROID_KEY_PASSWORD` | kata sandi kunci |
| Variable | `API_BASE_URL` | mis. `https://api.presenza.biz.id/api` (wajib HTTPS) |

Lindungi tag rilis (Settings → Rules → Rulesets → tag `v*`) supaya hanya pemelihara yang bisa membuatnya.

### 3. Pasang APK pertama secara manual

Aplikasi yang sudah ada di HP (ditandatangani kunci debug) **tidak bisa** diperbarui oleh APK bertanda tangan resmi: Android menolak karena tanda tangannya berbeda. Copot dulu, lalu pasang `eabsensi-v1.0.0.apk` dari rilis pertama. Sejak itu semua pembaruan lewat aplikasi.

## Membuat rilis

```bash
git tag -a v1.0.1 -m "Perbaikan deteksi wajah di layar selfie"
git push origin v1.0.1
```

- Pesan tag anotasi menjadi **catatan rilis** yang tampil di lembar pembaruan (kosong bila tag ringan).
- `versionCode` dihitung dari tag: `MAJOR*10000 + MINOR*100 + PATCH` (1.0.3 → 10003, 1.2.0 → 10200). `MINOR` dan `PATCH` harus < 100. Tag harus selalu naik; Android menolak versionCode yang lebih kecil atau sama.
- Build lokal tanpa `android/key.properties` memakai kunci debug dan versionCode dari `pubspec.yaml`; APK-nya tidak bisa menimpa atau ditimpa APK rilis.

## Keamanan

- Unduhan hanya lewat HTTPS, dan `apk_url` harus di host yang sama dengan manifes (`version.json` dan APK keduanya dari `github.com`).
- SHA-256 di `version.json` diperiksa sebelum APK dipasang; tidak cocok = pembaruan dibatalkan.
- Pengaman utama adalah Android sendiri: APK yang ditandatangani kunci lain ditolak. Kunci itu hanya ada di GitHub Secrets.
- Aplikasi memakai Dio terpisah untuk manifes; token API tidak pernah dikirim ke GitHub.
- Matikan fitur ini dengan `--dart-define=UPDATE_MANIFEST_URL=` (kosong). Mode data dummy (`USE_MOCK=true`, default di build debug) juga mematikannya.

## Batasan

- Hanya Android. Repo publik berarti APK dan catatan rilis bisa diunduh siapa saja; ini tidak membuka data pegawai (data lewat API ber-token), tetapi jangan menaruh rahasia di APK atau catatan rilis.
- Pemasangan butuh satu ketukan pengguna dan izin "sumber tidak dikenal"; MDM kantor bisa memblokirnya.
- Untuk peluncuran luas, pakai Google Play (jalur uji internal/tertutup): pembaruan otomatis tanpa sentuhan. Izin `REQUEST_INSTALL_PACKAGES` yang dipakai fitur ini sebaiknya dilepas pada build Play (hapus plugin `ota_update` dan baris pembaruan di Profil).
- Alur pasang di perangkat sungguhan belum terbukti dari lingkungan pengembangan cloud; uji dengan dua rilis berurutan di satu HP.
