<?php
require_once 'config/database_sqlite.php';

// 获取特定玩家ID，如果没有则显示所有玩家列表
$trader_id = isset($_GET['id']) ? intval($_GET['id']) : null;

try {
    $pdo = getDBConnection();

    if ($trader_id) {
        // 获取玩家详细信息
        $stmt = $pdo->prepare("
            SELECT t.*,
                   COALESCE(
                       (SELECT SUM(bch.quantity * bc.base_value)
                        FROM bulk_commodity_holdings bch
                        JOIN bulk_commodities bc ON bch.commodity_id = bc.commodity_id
                        WHERE bch.player_id = t.trader_id), 0
                   ) as commodities_value,
                   COALESCE(
                       (SELECT SUM(ei.current_value)
                        FROM equipment_instances ei
                        WHERE ei.current_owner_id = t.trader_id
                        AND ei.owner_type = 'trader'), 0
                   ) as equipment_value
            FROM traders t
            WHERE t.trader_id = ?
        ");
        $stmt->execute([$trader_id]);
        $trader = $stmt->fetch(PDO::FETCH_ASSOC);

        if ($trader) {
            // 更新总资产值（金币 + 大宗商品价值 + 装备价值）
            $total_asset_value = $trader['gold_balance'] + $trader['commodities_value'] + $trader['equipment_value'];
            
            // 更新数据库中的总资产值
            $stmt = $pdo->prepare("
                UPDATE traders 
                SET total_asset_value = ? 
                WHERE trader_id = ?
            ");
            $stmt->execute([$total_asset_value, $trader_id]);
            
            // 更新当前页面显示的总资产值
            $trader['total_asset_value'] = $total_asset_value;
        }

        // 获取玩家持有的装备
        $stmt = $pdo->prepare("
            SELECT 
                ti.trader_item_id,
                ti.quantity,
                ti.purchase_price,
                ti.acquired_at,
                ti.is_locked,
                ti.notes,
                et.equipment_name,
                et.type_id,
                et.rarity,
                ei.durability,
                ei.current_value,
                ei.attributes,
                ety.type_name as equipment_type
            FROM trader_items ti
            JOIN equipment_instances ei ON ti.equipment_instance_id = ei.instance_id
            JOIN equipment_templates et ON ei.template_id = et.template_id
            JOIN equipment_types ety ON et.type_id = ety.type_id
            WHERE ti.trader_id = ? 
            AND ei.owner_type = 'trader'
            ORDER BY ti.acquired_at DESC
        ");
        $stmt->execute([$trader_id]);
        $equipment = $stmt->fetchAll(PDO::FETCH_ASSOC);

        // 获取玩家持有的大宗商品
        $stmt = $pdo->prepare("
            SELECT 
                bch.holding_id,
                bch.quantity,
                bc.commodity_name,
                bc.commodity_code,
                bc.category,
                bc.rarity,
                bc.base_value,
                (bc.base_value * bch.quantity) as total_value
            FROM bulk_commodity_holdings bch
            JOIN bulk_commodities bc ON bch.commodity_id = bc.commodity_id
            WHERE bch.player_id = ?
            ORDER BY bc.category, bc.commodity_name
        ");
        $stmt->execute([$trader_id]);
        $commodities = $stmt->fetchAll(PDO::FETCH_ASSOC);

    } else {
        // 获取所有玩家列表，包含大宗商品和装备价值
        $stmt = $pdo->query("
            SELECT 
                t.trader_id,
                t.display_name,
                t.trade_level,
                t.trade_reputation,
                t.total_trades,
                t.gold_balance,
                t.gold_balance + 
                COALESCE(
                    (SELECT SUM(bch.quantity * bc.base_value)
                     FROM bulk_commodity_holdings bch
                     JOIN bulk_commodities bc ON bch.commodity_id = bc.commodity_id
                     WHERE bch.player_id = t.trader_id), 0
                ) +
                COALESCE(
                    (SELECT SUM(ei.current_value)
                     FROM equipment_instances ei
                     WHERE ei.current_owner_id = t.trader_id
                     AND ei.owner_type = 'trader'), 0
                ) as total_asset_value
            FROM traders t
            ORDER BY total_asset_value DESC
        ");
        $traders = $stmt->fetchAll(PDO::FETCH_ASSOC);
    }
} catch(PDOException $e) {
    die("连接失败: " . $e->getMessage());
}
?>

<!DOCTYPE html>
<html lang="zh">
<head>
    <meta charset="UTF-8">
    <title><?php echo $trader_id ? "玩家详情" : "玩家列表"; ?></title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css">
    <style>
        .rarity-common { color: #808080; }
        .rarity-uncommon { color: #00ff00; }
        .rarity-rare { color: #0000ff; }
        .rarity-epic { color: #800080; }
        .rarity-legendary { color: #ffa500; }
    </style>
</head>
<body>
    <div class="container mt-4">
        <nav aria-label="breadcrumb">
            <ol class="breadcrumb">
                <li class="breadcrumb-item"><a href="index.html">首页</a></li>
                <?php if ($trader_id): ?>
                    <li class="breadcrumb-item"><a href="view_traders.php">玩家列表</a></li>
                    <li class="breadcrumb-item active">玩家详情</li>
                <?php else: ?>
                    <li class="breadcrumb-item active">玩家列表</li>
                <?php endif; ?>
            </ol>
        </nav>

        <?php if ($trader_id && $trader): ?>
            <!-- 玩家详情页 -->
            <div class="row">
                <div class="col-md-4">
                    <div class="card">
                        <div class="card-body">
                            <h5 class="card-title"><?php echo htmlspecialchars($trader['display_name']); ?></h5>
                            <img src="<?php echo $trader['avatar_url'] ?: 'assets/images/default_avatar.svg'; ?>" 
                                 class="img-fluid rounded mb-3" alt="头像">
                            
                            <!-- 基本信息 -->
                            <div class="mb-3">
                                <h6>基本信息</h6>
                                <p>交易等级: <?php echo $trader['trade_level']; ?></p>
                                <p>交易经验: <?php echo $trader['trade_experience']; ?></p>
                                <p>信誉评分: <?php echo $trader['trade_reputation']; ?>/100</p>
                                <p>注册时间: <?php echo $trader['created_at']; ?></p>
                            </div>

                            <!-- 资产信息 -->
                            <div class="mb-3">
                                <h6>资产信息</h6>
                                <p>金币余额: <?php echo number_format($trader['gold_balance'], 2); ?></p>
                                <p>总资产值: <?php echo number_format($trader['total_asset_value'], 2); ?></p>
                            </div>

                            <!-- 交易统计 -->
                            <div class="mb-3">
                                <h6>交易统计</h6>
                                <p>总交易次数: <?php echo $trader['total_trades']; ?></p>
                                <p>成功交易: <?php echo $trader['successful_trades']; ?></p>
                                <p>总收益: <?php echo number_format($trader['total_profit'], 2); ?></p>
                                <p>最佳收益: <?php echo number_format($trader['best_trade_profit'], 2); ?></p>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="col-md-8">
                    <!-- 持有装备列表 -->
                    <div class="card mb-4">
                        <div class="card-body">
                            <h5 class="card-title">持有装备</h5>
                            <div class="table-responsive">
                                <table class="table table-hover">
                                    <thead>
                                        <tr>
                                            <th>装备名称</th>
                                            <th>类型</th>
                                            <th>稀有度</th>
                                            <th>耐久度</th>
                                            <th>当前价值</th>
                                            <th>购入价格</th>
                                            <th>获得时间</th>
                                            <th>状态</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <?php foreach ($equipment as $item): ?>
                                        <tr>
                                            <td>
                                                <span class="rarity-<?php echo strtolower($item['rarity']); ?>">
                                                    <?php echo htmlspecialchars($item['equipment_name']); ?>
                                                </span>
                                            </td>
                                            <td><?php echo htmlspecialchars($item['equipment_type']); ?></td>
                                            <td><?php echo htmlspecialchars($item['rarity']); ?></td>
                                            <td><?php echo $item['durability']; ?>/100</td>
                                            <td><?php echo number_format($item['current_value'], 2); ?></td>
                                            <td><?php echo number_format($item['purchase_price'], 2); ?></td>
                                            <td><?php echo $item['acquired_at']; ?></td>
                                            <td>
                                                <?php if ($item['is_locked']): ?>
                                                    <span class="badge bg-warning">🔒已锁定</span>
                                                <?php else: ?>
                                                    <span class="badge bg-success">可交易</span>
                                                <?php endif; ?>
                                            </td>
                                        </tr>
                                        <?php endforeach; ?>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>

                    <!-- 持有大宗商品列表 -->
                    <div class="card">
                        <div class="card-body">
                            <h5 class="card-title">持有商品</h5>
                            <div class="table-responsive">
                                <table class="table table-hover">
                                    <thead>
                                        <tr>
                                            <th>商品名称</th>
                                            <th>类别</th>
                                            <th>稀有度</th>
                                            <th>持有数量</th>
                                            <th>单价</th>
                                            <th>总价值</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <?php foreach ($commodities as $commodity): ?>
                                        <tr>
                                            <td>
                                                <span class="rarity-<?php echo strtolower($commodity['rarity']); ?>">
                                                    <?php echo htmlspecialchars($commodity['commodity_name']); ?>
                                                </span>
                                                <small class="text-muted">[<?php echo $commodity['commodity_code']; ?>]</small>
                                            </td>
                                            <td><?php echo htmlspecialchars($commodity['category']); ?></td>
                                            <td><?php echo htmlspecialchars($commodity['rarity']); ?></td>
                                            <td><?php echo number_format($commodity['quantity'], 2); ?></td>
                                            <td><?php echo number_format($commodity['base_value'], 2); ?></td>
                                            <td><?php echo number_format($commodity['total_value'], 2); ?></td>
                                        </tr>
                                        <?php endforeach; ?>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

        <?php else: ?>
            <!-- 玩家列表页 -->
            <div class="card">
                <div class="card-body">
                    <h5 class="card-title">玩家列表</h5>
                    <div class="table-responsive">
                        <table class="table table-hover">
                            <thead>
                                <tr>
                                    <th>玩家名称</th>
                                    <th>交易等级</th>
                                    <th>信誉评分</th>
                                    <th>总交易次数</th>
                                    <th>金币余额</th>
                                    <th>总资产</th>
                                    <th>操作</th>
                                </tr>
                            </thead>
                            <tbody>
                                <?php foreach ($traders as $t): ?>
                                <tr>
                                    <td><?php echo htmlspecialchars($t['display_name']); ?></td>
                                    <td><?php echo $t['trade_level']; ?></td>
                                    <td><?php echo $t['trade_reputation']; ?>/100</td>
                                    <td><?php echo $t['total_trades']; ?></td>
                                    <td><?php echo number_format($t['gold_balance'], 2); ?></td>
                                    <td><?php echo number_format($t['total_asset_value'], 2); ?></td>
                                    <td>
                                        <a href="view_traders.php?id=<?php echo $t['trader_id']; ?>" 
                                           class="btn btn-sm btn-primary">查看详情</a>
                                    </td>
                                </tr>
                                <?php endforeach; ?>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        <?php endif; ?>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html> 