<?php
require_once 'config/database_sqlite.php';

try {
    $pdo = getDBConnection();
    
    // 获取队伍统计
    $sql = "SELECT 
                t.*,
                COUNT(DISTINCT tm.player_id) as current_members,
                GROUP_CONCAT(
                    DISTINCT
                    CASE 
                        WHEN tm.role = 'leader' THEN p.character_name || ' (队长)'
                        ELSE p.character_name
                    END
                    ORDER BY tm.role DESC, p.character_name
                ) as member_list,
                COALESCE(SUM(CASE WHEN tm.role = 'leader' THEN p.leadership_skill ELSE 0 END), 0) as leader_skill,
                AVG(DISTINCT p.current_level) as avg_level,
                SUM(DISTINCT p.venture_skill) as total_venture_skill,
                COUNT(DISTINCT e.instance_id) as total_equipment,
                COALESCE(SUM(e.current_value), 0) as total_equipment_value
            FROM adventure_teams t
            LEFT JOIN team_members tm ON t.team_id = tm.team_id
            LEFT JOIN players p ON tm.player_id = p.player_id
            LEFT JOIN equipment_instances e ON p.player_id = e.current_owner_id AND e.is_broken = FALSE
            GROUP BY t.team_id, t.team_name, t.team_leader, t.team_size, t.specialization, 
                     t.team_level, t.success_rate, t.current_status, 
                     t.base_cost, t.team_description
            ORDER BY t.success_rate DESC";
            
    $stmt = $pdo->query($sql);
    $teams = $stmt->fetchAll();
    
    // 获取总计
    $sql = "SELECT 
                COUNT(DISTINCT t.team_id) as total_teams,
                COUNT(DISTINCT tm.player_id) as total_members,
                COUNT(DISTINCT CASE WHEN tm.role = 'leader' THEN tm.player_id END) as total_leaders,
                AVG(t.success_rate) as avg_success_rate,
                COUNT(DISTINCT CASE WHEN t.current_status = 'available' THEN t.team_id END) as available_teams
            FROM adventure_teams t
            LEFT JOIN team_members tm ON t.team_id = tm.team_id";
            
    $stmt = $pdo->query($sql);
    $totals = $stmt->fetch();
    
} catch (Exception $e) {
    $error = $e->getMessage();
}
?>

<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>队伍统计 - 游戏角色管理系统</title>
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
        .summary-cards {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin-bottom: 40px;
        }
        .summary-card {
            background: #f8f9fa;
            padding: 20px;
            border-radius: 10px;
            text-align: center;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        .summary-card .value {
            font-size: 24px;
            font-weight: bold;
            color: #2c3e50;
            margin: 10px 0;
        }
        .summary-card .label {
            color: #7f8c8d;
            font-size: 14px;
        }
        .team-cards {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(350px, 1fr));
            gap: 20px;
        }
        .team-card {
            background: #fff;
            border-radius: 10px;
            padding: 20px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            border-left: 4px solid #3498db;
        }
        .team-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 15px;
            padding-bottom: 10px;
            border-bottom: 1px solid #eee;
        }
        .team-name {
            font-size: 18px;
            font-weight: bold;
            color: #2c3e50;
        }
        .team-status {
            padding: 4px 8px;
            border-radius: 12px;
            font-size: 12px;
            color: white;
        }
        .status-available { background: #2ecc71; }
        .status-busy { background: #e74c3c; }
        .team-stats {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 10px;
            margin-bottom: 15px;
        }
        .stat-item {
            font-size: 14px;
            color: #7f8c8d;
        }
        .stat-value {
            font-weight: bold;
            color: #2c3e50;
        }
        .team-members {
            font-size: 14px;
            color: #666;
            line-height: 1.4;
        }
        .team-description {
            margin-top: 10px;
            font-size: 14px;
            color: #666;
            line-height: 1.4;
        }
        .specialization-badge {
            display: inline-block;
            padding: 4px 8px;
            border-radius: 12px;
            font-size: 12px;
            color: white;
            background: #9b59b6;
            margin-left: 10px;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <a href="index.html" class="back-btn">← 返回首页</a>
            <h1>队伍统计</h1>
            <p>查看所有冒险队伍的详细信息</p>
        </div>
        
        <div class="content">
            <?php if (isset($error)): ?>
                <div class="error-message"><?= htmlspecialchars($error) ?></div>
            <?php else: ?>
                <!-- 总览卡片 -->
                <div class="summary-cards">
                    <div class="summary-card">
                        <div class="label">队伍总数</div>
                        <div class="value">👥 <?= number_format($totals['total_teams']) ?></div>
                    </div>
                    <div class="summary-card">
                        <div class="label">总队员数</div>
                        <div class="value">🧑‍🤝‍🧑 <?= number_format($totals['total_members']) ?></div>
                    </div>
                    <div class="summary-card">
                        <div class="label">平均成功率</div>
                        <div class="value">📈 <?= number_format($totals['avg_success_rate'], 1) ?>%</div>
                    </div>
                    <div class="summary-card">
                        <div class="label">可接任务队伍</div>
                        <div class="value">✅ <?= number_format($totals['available_teams']) ?></div>
                    </div>
                </div>

                <!-- 队伍卡片 -->
                <div class="team-cards">
                    <?php foreach ($teams as $team): ?>
                    <div class="team-card">
                        <div class="team-header">
                            <div class="team-name">
                                <?= htmlspecialchars($team['team_name']) ?>
                                <span class="specialization-badge"><?= ucfirst($team['specialization']) ?></span>
                            </div>
                            <span class="team-status status-<?= $team['current_status'] ?>">
                                <?= $team['current_status'] === 'available' ? '可接任务' : '任务中' ?>
                            </span>
                        </div>
                        <div class="team-stats">
                            <div class="stat-item">
                                成员: <span class="stat-value"><?= $team['current_members'] ?>/<?= $team['team_size'] ?></span>
                            </div>
                            <div class="stat-item">
                                等级: <span class="stat-value"><?= number_format($team['avg_level'], 1) ?></span>
                            </div>
                            <div class="stat-item">
                                成功率: <span class="stat-value"><?= number_format($team['success_rate'], 1) ?>%</span>
                            </div>
                            <div class="stat-item">
                                经验: <span class="stat-value"><?= number_format($team['experience_points']) ?></span>
                            </div>
                            <div class="stat-item">
                                装备数: <span class="stat-value"><?= number_format($team['total_equipment']) ?></span>
                            </div>
                            <div class="stat-item">
                                装备价值: <span class="stat-value"><?= number_format($team['total_equipment_value']) ?></span>
                            </div>
                        </div>
                        <div class="team-members">
                            <strong>成员列表:</strong> <?= htmlspecialchars($team['member_list']) ?>
                        </div>
                        <div class="team-description">
                            <?= htmlspecialchars($team['team_description']) ?>
                        </div>
                    </div>
                    <?php endforeach; ?>
                </div>
            <?php endif; ?>
        </div>
    </div>
</body>
</html> 