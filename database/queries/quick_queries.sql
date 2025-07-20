-- =============================================
-- 快速查询脚本
-- 包含各模块常用查询示例
-- =============================================

-- -----------------------------
-- 1. 玩家系统查询 (01_players)
-- -----------------------------

-- 查看所有可雇佣的角色及其主要属性
SELECT 
    character_name,
    character_class,
    rarity,
    hire_cost,
    CONCAT(trade_skill, '/', venture_skill, '/', leadership_skill) as '交易/冒险/领导',
    is_available
FROM players
WHERE is_available = TRUE
ORDER BY hire_cost DESC;

-- 查看角色的详细状态
SELECT 
    p.character_name,
    m.happiness as '心情',
    m.stress as '压力',
    m.fatigue as '疲劳',
    m.team_relationship as '团队关系'
FROM players p
JOIN player_mood m ON p.player_id = m.player_id
WHERE p.is_available = TRUE;

-- -----------------------------
-- 2. 物品系统查询 (02_item_module)
-- -----------------------------

-- 查看大宗货品总体统计
WITH commodity_totals AS (
    SELECT 
        c.commodity_id,
        c.commodity_name,
        c.category,
        c.rarity,
        c.base_value,
        SUM(COALESCE(h.quantity, 0)) as total_quantity,
        COUNT(DISTINCT h.player_id) as holder_count
    FROM bulk_commodities c
    LEFT JOIN bulk_commodity_holdings h ON c.commodity_id = h.commodity_id
    GROUP BY c.commodity_id, c.commodity_name, c.category, c.rarity, c.base_value
)
SELECT 
    commodity_name as '物品名',
    category as '类别',
    rarity as '稀有度',
    total_quantity as '总数量',
    base_value as '单价',
    (total_quantity * base_value) as '总价值',
    holder_count as '持有人数'
FROM commodity_totals
ORDER BY base_value DESC;

-- 查看装备实例及其属性
SELECT 
    t.equipment_name as '装备名称',
    et.type_name as '装备类型',
    t.rarity as '稀有度',
    i.durability as '当前耐久',
    t.base_durability as '最大耐久',
    p.character_name as '所有者',
    i.creation_type as '获得方式',
    CASE 
        WHEN t.is_legendary = TRUE THEN '是'
        ELSE '否'
    END as '是否传说',
    i.enhancement_level as '强化等级',
    i.attributes as '当前属性',
    i.power_level as '力量等级'
FROM equipment_templates t
JOIN equipment_types et ON t.type_id = et.type_id
JOIN equipment_instances i ON t.template_id = i.template_id
LEFT JOIN players p ON i.current_owner_id = p.player_id
ORDER BY t.rarity DESC, t.base_value DESC;

-- 查看装备强化统计
SELECT 
    t.rarity as '稀有度',
    COUNT(DISTINCT i.instance_id) as '装备总数',
    AVG(i.enhancement_level) as '平均强化等级',
    SUM(CASE WHEN i.enhancement_level > 0 THEN 1 ELSE 0 END) as '已强化装备数',
    MAX(i.enhancement_level) as '最高强化等级'
FROM equipment_templates t
JOIN equipment_instances i ON t.template_id = i.template_id
GROUP BY t.rarity
ORDER BY FIELD(t.rarity, 'legendary', 'epic', 'rare', 'uncommon', 'common');

-- 查看装备历史记录
SELECT 
    t.equipment_name as '装备名称',
    h.event_type as '事件类型',
    p_from.character_name as '原所有者',
    p_to.character_name as '新所有者',
    h.event_time as '事件时间',
    h.details as '详细信息'
FROM equipment_templates t
JOIN equipment_instances i ON t.template_id = i.template_id
JOIN equipment_history h ON i.instance_id = h.instance_id
LEFT JOIN players p_from ON h.from_owner_id = p_from.player_id
LEFT JOIN players p_to ON h.to_owner_id = p_to.player_id
ORDER BY h.event_time DESC
LIMIT 10;

-- 查看大宗货品持有明细
SELECT 
    c.commodity_name as '物品名',
    c.category as '类别',
    p.character_name as '持有者',
    h.quantity as '持有数量',
    c.base_value as '单价',
    (h.quantity * c.base_value) as '持有总值'
FROM bulk_commodities c
JOIN bulk_commodity_holdings h ON c.commodity_id = h.commodity_id
JOIN players p ON h.player_id = p.player_id
ORDER BY c.base_value DESC, h.quantity DESC;

-- 按类别统计大宗货品
SELECT 
    c.category as '类别',
    COUNT(DISTINCT c.commodity_id) as '物品种类数',
    SUM(COALESCE(h.quantity, 0)) as '总数量',
    SUM(COALESCE(h.quantity, 0) * c.base_value) as '类别总值'
FROM bulk_commodities c
LEFT JOIN bulk_commodity_holdings h ON c.commodity_id = h.commodity_id
GROUP BY c.category
HAVING SUM(COALESCE(h.quantity, 0)) > 0
ORDER BY SUM(COALESCE(h.quantity, 0) * c.base_value) DESC;

-- 按稀有度统计大宗货品
SELECT 
    c.rarity as '稀有度',
    COUNT(DISTINCT c.commodity_id) as '物品种类数',
    SUM(COALESCE(h.quantity, 0)) as '总数量',
    SUM(COALESCE(h.quantity, 0) * c.base_value) as '稀有度总值'
FROM bulk_commodities c
LEFT JOIN bulk_commodity_holdings h ON c.commodity_id = h.commodity_id
GROUP BY c.rarity
HAVING SUM(COALESCE(h.quantity, 0)) > 0
ORDER BY FIELD(c.rarity, 'legendary', 'epic', 'rare', 'uncommon', 'common');

-- -----------------------------
-- 3. 交易系统查询 (03_trade_module)
-- -----------------------------

-- 查看最近的交易订单
SELECT 
    p.character_name as '交易者',
    CASE t.item_type
        WHEN 'bulk_commodity' THEN bc.commodity_name
        WHEN 'equipment' THEN et.equipment_name
    END as '物品名称',
    t.order_type as '交易类型',
    t.quantity as '数量',
    t.price as '单价',
    t.total_value as '总价值',
    t.status as '状态',
    t.order_time as '下单时间'
FROM trade_orders t
LEFT JOIN players p ON t.player_id = p.player_id
LEFT JOIN bulk_commodities bc ON t.item_type = 'bulk_commodity' AND t.item_id = bc.commodity_id
LEFT JOIN equipment_templates et ON t.item_type = 'equipment' AND t.item_id = et.template_id
ORDER BY t.order_time DESC
LIMIT 10;

-- 查看当前市场趋势
SELECT 
    CASE mt.item_type
        WHEN 'bulk_commodity' THEN bc.commodity_name
        WHEN 'equipment' THEN et.equipment_name
    END as '物品名称',
    mt.trend_type as '趋势类型',
    mt.strength as '强度',
    mt.market_sentiment as '市场情绪',
    mt.current_price as '当前价格',
    mt.price_change_percent as '价格变化(%)',
    mt.trend_status as '趋势状态',
    mt.start_time as '开始时间'
FROM market_trends mt
LEFT JOIN bulk_commodities bc ON mt.item_type = 'bulk_commodity' AND mt.item_id = bc.commodity_id
LEFT JOIN equipment_templates et ON mt.item_type = 'equipment' AND mt.item_id = et.template_id
WHERE mt.is_active = TRUE
ORDER BY mt.strength DESC;

-- 查看价格波动最大的商品
SELECT 
    c.commodity_name as '商品名称',
    c.category as '类别',
    h.avg_price as '当前均价',
    c.price_change_24h as '24小时变化(%)',
    c.volume_24h as '24小时成交量',
    h.turnover as '成交额',
    h.timestamp as '更新时间'
FROM bulk_commodities c
JOIN bulk_commodity_price_history h ON c.commodity_id = h.commodity_id
WHERE h.timestamp >= DATE_SUB(NOW(), INTERVAL 24 HOUR)
ORDER BY ABS(c.price_change_24h) DESC
LIMIT 10;

-- 查看手续费规则
SELECT 
    fee_name as '规则名称',
    fee_type as '交易类型',
    base_rate * 100 as '基础费率(%)',
    min_fee as '最低费用',
    max_fee as '最高费用',
    CASE item_type
        WHEN 'all' THEN '所有商品'
        WHEN 'bulk_commodity' THEN '大宗商品'
        WHEN 'equipment' THEN '装备'
    END as '适用类型',
    priority as '优先级',
    is_active as '是否生效'
FROM trading_fees
WHERE is_active = TRUE
ORDER BY priority DESC;

-- 查看玩家交易统计
SELECT 
    p.character_name as '玩家名称',
    COUNT(t.order_id) as '总交易次数',
    SUM(CASE WHEN t.order_type = 'buy' THEN 1 ELSE 0 END) as '买入次数',
    SUM(CASE WHEN t.order_type = 'sell' THEN 1 ELSE 0 END) as '卖出次数',
    SUM(t.total_value) as '交易总额',
    SUM(t.actual_fees) as '总手续费',
    AVG(t.actual_fees / t.total_value) * 100 as '平均费率(%)'
FROM players p
LEFT JOIN trade_orders t ON p.player_id = t.player_id
WHERE t.status = 'filled'
GROUP BY p.player_id, p.character_name
ORDER BY SUM(t.total_value) DESC
LIMIT 10;

-- 查看自动交易规则状态
SELECT 
    p.character_name as '玩家名称',
    r.rule_name as '规则名称',
    r.rule_type as '规则类型',
    CASE r.item_type
        WHEN 'bulk_commodity' THEN bc.commodity_name
        WHEN 'equipment' THEN et.equipment_name
    END as '目标物品',
    r.trigger_condition as '触发条件',
    r.trigger_value as '触发值',
    r.execution_count as '已执行次数',
    r.is_active as '是否激活'
FROM auto_trading_rules r
JOIN players p ON r.player_id = p.player_id
LEFT JOIN bulk_commodities bc ON r.item_type = 'bulk_commodity' AND r.item_id = bc.commodity_id
LEFT JOIN equipment_templates et ON r.item_type = 'equipment' AND r.item_id = et.template_id
WHERE r.is_active = TRUE
ORDER BY r.execution_count DESC;

-- 查看成交记录
SELECT 
    e.execution_time as '成交时间',
    bp.character_name as '买方',
    sp.character_name as '卖方',
    e.executed_price as '成交价',
    e.executed_quantity as '成交数量',
    e.execution_value as '成交金额',
    e.buyer_fee as '买方手续费',
    e.seller_fee as '卖方手续费',
    e.market_price as '市场价',
    e.price_impact as '价格影响'
FROM trade_executions e
JOIN players bp ON e.buyer_id = bp.player_id
JOIN players sp ON e.seller_id = sp.player_id
ORDER BY e.execution_time DESC
LIMIT 10;

-- -----------------------------
-- 4. 冒险系统查询 (04_venture_module)
-- -----------------------------

-- 查看冒险队伍状态
SELECT 
    t.team_name as '队伍名称',
    t.team_leader as '队长',
    t.specialization as '专精',
    t.success_rate as '成功率',
    t.current_status as '当前状态',
    t.morale as '士气'
FROM adventure_teams t;

-- 查看可投资的冒险项目
SELECT 
    project_name as '项目名称',
    difficulty as '难度',
    required_team_size as '需求人数',
    CONCAT(risk_level*100, '%') as '风险等级',
    CONCAT(expected_return_rate, '%') as '预期收益',
    status as '状态'
FROM adventure_projects
WHERE status = 'funding';

-- -----------------------------
-- 5. 交互系统查询 (05_interaction_system)
-- -----------------------------

-- 查看活跃的市场事件
SELECT 
    event_name as '事件名称',
    event_type as '类型',
    impact_magnitude as '影响程度',
    start_time as '开始时间',
    status as '状态'
FROM market_events
WHERE status = 'active';

-- 查看生态系统状态
SELECT 
    c.commodity_name as '资源名称',
    e.ecosystem_health as '生态健康度',
    e.exploitation_level as '开发程度',
    e.status as '状态'
FROM ecosystem_balance e
JOIN bulk_commodities c ON e.commodity_id = c.commodity_id
WHERE e.ecosystem_health < 90;

-- 查看经济周期状态
SELECT 
    cycle_name as '周期名称',
    cycle_type as '类型',
    current_phase as '当前阶段',
    market_multiplier as '市场乘数',
    progress_percent as '进度'
FROM economic_cycles
WHERE is_active = TRUE; 