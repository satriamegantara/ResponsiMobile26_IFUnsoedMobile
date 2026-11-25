# PRD: Aplikasi Cuaca Flutter (Responsi Pemrograman Mobile)

| Item | Keterangan |
|---|---|
| Nama Mahasiswa | Satria (NIM H1D024022) |
| Framework | Flutter (Dart) |
| Sumber Data | Open-Meteo Weather Forecast API & Geocoding API |
| Arsitektur | Model-View-ViewModel (MVVM) |
| State Management | `StatefulWidget` + `setState` (sesuai materi kelas) |
| Penyimpanan Lokal | Hive |
| Deadline | 26 November 2026, pukul 10.00 |

---

## 1. Ringkasan

Aplikasi cuaca sederhana yang menampilkan kondisi cuaca terkini dan perkiraan beberapa hari ke depan untuk kota yang dipilih pengguna. Pengguna dapat mencari kota berdasarkan nama, memilih kota dari hasil pencarian, dan menyimpan kota sebagai favorit. Data favorit dan riwayat pencarian disimpan secara lokal dengan Hive dan ditampilkan kembali saat aplikasi dibuka.

## 2. Tujuan

1. Memenuhi seluruh ketentuan teknis dan ketentuan pengumpulan responsi.
2. Menerapkan MVVM, pengelolaan state dengan `setState`, dan HTTP GET ke REST API.
3. Menerapkan penyimpanan lokal dengan Hive.
4. Menghasilkan riwayat commit yang jelas per fitur/modul untuk mendukung video penjelasan.

## 3. Ruang Lingkup

### 3.1 In Scope
- Dua screen wajib: **Home/Weather Screen** dan **Search/Location Screen**.
- Pencarian kota melalui Open-Meteo Geocoding API.
- Pengambilan data cuaca dari Open-Meteo Weather Forecast API.
- Penanganan loading, data kosong, dan error (termasuk tidak ada koneksi internet).
- Favorit lokasi dan riwayat pencarian tersimpan di Hive.
- Data favorit dimuat ulang saat aplikasi dibuka.
- Tampilan mengikuti Material Design, Theme terpusat, dan Typography yang jelas.
- Layout responsif (`Expanded`, `Wrap`, `SingleChildScrollView`, dan sejenisnya).

### 3.2 Out of Scope
- Autentikasi atau login (Open-Meteo tidak memerlukan API key atau token).
- Backend sendiri.
- Notifikasi cuaca.
- Lokasi otomatis via GPS (tidak diwajibkan).

## 4. Pengguna

Mahasiswa yang menggunakan aplikasi untuk melihat cuaca kota tertentu dan menyimpan kota yang sering dicek. Penilai responsi juga bertindak sebagai pengguna yang menguji seluruh alur.

## 5. Teknologi dan Dependensi

| Package | Fungsi | Versi |
|---|---|---|
| `http` | HTTP GET ke Open-Meteo | ^1.2.0 |
| `hive` | Penyimpanan lokal (NoSQL) | ^2.2.3 |
| `hive_flutter` | Inisialisasi Hive untuk Flutter | ^1.1.0 |
| `path_provider` | Dependensi tidak langsung Hive | ^2.1.0 |

Catatan:
- Package `open_meteo` di pub.dev boleh dipakai, tetapi **tidak wajib**. Pilihan default adalah `http` murni agar mudah dijelaskan saat video.
- Dependensi `shared_preferences` dari materi tidak dipakai, karena pilihan penyimpanan lokal adalah Hive.
- Pin versi di `pubspec.yaml` sesuai versi stabil terbaru yang kompatibel dengan Flutter SDK yang terpasang. Jalankan `flutter pub get` setelah menambah dependensi.

## 6. Arsitektur MVVM

```
lib/
├── main.dart                     # Inisialisasi Hive, runApp, theme, routes
├── config/
│   ├── app_theme.dart            # ThemeData terpusat (warna, typography)
│   └── api_config.dart           # Base URL dan konstanta endpoint Open-Meteo
├── models/
│   ├── weather_model.dart        # Model respons forecast (current + daily)
│   ├── location_model.dart       # Model hasil geocoding (name, lat, lon, country, admin1)
│   └── favorite_model.dart       # Model favorit untuk disimpan di Hive
├── services/
│   ├── api_exception.dart        # Exception kustom (NoInternet, NotFound, Server, Parse)
│   ├── weather_service.dart      # HTTP GET ke Weather Forecast API
│   └── geocoding_service.dart    # HTTP GET ke Geocoding API
├── repositories/
│   └── local_storage_repository.dart  # CRUD Hive: favorit dan riwayat pencarian
├── viewmodels/
│   ├── home_viewmodel.dart       # State dan logika halaman cuaca
│   └── search_viewmodel.dart     # State dan logika halaman pencarian
├── views/
│   ├── home_screen.dart          # StatefulWidget, menampilkan HomeViewModel
│   └── search_screen.dart        # StatefulWidget, menampilkan SearchViewModel
└── widgets/
    ├── current_weather_card.dart # Kartu kondisi cuaca terkini
    ├── weather_detail_item.dart  # Item kelembapan, angin, peluang hujan
    ├── daily_forecast_tile.dart  # Baris perkiraan harian
    └── location_tile.dart        # Baris hasil pencarian / favorit
```

### 6.1 Aturan MVVM
- **Model**: hanya data dan `fromJson`/`toJson`. Tidak ada logika UI.
- **Service**: hanya HTTP dan parsing JSON. Melempar `ApiException` jika gagal.
- **Repository**: membungkus Hive agar ViewModel tidak mengakses Hive langsung.
- **ViewModel**: menyimpan state (loading, data, error, daftar kosong). Memanggil service dan repository. Tidak mengimpor widget Flutter.
- **View**: `StatefulWidget` yang membuat instance ViewModel, memanggil method-nya di `initState`, dan memanggil `setState` setelah state ViewModel berubah. Tidak berisi logika HTTP atau Hive.

### 6.2 Pola State dengan setState
- ViewModel adalah class biasa dengan field `isLoading`, `errorMessage`, `data`, dan method async seperti `loadWeather()`.
- Setiap method async di ViewModel diakhiri dengan memberi tahu View, misalnya lewat callback `onChanged` yang diisi `setState(() {})` di View.
- Semua pemanggilan `setState` harus dicek dengan `if (mounted)` setelah `await`.

## 7. Spesifikasi Fitur

### 7.1 Screen 1: Home / Weather Screen

Tujuan: menampilkan cuaca untuk kota yang sedang dipilih.

| ID | Kebutuhan | Keterangan |
|---|---|---|
| H1 | Nama kota | Menampilkan nama kota yang sedang dipilih beserta negara atau wilayah jika ada. |
| H2 | Kondisi cuaca | Menampilkan deskripsi dari `current.weather_code` (dipetakan ke teks dan ikon). |
| H3 | Suhu saat ini | `current.temperature_2m`, dengan satuan °C. |
| H4 | Informasi tambahan | Kelembapan (`current.relative_humidity_2m`), kecepatan angin (`current.wind_speed_10m`), peluang hujan maksimum hari ini (`daily.precipitation_probability_max`). |
| H5 | Perkiraan harian | Daftar beberapa hari ke depan dengan suhu maksimum dan minimum (`daily.temperature_2m_max`, `daily.temperature_2m_min`). |
| H6 | Tombol cari | Membuka Search Screen. |
| H7 | Tombol favorit | Menyimpan atau menghapus kota aktif dari favorit. |
| H8 | Loading | Menampilkan `CircularProgressIndicator` saat data diambil. |
| H9 | Data kosong | Menampilkan pesan jika belum ada kota dipilih dan favorit kosong, dengan ajakan untuk mencari kota. |
| H10 | Error | Menampilkan pesan error dan tombol "Coba lagi". |
| H11 | Favorit cepat | Daftar favorit ditampilkan di Home (opsional tetapi disarankan) untuk berpindah kota. |

Parameter request forecast:

```
https://api.open-meteo.com/v1/forecast
  ?latitude={lat}
  &longitude={lon}
  &current=temperature_2m,relative_humidity_2m,apparent_temperature,precipitation,weather_code,wind_speed_10m
  &daily=temperature_2m_max,temperature_2m_min,precipitation_probability_max,weather_code
  &timezone=auto
```

Catatan: `weather_code` pada `daily` bersifat opsional dan boleh dipakai untuk ikon di daftar harian. Atur `forecast_days` (default 7) bila perlu.

### 7.2 Screen 2: Search / Location Screen

Tujuan: mencari kota, memilih hasilnya, dan mengelola favorit.

| ID | Kebutuhan | Keterangan |
|---|---|---|
| S1 | Input pencarian | `TextField` dengan tombol cari. Minimal 2 karakter sebelum request. |
| S2 | Request ke API | Setiap pencarian memanggil Geocoding API. Ini wajib, tidak boleh memfilter data statis. |
| S3 | Daftar hasil | Menampilkan nama kota, wilayah, dan negara dari hasil API. |
| S4 | Pilih lokasi | Tap pada hasil memilih kota, lalu kembali ke Home dan memuat cuaca kota tersebut. |
| S5 | Simpan favorit | Tombol bintang pada hasil untuk menyimpan ke Hive. |
| S6 | Riwayat pencarian | Menyimpan kata kunci terakhir (maks. 10) ke Hive dan menampilkannya saat input kosong. |
| S7 | Loading | Indikator saat request berjalan. |
| S8 | Data kosong | Pesan "Kota tidak ditemukan" jika `results` tidak ada dalam respons. |
| S9 | Error | Pesan error ketika request gagal atau tidak ada koneksi. |

Parameter request geocoding:

```
https://geocoding-api.open-meteo.com/v1/search
  ?name={query}
  &count=10
  &language=id
  &format=json
```

Penting: ketika tidak ada kota yang cocok, Open-Meteo tidak mengirim field `results`. Parsing harus menangani kondisi ini.

### 7.3 Penyimpanan Lokal (Hive)

Box yang digunakan:

| Box | Isi | Format |
|---|---|---|
| `favorites` | Kota favorit | `Map` dengan kunci `id` (lat_lon), `name`, `admin1`, `country`, `latitude`, `longitude` |
| `search_history` | Kata kunci pencarian | `String`, maksimal 10 item terbaru |

Aturan:
- Inisialisasi dengan `await Hive.initFlutter()` dan `await Hive.openBox(...)` di `main()` sebelum `runApp`.
- Pakai `Map` agar tidak perlu membuat `TypeAdapter` dan `build_runner`. Ini menjaga scope tetap sederhana.
- Data harus tetap ada saat aplikasi ditutup lalu dibuka lagi.
- Kota aktif terakhir disimpan juga (box `settings`, kunci `last_city`). Saat aplikasi dibuka, kota ini dimuat ulang dari API. Jika tidak ada, gunakan favorit pertama, atau tampilkan kondisi kosong.

## 8. Penanganan Error

| Kondisi | Perilaku |
|---|---|
| Tidak ada internet (`SocketException`) | `ApiException.noInternet`, tampilkan pesan "Tidak ada koneksi internet". |
| Status HTTP bukan 200 | `ApiException.server` dengan kode status. |
| Respons JSON tidak sesuai model | `ApiException.parse`, tampilkan "Data tidak dapat dibaca". |
| Timeout | Gunakan `.timeout(Duration(seconds: 10))`, lempar `ApiException.timeout`. |
| Geocoding tanpa hasil | Bukan error, tampilkan state kosong. |

Seluruh error ditampilkan lewat state ViewModel, bukan dengan `print` saja.

## 9. Desain dan Tampilan

- **Theme**: `ThemeData` dengan `useMaterial3: true`, `ColorScheme.fromSeed` dari warna biru langit atau sejenisnya. Didefinisikan di `app_theme.dart`.
- **Typography**: `textTheme` konsisten. Suhu besar (misal 64 sp), nama kota (titleLarge), detail (bodyMedium).
- **Ikon cuaca**: pemetaan `weather_code` ke ikon Material (misal `Icons.wb_sunny`, `Icons.cloud`, `Icons.grain`, `Icons.thunderstorm`).
- **Responsif**: gunakan `SingleChildScrollView`, `Wrap`, dan `Expanded`. Uji pada emulator kecil dan besar.
- **Konsistensi**: semua warna dan gaya teks diambil dari Theme, tidak hardcoded di widget.

## 10. Rencana Commit (Per Fitur/Modul)

Setiap commit harus berdiri sendiri dan bisa dijalankan (`flutter analyze` tanpa error). Pesan commit mengikuti format `feat(scope): deskripsi`.

| No | Commit | Isi |
|---|---|---|
| 1 | `chore: setup project dan dependensi` | `pubspec.yaml`, struktur folder kosong, `main.dart` minimal |
| 2 | `feat(config): tambah app theme dan api config` | `app_theme.dart`, `api_config.dart` |
| 3 | `feat(model): tambah model weather, location, favorite` | Tiga file model dengan `fromJson` |
| 4 | `feat(service): tambah api exception dan weather service` | Exception dan HTTP GET forecast |
| 5 | `feat(service): tambah geocoding service` | HTTP GET geocoding dan penanganan `results` kosong |
| 6 | `feat(storage): tambah local storage repository dengan hive` | Inisialisasi Hive, box favorit, riwayat, kota terakhir |
| 7 | `feat(viewmodel): tambah home viewmodel` | State loading, data, error, dan method muat cuaca |
| 8 | `feat(viewmodel): tambah search viewmodel` | State pencarian, riwayat, dan favorit |
| 9 | `feat(ui): tambah home screen` | Tampilan cuaca, loading, error, data kosong |
| 10 | `feat(ui): tambah search screen` | Input, daftar hasil, tombol favorit |
| 11 | `feat(navigation): hubungkan home dan search` | Navigasi dua arah dan pengembalian kota terpilih |
| 12 | `feat(favorite): muat favorit dan kota terakhir saat startup` | Persistensi setelah app ditutup |
| 13 | `docs: tambah README dengan struktur, API, MVVM, dan screenshot` | README lengkap |

## 11. Ketentuan Pengumpulan (Dari Dokumen Responsi)

Checklist yang wajib dipenuhi:

- [ ] Source code Flutter di repository GitHub pribadi.
- [ ] Dokumentasi singkat tentang struktur aplikasi, implementasi API, dan penerapan MVVM (ditulis di README).
- [ ] Screenshot setiap screen di `README.md`.
- [ ] Video penjelasan kode (disiapkan mahasiswa, dengan dukungan riwayat commit).
- [ ] Data cuaca berasal dari API, bukan data statis atau hardcoded.
- [ ] Fitur pencarian melakukan request ke API.
- [ ] Mahasiswa mampu menjelaskan setiap bagian kode.
- [ ] Pengumpulan link melalui Google Form sebelum 26 November 2026 pukul 10.00.

## 12. Instruksi untuk AI Developer

1. Kerjakan sesuai urutan commit pada bagian 10. Satu commit untuk satu fitur atau modul.
2. Di setiap akhir commit, tulis penjelasan singkat di **chat** (bukan di file atau direktori) yang berisi: file apa yang dibuat atau diubah, alasan desain, dan bagian kode yang penting untuk dijelaskan di video.
3. Jangan membuat file penjelasan tambahan di direktori proyek selain README.md.
4. Jangan menambahkan autentikasi, token, atau kode dari modul login/CRUD yang tidak relevan. Kode `Api` dengan header `Authorization` dari materi tidak dibutuhkan.
5. Jangan membuat package `flutter_bloc`, `provider`, atau `riverpod`. State management adalah `setState`.
6. Jangan menggunakan data statis untuk cuaca maupun hasil pencarian.
7. Gunakan `async/await` dan `try/catch` untuk setiap pemanggilan jaringan dan Hive.
8. Tulis komentar singkat di kelas utama, cukup untuk membantu mahasiswa menjelaskan kode.
9. Sebelum commit, jalankan `flutter analyze` dan pastikan tidak ada error.
10. Jika ada keputusan teknis di luar PRD, tanyakan dulu sebelum menerapkannya.

## 13. Kriteria Penerimaan

- Aplikasi berjalan di emulator Android tanpa crash.
- Pencarian "Jakarta" atau "Purwokerto" menampilkan hasil dari API dan dapat dipilih.
- Home menampilkan nama kota, suhu, kelembapan, kecepatan angin, peluang hujan, dan perkiraan harian.
- Favorit tersimpan, tetap ada setelah aplikasi ditutup dan dibuka ulang.
- Mode pesawat menampilkan pesan error yang jelas, bukan layar merah.
- Struktur folder dan pemisahan Model, View, dan ViewModel terlihat jelas di kode.
- README memuat screenshot kedua screen.
