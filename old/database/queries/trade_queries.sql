-- Trade模块查询脚本

-- 1. 查看所有商品及其当前价格
SELECT 
    commodity_name AS '商品名称',
    commodity_symbol AS '符号',
    category AS '类别',
    rarity AS '稀有度',
    current_price AS '当前价格',
    price_change_24h AS '24h涨跌',
    volume_24h AS '24h成交量',
    market_cap AS '市值'
FROM commodities 
WHERE is_active = TRUE
ORDER BY market_cap DESC;

-- 2. 查看价格波动最大的商品
SELECT 
    c.commodity_name AS '商品名称',
    c.current_price AS '当前价格',
    c.price_change_24h AS '24h涨跌幅',
    c.volatility_index AS '波动指数',
    c.volume_24h AS '24h成交量'
FROM commodities c
WHERE c.is_active = TRUE
ORDER BY ABS(c.price_change_24h) DESC
LIMIT 10;

-- 3. 查看玩家的交易订单
SELECT 
    p.username AS '玩家',
    c.commodity_name AS '商品',
    t.order_type AS '类型',
    t.quantity AS '数量',
    t.price AS '价格',
    t.total_value AS '总值',
    t.status AS '状态',
    t.order_time AS '下单时间'
FROM trade_orders t
JOIN players p ON t.player_id = p.player_id
JOIN commodities c ON t.commodity_id = c.commodity_id
WHERE p.username = 'test_user' -- 替换为实际用户名
ORDER BY t.order_time DESC;

-- 4. 查看商品价格历史
SELECT 
    c.commodity_name AS '商品名称',
    ph.price AS '价格',
    ph.volume AS '成交量',
    ph.timestamp AS '时间',
    ph.price_source AS '价格来源'
FROM price_history ph
JOIN commodities c ON ph.commodity_id = c.commodity_id
WHERE c.commodity_symbol = 'DSG' -- 龙鳞金
ORDER BY ph.timestamp DESC
LIMIT 50;

-- 5. 市场趋势分析
SELECT 
    c.commodity_name AS '商品名称',
    mt.trend_type AS '趋势类型',
    mt.strength AS '强度',
    mt.duration_hours AS '持续时间(小时)',
    mt.start_price AS '起始价格',
    mt.end_price AS '结束价格',
    mt.market_sentiment AS '市场情绪',
    mt.start_time AS '开始时间'
FROM market_trends mt
JOIN commodities c ON mt.commodity_id = c.commodity_id
WHERE mt.is_active = TRUE
ORDER BY mt.strength DESC;

-- 6. 自动交易规则监控
SELECT 
    p.username AS '玩家',
    c.commodity_name AS '商品',
    atr.rule_name AS '规则名称',
    atr.rule_type AS '规则类型',
    atr.trigger_price AS '触发价格',
    atr.target_price AS '目标价格',
    atr.quantity AS '数量',
    atr.is_active AS '是否启用',
    atr.execution_count AS '执行次数',
    atr.last_executed AS '最后执行时间'
FROM auto_trading_rules atr
JOIN players p ON atr.player_id = p.player_id
JOIN commodities c ON atr.commodity_id = c.commodity_id
WHERE atr.is_active = TRUE
ORDER BY atr.trigger_price DESC;

-- 7. 交易手续费计算
SELECT 
    tf.fee_type AS '手续费类型',
    tf.player_level AS '玩家等级',
    tf.fee_rate AS '费率',
    tf.minimum_fee AS '最低费用',
    tf.maximum_fee AS '最高费用',
    c.commodity_name AS '商品名称'
FROM trading_fees tf
LEFT JOIN commodities c ON tf.commodity_id = c.commodity_id
WHERE tf.is_active = TRUE
ORDER BY tf.player_level, tf.fee_type;

-- 8. 玩家资产统计
SELECT 
    p.username AS '玩家',
    pa.asset_type AS '资产类型',
    pa.asset_name AS '资产名称',
    pa.quantity AS '数量',
    pa.average_cost AS '平均成本',
    CASE 
        WHEN pa.asset_type = 'commodity' THEN pa.quantity * c.current_price
        ELSE pa.quantity
    END AS '当前价值'
FROM player_assets pa
JOIN players p ON pa.player_id = p.player_id
LEFT JOIN commodities c ON pa.asset_name = c.commodity_name AND pa.asset_type = 'commodity'
WHERE p.username = 'test_user' -- 替换为实际用户名
ORDER BY pa.asset_type, pa.asset_name;

-- 9. 市场成交量排行
SELECT 
    c.commodity_name AS '商品名称',
    c.volume_24h AS '24h成交量',
    c.current_price AS '当前价格',
    c.market_cap AS '市值',
    COUNT(t.order_id) AS '订单数量'
FROM commodities c
LEFT JOIN trade_orders t ON c.commodity_id = t.commodity_id 
    AND t.order_time >= DATE_SUB(NOW(), INTERVAL 24 HOUR)
WHERE c.is_active = TRUE
GROUP BY c.commodity_id
ORDER BY c.volume_24h DESC
LIMIT 10;

-- 10. 价格预警监控
SELECT 
    c.commodity_name AS '商品名称',
    c.current_price AS '当前价格',
    c.price_change_24h AS '24h变化',
    CASE 
        WHEN c.price_change_24h > 20 THEN '急涨'
        WHEN c.price_change_24h < -20 THEN '急跌'
        WHEN c.price_change_24h > 10 THEN '上涨'
        WHEN c.price_change_24h < -10 THEN '下跌'
        ELSE '平稳'
    END AS '价格状态',
    c.volatility_index AS '波动指数'
FROM commodities c
WHERE c.is_active = TRUE
    AND (ABS(c.price_change_24h) > 10 OR c.volatility_index > 5)
ORDER BY ABS(c.price_change_24h) DESC; 