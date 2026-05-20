# Sistem Inventaris — inventaris_db

Sistem manajemen inventaris berbasis PHP & MySQL dengan fitur peminjaman dan pengembalian barang.

## Struktur File

```
inventaris/
├── inventaris_db.sql       ← Import database di sini
├── index.php               ← Redirect otomatis
├── login.php
├── logout.php
├── includes/
│   ├── config.php          ← Konfigurasi database & helper
│   ├── header.php
│   └── footer.php
├── admin/
│   ├── dashboard.php       ← Statistik & ringkasan
│   ├── barang.php          ← Tambah / edit / hapus barang
│   ├── peminjaman.php      ← Kelola peminjaman & pengembalian
│   └── laporan.php         ← Laporan + export CSV
└── user/
    ├── dashboard.php       ← Dashboard peminjam
    ├── daftar_barang.php   ← Lihat & pinjam barang
    └── riwayat.php         ← Riwayat pinjaman sendiri
```

## Cara Install

1. **Import database:**
   ```
   mysql -u root -p < inventaris_db.sql
   ```
   Atau buka phpMyAdmin → Import → pilih `inventaris_db.sql`

2. **Edit konfigurasi** di `includes/config.php`:
   ```php
   define('DB_HOST', 'localhost');
   define('DB_USER', 'root');
   define('DB_PASS', '');  // ← sesuaikan password MySQL Anda
   define('DB_NAME', 'inventaris_db');
   ```

3. **Letakkan folder** di direktori web server:
   - XAMPP: `C:/xampp/htdocs/inventaris/`
   - WAMP:  `C:/wamp64/www/inventaris/`
   - Linux: `/var/www/html/inventaris/`

4. **Akses** di browser: `http://localhost/inventaris/`

## Akun Default

| Username | Password | Role    |
|----------|----------|---------|
| admin    | password | Admin   |
| budi     | password | Peminjam|

> **Penting:** Ganti password default setelah pertama kali login!

## Fitur

### Admin
- Dashboard statistik (total barang, pengguna, pinjaman aktif)
- Kelola barang: tambah, edit (nama/jumlah/kondisi), hapus
- Kondisi barang: **baik** / **rusak**
- Kelola peminjaman: lihat semua, filter status, proses pengembalian
- Laporan peminjaman: filter tanggal + **export CSV**

### Peminjam (User)
- Lihat daftar barang beserta stok & kondisi
- Pinjam barang langsung dari tabel (stok otomatis berkurang)
- Barang rusak tidak bisa dipinjam
- Lihat riwayat peminjaman sendiri

## Database

### Tabel
- `user` — akun pengguna dengan role admin/peminjam
- `barang` — data barang (jumlah, kondisi: baik/rusak)
- `peminjaman` — transaksi pinjam-kembali

### Stored Procedure
- `pinjam_barang(id_user, id_barang, jumlah)` — catat peminjaman + kurangi stok, dengan validasi stok
- `kembalikan_barang(id_pinjam)` — catat pengembalian + tambah stok kembali

### Function
- `status_barang(jumlah)` — mengembalikan 'Tersedia' atau 'Habis'

## Keamanan
- Password di-hash dengan `password_hash()` (bcrypt)
- Input di-sanitize dengan `mysqli::real_escape_string` + `htmlspecialchars`
- Prepared statements untuk query sensitif
- Session check di setiap halaman (middleware `requireLogin()` / `requireAdmin()`)
- Barang yang sedang dipinjam tidak bisa dihapus
