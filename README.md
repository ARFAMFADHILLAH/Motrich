# Motrich - Personal Money Tracker

**Motrich** adalah aplikasi manajemen keuangan pribadi (pencatat uang masuk & keluar) berbasis Flutter untuk **Android**, **iOS**, dan **Web**. Dibangun dengan arsitektur **Dual Mode**: **Guest Mode** (Offline-first, tanpa login) dan **Cloud Sync** (Supabase PostgreSQL + Auth).

---

## ✨ Fitur Utama

### 🔐 Fleksibilitas Akses (Dual Mode)
| Mode | Deskripsi |
|------|-----------|
| **Mode Tamu (Guest)** | Langsung pakai tanpa login. Data tersimpan lokal di perangkat (`SharedPreferences`). Cocok untuk penggunaan cepat/privasi. |
| **Cloud Sync (Supabase)** | Register/Login via Email. Data otomatis tersinkron ke database PostgreSQL Supabase dengan **Row Level Security (RLS)** per user. Aman saat ganti HP. |

### 💰 Manajemen Dompet & Rekening (Customizable)
- Tambah, edit, hapus dompet/rekening bebas (Cash, Bank, E-Wallet, Investasi, dll)
- Set saldo awal otomatis
- Auto-create wallet "Dompet Utama" saat user pertama kali login cloud

### 📝 Transaksi Lengkap
- **Pemasukan** & **Pengeluaran** dengan validasi format angka Indonesia (50.000 → 50000)
- **Transfer antar dompet** (update saldo otomatis)
- Kategori transaksi **customizable** (tambah/hapus kategori sesuka hati)
- Pilih dompet sumber, tanggal fleksibel, catatan tambahan
- Hapus transaksi dengan rollback saldo otomatis

### 📊 Anggaran (Budget) Fleksibel
- Budget Harian / Bulanan / Tahunan
- Progress bar visual (Hijau = aman, Merah = melebihi batas)
- Indikator real-time pengeluaran vs batas

### 🎯 Fitur Pendukung
- **Target Tabungan**: Set target nominal, tracking progress (klik +Rp100.000)
- **Pengingat Tagihan**: Jatuh tempo, checkbox lunas/belum
- **Utang & Piutang**: Toggle "Utang Saya" / "Piutang Orang", switch lunas
- **Mode Gelap/Terang**: Toggle di AppBar, preferensi tersimpan otomatis
- **Sapaan Waktu Dinamis**: "Selamat Pagi/Siang/Sore/Malam, [Nama]!"

### 📤 Ekspor/Impor & Backup
- Data Guest Mode: SharedPreferences (backup manual via file manager)
- Data Cloud: Tersimpan di Supabase (auto-sync)

---

## 🏗️ Tech Stack

| Layer | Technology |
|-------|------------|
| **Framework** | Flutter 3.x (Dart 3.x) |
| **State Management** | `ChangeNotifier` / `setState` (ringan, tanpa overhead) |
| **Database (Cloud)** | Supabase (PostgreSQL) + **RLS per user** |
| **Auth** | Supabase Auth (Email/Password) |
| **Storage (Local)** | `shared_preferences` (Guest Mode) |
| **ID Generator** | `uuid` v4 (UUID v4 standar) |
| **Date/Time** | `intl` (locale `id_ID`) |
| **Icons** | Material Icons + Custom SVG logo |
| **Build Target** | Android (APK/AAB), iOS, Web (Wasm) |

---

## 📂 Struktur Folder

```
motrich/
├── android/                    # Konfigurasi native Android
├── ios/                        # Konfigurasi native iOS
├── web/                        # Konfigurasi Web (manifest, index.html, icons)
├── lib/
│   ├── main.dart               # Entry point + semua logic (single-file architecture)
│   └── (tidak ada folder features/ karena arsitektur single-file)
├── assets/
│   └── icon/
│       └── logo.svg            # Logo aplikasi (wallet icon gradient)
├── tool/
│   └── gen_icons.dart          # Script generate PNG icons dari SVG
├── test/
│   └── widget_test.dart        # Unit test smoke test
├── supabase_schema.sql         # Schema lengkap Supabase (UUID, RLS, Trigger)
├── pubspec.yaml                # Dependencies & config flutter_launcher_icons
├── analysis_options.yaml       # Lint rules
├── .gitignore
└── README.md                   # Dokumentasi ini
```

---

## ⚙️ Setup & Instalasi

### 1. Prasyarat
- Flutter SDK 3.19+ (Dart 3.3+)
- Android Studio / VS Code + Flutter extension
- Akun **Supabase** (gratis: database.postgres.new)

### 2. Clone & Install Dependencies
```bash
git clone <repository-url>
cd motrich
flutter pub get
```

### 3. Setup Supabase (Wajib untuk Cloud Mode)

#### A. Buat Project Supabase
1. Buka [supabase.com](https://supabase.com) → **New Project**
2. Catat **Project URL** & **anon/public key** (Settings → API)

#### B. Jalankan Schema Database
1. Buka **SQL Editor** di Dashboard Supabase
2. Copy-paste isi file `supabase_schema.sql` → **Run**
   - Schema ini sudah include: UUID, `user_id`, RLS Policies, Trigger auto-update saldo wallet

#### C. Matikan Email Confirmation (Development)
1. **Authentication** → **Providers** → **Email**
2. **Disable** "Confirm email" (agar user langsung aktif setelah register)

#### D. Update Konfigurasi di `lib/main.dart`
```dart
const String supabaseUrl = 'https://YOUR-PROJECT-ID.supabase.co';
const String supabasePublishableKey = 'YOUR-ANON-KEY';
```

### 4. Generate App Icons (Opsional - sudah di-generate)
```bash
flutter pub run flutter_launcher_icons
```

### 5. Jalankan Aplikasi
```bash
# Web (development)
flutter run -d chrome
# atau tanpa hot reload
flutter run -d web-server

# Android
flutter run -d android

# iOS (macOS only)
flutter run -d ios
```

### 6. Build Release
```bash
# Web (Cloudflare Pages / Vercel / Netlify)
flutter build web --release --wasm
# Output: build/web/

# Android APK
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk

# Android App Bundle (Play Store)
flutter build appbundle --release

# iOS (macOS only)
flutter build ios --release
```

---

## 🔐 Keamanan & Privasi

- **RLS (Row Level Security)**: Setiap tabel hanya bisa diakses owner-nya (`auth.uid() = user_id`)
- **Anon Key**: Hanya untuk read/write data milik user sendiri (tidak bisa akses data user lain)
- **Guest Mode**: Data 100% lokal di perangkat, tidak pernah keluar ke internet
- **Trigger DB**: Update saldo wallet otomatis di sisi server (tidak bisa dimanipulasi client)

---

## 📱 Screenshot / UI Preview

| Dashboard (Light) | Dashboard (Dark) | Transaksi | Profil |
|-------------------|------------------|-----------|--------|
| *Total saldo, sapaan waktu, dompet, transaksi terbaru* | *Mode gelap otomatis* | *Form transaksi lengkap* | *Status cloud/guest, statistik, versi* |

---

## 🧪 Testing

```bash
# Jalankan unit test
flutter test

# Analisis static code
flutter analyze
```

---

## 📦 Deployment

### Web (Static Hosting)
- **Cloudflare Pages**: Connect repo → Build command: `flutter build web --release --wasm` → Output: `build/web`
- **Vercel/Netlify**: Same config
- **Firebase Hosting**: `firebase deploy --only hosting`

### Mobile
- **Android**: GitHub Actions workflow `.github/workflows/android.yml` (build APK/AAB otomatis)
- **iOS**: Butuh macOS + Xcode + Apple Developer Account

---

## 🤝 Kontribusi

1. Fork repository
2. Buat branch fitur: `git checkout -b fitur/nama-fitur`
3. Commit changes: `git commit -m "feat: deskripsi singkat"`
4. Push branch: `git push origin fitur/nama-fitur`
5. Buat Pull Request

---

## 📄 Lisensi & Copyright

```
MIT License

Copyright (c) 2025 Motrich Manager

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

---

## 👨‍💻 Author

**Motrich Manager** - Aplikasi keuangan pribadi modern, ringan, dan aman.

> Dibangun dengan ❤️ menggunakan **Flutter** + **Supabase**  
> © 2025 Motrich Manager - All Rights Reserved