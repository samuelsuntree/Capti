<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>物品系统 - 游戏管理系统</title>
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
        .item-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
            margin-top: 20px;
        }
        .item-card {
            background: #f8f9fa;
            border-radius: 8px;
            padding: 15px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        .item-card h3 {
            color: #2c3e50;
            margin-bottom: 10px;
            font-size: 1.2em;
        }
        .rarity {
            display: inline-block;
            padding: 3px 8px;
            border-radius: 4px;
            font-size: 0.9em;
            margin-bottom: 8px;
        }
        .rarity.common { background: #dcdcdc; }
        .rarity.uncommon { background: #a8e6cf; }
        .rarity.rare { background: #3498db; color: white; }
        .rarity.epic { background: #9b59b6; color: white; }
        .rarity.legendary { background: #f1c40f; }
        .description {
            margin: 20px 0;
            line-height: 1.6;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🎮 物品系统</h1>
            <p id="subTitle">物品列表</p>
        </div>
        
        <nav class="nav">
            <ul>
                <li><a href="index.html">主页</a></li>
                <li><a href="view_items.php?type=bulk">大宗货品</a></li>
                <li><a href="view_items.php?type=equipment">装备</a></li>
                <li><a href="view_items.php?type=legendary">传说装备</a></li>
            </ul>
        </nav>
        
        <div class="content">
            <div class="description" id="typeDescription"></div>
            <div class="item-grid" id="itemGrid">
                <?php
                require_once('config/database_sqlite.php');

                try {
                    $pdo = getDBConnection();
                    
                    $type = $_GET['type'] ?? 'bulk';
                    
                    if ($type === 'bulk') {
                        // 查询大宗货品模板
                        $sql = "SELECT 
                            commodity_name,
                            commodity_code,
                            category,
                            rarity,
                            base_value,
                            description,
                            CASE 
                                WHEN category = 'currency' THEN exchange_rate
                                WHEN category = 'gem' THEN purity
                                WHEN category = 'ore' THEN refine_ratio
                                ELSE NULL
                            END as special_attribute,
                            obtainable_from
                        FROM bulk_commodities
                        ORDER BY category, rarity DESC, base_value DESC";
                        
                        $stmt = $pdo->query($sql);
                        while ($item = $stmt->fetch(PDO::FETCH_ASSOC)) {
                            $sources = $item['obtainable_from'] ? json_decode($item['obtainable_from'], true) : null;
                            echo "<div class='item-card'>";
                            echo "<h3>{$item['commodity_name']}</h3>";
                            echo "<span class='rarity {$item['rarity']}'>{$item['rarity']}</span>";
                            echo "<p>类别: {$item['category']}</p>";
                            echo "<p>基础价值: {$item['base_value']}</p>";
                            if ($item['description']) {
                                echo "<p>描述: {$item['description']}</p>";
                            }
                            if ($item['special_attribute']) {
                                $attrName = match($item['category']) {
                                    'currency' => '兑换比率',
                                    'gem' => '基础纯度',
                                    'ore' => '提炼比率',
                                    default => '特殊属性'
                                };
                                echo "<p>{$attrName}: {$item['special_attribute']}</p>";
                            }
                            if ($sources) {
                                echo "<p>获取途径: " . implode(', ', $sources) . "</p>";
                            }
                            echo "</div>";
                        }
                    } else {
                        // 查询装备模板
                        $sql = "SELECT 
                            t.equipment_name,
                            t.rarity,
                            t.base_value,
                            t.level_requirement,
                            t.base_durability,
                            t.base_attributes,
                            t.description,
                            t.is_legendary,
                            t.special_abilities,
                            t.lore,
                            et.type_name,
                            et.type_category,
                            et.equip_slot,
                            et.can_dual_wield
                        FROM equipment_templates t
                        JOIN equipment_types et ON t.type_id = et.type_id
                        WHERE " . ($type === 'legendary' ? 't.is_legendary = TRUE' : 't.is_legendary = FALSE') . "
                        ORDER BY t.rarity DESC, t.base_value DESC";
                        
                        $stmt = $pdo->query($sql);
                        while ($item = $stmt->fetch(PDO::FETCH_ASSOC)) {
                            $attributes = $item['base_attributes'] ? json_decode($item['base_attributes'], true) : null;
                            $abilities = $item['special_abilities'] ? json_decode($item['special_abilities'], true) : null;
                            
                            echo "<div class='item-card'>";
                            echo "<h3>{$item['equipment_name']}</h3>";
                            echo "<span class='rarity {$item['rarity']}'>{$item['rarity']}</span>";
                            if ($item['is_legendary']) {
                                echo "<p style='color: gold;'>✨ 传说装备</p>";
                            }
                            echo "<p>类型: {$item['type_name']} ({$item['type_category']})</p>";
                            echo "<p>装备位置: {$item['equip_slot']}</p>";
                            echo "<p>等级要求: {$item['level_requirement']}</p>";
                            echo "<p>基础价值: {$item['base_value']}</p>";
                            echo "<p>基础耐久: {$item['base_durability']}</p>";
                            
                            if ($item['can_dual_wield']) {
                                echo "<p>可双持</p>";
                            }
                            
                            if ($attributes) {
                                echo "<p>基础属性:<br>";
                                foreach ($attributes as $attr => $value) {
                                    echo "- {$attr}: {$value}<br>";
                                }
                                echo "</p>";
                            }
                            
                            if ($item['description']) {
                                echo "<p>描述: {$item['description']}</p>";
                            }
                            
                            if ($abilities) {
                                echo "<p>特殊能力:<br>";
                                foreach ($abilities as $ability) {
                                    echo "- {$ability}<br>";
                                }
                                echo "</p>";
                            }
                            
                            if ($item['lore']) {
                                echo "<p>传说背景: {$item['lore']}</p>";
                            }
                            
                            echo "</div>";
                        }
                    }
                } catch(PDOException $e) {
                    echo "<div class='error'>数据库错误: " . htmlspecialchars($e->getMessage()) . "</div>";
                }
                ?>
            </div>
        </div>
    </div>

    <script>
        const type = new URLSearchParams(window.location.search).get('type') || 'bulk';
        const descriptions = {
            'bulk': '大宗货品包括货币、矿石、宝石和材料等可堆叠物品。这些物品可以用于交易、制作和任务。',
            'equipment': '装备系统包含各种武器、防具、饰品和工具。每件装备都有独特的属性和强化等级。',
            'legendary': '传说装备是游戏中最稀有和强大的装备，拥有独特的觉醒和封印机制。'
        };

        // 更新页面标题和描述
        document.getElementById('subTitle').textContent = {
            'bulk': '大宗货品列表',
            'equipment': '装备列表',
            'legendary': '传说装备列表'
        }[type];
        document.getElementById('typeDescription').textContent = descriptions[type];
    </script>
</body>
</html> 