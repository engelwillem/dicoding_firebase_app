# PocketLog — Offline Catalog App (Flutter)

PocketLog adalah aplikasi log yang terinspirasi dalam bentuk Pocket untuk mengcapture hal-hal penting dengan mengkategorikan gambar pada momen penting, agar mudah mengakses dan tidak perlu repot mencari di tumpukan gambar dalam Hp. Ini merupakan **offline-first app** saya yang dibuat dengan **Flutter** 
Proyek ini saya siapkan sebagai **submission Dicoding** sekaligus showcase portofolio: fokus pada struktur aplikasi yang rapi, navigasi jelas, dan UI aman dari overflow.

---

## 🎯 What this app does (Manfaat untuk pengguna)
PocketLog membantu pengguna untuk:

- **Melihat daftar item katalog** dengan informasi singkat (nama + kategori)
- **Membuka detail item** untuk membaca deskripsi lebih lengkap
- **Mencari item** menggunakan fitur **search** (pencarian lokal/offline)
- Menyediakan ruang pengembangan untuk fitur lanjutan seperti:
  - foto per item (offline storage),
  - favorit,
  - atau sinkronisasi ke cloud (opsional, bukan fokus submission)

Cocok dikembangkan juga untuk kebutuhan sederhana lainnya seperti:
- katalog produk UMKM,
- inventaris personal,
- catatan item koleksi,
- daftar perlengkapan kerja/proyek.

---

## ✅ Requirements Checklist (Dicoding Submission)
Proyek ini memenuhi kriteria utama submission:

- **Stateless Widget** ✅  
  Contoh: `MyApp`, `HomePage`, `DetailPage`
- **Stateful Widget** ✅  
  Contoh: `SearchPage` (mengelola input & hasil filter)
- **Minimal 2 halaman + Navigation** ✅  
  Home → Detail, Home → Search
- **Tidak overflow** ✅  
  Menggunakan `SafeArea`, `SingleChildScrollView`, dan layout fleksibel
- **Tema bebas + UI rapi** ✅  
  Material 3 + color scheme seed

---

## 🧱 Tech Stack
- **Flutter (Stable)**
- **Dart**
- UI: **Material 3**
- Data: **Local in-memory (offline)**

> Catatan: proyek ini sengaja dibuat **offline** agar stabil dan mudah dibuild oleh reviewer. Integrasi backend/cloud dapat ditambahkan kemudian.

---

## 🧭 App Flow (User Journey)
1. **Home**  
   Pengguna melihat list item katalog.
2. Tap item → **Detail**  
   Melihat detail item + deskripsi.
3. Tap ikon search → **Search**  
   Ketik kata kunci, hasil terfilter secara lokal.

---

## 📸 Screenshots
> Tambahkan screenshot jika ingin (recommended untuk recruiter).

Contoh struktur folder:
```md
![Home](screenshots/home.png)
![Detail](screenshots/detail.png)
![Search](screenshots/search.png)
```

▶️ How to Run (Local)
Pastikan Flutter sudah ter-install dan flutter doctor aman.
```
flutter pub get
flutter run
```

Build APK release:
```
flutter build apk --release
```

📁 Project Structure (ringkas)
```
lib/
  main.dart               # entry point + UI utama (home/detail/search)
android/
ios/
pubspec.yaml
```

## 🚀 Next Improvements (Roadmap)

Jika dikembangkan lebih lanjut, PocketLog bisa ditingkatkan dengan:
- Penyimpanan data lokal permanen (SQLite / Hive)
- CRUD item katalog (Tambah/Edit/Hapus)
- Foto item offline + cropping yang stabil
- Favorit & kategori dinamis
- Sinkronisasi cloud opsional (Firebase / Supabase)

## 👤 Author (E B Willem)
Jika Anda recruiter / business owner dan ingin berdiskusi tentang pengembangan aplikasi mobile untuk kebutuhan bisnis, silakan hubungi saya melalui profil GitHub ini.
