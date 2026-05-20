<?php
require_once 'includes/config.php';
if (isLoggedIn()) {
    header("Location: " . ($_SESSION['role'] === 'admin' ? 'admin/dashboard.php' : 'user/dashboard.php'));
} else {
    header("Location: login.php");
}
exit;
