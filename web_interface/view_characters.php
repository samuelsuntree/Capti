<?php
require_once 'config/database.php';

try {
    $pdo = getDBConnection();
    
    // 获取搜索和筛选参数
    $search = $_GET['search'] ?? '';
    $rarity = $_GET['rarity'] ?? '';
    $class = $_GET['class'] ?? '';
    $sortBy = $_GET['sort'] ?? 'player_id';
    $sortOrder = $_GET['order'] ?? 'DESC';
    
    // 构建查询
    $where = [];
    $params = [];
    
    if (!empty($search)) {
        $where[] = "(p.character_name LIKE :search OR p.display_name LIKE :search)";
        $params['search'] = '%' . $search . '%';
    }
    
    if (!empty($rarity)) {
        $where[] = "p.rarity = :rarity";
        $params['rarity'] = $rarity;
    }
    
    if (!empty($class)) {
        $where[] = "p.character_class = :class";
        $params['class'] = $class;
    }
    
    $whereClause = !empty($where) ? ' WHERE ' . implode(' AND ', $where) : '';
    
    // 联表查询，包含情绪状态和队伍信息
    $sql = "SELECT 
                p.*,
                m.happiness, m.stress, m.motivation, m.confidence, m.fatigue, m.focus, m.team_relationship, m.reputation,
                t.team_name, tm.role as team_role,
                COALESCE(asset_counts.asset_count, 0) as asset_count,
                COALESCE(equipment_value.total_value, 0) as equipment_value
            FROM players p
            LEFT JOIN player_mood m ON p.player_id = m.player_id
            LEFT JOIN team_members tm ON p.player_id = tm.player_id
            LEFT JOIN adventure_teams t ON tm.team_id = t.team_id
            LEFT JOIN (
                SELECT player_id, COUNT(*) as asset_count 
                FROM player_assets 
                GROUP BY player_id
            ) asset_counts ON p.player_id = asset_counts.player_id
            LEFT JOIN (
                SELECT 
                    ei.current_owner_id as player_id,
                    SUM(ei.current_value) as total_value
                FROM equipment_instances ei
                WHERE ei.owner_type = 'player'
                GROUP BY ei.current_owner_id
            ) equipment_value ON p.player_id = equipment_value.player_id
            " . $whereClause . "
            ORDER BY p." . $sortBy . " " . $sortOrder;
            
    $stmt = $pdo->prepare($sql);
    $stmt->execute($params);
    $characters = $stmt->fetchAll();
    
} catch (Exception $e) {
    $error = "查询失败：" . $e->getMessage();
    $characters = [];
}

// 在PHP部分添加函数
function getCharacterAvatar($avatar_url) {
    if (empty($avatar_url)) {
        return 'assets/images/default_avatar.svg';
    }
    return $avatar_url;
}

// 解析性格特质JSON
function parseTraits($traitsJson) {
    if (empty($traitsJson)) return [];
    $traits = json_decode($traitsJson, true);
    return is_array($traits) ? $traits : [];
}
?>

<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>查看角色 - 游戏角色管理系统</title>
    <style>
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
            max-width: 1600px;
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
        }
        .header h1 {
            font-size: 2.5em;
            margin-bottom: 10px;
        }
        .nav {
            background: #34495e;
            padding: 0;
        }
        .nav ul {
            list-style: none;
            display: flex;
            justify-content: center;
        }
        .nav li {
            margin: 0 5px;
        }
        .nav a {
            display: block;
            padding: 15px 25px;
            color: white;
            text-decoration: none;
            transition: background 0.3s;
        }
        .nav a:hover, .nav a.active {
            background: #2c3e50;
        }
        .content {
            padding: 40px;
        }
        .filters {
            background: #f8f9fa;
            padding: 20px;
            border-radius: 10px;
            margin-bottom: 30px;
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 15px;
            align-items: end;
        }
        .filter-group {
            display: flex;
            flex-direction: column;
        }
        .filter-group label {
            margin-bottom: 5px;
            font-weight: bold;
            color: #2c3e50;
        }
        .filter-group input,
        .filter-group select {
            padding: 8px;
            border: 1px solid #ddd;
            border-radius: 5px;
            font-size: 14px;
        }
        .filter-btn {
            background: #3498db;
            color: white;
            padding: 10px 20px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
        }
        .characters-table {
            width: 100%;
            border-collapse: collapse;
            background: white;
            border-radius: 10px;
            overflow: hidden;
            box-shadow: 0 5px 15px rgba(0,0,0,0.1);
            font-size: 12px;
        }
        .characters-table th {
            background: #34495e;
            color: white;
            padding: 10px 8px;
            text-align: left;
            font-weight: bold;
            font-size: 11px;
        }
        .characters-table th a {
            color: white;
            text-decoration: none;
        }
        .characters-table td {
            padding: 8px;
            border-bottom: 1px solid #eee;
            vertical-align: top;
        }
        .characters-table tr:hover {
            background: #f8f9fa;
        }
        .rarity-badge {
            padding: 4px 8px;
            border-radius: 12px;
            font-size: 10px;
            font-weight: bold;
            color: white;
            white-space: nowrap;
        }
        .rarity-legendary { background: #e74c3c; }
        .rarity-epic { background: #9b59b6; }
        .rarity-rare { background: #3498db; }
        .rarity-uncommon { background: #2ecc71; }
        .rarity-common { background: #95a5a6; }
        .class-badge {
            padding: 4px 8px;
            border-radius: 12px;
            font-size: 10px;
            font-weight: bold;
            color: white;
            background: #f39c12;
            white-space: nowrap;
        }
        .team-badge {
            padding: 4px 8px;
            border-radius: 12px;
            font-size: 10px;
            font-weight: bold;
            color: white;
            background: #8e44ad;
            white-space: nowrap;
        }
        .role-leader { background: #e74c3c; }
        .role-regular { background: #3498db; }
        .role-trainee { background: #95a5a6; }
        .stat-mini {
            width: 60px;
            height: 12px;
            background: #ecf0f1;
            border-radius: 6px;
            overflow: hidden;
            position: relative;
            margin: 2px 0;
        }
        .stat-fill {
            height: 100%;
            background: linear-gradient(90deg, #27ae60, #2ecc71);
            transition: width 0.3s;
        }
        .stat-text {
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 9px;
            font-weight: bold;
            color: #2c3e50;
        }
        .traits-list {
            max-width: 120px;
            font-size: 10px;
        }
        .trait-tag {
            display: inline-block;
            background: #ecf0f1;
            color: #2c3e50;
            padding: 2px 6px;
            border-radius: 8px;
            margin: 1px;
            font-size: 9px;
        }
        .trait-positive { background: #d5f4e6; color: #27ae60; }
        .trait-negative { background: #fadbd8; color: #e74c3c; }
        .trait-neutral { background: #eaecee; color: #5d6d7e; }
        .no-data {
            text-align: center;
            padding: 40px;
            color: #7f8c8d;
            font-size: 18px;
        }
        .available-yes { color: #27ae60; font-weight: bold; }
        .available-no { color: #e74c3c; font-weight: bold; }
        .mood-indicators {
            display: flex;
            flex-direction: column;
            gap: 2px;
        }
        .mood-item {
            display: flex;
            align-items: center;
            gap: 5px;
            font-size: 9px;
        }
        .mood-icon {
            width: 12px;
            height: 12px;
            border-radius: 50%;
        }
        .mood-happy { background: #2ecc71; }
        .mood-stress { background: #e74c3c; }
        .mood-motivation { background: #3498db; }
        .stats-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 2px;
            font-size: 9px;
        }
        .scrollable-table {
            overflow-x: auto;
        }
        .character-info {
            display: flex;
            align-items: center;
            gap: 15px;
            padding: 8px 0;
        }

        .character-avatar {
            width: 48px;
            height: 48px;
            border-radius: 50%;
            overflow: hidden;
            flex-shrink: 0;
            border: 2px solid rgba(0,0,0,0.1);
        }

        .character-avatar img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }

        .character-details {
            flex-grow: 1;
        }

        .character-name {
            font-size: 14px;
            font-weight: bold;
            margin-bottom: 4px;
        }

        .character-name a {
            color: #2c3e50;
            text-decoration: none;
            transition: color 0.2s;
        }

        .character-name a:hover {
            color: #3498db;
        }

        .character-display-name {
            font-size: 12px;
            color: #666;
            margin-bottom: 6px;
        }

        .character-badges {
            display: flex;
            gap: 6px;
            margin-bottom: 6px;
        }

        .character-level {
            font-size: 11px;
            color: #666;
        }

        .character-costs {
            font-size: 11px;
            color: #666;
            display: flex;
            gap: 10px;
        }

        .cost-item {
            display: flex;
            align-items: center;
            gap: 4px;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>👥 角色管理系统</h1>
            <p>查看和管理所有雇佣角色</p>
        </div>
        
        <nav class="nav">
            <ul>
                <li><a href="index.html">主页</a></li>
                <li><a href="add_character.html">添加角色</a></li>
                <li><a href="view_characters.php" class="active">查看角色</a></li>
            </ul>
        </nav>
        
        <div class="content">
            <!-- 筛选器 -->
            <form method="GET" class="filters">
                <div class="filter-group">
                    <label>搜索角色</label>
                    <input type="text" name="search" value="<?= htmlspecialchars($search) ?>" placeholder="角色名称...">
                </div>
                <div class="filter-group">
                    <label>稀有度</label>
                    <select name="rarity">
                        <option value="">全部</option>
                        <option value="legendary" <?= $rarity === 'legendary' ? 'selected' : '' ?>>传奇</option>
                        <option value="epic" <?= $rarity === 'epic' ? 'selected' : '' ?>>史诗</option>
                        <option value="rare" <?= $rarity === 'rare' ? 'selected' : '' ?>>稀有</option>
                        <option value="uncommon" <?= $rarity === 'uncommon' ? 'selected' : '' ?>>不凡</option>
                        <option value="common" <?= $rarity === 'common' ? 'selected' : '' ?>>普通</option>
                    </select>
                </div>
                <div class="filter-group">
                    <label>职业</label>
                    <select name="class">
                        <option value="">全部</option>
                        <option value="warrior" <?= $class === 'warrior' ? 'selected' : '' ?>>战士</option>
                        <option value="archer" <?= $class === 'archer' ? 'selected' : '' ?>>弓箭手</option>
                        <option value="explorer" <?= $class === 'explorer' ? 'selected' : '' ?>>探险家</option>
                        <option value="scholar" <?= $class === 'scholar' ? 'selected' : '' ?>>学者</option>
                        <option value="mystic" <?= $class === 'mystic' ? 'selected' : '' ?>>法师</option>
                        <option value="survivor" <?= $class === 'survivor' ? 'selected' : '' ?>>生存者</option>
                    </select>
                </div>
                <div class="filter-group">
                    <button type="submit" class="filter-btn">🔍 筛选</button>
                </div>
            </form>

            <?php if (isset($error)): ?>
                <div class="alert error"><?= htmlspecialchars($error) ?></div>
            <?php endif; ?>

            <?php if (empty($characters)): ?>
                <div class="no-data">
                    <p>😔 暂无角色数据</p>
                    <p><a href="add_character.html">点击添加第一个角色</a></p>
                </div>
            <?php else: ?>
                <div class="scrollable-table">
                    <table class="characters-table">
                        <thead>
                            <tr>
                                <th><a href="?sort=player_id&order=<?= $sortBy === 'player_id' && $sortOrder === 'ASC' ? 'DESC' : 'ASC' ?>">ID</a></th>
                                <th><a href="?sort=character_name&order=<?= $sortBy === 'character_name' && $sortOrder === 'ASC' ? 'DESC' : 'ASC' ?>">角色信息</a></th>
                                <th>基础属性</th>
                                <th>精神属性</th>
                                <th>技能</th>
                                <th>情绪状态</th>
                                <th>队伍信息</th>
                                <th>性格特质</th>
                                <th>状态</th>
                            </tr>
                        </thead>
                        <tbody>
                            <?php foreach ($characters as $char): 
                                // $traits = parseTraits($char['personality_traits']); // This line is removed as per the new_code
                            ?>
                            <tr>
                                <td><?= $char['player_id'] ?></td>
                                <td>
                                    <div class="character-info">
                                        <div class="character-avatar">
                                            <img src="<?= getCharacterAvatar($char['avatar_url']) ?>" 
                                                 alt="<?= htmlspecialchars($char['character_name']) ?>"
                                                 onerror="this.src='assets/images/default_avatar.svg'">
                                        </div>
                                        <div class="character-details">
                                            <div class="character-name">
                                                <a href="character_detail.php?code=<?= urlencode($char['character_code']) ?>">
                                                    <?= htmlspecialchars($char['character_name']) ?>
                                                </a>
                                            </div>
                                            <div class="character-display-name">
                                                <?= htmlspecialchars($char['display_name']) ?>
                                            </div>
                                            <div class="character-badges">
                                                <span class="rarity-badge rarity-<?= $char['rarity'] ?>"><?= ucfirst($char['rarity']) ?></span>
                                                <span class="class-badge"><?= ucfirst($char['character_class']) ?></span>
                                            </div>
                                            <div class="character-level">
                                                Lv.<?= $char['current_level'] ?> (<?= number_format($char['total_experience']) ?>exp)
                                            </div>
                                            <div class="character-costs">
                                                <span class="cost-item">💰<?= number_format($char['hire_cost']) ?></span>
                                                <span class="cost-item">🔧<?= number_format($char['maintenance_cost']) ?></span>
                                            </div>
                                        </div>
                                    </div>
                                </td>
                                <td>
                                    <div class="stats-grid">
                                        <div>💪<?= $char['strength'] ?></div>
                                        <div>❤️<?= $char['vitality'] ?></div>
                                        <div>⚡<?= $char['agility'] ?></div>
                                        <div>🧠<?= $char['intelligence'] ?></div>
                                        <div>✨<?= $char['faith'] ?></div>
                                        <div>🍀<?= $char['luck'] ?></div>
                                    </div>
                                </td>
                                <td>
                                    <div class="stats-grid">
                                        <div>🛡️<?= $char['loyalty'] ?></div>
                                        <div>⚔️<?= $char['courage'] ?></div>
                                        <div>⏳<?= $char['patience'] ?></div>
                                        <div>💰<?= $char['greed'] ?></div>
                                        <div>📚<?= $char['wisdom'] ?></div>
                                        <div>🎭<?= $char['charisma'] ?></div>
                                    </div>
                                </td>
                                <td>
                                    <div class="stats-grid">
                                        <div>📈<?= $char['trade_skill'] ?></div>
                                        <div>🗡️<?= $char['venture_skill'] ?></div>
                                        <div>🤝<?= $char['negotiation_skill'] ?></div>
                                        <div>🔍<?= $char['analysis_skill'] ?></div>
                                        <div>👑<?= $char['leadership_skill'] ?></div>
                                    </div>
                                </td>
                                <td>
                                    <?php if ($char['happiness'] !== null): ?>
                                    <div class="mood-indicators">
                                        <div class="mood-item">
                                            <div class="mood-icon mood-happy"></div>
                                            <span><?= $char['happiness'] ?></span>
                                        </div>
                                        <div class="mood-item">
                                            <div class="mood-icon mood-stress"></div>
                                            <span><?= $char['stress'] ?></span>
                                        </div>
                                        <div class="mood-item">
                                            <div class="mood-icon mood-motivation"></div>
                                            <span><?= $char['motivation'] ?></span>
                                        </div>
                                    </div>
                                    <?php else: ?>
                                    <span style="color: #95a5a6;">无数据</span>
                                    <?php endif; ?>
                                </td>
                                <td>
                                    <?php if ($char['team_name']): ?>
                                        <div class="team-badge"><?= htmlspecialchars($char['team_name']) ?></div>
                                        <div class="role-<?= $char['team_role'] ?>" style="font-size: 10px; margin-top: 2px;">
                                            <?php
                                            $roleNames = ['leader' => '队长', 'regular' => '成员', 'trainee' => '学员'];
                                            echo $roleNames[$char['team_role']] ?? $char['team_role'];
                                            ?>
                                        </div>
                                    <?php else: ?>
                                        <span style="color: #95a5a6;">无队伍</span>
                                    <?php endif; ?>
                                </td>
                                <td>
                                    <div class="traits-list">
                                        <?php 
                                        $traits = json_decode($char['personality_traits'], true) ?? [];
                                        foreach ($traits as $trait): 
                                        ?>
                                            <span class="trait-tag trait-neutral"><?= htmlspecialchars($trait) ?></span>
                                        <?php endforeach; ?>
                                    </div>
                                </td>
                                <td>
                                    <div class="<?= $char['is_available'] ? 'available-yes' : 'available-no' ?>">
                                        <?= $char['is_available'] ? '✅ 可用' : '❌ 不可用' ?>
                                    </div>
                                    <div style="font-size: 10px; color: #7f8c8d;">
                                        资产: <?= $char['asset_count'] ?>项<br>
                                        装备价值: <?= number_format($char['equipment_value']) ?>
                                    </div>
                                </td>
                            </tr>
                            <?php endforeach; ?>
                        </tbody>
                    </table>
                </div>
                
                <div style="text-align: center; margin-top: 20px; color: #7f8c8d;">
                    共找到 <?= count($characters) ?> 个角色
                </div>
            <?php endif; ?>
        </div>
    </div>
</body>
</html> 