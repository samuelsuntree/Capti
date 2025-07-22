<?php
require_once 'config/database.php';

try {
    $pdo = getDBConnection();
    
    // 获取角色ID
    $character_code = $_GET['code'] ?? '';
    if (empty($character_code)) {
        throw new Exception('未指定角色代码');
    }
    
    // 获取角色基本信息
    $sql = "SELECT 
                p.*,
                m.happiness, m.stress, m.motivation, m.confidence, 
                m.fatigue, m.focus, m.team_relationship, m.reputation,
                t.team_name, t.team_description, t.specialization as team_specialization,
                tm.role as team_role, tm.contribution_score,
                t.success_rate as team_success_rate
            FROM players p
            LEFT JOIN player_mood m ON p.player_id = m.player_id
            LEFT JOIN team_members tm ON p.player_id = tm.player_id
            LEFT JOIN adventure_teams t ON tm.team_id = t.team_id
            WHERE p.character_code = :character_code";
            
    $stmt = $pdo->prepare($sql);
    $stmt->execute(['character_code' => $character_code]);
    $character = $stmt->fetch();
    
    if (!$character) {
        throw new Exception('未找到指定角色');
    }
    
    // 获取角色装备
    $sql = "SELECT 
                e.equipment_name, e.rarity, e.base_attributes, e.description,
                i.durability, i.enhancement_level, i.is_bound
            FROM equipment_instances i
            JOIN equipment_templates e ON i.template_id = e.template_id
            WHERE i.current_owner_id = :player_id
            AND i.owner_type = 'player'";
            
    $stmt = $pdo->prepare($sql);
    $stmt->execute(['player_id' => $character['player_id']]);
    $equipments = $stmt->fetchAll();
    
    // 获取角色特质
    $sql = "SELECT 
                t.trait_name, t.trait_category, t.description,
                t.trade_modifier, t.venture_modifier, t.loyalty_modifier, t.stress_modifier
            FROM personality_traits t
            WHERE t.trait_name IN (
                SELECT JSON_UNQUOTE(traits.trait)
                FROM players p,
                JSON_TABLE(p.personality_traits, '$[*]' COLUMNS (trait VARCHAR(50) PATH '$')) traits
                WHERE p.character_code = :character_code
            )";
            
    $stmt = $pdo->prepare($sql);
    $stmt->execute(['character_code' => $character_code]);
    $traits = $stmt->fetchAll();
    
} catch (Exception $e) {
    $error = $e->getMessage();
}

// 解析JSON属性
function parseJson($json) {
    if (empty($json)) return [];
    return json_decode($json, true) ?? [];
}

// 格式化属性值显示
function formatAttributeValue($value) {
    if (is_numeric($value)) {
        return $value > 0 ? "+$value" : $value;
    }
    return $value;
}

// 在PHP部分添加函数
function getCharacterAvatar($avatar_url) {
    if (empty($avatar_url) || !file_exists($avatar_url)) {
        return 'assets/images/default_avatar.svg';
    }
    return $avatar_url;
}
?>

<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><?= htmlspecialchars($character['character_name']) ?> - 角色详情</title>
    <style>
        /* 继承view_characters.php的基础样式 */
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        body {
            font-family: 'Microsoft YaHei', sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            padding: 20px;
        }
        .container {
            max-width: 1200px;
            margin: 0 auto;
            background: white;
            border-radius: 15px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.3);
            overflow: hidden;
        }
        .header {
            background: linear-gradient(135deg, #2c3e50 0%, #3498db 100%);
            color: white;
            padding: 30px;
            text-align: center;
            position: relative;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 30px;
        }
        .avatar-container {
            width: 150px;
            height: 150px;
            border-radius: 50%;
            overflow: hidden;
            border: 4px solid rgba(255, 255, 255, 0.3);
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.2);
            background: #fff;
            flex-shrink: 0;
        }
        .avatar-container img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }
        .header-info {
            text-align: left;
        }
        .header-info h1 {
            margin-bottom: 5px;
        }
        .back-btn {
            position: absolute;
            left: 20px;
            top: 50%;
            transform: translateY(-50%);
            color: white;
            text-decoration: none;
            padding: 10px 20px;
            background: rgba(0,0,0,0.2);
            border-radius: 20px;
            transition: background 0.3s;
        }
        .back-btn:hover {
            background: rgba(0,0,0,0.4);
        }
        .content {
            padding: 40px;
        }
        .character-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }
        .info-card {
            background: #f8f9fa;
            border-radius: 10px;
            padding: 20px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        .info-card h2 {
            color: #2c3e50;
            margin-bottom: 15px;
            border-bottom: 2px solid #3498db;
            padding-bottom: 10px;
        }
        .stat-group {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 10px;
            margin-bottom: 15px;
        }
        .stat-item {
            display: flex;
            align-items: center;
            gap: 10px;
        }
        .stat-label {
            color: #7f8c8d;
            font-size: 14px;
        }
        .stat-value {
            font-weight: bold;
            color: #2c3e50;
        }
        .equipment-list {
            display: grid;
            gap: 15px;
        }
        .equipment-item {
            background: white;
            border-radius: 8px;
            padding: 15px;
            box-shadow: 0 2px 5px rgba(0,0,0,0.05);
        }
        .equipment-name {
            font-weight: bold;
            color: #2c3e50;
            margin-bottom: 5px;
        }
        .equipment-stats {
            font-size: 14px;
            color: #7f8c8d;
        }
        .trait-list {
            display: flex;
            flex-wrap: wrap;
            gap: 10px;
        }
        .trait-item {
            background: #edf2f7;
            padding: 8px 15px;
            border-radius: 15px;
            font-size: 14px;
            color: #2c3e50;
        }
        .mood-chart {
            height: 200px;
            margin: 20px 0;
            position: relative;
        }
        .rarity-badge {
            padding: 4px 8px;
            border-radius: 12px;
            font-size: 12px;
            font-weight: bold;
            color: white;
            display: inline-block;
            margin: 5px 0;
        }
        .rarity-legendary { background: #e74c3c; }
        .rarity-epic { background: #9b59b6; }
        .rarity-rare { background: #3498db; }
        .rarity-uncommon { background: #2ecc71; }
        .rarity-common { background: #95a5a6; }
        .team-info {
            background: #fff;
            border-left: 4px solid #3498db;
            padding: 15px;
            margin-top: 15px;
        }
    </style>
</head>
<body>
    <div class="container">
        <?php if (isset($error)): ?>
            <div class="header">
                <a href="view_characters.php" class="back-btn">← 返回列表</a>
                <h1>错误</h1>
            </div>
            <div class="content">
                <div class="error-message"><?= htmlspecialchars($error) ?></div>
            </div>
        <?php else: ?>
            <div class="header">
                <a href="view_characters.php" class="back-btn">← 返回列表</a>
                <div class="avatar-container">
                    <img src="<?= getCharacterAvatar($character['avatar_url']) ?>" 
                         alt="<?= htmlspecialchars($character['character_name']) ?>"
                         onerror="this.src='assets/images/default_avatar.svg'">
                </div>
                <div class="header-info">
                    <h1><?= htmlspecialchars($character['character_name']) ?></h1>
                    <p><?= htmlspecialchars($character['display_name']) ?></p>
                    <span class="rarity-badge rarity-<?= $character['rarity'] ?>"><?= ucfirst($character['rarity']) ?></span>
                </div>
            </div>
            
            <div class="content">
                <div class="character-grid">
                    <!-- 基本信息 -->
                    <div class="info-card">
                        <h2>基本信息</h2>
                        <div class="stat-group">
                            <div class="stat-item">
                                <span class="stat-label">等级:</span>
                                <span class="stat-value">Lv.<?= $character['current_level'] ?></span>
                            </div>
                            <div class="stat-item">
                                <span class="stat-label">经验值:</span>
                                <span class="stat-value"><?= number_format($character['total_experience']) ?></span>
                            </div>
                            <div class="stat-item">
                                <span class="stat-label">雇佣费:</span>
                                <span class="stat-value"><?= number_format($character['hire_cost']) ?></span>
                            </div>
                            <div class="stat-item">
                                <span class="stat-label">维护费:</span>
                                <span class="stat-value"><?= number_format($character['maintenance_cost']) ?></span>
                            </div>
                        </div>
                    </div>

                    <!-- 属性信息 -->
                    <div class="info-card">
                        <h2>基础属性</h2>
                        <div class="stat-group">
                            <div class="stat-item">
                                <span class="stat-label">💪 力量:</span>
                                <span class="stat-value"><?= $character['strength'] ?></span>
                            </div>
                            <div class="stat-item">
                                <span class="stat-label">❤️ 体力:</span>
                                <span class="stat-value"><?= $character['vitality'] ?></span>
                            </div>
                            <div class="stat-item">
                                <span class="stat-label">⚡ 敏捷:</span>
                                <span class="stat-value"><?= $character['agility'] ?></span>
                            </div>
                            <div class="stat-item">
                                <span class="stat-label">🧠 智力:</span>
                                <span class="stat-value"><?= $character['intelligence'] ?></span>
                            </div>
                            <div class="stat-item">
                                <span class="stat-label">✨ 信仰:</span>
                                <span class="stat-value"><?= $character['faith'] ?></span>
                            </div>
                            <div class="stat-item">
                                <span class="stat-label">🍀 幸运:</span>
                                <span class="stat-value"><?= $character['luck'] ?></span>
                            </div>
                        </div>
                    </div>

                    <!-- 精神属性 -->
                    <div class="info-card">
                        <h2>精神属性</h2>
                        <div class="stat-group">
                            <div class="stat-item">
                                <span class="stat-label">🛡️ 忠诚:</span>
                                <span class="stat-value"><?= $character['loyalty'] ?></span>
                            </div>
                            <div class="stat-item">
                                <span class="stat-label">⚔️ 勇气:</span>
                                <span class="stat-value"><?= $character['courage'] ?></span>
                            </div>
                            <div class="stat-item">
                                <span class="stat-label">⏳ 耐心:</span>
                                <span class="stat-value"><?= $character['patience'] ?></span>
                            </div>
                            <div class="stat-item">
                                <span class="stat-label">💰 贪婪:</span>
                                <span class="stat-value"><?= $character['greed'] ?></span>
                            </div>
                            <div class="stat-item">
                                <span class="stat-label">📚 智慧:</span>
                                <span class="stat-value"><?= $character['wisdom'] ?></span>
                            </div>
                            <div class="stat-item">
                                <span class="stat-label">🎭 魅力:</span>
                                <span class="stat-value"><?= $character['charisma'] ?></span>
                            </div>
                        </div>
                    </div>

                    <!-- 技能信息 -->
                    <div class="info-card">
                        <h2>技能</h2>
                        <div class="stat-group">
                            <div class="stat-item">
                                <span class="stat-label">📈 交易:</span>
                                <span class="stat-value"><?= $character['trade_skill'] ?></span>
                            </div>
                            <div class="stat-item">
                                <span class="stat-label">🗡️ 冒险:</span>
                                <span class="stat-value"><?= $character['venture_skill'] ?></span>
                            </div>
                            <div class="stat-item">
                                <span class="stat-label">🤝 谈判:</span>
                                <span class="stat-value"><?= $character['negotiation_skill'] ?></span>
                            </div>
                            <div class="stat-item">
                                <span class="stat-label">🔍 分析:</span>
                                <span class="stat-value"><?= $character['analysis_skill'] ?></span>
                            </div>
                            <div class="stat-item">
                                <span class="stat-label">👑 领导:</span>
                                <span class="stat-value"><?= $character['leadership_skill'] ?></span>
                            </div>
                        </div>
                    </div>

                    <!-- 情绪状态 -->
                    <div class="info-card">
                        <h2>情绪状态</h2>
                        <div class="stat-group">
                            <div class="stat-item">
                                <span class="stat-label">😊 心情:</span>
                                <span class="stat-value"><?= $character['happiness'] ?></span>
                            </div>
                            <div class="stat-item">
                                <span class="stat-label">😰 压力:</span>
                                <span class="stat-value"><?= $character['stress'] ?></span>
                            </div>
                            <div class="stat-item">
                                <span class="stat-label">💪 动力:</span>
                                <span class="stat-value"><?= $character['motivation'] ?></span>
                            </div>
                            <div class="stat-item">
                                <span class="stat-label">🎯 专注:</span>
                                <span class="stat-value"><?= $character['focus'] ?></span>
                            </div>
                            <div class="stat-item">
                                <span class="stat-label">😴 疲劳:</span>
                                <span class="stat-value"><?= $character['fatigue'] ?></span>
                            </div>
                        </div>
                    </div>

                    <!-- 队伍信息 -->
                    <?php if ($character['team_name']): ?>
                    <div class="info-card">
                        <h2>队伍信息</h2>
                        <div class="team-info">
                            <h3><?= htmlspecialchars($character['team_name']) ?></h3>
                            <p><?= htmlspecialchars($character['team_description']) ?></p>
                            <div class="stat-group">
                                <div class="stat-item">
                                    <span class="stat-label">角色:</span>
                                    <span class="stat-value"><?= $character['team_role'] === 'leader' ? '队长' : '队员' ?></span>
                                </div>
                                <div class="stat-item">
                                    <span class="stat-label">贡献度:</span>
                                    <span class="stat-value"><?= $character['contribution_score'] ?></span>
                                </div>
                                <div class="stat-item">
                                    <span class="stat-label">专精:</span>
                                    <span class="stat-value"><?= htmlspecialchars($character['team_specialization']) ?></span>
                                </div>
                                <div class="stat-item">
                                    <span class="stat-label">成功率:</span>
                                    <span class="stat-value"><?= number_format($character['team_success_rate'], 1) ?>%</span>
                                </div>
                            </div>
                        </div>
                    </div>
                    <?php endif; ?>

                    <!-- 装备列表 -->
                    <div class="info-card">
                        <h2>装备 (<?= count($equipments) ?>)</h2>
                        <div class="equipment-list">
                            <?php foreach ($equipments as $equip): 
                                $attributes = parseJson($equip['base_attributes']);
                            ?>
                            <div class="equipment-item">
                                <div class="equipment-name">
                                    <?= htmlspecialchars($equip['equipment_name']) ?>
                                    <span class="rarity-badge rarity-<?= $equip['rarity'] ?>"><?= ucfirst($equip['rarity']) ?></span>
                                </div>
                                <div class="equipment-stats">
                                    <div>耐久度: <?= $equip['durability'] ?></div>
                                    <div>强化等级: +<?= $equip['enhancement_level'] ?></div>
                                    <?php foreach ($attributes as $key => $value): ?>
                                    <div><?= htmlspecialchars($key) ?>: <?= formatAttributeValue($value) ?></div>
                                    <?php endforeach; ?>
                                </div>
                            </div>
                            <?php endforeach; ?>
                        </div>
                    </div>

                    <!-- 特质列表 -->
                    <div class="info-card">
                        <h2>性格特质</h2>
                        <div class="trait-list">
                            <?php foreach ($traits as $trait): ?>
                            <div class="trait-item trait-<?= $trait['trait_category'] ?>">
                                <div class="trait-name">
                                    <?= htmlspecialchars($trait['trait_name']) ?>
                                    <?php
                                    $modifiers = [];
                                    if ($trait['trade_modifier'] != 0) {
                                        $modifiers[] = "交易 " . formatAttributeValue($trait['trade_modifier'] * 100) . "%";
                                    }
                                    if ($trait['venture_modifier'] != 0) {
                                        $modifiers[] = "冒险 " . formatAttributeValue($trait['venture_modifier'] * 100) . "%";
                                    }
                                    if ($trait['loyalty_modifier'] != 0) {
                                        $modifiers[] = "忠诚 " . formatAttributeValue($trait['loyalty_modifier'] * 100) . "%";
                                    }
                                    if ($trait['stress_modifier'] != 0) {
                                        $modifiers[] = "压力 " . formatAttributeValue($trait['stress_modifier'] * 100) . "%";
                                    }
                                    ?>
                                </div>
                                <div class="trait-description"><?= htmlspecialchars($trait['description']) ?></div>
                                <?php if (!empty($modifiers)): ?>
                                <div class="trait-modifiers">
                                    <?= implode(' | ', $modifiers) ?>
                                </div>
                                <?php endif; ?>
                            </div>
                            <?php endforeach; ?>
                        </div>
                    </div>
                </div>
            </div>
        <?php endif; ?>
    </div>
</body>
</html> 