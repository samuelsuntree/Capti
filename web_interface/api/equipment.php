<?php
require_once('../config/database.php');

header('Content-Type: application/json');

try {
    $pdo = new PDO($dsn, $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    // 构建查询条件
    $conditions = array();
    $params = array();

    if (!empty($_GET['type'])) {
        $conditions[] = "et.type_category = :type";
        $params[':type'] = $_GET['type'];
    }

    if (!empty($_GET['rarity'])) {
        $conditions[] = "t.rarity = :rarity";
        $params[':rarity'] = $_GET['rarity'];
    }

    if (!empty($_GET['search'])) {
        $conditions[] = "t.equipment_name LIKE :search";
        $params[':search'] = '%' . $_GET['search'] . '%';
    }

    // 构建SQL查询
    $sql = "SELECT 
        t.equipment_name,
        t.rarity,
        t.is_legendary,
        t.base_value,
        t.level_requirement,
        et.type_name,
        et.type_category,
        COUNT(i.instance_id) as instances_count,
        AVG(i.enhancement_level) as avg_enhancement,
        MAX(i.enhancement_level) as max_enhancement
    FROM equipment_templates t
    JOIN equipment_types et ON t.type_id = et.type_id
    LEFT JOIN equipment_instances i ON t.template_id = i.template_id AND i.is_broken = FALSE";

    if (!empty($conditions)) {
        $sql .= " WHERE " . implode(" AND ", $conditions);
    }

    $sql .= " GROUP BY t.template_id, t.equipment_name, t.rarity, t.is_legendary, t.base_value, 
              t.level_requirement, et.type_name, et.type_category
              ORDER BY t.rarity DESC, t.base_value DESC";

    // 执行查询
    $stmt = $pdo->prepare($sql);
    $stmt->execute($params);
    $results = $stmt->fetchAll(PDO::FETCH_ASSOC);

    // 处理结果
    foreach ($results as &$item) {
        $item['avg_enhancement'] = round($item['avg_enhancement'], 1);
        $item['instances_count'] = (int)$item['instances_count'];
        $item['is_legendary'] = (bool)$item['is_legendary'];
        $item['level_requirement'] = (int)$item['level_requirement'];
    }

    echo json_encode($results);
} catch(PDOException $e) {
    http_response_code(500);
    echo json_encode(array('error' => '数据库错误: ' . $e->getMessage()));
}
?> 