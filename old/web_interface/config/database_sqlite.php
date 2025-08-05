<?php
// SQLite数据库配置 - 自动检测路径
$currentDir = dirname(__FILE__);
$projectRoot = dirname(dirname($currentDir));
$dbPath = $projectRoot . '/sqlite_database/game_trade.db';
define('DB_PATH', $dbPath);

// 创建SQLite数据库连接
function getDBConnection() {
    try {
        $dsn = "sqlite:" . DB_PATH;
        $options = [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::ATTR_EMULATE_PREPARES => false,
        ];
        
        $pdo = new PDO($dsn, null, null, $options);
        
        // 启用外键约束
        $pdo->exec('PRAGMA foreign_keys = ON');
        
        return $pdo;
    } catch (PDOException $e) {
        die("SQLite数据库连接失败: " . $e->getMessage());
    }
}

// 测试数据库连接
function testConnection() {
    try {
        $pdo = getDBConnection();
        return true;
    } catch (Exception $e) {
        return false;
    }
}
?> 