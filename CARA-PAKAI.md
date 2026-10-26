# Cara memasukkan paket ini ke repo

1. Ekstrak zip ini.
2. Salin ke root repo `eabsensi-mobile-app`:
   - folder `docs/` → `eabsensi-mobile-app/docs/`
   - `TASKS.md` → timpa `eabsensi-mobile-app/TASKS.md`
3. Di `CLAUDE.md`, ganti baris
   `Arah visual boleh mengikuti ../eabsensi-v2/DESIGN.md (desain "Soft").`
   menjadi
   `Tampilan wajib mengikuti docs/design/README.md dan prototipe docs/design/prototype/ (high-fidelity). Bila bertentangan dengan kontrak API, kontrak yang menang; catat di docs/design/DEVIATIONS.md.`
4. Commit dan push:
   ```
   git add docs TASKS.md CLAUDE.md
   git commit -m "docs: tambah spesifikasi desain mobile dan perbarui task"
   git push
   ```
5. Jalankan Claude Code di folder repo, lalu minta:
   > Baca CLAUDE.md, TASKS.md, dan docs/design/README.md. Kerjakan task berikutnya yang belum selesai.
