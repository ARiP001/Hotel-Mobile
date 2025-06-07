# TuruKamar

Aplikasi mobile Flutter untuk pemesanan dan manajemen hotel.

## Konsep Aplikasi

TuruKamar adalah aplikasi yang dirancang untuk membantu pengguna dalam memesan dan mengelola hotel. Aplikasi ini menawarkan berbagai fitur untuk memudahkan pengguna dalam mencari, memesan, dan mengelola akomodasi mereka.

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
   - Menggunakan `SharedPreferences` dan 'Hive' untuk penyimpanan lokal
   - Menyimpan data user, booking, dan preferensi

4. **Terdapat web service / API boleh sampai pemanfaatan IoT, games atau multiplatform (Android, iOS) serta memiliki fasilitas LBS yang terkait tema** ✅
   - Menggunakan Xotelo API untuk data hotel
   - Menggunakan `Geolocator` untuk fitur LBS
   - Mendukung multiplatform (Android/iOS)

5. **Terdapat menu buttom navigation: menu profil (ada gambar) dan menu saran dan kesan mata kuliah Teknologi dan Pemrograman Mobile dan logout** ✅
   - Menu profil dengan gambar
   - Menu saran dan kesan
   - Fitur logout

6. **Memiliki menu tambahan konversi mata uang (min. 3 mata uang) dan konversi waktu (minimal ada: WIB, WIT, WITA, London) yang terpadukan dengan konsep** ✅
   - Konversi 3 mata uang (USD, IDR, EUR, JPY)
   - Konversi waktu (WIB, WITA, WIT, UTC)
   - Terintegrasi dengan sistem booking

7. **Memiliki fasilitas pencarian dan pemilihan serta notifikasi sesuai dengan konsep** ✅
   - Fitur pencarian hotel
   - Sistem notifikasi untuk booking
   - Notifikasi untuk pembayaran

8. **Memiliki sensor sederhana (accelerometer/ gyroscope / magnetometer / barometer)** ✅
   - Menggunakan `sensors_plus` untuk accelerometer
   - Implementasi shake detection untuk konfirmasi top up
   - Sensor untuk interaksi user


### Fitur Utama

- Autentikasi pengguna (login/register)
- Pencarian dan filter hotel
- Manajemen pemesanan
- Kustomisasi profil
- Konversi mata uang
- Notifikasi
- Generasi PDF untuk bukti pembayaran

### Alur Aplikasi

1. Pengguna di halaman Utama (kosong) → ke halaman daftar surat → klik surat tersebut → isi target hafalan sampai tanggal berapa, dikasih tahu pengingatnya kapan → Tersimpan di Database.
2. Di Halaman Utama tersedia list itu → di tekan → Mulai menghafal (Terdapat lokasi menghafal juga, dan sensor apakah hp sedang berdiri atau tidur) → Selesai → Tercatat di database sudah selesai untuk hari itu → Halaman utama kosong.
3. Notifikasi bunyi → Bisa dilihat kembali di halaman notifikasi → mulai menghafal.
4. Pengguna buka halaman detail → bisa melihat data pribadi → bisa melihat kesan TPM.
5. Pengguna buka halaman detail → Pengguna buka halaman berlangganan --> nanti tulisan pilihannya 10 Dolar --> Pengguna bakal masukin uang secara IDR nanti di sistem bakal convert menjadi Dolar. Kalo IDR belum mencukupi, tombol pembayaran belum bisa ditekan --> Pengguna berhasil menemukan uang yang sesuai --> Nanti jadi berlangganan --> Pengguna set waktu untuk pembayaran selanjutnya (konversi waktu).

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

## API yang Digunakan

Aplikasi ini menggunakan [Xotelo API](https://xotelo.com/#endpoint-search) untuk mendapatkan data hotel secara real-time. API ini menyediakan endpoint untuk mendapatkan daftar hotel berdasarkan lokasi.

- **Latest list endpoint (/list)**: Mendapatkan daftar hotel berdasarkan lokasi.

API ini memungkinkan aplikasi untuk menampilkan informasi hotel yang akurat dan terkini kepada pengguna.

