<?php
require_once 'config/database_sqlite.php';

try {
    $pdo = getDBConnection();
    
    // 获取角色资产统计
    $sql = "SELECT 
                p.character_name,
                p.display_name,
                p.rarity,
                p.hire_cost,
                p.maintenance_cost,
                COUNT(e.instance_id) as equipment_count,
                COALESCE(SUM(e.current_value), 0) as equipment_value,
                COALESCE(commodity_stats.commodity_value, 0) as commodity_value
            FROM players p
            LEFT JOIN equipment_instances e ON p.player_id = e.current_owner_id AND e.is_broken = FALSE
            LEFT JOIN (
                SELECT 
                    h.player_id,
                    SUM(h.quantity * c.current_value) as commodity_value
                FROM bulk_commodity_holdings h
                JOIN bulk_commodities c ON h.commodity_id = c.commodity_id
                GROUP BY h.player_id
            ) as commodity_stats ON p.player_id = commodity_stats.player_id
            GROUP BY p.player_id
            ORDER BY (p.hire_cost + COALESCE(SUM(e.current_value), 0) + COALESCE(commodity_stats.commodity_value, 0)) DESC";
            
    $stmt = $pdo->query($sql);
    $characterAssets = $stmt->fetchAll();
    
    // 获取总计
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
    <title>资产统计 - 游戏角色管理系统</title>
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
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
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
        .assets-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
            background: white;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            border-radius: 10px;
            overflow: hidden;
        }
        .assets-table th {
            background: #34495e;
            color: white;
            padding: 15px;
            text-align: left;
            font-size: 14px;
        }
        .assets-table td {
            padding: 12px 15px;
            border-bottom: 1px solid #eee;
            font-size: 14px;
        }
        .assets-table tr:hover {
            background: #f8f9fa;
        }
        .rarity-badge {
            padding: 4px 8px;
            border-radius: 12px;
            font-size: 12px;
            font-weight: bold;
            color: white;
            display: inline-block;
        }
        .rarity-legendary { background: #e74c3c; }
        .rarity-epic { background: #9b59b6; }
        .rarity-rare { background: #3498db; }
        .rarity-uncommon { background: #2ecc71; }
        .rarity-common { background: #95a5a6; }
        .total-row {
            font-weight: bold;
            background: #f8f9fa;
        }
        .total-row td {
            border-top: 2px solid #34495e;
        }
        .value-cell {
            text-align: right;
            font-family: monospace;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <a href="index.html" class="back-btn">← 返回首页</a>
            <h1>资产统计</h1>
            <p>查看所有角色的资产分布</p>
        </div>
        
        <div class="content">
            <?php if (isset($error)): ?>
                <div class="error-message"><?= htmlspecialchars($error) ?></div>
            <?php else: ?>
                <!-- 总览卡片 -->
                <div class="summary-cards">
                    <div class="summary-card">
                        <div class="label">总资产</div>
                        <div class="value">💰 <?= number_format($totals['total_hire_cost'] + $totals['total_equipment_value'] + $totals['total_commodity_value'], 2) ?></div>
                    </div>
                    <div class="summary-card">
                        <div class="label">角色总数</div>
                        <div class="value">👥 <?= number_format($totals['total_characters']) ?></div>
                    </div>
                    <div class="summary-card">
                        <div class="label">装备总数</div>
                        <div class="value">⚔️ <?= number_format($totals['total_equipment']) ?></div>
                    </div>
                    <div class="summary-card">
                        <div class="label">每日维护费</div>
                        <div class="value">🔧 <?= number_format($totals['total_maintenance_cost'], 2) ?></div>
                    </div>
                </div>

                <!-- 资产明细表 -->
                <table class="assets-table">
                    <thead>
                        <tr>
                            <th>角色</th>
                            <th>稀有度</th>
                            <th>雇佣价值</th>
                            <th>装备数量</th>
                            <th>装备价值</th>
                            <th>商品价值</th>
                            <th>总价值</th>
                            <th>维护费</th>
                        </tr>
                    </thead>
                    <tbody>
                        <?php foreach ($characterAssets as $asset): 
                            $totalValue = $asset['hire_cost'] + $asset['equipment_value'] + $asset['commodity_value'];
                        ?>
                        <tr>
                            <td>
                                <div><strong><?= htmlspecialchars($asset['character_name']) ?></strong></div>
                                <div style="font-size: 12px; color: #666;"><?= htmlspecialchars($asset['display_name']) ?></div>
                            </td>
                            <td><span class="rarity-badge rarity-<?= $asset['rarity'] ?>"><?= ucfirst($asset['rarity']) ?></span></td>
                            <td class="value-cell"><?= number_format($asset['hire_cost'], 2) ?></td>
                            <td class="value-cell"><?= number_format($asset['equipment_count']) ?></td>
                            <td class="value-cell"><?= number_format($asset['equipment_value'], 2) ?></td>
                            <td class="value-cell"><?= number_format($asset['commodity_value'], 2) ?></td>
                            <td class="value-cell"><?= number_format($totalValue, 2) ?></td>
                            <td class="value-cell"><?= number_format($asset['maintenance_cost'], 2) ?></td>
                        </tr>
                        <?php endforeach; ?>
                        <tr class="total-row">
                            <td colspan="2">总计</td>
                            <td class="value-cell"><?= number_format($totals['total_hire_cost'], 2) ?></td>
                            <td class="value-cell"><?= number_format($totals['total_equipment']) ?></td>
                            <td class="value-cell"><?= number_format($totals['total_equipment_value'], 2) ?></td>
                            <td class="value-cell"><?= number_format($totals['total_commodity_value'], 2) ?></td>
                            <td class="value-cell"><?= number_format($totals['total_hire_cost'] + $totals['total_equipment_value'] + $totals['total_commodity_value'], 2) ?></td>
                            <td class="value-cell"><?= number_format($totals['total_maintenance_cost'], 2) ?></td>
                        </tr>
                    </tbody>
                </table>
            <?php endif; ?>
        </div>
    </div>
</body>
</html> 