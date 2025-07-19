<?php
header('Content-Type: application/json; charset=utf-8');
require_once '../config/database.php';

try {
    $pdo = getDBConnection();
    
    // 获取总角色数
    $totalQuery = "SELECT COUNT(*) as total FROM players";
    $totalStmt = $pdo->prepare($totalQuery);
    $totalStmt->execute();
    $totalResult = $totalStmt->fetch();
    $totalCharacters = $totalResult['total'];
    
    // 获取传奇角色数
    $legendaryQuery = "SELECT COUNT(*) as legendary FROM players WHERE rarity = 'legendary'";
    $legendaryStmt = $pdo->prepare($legendaryQuery);
    $legendaryStmt->execute();
    $legendaryResult = $legendaryStmt->fetch();
    $legendaryCount = $legendaryResult['legendary'];
    
    // 获取平均等级
    $avgLevelQuery = "SELECT AVG(current_level) as avg_level FROM players";
    $avgLevelStmt = $pdo->prepare($avgLevelQuery);
    $avgLevelStmt->execute();
    $avgLevelResult = $avgLevelStmt->fetch();
    $avgLevel = round($avgLevelResult['avg_level'], 1);
    
    // 获取总价值
    $totalValueQuery = "SELECT SUM(hire_cost) as total_value FROM players";
    $totalValueStmt = $pdo->prepare($totalValueQuery);
    $totalValueStmt->execute();
    $totalValueResult = $totalValueStmt->fetch();
    $totalValue = number_format($totalValueResult['total_value'] ?? 0);
    
    echo json_encode([
        'success' => true,
        'total' => $totalCharacters,
        'legendary' => $legendaryCount,
        'avgLevel' => $avgLevel,
        'totalValue' => $totalValue
    ]);
    
} catch (Exception $e) {
    echo json_encode([
        'success' => false,
        'message' => '获取统计信息失败：' . $e->getMessage()
    ]);
}
?> 