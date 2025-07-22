<?php
require_once('../config/database_sqlite.php');

header('Content-Type: application/json');

try {
    $pdo = getDBConnection();
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    // 构建查询条件
    $conditions = array();
    $params = array();

    if (!empty($_GET['category'])) {
        $conditions[] = "c.category = :category";
        $params[':category'] = $_GET['category'];
    }

    if (!empty($_GET['rarity'])) {
        $conditions[] = "c.rarity = :rarity";
        $params[':rarity'] = $_GET['rarity'];
    }

    if (!empty($_GET['search'])) {
        $conditions[] = "(c.commodity_name LIKE :search OR c.commodity_code LIKE :search)";
        $params[':search'] = '%' . $_GET['search'] . '%';
    }

    // 构建SQL查询
    $sql = "SELECT 
        c.commodity_name,
        c.commodity_code,
        c.category,
        c.rarity,
        c.base_value,
        COALESCE(SUM(h.quantity), 0) as total_quantity
    FROM bulk_commodities c
    LEFT JOIN bulk_commodity_holdings h ON c.commodity_id = h.commodity_id";

    if (!empty($conditions)) {
        $sql .= " WHERE " . implode(" AND ", $conditions);
    }

    $sql .= " GROUP BY c.commodity_id, c.commodity_name, c.commodity_code, c.category, c.rarity, c.base_value
              ORDER BY c.rarity DESC, c.base_value DESC";

    // 执行查询
    $stmt = $pdo->prepare($sql);
    $stmt->execute($params);
    $results = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo json_encode($results);
} catch(PDOException $e) {
    http_response_code(500);
    echo json_encode(array('error' => '数据库错误: ' . $e->getMessage()));
}
?> 