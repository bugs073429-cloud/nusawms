# Nusa WMS – integrasi alur data

## Alur data yang terhubung

1. **Master Produk / Gudang / Lokasi / Pemasok** menyimpan referensi yang digunakan formulir transaksi.
2. **Logistik Masuk** dan **Inbound & Outbound** memvalidasi produk, gudang, lokasi, batch (bila diwajibkan), lalu memposting saldo `inventory`, ledger `stock_movements`, order `orders`, item `order_items`, dan `audit_logs` dalam transaksi database.
3. **Transfer** memposting pengurangan dan penambahan saldo gudang serta dua baris ledger (`TRANSFER_OUT`/`TRANSFER_IN`) dengan referensi ke transfer.
4. **Inventaris**, **Kontrol Stok**, **Dasbor**, **Pergerakan Stok**, **Laporan**, dan **Ekspor CSV** membaca tabel inventory/ledger yang sama, sehingga perubahan transaksi tampil konsisten.
5. **Jadwal Pengiriman** membaca order yang memiliki `scheduled_at`.

## Instalasi/update

- Backup folder aplikasi dan database terlebih dahulu.
- Salin isi `wms_starter` ke folder aplikasi yang ada.
- Tidak ada perubahan skema database pada pembaruan ini; tidak perlu import ulang `schema.sql`.
- Pastikan konfigurasi `config.php` tetap sesuai database lokal.

## Batasan yang masih perlu diselesaikan sebelum produksi

- Transfer masih menyelesaikan dispatch dan penerimaan dalam satu aksi; status in-transit belum menjadi workflow dua tahap.
- Transfer saat ini belum mendukung pemilihan batch secara eksplisit.
- Serial-number tracking penuh, picking/packing/dispatch bertahap, reservasi order, dan workflow approval cycle-count belum lengkap.
- Jadwal hanya menampilkan order yang sudah mempunyai `scheduled_at`; UI pembuatan appointment belum tersedia.
- Google Sheets saat ini alur ekspor/impor CSV manual, bukan sinkronisasi API.

Jangan gunakan sebagai sistem stok produksi sebelum uji penerimaan, pengeluaran, transfer, batch/serial, dan rekonsiliasi di salinan database uji.

## Peran, izin, dan enforcement

- Menu **Peran & Izin** mengelola pembuatan/pembaruan/penghapusan peran, izin menu granular, pembuatan pengguna, pergantian peran, dan aktivasi/nonaktivasi pengguna.
- Kolom `roles.permissions` yang sudah ada menyimpan array JSON key menu; nilai `*` berarti akses penuh. Tidak diperlukan migrasi skema untuk modul ini.
- Middleware memuat ulang status akun dan izin dari database pada setiap request. Navigasi menyembunyikan menu tanpa izin, dan akses URL langsung ditolak dengan HTTP 403.
- POST divalidasi terhadap route yang sesuai untuk mencegah aksi admin dikirim melalui halaman lain. CSRF tetap diverifikasi oleh bootstrap.
- Penghapusan peran diblokir jika peran masih dipakai; akun sendiri tidak dapat dinonaktifkan; akun dengan akses penuh terakhir dilindungi.
- Gunakan HTTPS untuk produksi, siapkan minimal dua akun administrator, dan uji matriks akses dengan akun peran berbeda sebelum go-live.
