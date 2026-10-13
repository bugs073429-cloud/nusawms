<?php
declare(strict_types=1);
$root = dirname(__DIR__, 2);
$appSource = is_file($root . '/src/app.php') ? (string) file_get_contents($root . '/src/app.php') : '';
$checks = [
    'public entry point exists' => is_file($root . '/public/index.php'),
    'application source exists' => is_file($root . '/src/app.php'),
    'core bootstrap exists' => is_file($root . '/src/core/bootstrap.php'),
    'legacy bootstrap bridge exists' => is_file($root . '/app/bootstrap.php'),
    'legacy config exists' => is_file($root . '/config.php'),
    'schema retained' => is_file($root . '/database/schema.sql'),
    'scanner assets retained' => is_file($root . '/public/assets/app.js') && is_file($root . '/public/assets/app.css'),
    'non-public source protected' => is_file($root . '/src/.htaccess') && is_file($root . '/database/.htaccess') && is_file($root . '/config/.htaccess'),
    'live stock alert query implemented' => str_contains($appSource, 'function stock_alert_rows(PDO $p') && str_contains($appSource, 'HAVING GREATEST(p.safety_stock,p.reorder_point)>0') && str_contains($appSource, 'COALESCE(SUM(i.qty_on_hand-i.qty_reserved),0)<=GREATEST(p.safety_stock,p.reorder_point)'),
    'stock control page is operational' => str_contains($appSource, 'function page_stock_control(PDO $p') && str_contains($appSource, 'Batch mendekati kedaluwarsa'),
    'analytics includes inventory-ledger consistency KPI' => str_contains($appSource, 'Selisih inventory vs ledger') && str_contains($appSource, 'stock_movements'),
    'barcode generator route and navigation exist' => str_contains($appSource, "'barcode-generator'") && str_contains($appSource, 'function page_barcode_generator():void'),
    'barcode generator has QR and Code 128 modes' => str_contains($appSource, 'QRCode.CorrectLevel.M') && str_contains($appSource, 'CODE128'),
    'barcode generator download and print controls exist' => str_contains($appSource, 'code-download') && str_contains($appSource, 'code-print') && str_contains($appSource, 'printing-codegen'),
    'all reference menu routes registered' => count(array_filter(['outbound','cycle-count','stock-opname','transfer-bin','search-goods','pivot-session','movement-tracking','history-cc-transfer','discrepancy','fast-slow-dead','dashboard-report','data-induk','data-bin-cl','master-produk-cloud','rfid-map'], static fn($route) => str_contains($appSource, "'" . $route . "'"))) >= 15,
    'reference modules explain unconfigured integrations' => str_contains($appSource, 'Koneksi Cloud/Supabase') && str_contains($appSource, 'Mapping RFID (UID)'),
    'RFID mapping page is operational' => str_contains($appSource, 'function page_rfid_map(PDO $p):void') && str_contains($appSource, 'rfid_mapping_save') && str_contains($appSource, 'rfid_mapping_deactivate'),
    'RFID mapping migration and documentation exist' => is_file($root . '/database/migrations/20261012_rfid_mappings.sql') && is_file($root . '/docs/architecture/RFID_MAPPING.md'),
    'RFID UID uniqueness and product foreign key enforced' => str_contains((string) file_get_contents($root . '/database/migrations/20261012_rfid_mappings.sql'), 'uid VARCHAR(160) NOT NULL UNIQUE') && str_contains((string) file_get_contents($root . '/database/migrations/20261012_rfid_mappings.sql'), 'FOREIGN KEY(product_id) REFERENCES products(id)'),
    'fast slow dead stock has dedicated handler and ledger aging rule' => str_contains($appSource, 'function page_fast_slow_dead(PDO $p):void') && str_contains($appSource, 'days_since_movement'),
    'movement tracking has dedicated filtered handler' => str_contains($appSource, 'function page_movement_tracking(PDO $p):void') && str_contains($appSource, 'p.sku LIKE ? OR p.name LIKE ?'),
    'cloud master menu does not falsely reuse local product CRUD' => str_contains($appSource, 'function page_master_produk_cloud(PDO $p):void') && str_contains($appSource, 'Integrasi cloud belum aktif.'),
    'scan session PDO parameter query uses prepare and execute' => str_contains($appSource, '$active=$p->prepare(') && str_contains($appSource, '$active->execute('),
    'POST actions have explicit route authorization' => str_contains($appSource, 'function post_action_routes(string $do,array $post):array') && str_contains($appSource, '$allowedPostRoutes=post_action_routes($do,$_POST)') && str_contains($appSource, '!in_array($action,$allowedPostRoutes,true)'),
    'stock POST route is bound to declared direction' => str_contains($appSource, "return \$direction==='INBOUND'?['inbound','orders']") && str_contains($appSource, "\$direction==='OUTBOUND'?['outbound','orders']"),
    'POST handler validates permission for the actual requested menu' => str_contains($appSource, '$allowedRoutes=post_action_routes((string)$do,$_POST)') && str_contains($appSource, '!permission_allowed($page'),
    'session cookies use HttpOnly SameSite and HTTPS-aware Secure flags' => str_contains((string)file_get_contents($root . '/src/core/bootstrap.php'), "'httponly' => true") && str_contains((string)file_get_contents($root . '/src/core/bootstrap.php'), "'samesite' => 'Lax'"),
    'CSV export validates ISO dates and date range' => str_contains($appSource, 'Rentang tanggal ekspor tidak valid.') && str_contains($appSource, '$from>$to'),
    'session migration creates both required tables idempotently' => str_contains((string)file_get_contents($root . '/database/migrations/20261012_scan_sessions.sql'), 'CREATE TABLE IF NOT EXISTS scan_sessions') && str_contains((string)file_get_contents($root . '/database/migrations/20261012_scan_sessions.sql'), 'CREATE TABLE IF NOT EXISTS scan_session_events'),
    'stock consistency diagnostics cover ledger, transfer and negative stock' => str_contains((string)file_get_contents($root . '/tests/stock_consistency_checks.sql'), 'inventory_qty') && str_contains((string)file_get_contents($root . '/tests/stock_consistency_checks.sql'), 'out_count<>1 OR in_count<>1') && str_contains((string)file_get_contents($root . '/tests/stock_consistency_checks.sql'), 'qty_on_hand < 0'),
];
$failed = false;
foreach ($checks as $label => $ok) {
    echo ($ok ? '[PASS] ' : '[FAIL] ') . $label . PHP_EOL;
    $failed = $failed || !$ok;
}
exit($failed ? 1 : 0);
