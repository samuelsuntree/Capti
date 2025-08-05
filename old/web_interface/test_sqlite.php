<?php
// SQLite连接测试脚本
require_once 'config/database_sqlite.php';

try {
    $pdo = getDBConnection();
    echo "✅ SQLite连接成功！
";
    
    // 测试查询
    $stmt = $pdo->query("SELECT COUNT(*) as count FROM players");
    $result = $stmt->fetch();
    echo "📊 玩家数量: " . $result['count'] . "
";
    
    // 测试复杂查询
    $stmt = $pdo->query("SELECT character_name, character_class, rarity FROM players LIMIT 3");
    $players = $stmt->fetchAll();
    echo "👥 前3个玩家:
";
    foreach ($players as $player) {
        echo "  - {$player['character_name']} ({$player['character_class']}, {$player['rarity']})
";
    }
    
} catch (Exception $e) {
    echo "❌ 连接失败: " . $e->getMessage() . "
";
}
?>
