# Data Bin CL dan Rekap Pivot Sesi

## Data Bin CL
- Membaca master lokasi, gudang, dan saldo inventaris dari database lokal.
- Mendukung filter gudang, pencarian kode/komponen lokasi, dan status aktif/nonaktif.
- Menampilkan on-hand, reserved, serta jumlah SKU berbeda dengan saldo positif.
- Tidak melakukan sinkronisasi Cloud/Supabase dan tidak mengubah stok.

## Rekap Pivot Sesi
- Membutuhkan migrasi `database/migrations/20261012_scan_sessions.sql` satu kali.
- Operator membuka sesi, memindai/mengetik SKU, barcode, atau UID RFID, lalu menutup sesi.
- Hasil scan disimpan sebagai aktivitas audit dan dipivot per sesi; kode tak dikenal juga disimpan sebagai UNMATCHED.
- Pencatatan scan tidak membuat transaksi stok dan tidak mengubah inventory atau stock ledger.
- Pencocokan UID hanya menggunakan pemetaan RFID aktif; reader fisik yang membutuhkan driver/protokol khusus tetap memerlukan integrasi perangkat.
