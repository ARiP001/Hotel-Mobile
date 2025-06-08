# TuruKamar
Aplikasi mobile Flutter untuk booking kamar hotel provinsi DIY.

## Data Diri

- Dosen : Bagus Muhammad Akbar
- Nama : Arif F*****
- NIM : 123220136
- Kelas : TPM IF-D

## Dokumen Untuk Kuliah PPT

- PPT Projek Akhir : [Link Disini](https://www.canva.com)
- Laporan Projek Akhir : [Link Disini](https://docs.google.com/document/d/18eAxOyaWCwpzyZIK1w-eFOn4QVmLglc8vPEDpYtzKxs/edit?usp=sharing)

## Konsep Aplikasi

TuruKamar adalah aplikasi yang dirancang untuk membantu pengguna dalam memesan kamar hotel. Aplikasi ini menawarkan berbagai fitur untuk memudahkan pengguna dalam mencari, memesan, dan mengelola akomodasi mereka.

## API yang Digunakan

Aplikasi ini menggunakan [Xotelo API](https://xotelo.com/#endpoint-search) untuk mendapatkan data hotel secara real-time. API ini menyediakan endpoint untuk mendapatkan daftar hotel berdasarkan lokasi.

- **Latest list endpoint (/list)**: Mendapatkan daftar hotel berdasarkan lokasi.

API ini memungkinkan aplikasi untuk menampilkan informasi hotel yang akurat dan terkini kepada pengguna.


## Kriteria Projek

Projek ini dibuat menggunakan kriteria berikut:

1. **Memiliki konsep projek akhir** ✅
   - Aplikasi hotel booking dengan fitur lengkap
   - Terintegrasi dengan API hotel
   - Memiliki sistem booking dan manajemen akun

2. **Terdapat login dengan enkripsi (tidak menggunakan firebase) dan session** ✅
   - Menggunakan `SessionManager` untuk manajemen session
   - Data login disimpan di `SharedPreferences`
   - Menggunakan enkripsi untuk keamanan data

3. **Terkoneksi database / penyimpanan (SQLite, Hive, dll)** ✅
   - Menggunakan `SharedPreferences` dan `Hive` untuk penyimpanan lokal
   - Menyimpan data user, booking, dan bookmark

4. **Terdapat web service / API boleh sampai pemanfaatan IoT, games atau multiplatform (Android, iOS) serta memiliki fasilitas LBS yang terkait tema** ✅
   - Menggunakan Xotelo API untuk data hotel
   - Menggunakan `Geolocator` untuk fitur LBS

5. **Terdapat menu buttom navigation: menu profil (ada gambar) dan menu saran dan kesan mata kuliah Teknologi dan Pemrograman Mobile dan logout** ✅
   - Menu profil user dan profil pengembang
   - Menu saran dan kesan
   - Fitur logout

6. **Memiliki menu tambahan konversi mata uang (min. 3 mata uang) dan konversi waktu (minimal ada: WIB, WIT, WITA, London) yang terpadukan dengan konsep** ✅
   - Konversi 3 mata uang (USD, IDR, EUR, JPY)
   - Konversi waktu (WIB, WITA, WIT, UTC)
   - Terintegrasi dengan sistem booking

7. **Memiliki fasilitas pencarian dan pemilihan serta notifikasi sesuai dengan konsep** ✅
   - Fitur pencarian hotel
   - Fitur filter berdasarkan kabupaten, harga, dan rating
   - Fitur notifikasi untuk booking, login, dan topup

8. **Memiliki sensor sederhana (accelerometer/ gyroscope / magnetometer / barometer)** ✅
   - Menggunakan `sensors_plus` untuk accelerometer
   - Implementasi shake detection untuk konfirmasi top up dan booking kamar

## Fitur Tambahan
  - Generate resi PDF bukti transaksi
  - Bookmark hotel favorit


## Setup

1. Clone repository:
   ```bash
   git clone https://github.com/yourusername/TuruKamar.git
   ```

2. Navigasi ke direktori proyek:
   ```bash
   cd TuruKamar
   ```

3. Install dependencies:
   ```bash
   flutter pub get
   ```

4. Jalankan aplikasi:
   ```bash
   flutter run
   ```

## Dependencies

- **Flutter**: Framework UI untuk pengembangan aplikasi mobile.
- **SharedPreferences**: Menyimpan data sederhana seperti preferensi pengguna.
- **Intl**: Menangani internasionalisasi dan format data seperti tanggal dan mata uang.
- **PDF**: Membuat dan memanipulasi file PDF.
- **Printing**: Mencetak dokumen dari aplikasi.
- **Image Picker**: Memilih gambar dari galeri atau kamera.
- **Geolocator**: Mendapatkan lokasi pengguna.
- **Google Maps Flutter**: Menampilkan peta Google di aplikasi.
- **Google Fonts**: Menggunakan font Google di aplikasi.
- **Sensors Plus**: Mengakses sensor perangkat seperti akselerometer dan giroskop.
