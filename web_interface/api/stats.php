<?php
require_once '../config/database.php';

try {
    $pdo = getDBConnection();
    
    // 使用与 view_assets.php 完全相同的查询方式
    $sql = "SELECT 
                SUM(p.hire_cost) as total_hire_cost,
                SUM(p.maintenance_cost) as total_maintenance_cost,
                COUNT(DISTINCT p.player_id) as total_characters,
                COUNT(DISTINCT e.instance_id) as total_equipment,
                COALESCE(SUM(e.current_value), 0) as total_equipment_value,
                (SELECT COALESCE(SUM(h.quantity * c.current_value), 0)
                 FROM bulk_commodity_holdings h
                 JOIN bulk_commodities c ON h.commodity_id = c.commodity_id) as total_commodity_value
            FROM players p
            LEFT JOIN equipment_instances e ON p.player_id = e.current_owner_id AND e.is_broken = FALSE";
            
    $stmt = $pdo->query($sql);
    $totals = $stmt->fetch(PDO::FETCH_ASSOC);
    
    // 计算总资产
    $totalValue = $totals['total_hire_cost'] + 
                 $totals['total_equipment_value'] + 
                 $totals['total_commodity_value'];
    
    // 返回统计数据
    $response = [
        'total' => $totals['total_characters'],
        'legendary' => $totals['total_characters'], // 这里需要单独查询传奇角色数量
        'equipment' => $totals['total_equipment'],
        'totalValue' => number_format($totalValue, 2)
    ];
    
    // 补充查询传奇角色数量
    $sql = "SELECT COUNT(*) as legendary FROM players WHERE rarity = 'legendary'";
    $stmt = $pdo->query($sql);
    $legendaryCount = $stmt->fetch(PDO::FETCH_ASSOC);
    $response['legendary'] = $legendaryCount['legendary'];
    
    header('Content-Type: application/json');
    echo json_encode($response);
    
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(['error' => $e->getMessage()]);
}
?> 