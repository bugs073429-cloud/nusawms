# Generator Barcode dan QR

Menu **Inventaris → Buat Barcode QR** menyediakan generator client-side untuk teks, SKU, kode bin, atau referensi lainnya.

- QR Code: ukuran 120–420 px, tiga preset ukuran, unduh PNG, dan cetak.
- Barcode: Code 128, dengan validasi library saat render.
- Mode gabungan: menampilkan QR + barcode, dapat diunduh sebagai PNG gabungan atau dicetak.
- Label teks: dapat diaktifkan/nonaktifkan dan ukuran font dapat diubah.
- Generator bersifat read-only terhadap master data dan tidak membuat transaksi stok.

Generator memakai `qrcodejs` dan `JsBarcode` dari CDN dengan fallback. Koneksi internet diperlukan untuk memuat library. Jika CDN tidak tersedia, halaman memberi status error dan fitur scan/operasional lain tetap tidak terpengaruh.

Akses route mengikuti mekanisme permission yang sudah ada. Administrator perlu memberikan izin `barcode-generator` kepada peran khusus yang harus memakai menu baru; peran dengan izin `*` mendapat akses otomatis.
