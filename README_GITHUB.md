# Menjalankan Nusa WMS melalui GitHub

## Apa yang dilakukan GitHub Actions

Repository ini dilengkapi workflow `.github/workflows/php-ci.yml`. Workflow berjalan otomatis saat ada push ke branch `main` atau `master`, saat pull request, atau secara manual melalui tab **Actions**. Workflow memeriksa sintaks semua file PHP dan menjalankan pemeriksaan struktur proyek.

**Penting:** GitHub Actions menjalankan pemeriksaan di runner sementara. GitHub Pages tidak menjalankan PHP atau MySQL, sehingga workflow ini tidak membuat aplikasi WMS menjadi website publik yang terus aktif.

## Upload ZIP ke repository

1. Buat repository baru di GitHub.
2. Ekstrak ZIP ini secara lokal.
3. Upload isi folder hasil ekstraksi ke root repository. Pastikan `public/`, `src/`, `database/`, `tests/`, `config.php`, dan `.github/workflows/php-ci.yml` terlihat langsung di root repository. Jangan upload folder pembungkus ZIP tambahan.
4. Commit perubahan ke branch `main`.
5. Buka tab **Actions**, lalu pilih **Nusa WMS - PHP CI**. Periksa hasil kedua langkah pemeriksaan.

## Menjalankan aplikasi WMS

Aplikasi ini membutuhkan PHP 8.1+ dan MySQL 8+ atau MariaDB. Untuk pengujian lokal menggunakan XAMPP, ikuti petunjuk di `README.md`, sesuaikan `base_url` pada `config.php` dengan lokasi instalasi, lalu import `database/schema.sql` ke database kosong.

Untuk membuat aplikasi tersedia melalui internet, deploy ke layanan hosting yang mendukung PHP dan MySQL/MariaDB. Jangan memakai GitHub Pages untuk menjalankan backend PHP. Jangan masukkan kredensial produksi atau data inventaris asli ke repository publik.

## Catatan database

`database/schema.sql` berisi perintah `DROP TABLE IF EXISTS`. Import file tersebut akan menghapus tabel bernama sama pada database yang dipilih. Gunakan hanya database baru/kosong atau lakukan backup dan tinjau SQL terlebih dahulu.
