# Integrasi Menu dari INVENTORY WMS

Menu dari referensi `INVENTORY WMS.html` sudah ditambahkan ke navigasi Nusa WMS PHP/MySQL dan diarahkan ke route aplikasi.

## Pemetaan menu

- Inbound / Retur → workflow order inbound yang tersedia. Alur retur khusus belum terpisah.
- Outbound (Keluar) → workflow order outbound.
- Cycle Count Bin dan Stock Opname Harian → halaman petunjuk dengan tautan ke rekonsiliasi/inventaris; sesi count, approval, dan posting selisih belum dibuat.
- Transfer Bin → transfer antar gudang yang sudah tersedia.
- Pencarian Barang → saldo inventaris aktual.
- Rekap Pivot Sesi → tautan laporan dan ledger; skema sesi scan dari aplikasi referensi tidak tersedia di database lokal.
- Tracking Movement → ledger pergerakan stok.
- History CC & Transfer → riwayat transfer aktual; histori cycle count belum tersedia.
- Discrepancy → rekonsiliasi stok.
- Fast/Slow/Dead Stock → analitik yang tersedia.
- Dashboard Report → laporan operasional.
- Data Induk (Cloud) → halaman transparan yang menyatakan koneksi cloud belum dikonfigurasi.
- Data Bin CL → master lokasi/bin dari database lokal.
- Master Produk Cloud → master produk lokal; tidak mengklaim sinkronisasi cloud.
- Mapping RFID (UID) → halaman persiapan; skema UID dan perangkat reader belum tersedia.
- Buat Barcode QR → generator QR/Code 128 yang sudah tersedia.

## Batasan integrasi

File referensi adalah aplikasi HTML satu halaman dengan asumsi layanan Cloud/Supabase dan aset eksternal. Menyalin seluruh JavaScript-nya secara langsung ke aplikasi PHP tidak aman untuk integritas stok dan tidak kompatibel tanpa migrasi skema, autentikasi, dan kontrak API. Karena itu, menu yang dapat dipetakan menggunakan data Nusa WMS yang ada; menu yang membutuhkan skema/layanan baru menampilkan status yang jelas dan tidak membuat data palsu.
