<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login — Inventaris</title>
    <link href="https://fonts.googleapis.com/css2?family=IBM+Plex+Mono:wght@400;600&family=IBM+Plex+Sans:wght@400;500;600&display=swap" rel="stylesheet">
    <style>
        :root {
            --bg: #0f1117; --surface: #1a1d27; --border: #2a2d3a;
            --accent: #4ade80; --danger: #f87171; --text: #e2e8f0; --muted: #64748b;
        }
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body {
            font-family: 'IBM Plex Sans', sans-serif;
            background: var(--bg);
            color: var(--text);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        .login-box {
            width: 100%;
            max-width: 400px;
            padding: 2.5rem;
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: 8px;
        }
        .brand {
            font-family: 'IBM Plex Mono', monospace;
            font-size: 1.5rem;
            font-weight: 600;
            color: var(--accent);
            margin-bottom: 0.25rem;
        }
        .brand span { color: var(--muted); }
        .subtitle { font-size: 0.8rem; color: var(--muted); margin-bottom: 2rem; }
        .form-group { margin-bottom: 1rem; }
        label { display: block; font-size: 0.8rem; color: var(--muted); margin-bottom: 0.35rem; }
        input {
            width: 100%; background: var(--bg); border: 1px solid var(--border);
            color: var(--text); padding: 0.65rem 0.8rem; border-radius: 6px;
            font-family: 'IBM Plex Sans', sans-serif; font-size: 0.875rem; outline: none;
            transition: border-color 0.15s;
        }
        input:focus { border-color: var(--accent); }
        .btn {
            width: 100%; padding: 0.65rem; background: var(--accent); color: #000;
            border: none; border-radius: 6px; font-size: 0.875rem; font-weight: 600;
            cursor: pointer; font-family: 'IBM Plex Sans', sans-serif; margin-top: 0.5rem;
            transition: background 0.15s;
        }
        .btn:hover { background: #22c55e; }
        .alert {
            padding: 0.7rem 0.9rem; border-radius: 6px; margin-bottom: 1rem;
            font-size: 0.8rem; background: #f8717120; border: 1px solid #f8717144; color: var(--danger);
        }
        .hint { font-size: 0.75rem; color: var(--muted); margin-top: 1rem; text-align:center; }
        .hint code { font-family: 'IBM Plex Mono', monospace; color: var(--text); }
    </style>
</head>
<body>
<?php
require_once 'includes/config.php';
if (isLoggedIn()) {
    header("Location: " . ($_SESSION['role'] === 'admin' ? 'admin/dashboard.php' : 'user/dashboard.php'));
    exit;
}
$error = '';
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $username = sanitize($conn, $_POST['username'] ?? '');
    $password = $_POST['password'] ?? '';
    if ($username && $password) {
        $stmt = $conn->prepare("SELECT id_user, nama, password, role FROM user WHERE username = ?");
        $stmt->bind_param("s", $username);
        $stmt->execute();
        $result = $stmt->get_result()->fetch_assoc();
        if ($result && password_verify($password, $result['password'])) {
            $_SESSION['id_user'] = $result['id_user'];
            $_SESSION['nama']    = $result['nama'];
            $_SESSION['role']    = $result['role'];
            header("Location: " . ($result['role'] === 'admin' ? 'admin/dashboard.php' : 'user/dashboard.php'));
            exit;
        } else {
            $error = 'Username atau password salah.';
        }
    } else {
        $error = 'Semua field wajib diisi.';
    }
}
?>
<div class="login-box">
    <div class="brand">Silakan<span> </span>Login</div>
    <div class="subtitle">Sistem Manajemen Inventaris</div>
    <?php if ($error): ?>
        <div class="alert"><?= htmlspecialchars($error) ?></div>
    <?php endif; ?>
    <form method="POST">
        <div class="form-group">
            <label>Username</label>
            <input type="text" name="username" required autocomplete="username">
        </div>
        <div class="form-group">
            <label>Password</label>
            <input type="password" name="password" required autocomplete="current-password">
        </div>
        <button type="submit" class="btn">Masuk</button>
    </form>
    <p class="hint">Demo: <code>admin</code> / <code>password</code> &nbsp;|&nbsp; <code>budi</code> / <code>password</code></p>
</div>
</body>
</html>
