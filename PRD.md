# Product Requirement Document (PRD): Motrich

## 1. Ringkasan
Motrich adalah aplikasi manajemen keuangan pribadi (pencatat uang masuk & keluar) berbasis Flutter untuk Android, iOS, dan Web.

## 2. Target Deployment
- Mobile: Google Play Store / APK (via GitHub Actions).
- Web: Cloudflare Pages (Hosting statis secepat kilat).

## 3. Tech Stack
- Framework: Flutter (Dart)
- State Management: Riverpod / Provider (paling minimalis)
- Penyimpanan Lokal: Hive / Isar / sqflite

## 4. Fitur Utama (MVP)
1. **Dashboard**: Ringkasan saldo total, total pemasukan & pengeluaran, daftar transaksi terakhir.
2. **Manajemen Transaksi**: Tambah, ubah, hapus pemasukan/pengeluaran lengkap dengan kategori (Makanan, Transportasi, Gaji, dll) dan tanggal.
3. **Anggaran (Budgeting)**: Batasan pengeluaran bulanan per kategori.
4. **Ekspor/Impor Data**: Backup data lokal dalam bentuk JSON/CSV.
