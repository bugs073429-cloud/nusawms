# Struktur proyek Nusa WMS

```text
wms_starter/
├── public/                 # Web root: front controller dan aset statis
│   ├── index.php           # Entry point kompatibel Apache/XAMPP
│   └── assets/             # CSS dan JavaScript
├── src/                    # Source code aplikasi
│   ├── app.php             # Router/controller aplikasi (legacy monolith, dipertahankan aman)
│   ├── core/               # Bootstrap, koneksi PDO, sesi, CSRF, audit
│   ├── ui/                 # Target pemisahan komponen UI
│   ├── services/           # Target pemisahan aturan bisnis
│   ├── repositories/       # Target pemisahan akses data
│   ├── models/              # Target model domain
│   └── utils/               # Target utilitas umum
├── config/                 # Template dan panduan konfigurasi
├── config.php              # Konfigurasi aktif lokal (kompatibilitas lama)
├── config.example.php      # Template konfigurasi legacy
├── database/               # Schema, migration, diagnostic SQL
├── tests/                  # Tes regresi dan SQL diagnostics
├── docs/                   # Dokumentasi pengguna dan arsitektur
├── scripts/                # Skrip pemeliharaan/deployment
├── data/                   # Direktori data lokal, tidak untuk web publik
└── logs/                   # Direktori log lokal, tidak untuk web publik
```

## Keputusan kompatibilitas

- URL `http://localhost/wms_starter/public/` dan path aset `assets/...` tetap sama.
- `public/index.php` tetap menjadi entry point; hanya meneruskan eksekusi ke `src/app.php`.
- `app/bootstrap.php` dipertahankan sebagai bridge untuk integrasi lama; bootstrap kanonis ada di `src/core/bootstrap.php`.
- `config.php`, `database/schema.sql`, dan migration tidak dipindahkan atau diubah agar setup XAMPP/database yang sudah ada tidak rusak.
- Logika aplikasi masih terkonsentrasi di `src/app.php`. Folder layanan/repository/UI/model disiapkan untuk ekstraksi bertahap, bukan klaim bahwa seluruh monolith sudah terpecah.

## Rekomendasi deployment

Atur Apache DocumentRoot/alias ke folder `public` jika deployment mengizinkan. Untuk pola XAMPP starter, URL `.../public/` tetap didukung. Batasi akses HTTP ke `config.php`, `src/`, `database/`, `data/`, `logs/`, dan `tests/`; jangan jadikan root proyek sebagai document root.

## Inventory monitoring rules

- Stock balances are read from committed `inventory` rows; available quantity is `qty_on_hand - qty_reserved`.
- Low-stock alerts are derived on each request for active SKUs with a configured threshold (`max(safety_stock, reorder_point) > 0`) where available quantity is at or below that threshold. Products without a configured positive threshold are intentionally excluded to avoid false alerts.
- `stock-control` is read-only. It does not adjust quantities or write ledger entries.
- Analytics throughput/productivity comes from `stock_movements`; occupancy comes from active `locations` and current `inventory`; batch aging includes only stock linked to `product_batches`.
- Analytics also compares inventory balances with the aggregate movement ledger by product, warehouse, location, and batch. Differences require investigation; the system never auto-corrects them.
- “Real-time” here means current committed database values are queried when the page is requested/refreshed. This starter does not implement WebSocket/push updates or external AI prediction.
