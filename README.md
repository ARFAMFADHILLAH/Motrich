# Motrich - Personal Money Tracker

Motrich adalah aplikasi manajemen keuangan pribadi (pencatat uang masuk & keluar) berbasis Flutter untuk Android, iOS, dan Web.

## 🚀 Fitur Utama
- **Dashboard Interaktif**: Ringkasan saldo total, total pemasukan, dan total pengeluaran secara real-time.
- **Manajemen Transaksi**: Tambah, ubah, dan hapus transaksi (pemasukan/pengeluaran) lengkap dengan kategori (Makanan, Transport, Belanja, Gaji, dll).
- **Penyimpanan Lokal**: Data tersimpan aman di perangkat menggunakan `shared_preferences`.
- **Cross-Platform**: Dirancang untuk berjalan mulus di Mobile (Android/iOS) dan Web.

## 📱 Tech Stack
- **Framework**: Flutter (Dart)
- **State Management**: Stateful / Provider
- **Storage**: Shared Preferences

## 🛠️ Cara Menjalankan Project
1. Clone repository ini:
   ```bash
   git clone https://github.com/username/motrich.git
   cd motrich
   ```
2. Ambil dependencies:
   ```bash
   flutter pub get
   ```
3. Jalankan aplikasi:
   - Web: `flutter run -d chrome`
   - Android/Mobile: `flutter run`

## 📦 Deployment
- **Web**: Hosting statis ke Cloudflare Pages / Vercel dari folder `build/web`.
- **Android**: Build APK via GitHub Actions (cek tab Actions di repository GitHub Anda).
