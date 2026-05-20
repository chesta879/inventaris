-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: May 20, 2026 at 08:58 AM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `inventaris_db`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `kembalikan_barang` (IN `p_id_pinjam` INT)   BEGIN
    DECLARE v_id_barang INT;
    DECLARE v_jumlah INT;
    DECLARE v_status VARCHAR(20);

    SELECT id_barang, jumlah_pinjam, status
    INTO v_id_barang, v_jumlah, v_status
    FROM peminjaman WHERE id_pinjam = p_id_pinjam;

    IF v_status IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Data peminjaman tidak ditemukan';
    ELSEIF v_status = 'dikembalikan' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Barang sudah dikembalikan';
    ELSE
        UPDATE peminjaman
        SET tanggal_kembali = CURDATE(), status = 'dikembalikan'
        WHERE id_pinjam = p_id_pinjam;

        UPDATE barang
        SET jumlah = jumlah + v_jumlah
        WHERE id_barang = v_id_barang;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `pinjam_barang` (IN `p_id_user` INT, IN `p_id_barang` INT, IN `p_jumlah` INT)   BEGIN
    DECLARE stok_ada INT;
    SELECT jumlah INTO stok_ada FROM barang WHERE id_barang = p_id_barang;

    IF stok_ada IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Barang tidak ditemukan';
    ELSEIF stok_ada < p_jumlah THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Stok tidak mencukupi';
    ELSE
        INSERT INTO peminjaman(id_user, id_barang, jumlah_pinjam, tanggal_pinjam, status)
        VALUES(p_id_user, p_id_barang, p_jumlah, CURDATE(), 'dipinjam');

        UPDATE barang
        SET jumlah = jumlah - p_jumlah
        WHERE id_barang = p_id_barang;
    END IF;
END$$

--
-- Functions
--
CREATE DEFINER=`root`@`localhost` FUNCTION `status_barang` (`jumlah` INT) RETURNS VARCHAR(20) CHARSET utf8mb4 COLLATE utf8mb4_unicode_ci DETERMINISTIC BEGIN
    DECLARE hasil VARCHAR(20);
    IF jumlah <= 0 THEN
        SET hasil = 'Habis';
    ELSE
        SET hasil = 'Tersedia';
    END IF;
    RETURN hasil;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `barang`
--

CREATE TABLE `barang` (
  `id_barang` int(11) NOT NULL,
  `nama_barang` varchar(100) NOT NULL,
  `jumlah` int(11) NOT NULL DEFAULT 0,
  `kondisi_barang` enum('baik','rusak') NOT NULL DEFAULT 'baik'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `barang`
--

INSERT INTO `barang` (`id_barang`, `nama_barang`, `jumlah`, `kondisi_barang`) VALUES
(1, 'Laptop Dell', 10, 'baik'),
(2, 'Proyektor Epson', 5, 'rusak'),
(3, 'Kamera DSLR', 3, 'baik'),
(4, 'Tripod', 8, 'rusak'),
(5, 'Mikrofon', 6, 'rusak'),
(6, 'IPHONE 17 PROMAX 2TB', 11, 'baik');

-- --------------------------------------------------------

--
-- Table structure for table `peminjaman`
--

CREATE TABLE `peminjaman` (
  `id_pinjam` int(11) NOT NULL,
  `id_user` int(11) NOT NULL,
  `id_barang` int(11) NOT NULL,
  `jumlah_pinjam` int(11) NOT NULL,
  `tanggal_pinjam` date NOT NULL,
  `tanggal_kembali` date DEFAULT NULL,
  `status` enum('dipinjam','dikembalikan') NOT NULL DEFAULT 'dipinjam'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `peminjaman`
--

INSERT INTO `peminjaman` (`id_pinjam`, `id_user`, `id_barang`, `jumlah_pinjam`, `tanggal_pinjam`, `tanggal_kembali`, `status`) VALUES
(1, 2, 6, 1, '2026-05-20', '2026-05-20', 'dikembalikan'),
(2, 2, 3, 1, '2026-05-20', '2026-05-20', 'dikembalikan'),
(3, 2, 3, 1, '2026-05-20', '2026-05-20', 'dikembalikan'),
(4, 2, 1, 1, '2026-05-20', '2026-05-20', 'dikembalikan'),
(5, 2, 1, 1, '2026-05-20', '2026-05-20', 'dikembalikan'),
(6, 2, 2, 1, '2026-05-20', '2026-05-20', 'dikembalikan'),
(7, 2, 2, 1, '2026-05-20', '2026-05-20', 'dikembalikan'),
(8, 2, 4, 1, '2026-05-20', '2026-05-20', 'dikembalikan'),
(9, 2, 4, 1, '2026-05-20', '2026-05-20', 'dikembalikan');

-- --------------------------------------------------------

--
-- Table structure for table `user`
--

CREATE TABLE `user` (
  `id_user` int(11) NOT NULL,
  `nama` varchar(100) NOT NULL,
  `username` varchar(50) NOT NULL,
  `password` varchar(255) NOT NULL,
  `role` enum('admin','peminjam') NOT NULL DEFAULT 'peminjam'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `user`
--

INSERT INTO `user` (`id_user`, `nama`, `username`, `password`, `role`) VALUES
(1, 'Administrator', 'admin', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'admin'),
(2, 'Budi Santoso', 'budi', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'peminjam');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `barang`
--
ALTER TABLE `barang`
  ADD PRIMARY KEY (`id_barang`);

--
-- Indexes for table `peminjaman`
--
ALTER TABLE `peminjaman`
  ADD PRIMARY KEY (`id_pinjam`),
  ADD KEY `id_user` (`id_user`),
  ADD KEY `id_barang` (`id_barang`);

--
-- Indexes for table `user`
--
ALTER TABLE `user`
  ADD PRIMARY KEY (`id_user`),
  ADD UNIQUE KEY `username` (`username`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `barang`
--
ALTER TABLE `barang`
  MODIFY `id_barang` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `peminjaman`
--
ALTER TABLE `peminjaman`
  MODIFY `id_pinjam` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT for table `user`
--
ALTER TABLE `user`
  MODIFY `id_user` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `peminjaman`
--
ALTER TABLE `peminjaman`
  ADD CONSTRAINT `peminjaman_ibfk_1` FOREIGN KEY (`id_user`) REFERENCES `user` (`id_user`),
  ADD CONSTRAINT `peminjaman_ibfk_2` FOREIGN KEY (`id_barang`) REFERENCES `barang` (`id_barang`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
