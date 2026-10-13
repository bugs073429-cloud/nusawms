# Nusa WMS — Integration & Regression Audit

Tanggal: 2026-10-13
Paket dasar: Nusa_WMS_Audit_Fix_v2

## Cakupan yang dapat diverifikasi di lingkungan audit

- PHP syntax: `php -l src/app.php` dan `php -l tests/php/test_project_structure.php` lulus.
- JavaScript syntax: `node --check public/assets/app.js` lulus.
- Struktur/fitur statis: `php tests/php/test_project_structure.php` lulus untuk 26 pemeriksaan.
- Migration sesi: file migration menggunakan `CREATE TABLE IF NOT EXISTS` untuk `scan_sessions` dan `scan_session_events`; foreign key mengarah ke `users`, `products`, dan `warehouses`.
- Diagnostik saldo/ledger: `tests/stock_consistency_checks.sql` memeriksa selisih saldo, transfer tidak seimbang, referensi ledger yang tidak lengkap, dan stok negatif.
- ZIP: validasi arsip dijalankan setelah paket dibuat.

## Perubahan keamanan dalam audit ini

POST action sekarang memiliki allowlist route yang eksplisit. Sebelumnya, izin diperiksa pada menu/route yang diminta, sedangkan `handle_post()` menerima nama aksi global. Kondisi tersebut berisiko memungkinkan akun dengan izin pada route yang tidak terkait mengirim aksi POST lain. Allowlist kini mengikat aksi produk, gudang, lokasi, pemasok, jadwal, transfer, pivot sesi, RFID, serta administrasi role ke route yang semestinya. Aksi stock posting juga memeriksa arah transaksi terhadap route inbound/outbound (atau orders).

## Temuan dan batasan yang harus diselesaikan sebelum produksi

1. Belum tersedia koneksi MySQL/MariaDB pada lingkungan audit ini. Karena itu, query dan migrasi belum dieksekusi terhadap database aktual.
2. Belum tersedia browser automation/browser runtime untuk login dan uji navigasi interaktif end-to-end.
3. Form Master Produk yang ditemukan mendukung tambah dan daftar, tetapi belum menyediakan alur edit produk yang terlihat di UI. Jangan menganggap edit master produk telah lulus.
4. Transfer saat ini secara eksplisit hanya mendukung stok non-batch dan langsung dicatat sebagai `RECEIVED`. Batch transfer dan alur dispatch/receive bertahap belum teruji/diimplementasikan pada alur ini.
5. Tracking serial pada transaksi stock post belum memiliki validasi serial per unit yang lengkap. Produk mode serial/serial-expiry perlu ditahan dari penggunaan transaksi umum sampai validasi serial diterapkan.
6. Integrasi cloud master belum aktif. Menu tersebut menjelaskan keterbatasan ini, bukan melakukan sinkronisasi.
7. Diagnostik ledger akan menandai selisih jika saldo awal inventory dibuat tanpa movement `OPENING`. Pastikan migrasi saldo awal membuat ledger pembuka atau dokumentasikan baseline sebelum menafsirkan hasil.

## Rencana tes integrasi pada database uji

Jalankan hanya pada salinan database, bukan produksi. Pastikan user, role, gudang, lokasi, produk, dan saldo awal uji telah tersedia.

1. **Inbound**: catat saldo awal 10 unit lewat movement pembuka yang sah, posting inbound +5, pastikan saldo 15 dan ledger bertambah +5.
2. **Outbound**: posting outbound 3, pastikan saldo 12 dan ledger -3.
3. **Outbound negatif**: coba keluarkan lebih dari stok tersedia dan coba stok reserved; transaksi harus ditolak tanpa perubahan saldo/ledger.
4. **Transfer**: pindahkan 4 unit dari gudang A ke B; saldo A turun 4, B naik 4, ada tepat satu `TRANSFER_OUT` dan satu `TRANSFER_IN`, jumlah keduanya seimbang.
5. **Lokasi**: coba pakai lokasi dari gudang berbeda; server harus menolak dan rollback.
6. **Produk**: uji SKU duplikat, barcode duplikat, nama kosong, tracking batch tanpa batch, expiry invalid, dan nilai stok negatif. Periksa apakah validasi memberi pesan yang aman dan tidak menulis parsial.
7. **Scan session**: impor `database/migrations/20261012_scan_sessions.sql` sekali ke database uji. Verifikasi kedua tabel dan FK di `information_schema`; buka sesi, simpan scan cocok/tidak cocok, tutup sesi, lalu periksa pivot.
8. **Role/POST**: dengan role terbatas, kirim POST ke route yang salah dengan token CSRF valid. Server harus memberi 403 dan tidak mengubah data. Uji juga token CSRF hilang/salah (419).
9. **RFID**: UID duplikat harus ditolak; mapping ke produk nonaktif/tidak ada ditolak; deaktivasi wajib memiliki alasan; histori tidak terhapus.
10. **Ekspor**: filter rentang tanggal, bandingkan jumlah/qty CSV dengan query laporan; uji tanggal awal/akhir tidak valid dan pastikan tidak mengekspor di luar rentang.
11. **Navigasi/browser**: login tiap role, klik semua menu yang diizinkan, uji responsive desktop/tablet, tombol kembali, form, filter, unduh, print, dan tidak ada fatal error pada log PHP/browser.
12. Jalankan `tests/stock_consistency_checks.sql` setelah tiap kelompok transaksi. Semua query diagnostik idealnya menghasilkan nol baris, dengan catatan baseline saldo awal di atas.

## Keputusan audit

**Lulus pemeriksaan statis dasar, belum lulus integrasi/operasional.** Jangan mempromosikan paket ke produksi sebelum tes database dan browser di atas dilakukan pada lingkungan pengguna.

## Revisi lanjutan: UX, authorization, dan ekspor

- Otorisasi aksi POST memakai `post_action_routes()` sebagai sumber rute yang konsisten. Handler memeriksa halaman aktual dan izin halaman tersebut, sehingga role yang hanya memiliki izin `inbound` atau `transfer-bin` tidak salah ditolak oleh pemeriksaan izin handler yang lebih umum.
- Cookie sesi ditandai `HttpOnly` dan `SameSite=Lax`; flag `Secure` aktif saat aplikasi diakses melalui HTTPS.
- Ekspor CSV memvalidasi format tanggal ISO dan memastikan tanggal awal tidak melewati tanggal akhir.
- Tes struktur diperluas untuk memverifikasi tiga kontrol tersebut.

### Batas pengujian

Pemeriksaan sintaks, JavaScript, dan tes struktur dijalankan lokal pada paket. Pengujian transaksi dengan MySQL, migrasi pada database aktif, hak akses end-to-end untuk setiap role, dan browser end-to-end tetap harus dilakukan di lingkungan XAMPP pengguna. Jangan menganggap status tersebut lulus berdasarkan tes struktur.
