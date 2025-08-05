<?php
require_once('../config/database_sqlite.php');

header('Content-Type: application/json');

try {
    $pdo = getDBConnection();
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    // 获取大宗货品总数和总价值
    $bulkQuery = "SELECT 
        COUNT(DISTINCT c.commodity_id) as total_commodities,
        SUM(h.quantity) as total_quantity,
        SUM(h.quantity * c.base_value) as total_value
    FROM bulk_commodities c
    LEFT JOIN bulk_commodity_holdings h ON c.commodity_id = h.commodity_id";
    
    $bulkResult = $pdo->query($bulkQuery)->fetch(PDO::FETCH_ASSOC);

    // 获取装备总数、传说装备数和总价值
    $equipQuery = "SELECT 
        COUNT(DISTINCT i.instance_id) as total_equipment,
        SUM(CASE WHEN t.is_legendary = TRUE THEN 1 ELSE 0 END) as legendary_count,
        SUM(i.current_value) as equipment_value
    FROM equipment_instances i
    JOIN equipment_templates t ON i.template_id = t.template_id
    WHERE i.is_broken = FALSE";
    
    $equipResult = $pdo->query($equipQuery)->fetch(PDO::FETCH_ASSOC);

    // 计算总计
    $response = array(
        'totalItems' => $bulkResult['total_commodities'] + $equipResult['total_equipment'],
        'totalEquipment' => $equipResult['total_equipment'],
        'legendaryItems' => $equipResult['legendary_count'],
        'totalValue' => number_format(
            $bulkResult['total_value'] + $equipResult['equipment_value'], 
            2, 
            '.', 
            ''
        )
    );

    echo json_encode($response);
} catch(PDOException $e) {
    http_response_code(500);
    echo json_encode(array('error' => '数据库错误: ' . $e->getMessage()));
}
?> 