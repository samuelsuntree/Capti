<?php
header('Content-Type: application/json; charset=utf-8');
require_once '../config/database_sqlite.php';

function generateCharacterCode($characterName, $characterClass) {
    // 从角色名中提取英文名（假设格式为：中文·英文 或 职业·名字）
    $nameParts = explode('·', $characterName);
    $englishName = '';
    
    if (count($nameParts) > 1) {
        // 尝试从第二部分获取英文名
        $englishName = preg_replace('/[^A-Za-z]/', '', $nameParts[1]);
    }
    
    if (empty($englishName)) {
        // 如果没有找到英文名，使用拼音转换（这里简化处理，实际应该使用拼音库）
        $englishName = strtoupper(substr(md5($characterName), 0, 8));
    }
    
    // 生成格式：NAME_CLASS_001
    $baseCode = strtoupper($englishName . '_' . $characterClass);
    
    try {
        $pdo = getDBConnection();
        
        // 查找同类型角色数量 - 使用SQLite的LIKE语法
        $sql = "SELECT COUNT(*) as count FROM players 
                WHERE character_code LIKE :base_code || '_%'";
        $stmt = $pdo->prepare($sql);
        $stmt->execute(['base_code' => $baseCode]);
        $result = $stmt->fetch();
        
        // 生成三位数序号
        $number = str_pad($result['count'] + 1, 3, '0', STR_PAD_LEFT);
        
        return $baseCode . '_' . $number;
    } catch (Exception $e) {
        // 如果数据库查询失败，使用时间戳作为备选
        return $baseCode . '_' . substr(time(), -3);
    }
}

// 只允许POST请求
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['success' => false, 'message' => '只允许POST请求']);
    exit;
}

try {
    $pdo = getDBConnection();
    
    // 获取表单数据
    $characterName = $_POST['characterName'];
    $characterClass = $_POST['characterClass'];
    
    // 生成角色代码
    $characterCode = generateCharacterCode($characterName, $characterClass);
    
    // 准备SQL语句 - 使用SQLite语法
    $sql = "INSERT INTO players (
        character_code,
        character_name,
        display_name,
        character_class,
        rarity,
        hire_cost,
        maintenance_cost,
        strength, vitality, agility, intelligence, faith, luck,
        loyalty, courage, patience, greed, wisdom, charisma,
        trade_skill, venture_skill, negotiation_skill, analysis_skill, leadership_skill,
        total_experience, current_level, skill_points,
        personality_traits,
        is_available
    ) VALUES (
        :character_code,
        :character_name,
        :display_name,
        :character_class,
        :rarity,
        :hire_cost,
        :maintenance_cost,
        :strength, :vitality, :agility, :intelligence, :faith, :luck,
        :loyalty, :courage, :patience, :greed, :wisdom, :charisma,
        :trade_skill, :venture_skill, :negotiation_skill, :analysis_skill, :leadership_skill,
        0, 1, 0,
        :personality_traits,
        :is_available
    )";
    
    // 准备参数
    $params = [
        'character_code' => $characterCode,
        'character_name' => $characterName,
        'display_name' => $_POST['displayName'],
        'character_class' => $characterClass,
        'rarity' => $_POST['rarity'],
        'hire_cost' => $_POST['hireCost'],
        'maintenance_cost' => $_POST['maintenanceCost'],
        'strength' => $_POST['strength'],
        'vitality' => $_POST['vitality'],
        'agility' => $_POST['agility'],
        'intelligence' => $_POST['intelligence'],
        'faith' => $_POST['faith'],
        'luck' => $_POST['luck'],
        'loyalty' => $_POST['loyalty'],
        'courage' => $_POST['courage'],
        'patience' => $_POST['patience'],
        'greed' => $_POST['greed'],
        'wisdom' => $_POST['wisdom'],
        'charisma' => $_POST['charisma'],
        'trade_skill' => $_POST['tradeSkill'],
        'venture_skill' => $_POST['ventureSkill'],
        'negotiation_skill' => $_POST['negotiationSkill'],
        'analysis_skill' => $_POST['analysisSkill'],
        'leadership_skill' => $_POST['leadershipSkill'],
        'personality_traits' => $_POST['traits'],
        'is_available' => $_POST['isAvailable']
    ];
    
    // 执行SQL
    $stmt = $pdo->prepare($sql);
    $stmt->execute($params);
    
    // 返回成功信息
    echo json_encode([
        'success' => true,
        'message' => '角色创建成功！角色代码：' . $characterCode,
        'character_code' => $characterCode
    ]);
    
} catch (Exception $e) {
    // 返回错误信息
    echo json_encode([
        'success' => false,
        'message' => '创建失败：' . $e->getMessage()
    ]);
}
?> 