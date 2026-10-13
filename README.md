# Nusa WMS — Warehouse Management System starter

A modular PHP 8.1+ / MySQL 8+ or MariaDB starter for XAMPP. Includes a responsive UI, setup/login, product/warehouse/location/supplier master data, basic inbound/outbound stock posting, basic inter-warehouse transfer, stock ledger, monthly movement report with Excel-compatible CSV export, and audit trail.

## Local setup (XAMPP)
1. Copy this folder to `C:\xampp\htdocs\wms_starter`.
2. Start Apache and MySQL from XAMPP Control Panel.
3. Open phpMyAdmin and import `database/schema.sql`.
4. Copy `config.example.php` to `config.php`; verify DB credentials and `base_url`.
5. Open `http://localhost/wms_starter/public/?action=setup` and create the first administrator (12+ character password).
6. Sign in at `http://localhost/wms_starter/public/`.

## Included routes
- Dashboard
- Master Produk (SKU, barcode, UOM, tracking mode, safety/buffer/reorder thresholds)
- Inventaris and stock movement ledger
- Inbound/outbound posting with transaction safety and stock availability validation
- Warehouses, locations, suppliers
- Basic inter-warehouse transfer
- Monthly/custom date-range report and CSV export readable by Excel
- Audit log and role tables

## Important scope notes before production
This is a functional foundation, not a fully validated enterprise WMS release. Advanced serial-level transactions, wave/batch/location-based picking, pack/dispatch scans, configurable order routing, consignment workflows, multi-client billing calculation, cycle-count approval workflow, and barcode scanner device integration are represented as extension points/database foundations and still require implementation and acceptance testing. The current transfer flow immediately records a transfer as received (no in-transit confirmation UI); transfer currently supports non-batch stock only. Serial tracking is stored in the schema but serial-by-serial enforcement is not yet implemented. Do not use for regulated or high-value inventory until these controls are completed and tested.

## Engineering notes
- PDO prepared statements, `utf8mb4`, InnoDB, session ID regeneration, password hashing, CSRF tokens, HTML escaping, database transactions for stock posting/transfers.
- Use HTTPS, restrict database credentials, set `display_errors=Off`, configure backups, and place configuration/secrets outside the public web root in production.
- CSV uses UTF-8 BOM and semicolon separators for Excel compatibility; it is not a native `.xlsx` workbook.
- Before production: add automated tests, permission middleware per route/action, rate limiting and login lockout, pagination, stock reconciliation jobs, migrations, approval workflows, and deployment hardening.

## Appointment & Dock Scheduling (upgrade)

Untuk mengaktifkan workflow Jadwal & Dock pada database WMS yang sudah ada:
1. Backup database.
2. Buka phpMyAdmin dan pilih database WMS aktif.
3. Import `database/migrations/20261012_dock_appointments.sql` satu kali.
4. Login lalu buka **Logistik Masuk → Jadwal Pengiriman**.
5. Buat dock untuk masing-masing gudang, lalu buat appointment dari order aktif.

Sistem memvalidasi bahwa dock dan order berada pada gudang yang sama, tipe dock sesuai arah order, waktu selesai lebih besar dari waktu mulai, tidak ada bentrok slot aktif pada dock yang sama, dan satu order tidak memiliki dua appointment aktif. Appointment tidak mengubah saldo stok. Check-in memindahkan status order ke RECEIVING (inbound) atau PICKING (outbound) jika status sebelumnya DRAFT/SCHEDULED. Posting stok tetap dilakukan melalui transaksi operasional terpisah.

Status appointment: BOOKED → CHECKED_IN → IN_PROGRESS → COMPLETED; appointment BOOKED dapat dibatalkan. Penguncian baris dock saat booking membantu mencegah bentrok pada permintaan bersamaan. Tetap lakukan uji integrasi pada salinan database sebelum produksi.


## Camera barcode / QR scanner

The `Pindai Barcode / QR` page uses the browser camera through `html5-qrcode` (CDN primary with jsDelivr fallback). It supports QR Code and common linear formats including Code 128, Code 39/93, EAN-13/8, UPC-A/E, ITF, Codabar, Data Matrix and PDF417. Camera access is only requested after the user presses **Mulai kamera**. A manual SKU/barcode search and USB scanner input remain available if camera access or the external library is unavailable.

**Browser requirements:** camera APIs require a secure context (`https://` or `http://localhost`). An ordinary `http://<LAN-IP>` URL is generally blocked by modern browsers. The user must explicitly allow camera permission. This environment can validate syntax and archive integrity, but real camera hardware and live MySQL/browser integration must be tested on the target device before production use.

## Struktur proyek (refactoring)

Source aplikasi kini berada di `src/app.php`, dengan bootstrap kanonis di `src/core/bootstrap.php`. `public/index.php` tetap menjadi entry point untuk menjaga kompatibilitas XAMPP, sedangkan `app/bootstrap.php` tetap tersedia sebagai bridge kompatibilitas. Folder `config/`, `docs/architecture/`, `scripts/`, `data/`, `logs/`, dan `tests/php/` memisahkan dokumentasi, template konfigurasi, pemeliharaan, data lokal, log, dan tes. Skema database serta konfigurasi aktif tidak dipindahkan.

Jalankan pemeriksaan struktur dengan `php tests/php/test_project_structure.php`. Folder `src/ui`, `src/services`, `src/repositories`, `src/models`, dan `src/utils` adalah tujuan ekstraksi bertahap; fungsi aktif masih berada di `src/app.php` untuk menghindari perubahan perilaku besar tanpa tes integrasi.
