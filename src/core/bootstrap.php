<?php
declare(strict_types=1);
$configPath = dirname(__DIR__, 2) . '/config.php';
if (!is_file($configPath)) { http_response_code(500); exit('Konfigurasi belum tersedia. Salin config.example.php menjadi config.php.'); }
$config = require $configPath;
date_default_timezone_set($config['timezone'] ?? 'Asia/Jakarta');
if (session_status() !== PHP_SESSION_ACTIVE) {
    session_name('NUSAWMS');
    $isHttps = (!empty($_SERVER['HTTPS']) && strtolower((string)$_SERVER['HTTPS']) !== 'off') || (($_SERVER['SERVER_PORT'] ?? null) === 443);
    session_set_cookie_params(['httponly' => true, 'secure' => $isHttps, 'samesite' => 'Lax', 'path' => '/']);
    session_start();
}
$dsn = sprintf('mysql:host=%s;port=%d;dbname=%s;charset=utf8mb4', $config['db']['host'], $config['db']['port'], $config['db']['name']);
$pdo = new PDO($dsn, $config['db']['user'], $config['db']['pass'], [PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION, PDO::ATTR_DEFAULT_FETCH_MODE=>PDO::FETCH_ASSOC, PDO::ATTR_EMULATE_PREPARES=>false]);
function e(mixed $v): string { return htmlspecialchars((string)$v, ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8'); }
function csrf_token(): string { if (empty($_SESSION['_csrf'])) $_SESSION['_csrf'] = bin2hex(random_bytes(32)); return $_SESSION['_csrf']; }
function verify_csrf(): void { if ($_SERVER['REQUEST_METHOD']==='POST' && !hash_equals($_SESSION['_csrf'] ?? '', $_POST['_csrf'] ?? '')) { http_response_code(419); exit('Sesi formulir kedaluwarsa. Muat ulang halaman.'); } }
function redirect(string $url): never { header('Location: '.$url); exit; }
function flash(string $message, string $type='success'): void { $_SESSION['_flash']=['message'=>$message,'type'=>$type]; }
function audit(PDO $pdo, string $action, string $entity, ?int $entityId=null, ?array $after=null): void { $q=$pdo->prepare('INSERT INTO audit_logs(user_id,action,entity_type,entity_id,after_data,ip_address) VALUES(?,?,?,?,?,?)'); $q->execute([$_SESSION['user']['id']??null,$action,$entity,$entityId,$after?json_encode($after,JSON_UNESCAPED_UNICODE):null,$_SERVER['REMOTE_ADDR']??null]); }
