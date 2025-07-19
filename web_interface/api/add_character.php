<?php
header('Content-Type: application/json; charset=utf-8');
require_once '../config/database.php';

// 只允许POST请求
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['success' => false, 'message' => '只允许POST请求']);
    exit;
}

try {
    $pdo = getDBConnection();
    
    // 获取表单数据
    $characterName = $_POST['characterName'] ?? '';
    $displayName = $_POST['displayName'] ?? '';
    $characterClass = $_POST['characterClass'] ?? '';
    $rarity = $_POST['rarity'] ?? '';
    $hireCost = floatval($_POST['hireCost'] ?? 0);
    $maintenanceCost = floatval($_POST['maintenanceCost'] ?? 0);
    $isAvailable = intval($_POST['isAvailable'] ?? 1) ? 1 : 0;
    
    // 基础属性
    $strength = intval($_POST['strength'] ?? 10);
    $vitality = intval($_POST['vitality'] ?? 10);
    $agility = intval($_POST['agility'] ?? 10);
    $intelligence = intval($_POST['intelligence'] ?? 10);
    $faith = intval($_POST['faith'] ?? 10);
    $luck = intval($_POST['luck'] ?? 10);
    
    // 精神属性
    $loyalty = intval($_POST['loyalty'] ?? 50);
    $courage = intval($_POST['courage'] ?? 50);
    $patience = intval($_POST['patience'] ?? 50);
    $greed = intval($_POST['greed'] ?? 50);
    $wisdom = intval($_POST['wisdom'] ?? 50);
    $charisma = intval($_POST['charisma'] ?? 50);
    
    // 专业技能
    $tradeSkill = intval($_POST['tradeSkill'] ?? 10);
    $ventureSkill = intval($_POST['ventureSkill'] ?? 10);
    $negotiationSkill = intval($_POST['negotiationSkill'] ?? 10);
    $analysisSkill = intval($_POST['analysisSkill'] ?? 10);
    $leadershipSkill = intval($_POST['leadershipSkill'] ?? 10);
    
    // 个性特质
    $traits = json_decode($_POST['traits'] ?? '[]', true);
    if (!is_array($traits)) {
        $traits = [];
    }
    
    // 验证必填字段
    if (empty($characterName) || empty($characterClass) || empty($rarity)) {
        echo json_encode(['success' => false, 'message' => '请填写所有必填字段']);
        exit;
    }
    
    // 验证稀有度
    $validRarities = ['common', 'uncommon', 'rare', 'epic', 'legendary'];
    if (!in_array($rarity, $validRarities)) {
        echo json_encode(['success' => false, 'message' => '无效的稀有度']);
        exit;
    }
    
    // 验证职业
    $validClasses = ['warrior', 'trader', 'explorer', 'scholar', 'mystic', 'survivor'];
    if (!in_array($characterClass, $validClasses)) {
        echo json_encode(['success' => false, 'message' => '无效的职业']);
        exit;
    }
    
    // 验证特质数量
    if (count($traits) > 5) {
        echo json_encode(['success' => false, 'message' => '最多只能选择5个性格特质']);
        exit;
    }
    
    // 开始数据库事务
    $pdo->beginTransaction();
    
    // 插入角色基本信息
    $sql = "INSERT INTO players (
        character_name, display_name, character_class, rarity, hire_cost, maintenance_cost,
        strength, vitality, agility, intelligence, faith, luck,
        loyalty, courage, patience, greed, wisdom, charisma,
        trade_skill, venture_skill, negotiation_skill, analysis_skill, leadership_skill,
        total_experience, current_level, skill_points, personality_traits, is_available
    ) VALUES (
        :character_name, :display_name, :character_class, :rarity, :hire_cost, :maintenance_cost,
        :strength, :vitality, :agility, :intelligence, :faith, :luck,
        :loyalty, :courage, :patience, :greed, :wisdom, :charisma,
        :trade_skill, :venture_skill, :negotiation_skill, :analysis_skill, :leadership_skill,
        0, 1, 0, :personality_traits, :is_available
    )";
    
    $stmt = $pdo->prepare($sql);
    $stmt->execute([
        'character_name' => $characterName,
        'display_name' => $displayName ?: $characterName,
        'character_class' => $characterClass,
        'rarity' => $rarity,
        'hire_cost' => $hireCost,
        'maintenance_cost' => $maintenanceCost,
        'strength' => $strength,
        'vitality' => $vitality,
        'agility' => $agility,
        'intelligence' => $intelligence,
        'faith' => $faith,
        'luck' => $luck,
        'loyalty' => $loyalty,
        'courage' => $courage,
        'patience' => $patience,
        'greed' => $greed,
        'wisdom' => $wisdom,
        'charisma' => $charisma,
        'trade_skill' => $tradeSkill,
        'venture_skill' => $ventureSkill,
        'negotiation_skill' => $negotiationSkill,
        'analysis_skill' => $analysisSkill,
        'leadership_skill' => $leadershipSkill,
        'personality_traits' => json_encode($traits, JSON_UNESCAPED_UNICODE),
        'is_available' => $isAvailable
    ]);
    
    $playerId = $pdo->lastInsertId();
    
    // 为角色添加初始情绪状态（基于稀有度和性格特质）
    $baseMoodValues = [
        'legendary' => ['happiness' => 80, 'stress' => 15, 'motivation' => 90, 'confidence' => 95, 'fatigue' => 10, 'focus' => 90, 'team_relationship' => 85, 'reputation' => 90],
        'epic' => ['happiness' => 75, 'stress' => 20, 'motivation' => 85, 'confidence' => 85, 'fatigue' => 15, 'focus' => 85, 'team_relationship' => 80, 'reputation' => 80],
        'rare' => ['happiness' => 70, 'stress' => 25, 'motivation' => 80, 'confidence' => 75, 'fatigue' => 20, 'focus' => 80, 'team_relationship' => 75, 'reputation' => 70],
        'uncommon' => ['happiness' => 65, 'stress' => 30, 'motivation' => 75, 'confidence' => 65, 'fatigue' => 25, 'focus' => 75, 'team_relationship' => 70, 'reputation' => 60],
        'common' => ['happiness' => 60, 'stress' => 35, 'motivation' => 70, 'confidence' => 55, 'fatigue' => 30, 'focus' => 70, 'team_relationship' => 65, 'reputation' => 50]
    ];
    
    $moodData = $baseMoodValues[$rarity] ?? $baseMoodValues['common'];
    
    // 根据性格特质调整情绪值
    foreach ($traits as $trait) {
        switch ($trait) {
            case '乐观':
                $moodData['happiness'] = min(100, $moodData['happiness'] + 10);
                $moodData['stress'] = max(1, $moodData['stress'] - 5);
                break;
            case '焦虑':
                $moodData['stress'] = min(100, $moodData['stress'] + 15);
                $moodData['confidence'] = max(1, $moodData['confidence'] - 10);
                break;
            case '冷静':
                $moodData['stress'] = max(1, $moodData['stress'] - 10);
                $moodData['focus'] = min(100, $moodData['focus'] + 5);
                break;
            case '领袖气质':
                $moodData['team_relationship'] = min(100, $moodData['team_relationship'] + 10);
                $moodData['confidence'] = min(100, $moodData['confidence'] + 5);
                break;
            case '懒惰':
                $moodData['motivation'] = max(1, $moodData['motivation'] - 15);
                $moodData['fatigue'] = min(100, $moodData['fatigue'] + 10);
                break;
            case '背叛者':
                $moodData['team_relationship'] = max(1, $moodData['team_relationship'] - 20);
                $moodData['reputation'] = max(1, $moodData['reputation'] - 15);
                break;
        }
    }
    
    $moodSql = "INSERT INTO player_mood (player_id, happiness, stress, motivation, confidence, fatigue, focus, team_relationship, reputation) 
                VALUES (:player_id, :happiness, :stress, :motivation, :confidence, :fatigue, :focus, :team_relationship, :reputation)";
    $moodStmt = $pdo->prepare($moodSql);
    $moodStmt->execute(array_merge(['player_id' => $playerId], $moodData));
    
    // 为角色添加初始资产（基于稀有度和职业）
    $goldAmounts = [
        'legendary' => 10000,
        'epic' => 5000,
        'rare' => 2000,
        'uncommon' => 1000,
        'common' => 500
    ];
    
    $goldAmount = $goldAmounts[$rarity] ?? 500;
    
    // 添加金币资产
    $assetSql = "INSERT INTO player_assets (player_id, asset_type, asset_name, quantity, equipment_quality) 
                 VALUES (:player_id, 'gold', '金币', :quantity, 'common')";
    $assetStmt = $pdo->prepare($assetSql);
    $assetStmt->execute([
        'player_id' => $playerId,
        'quantity' => $goldAmount
    ]);
    
    // 根据职业和稀有度添加初始装备
    $equipmentMap = [
        'warrior' => [
            'legendary' => [['龙鳞盔甲', 'masterwork'], ['烈焰之剑', 'excellent']],
            'epic' => [['精钢盔甲', 'excellent'], ['锋利长剑', 'good']],
            'rare' => [['钢制盔甲', 'good'], ['铁剑', 'common']],
            'uncommon' => [['皮甲', 'common']],
            'common' => []
        ],
        'trader' => [
            'legendary' => [['智慧法杖', 'masterwork'], ['商人华袍', 'excellent']],
            'epic' => [['智慧法杖', 'excellent'], ['商人长袍', 'good']],
            'rare' => [['商人长袍', 'good']],
            'uncommon' => [['商人服装', 'common']],
            'common' => []
        ],
        'explorer' => [
            'legendary' => [['探险者斗篷', 'masterwork'], ['精准弓箭', 'excellent']],
            'epic' => [['探险者斗篷', 'excellent'], ['猎弓', 'good']],
            'rare' => [['探险者背包', 'good']],
            'uncommon' => [['简易背包', 'common']],
            'common' => []
        ],
        'scholar' => [
            'legendary' => [['智者之书', 'masterwork'], ['学者长袍', 'excellent']],
            'epic' => [['古老典籍', 'excellent'], ['学者长袍', 'good']],
            'rare' => [['知识之书', 'good']],
            'uncommon' => [['基础书籍', 'common']],
            'common' => []
        ],
        'mystic' => [
            'legendary' => [['神秘水晶球', 'masterwork'], ['法师长袍', 'excellent']],
            'epic' => [['魔法水晶', 'excellent'], ['法师长袍', 'good']],
            'rare' => [['法师法杖', 'good']],
            'uncommon' => [['学徒长袍', 'common']],
            'common' => []
        ],
        'survivor' => [
            'legendary' => [['生存工具包', 'masterwork'], ['强化护甲', 'excellent']],
            'epic' => [['生存工具包', 'excellent'], ['轻便护甲', 'good']],
            'rare' => [['基础工具包', 'good']],
            'uncommon' => [['简易工具', 'common']],
            'common' => []
        ]
    ];
    
    $equipment = $equipmentMap[$characterClass][$rarity] ?? [];
    foreach ($equipment as $item) {
        $assetStmt->execute([
            'player_id' => $playerId,
            'asset_type' => 'equipment',
            'asset_name' => $item[0],
            'quantity' => 1,
            'equipment_quality' => $item[1]
        ]);
    }
    
    // 提交事务
    $pdo->commit();
    
    echo json_encode([
        'success' => true, 
        'message' => '角色创建成功！已为角色分配初始资产和情绪状态。',
        'character_id' => $playerId,
        'character_name' => $characterName,
        'initial_gold' => $goldAmount,
        'equipment_count' => count($equipment)
    ]);
    
} catch (Exception $e) {
    // 回滚事务
    if (isset($pdo)) {
        $pdo->rollback();
    }
    
    echo json_encode([
        'success' => false, 
        'message' => '创建失败：' . $e->getMessage()
    ]);
}
?> 