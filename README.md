# Aplikasi-Cashmate

Cashmate adalah aplikasi manajemen inventaris dan Point of Sales (POS) berbasis mobile yang dirancang untuk membantu Usaha Mikro, Kecil, dan Menengah (UMKM) beralih dari pencatatan manual ke sistem digital yang terintegrasi.

Proyek ini dikembangkan sebagai luaran magang di PT Raja Teknik Solusi untuk mengatasi permasalahan inefisiensi stok dan pencatatan transaksi manual.

##  Fitur Utama (Key Features)

Aplikasi ini mencakup 6 modul vital untuk operasional bisnis:

* Transaksi Kasir (POS):** Input penjualan cepat, keranjang belanja digital, dan kalkulasi total otomatis.
* Manajemen Inventaris Real-time:** Monitoring stok masuk/keluar dan notifikasi stok menipis (Stock Alert).
* Laporan & Analisis:** Laporan omzet harian, laba/rugi sederhana, dan rekapitulasi penjualan per periode.
* Manajemen Pembelian (Restock):** Otomasi penambahan stok saat barang masuk dari supplier.
* *Multi-User Access:** Hak akses berbeda untuk Admin/Pimpinan dan Kasir (Role-Based Access Control).

##  Tech Stack

* Frontend: Flutter (Dart)
* Backend: Native PHP
* Database: MySQL
* Architecture: MVC / MVVM Pattern
* Connectivity: REST API (JSON)


# Aplikasi CashMate (Kasir Mobile) 

Aplikasi kasir mobile berbasis Flutter untuk mengelola produk, pelanggan, pengguna, dan transaksi. Aplikasi ini menggunakan backend PHP yang berada di repository berikut:

Backend: https://github.com/oliviamarsha202/Aplikasi_Cashmate-PHP

---

## Teknologi

- Frontend: Flutter
- Bahasa: Dart
- Package penting: `http`, `image_picker`, `mobile_scanner`, `intl`, `google_fonts`
- Backend: PHP (lihat repo backend di atas)

---

## Persyaratan

- Flutter SDK (disarankan versi terbaru yang kompatibel dengan project)
- Android SDK / Xcode untuk build ke emulator/device
- PHP + MySQL (mis. XAMPP, WAMP, MAMP) untuk menjalankan backend
- Akses jaringan antara device/emulator dan server backend

---

## Persiapan Backend (singkat)

1. Clone repository backend:

   git clone https://github.com/oliviamarsha202/Aplikasi_Cashmate-PHP.git

2. Letakkan folder `Aplikasi_Cashmate-PHP` ke dalam web root server (mis. `htdocs` pada XAMPP) atau sesuaikan nama folder.

3. Pastikan folder diakses melalui URL seperti:

   http://<SERVER_IP>/aplikasi_kasir/

   Catatan: aplikasi mobile saat ini mengakses path `/aplikasi_kasir/` — jika Anda menaruh folder dengan nama berbeda, sesuaikan URL pada kode Flutter.

4. Buat database MySQL dan import file SQL jika disertakan di backend repo (cek README backend atau file `.sql`). Konfigurasikan `koneksi.php` di repo backend sesuai kredensial DB Anda.

---

## Konfigurasi Aplikasi Flutter (menghubungkan ke backend)

Aplikasi saat ini menggunakan URL API yang hard-coded (contoh: `http://192.168.1.2/aplikasi_kasir/api_login.php`). Anda perlu mengubah alamat IP / base URL sesuai server Anda.

File yang perlu diperiksa / diubah (lokasi default di project):

- `lib/main.dart` (api_login)
- `lib/user_page.dart` (api_user, api_tambah_user, api_hapus_user)
- `lib/transaksi_page.dart` (api_produk, api_pelanggan, api_transaksi)
- `lib/produk_page.dart` (api_produk, api_hapus_produk)
- `lib/tambah_produk.dart` (ipAddress tetapi beberapa titik menggunakan variabel `ipAddress`)
- `lib/tambah_pelanggan.dart` (ipAddress)
- `lib/pelanggan_page.dart` (ipAddress)
- `lib/edit_produk.dart` (ipAddress)
- `lib/dashboard.dart` (ipAddress)
- `lib/laporan_page.dart`, `lib/laba_page.dart`, `lib/kategori_page.dart`, `lib/kulakan_page.dart` (menggunakan alamat yang sama)

Rekomendasi: cari dan ganti semua `192.168.1.2` dengan alamat IP server Anda (atau gunakan `10.0.2.2` jika memakai Android emulator yang mengakses host machine).

Contoh untuk emulator Android (jika backend dijalankan di mesin lokal):

`http://10.0.2.2/aplikasi_kasir/api_login.php`

Atau, lebih baik pindahkan IP ke satu file konfigurasi (mis. `lib/config.dart`):

```dart
const String baseUrl = 'http://192.168.1.2/aplikasi_kasir/';
```

lalu gunakan `Uri.parse('$baseUrl/api_login.php')` di seluruh project untuk kemudahan konfigurasi.

---

## Menjalankan Aplikasi (Development)

1. Install dependency:

   flutter pub get

2. Jalankan pada device / emulator:

   flutter run

3. Bila terjadi error koneksi ke server:

- Pastikan server PHP berjalan dan endpoint dapat diakses dari browser/POSTMAN.
- Pastikan device/emulator berada di jaringan yang sama jika menggunakan IP lokal.
- Untuk Android emulator, gunakan `10.0.2.2` untuk mengakses host machine.

---

## Troubleshooting umum

- "Server Error" atau respon bukan JSON: buka `http://<SERVER_IP>/aplikasi_kasir/api_login.php` (atau endpoint yang relevan) di browser untuk melihat error PHP.
- Upload foto: pastikan folder `uploads/` pada backend punya permission yang benar (writable).
- Jika fungsi laporan bermasalah, periksa parameter tanggal dan filter pada `api_laporan.php` di backend.

---

## Daftar endpoint (yang dipakai di aplikasi)

- api_login.php
- api_user.php
- api_tambah_user.php
- api_hapus_user.php
- api_produk.php
- api_tambah_produk.php
- api_edit_produk.php
- api_hapus_produk.php
- api_kategori.php
- api_tambah_kategori.php
- api_pelanggan.php
- api_tambah_pelanggan.php
- api_hapus_pelanggan.php
- api_transaksi.php
- api_transaksi_rinci.php
- api_laporan.php
- api_laba.php
- api_kulakan.php
- api_detail_transaksi.php

(Cek repo backend untuk deskripsi masing-masing endpoint dan parameter yang diperlukan.)

---

## Contributing 

Jika Anda ingin memperbaiki fitur atau melakukan refactor (mis. memindahkan konfigurasi URL ke satu file), silakan buat branch baru dan ajukan PR. Tambahkan juga dokumentasi singkat di README ini jika menambah langkah setup.

---

## Lisensi

Project ini tidak memiliki lisensi tersurat di repo; tambahkan file `LICENSE` jika ingin mengatur lisensi proyek.

---

Jika perlu, saya bisa bantu juga membuat `lib/config.dart` untuk centralisasi `baseUrl` dan sekaligus mengganti semua referensi alamat yang ada. 💡


