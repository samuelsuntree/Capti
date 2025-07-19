-- =============================================
-- 快速查询示例
-- 基于最新的数据库结构
-- =============================================

-- 使用数据库
USE game_trade;

-- ========== 基本查询示例 ==========

-- 1. 查看所有表
SHOW TABLES;

-- 2. 查看数据库状态
SELECT 
    '数据库创建成功！' AS '状态',
    COUNT(*) AS '表数量'
FROM information_schema.TABLES 
WHERE TABLE_SCHEMA = 'game_trade';

-- ========== 角色系统查询 ==========

-- 3. 查看所有雇佣角色
SELECT 
    player_id,
    character_name,
    display_name,
    character_class,
    rarity,
    current_level,
    hire_cost,
    maintenance_cost,
    is_available
FROM players
ORDER BY rarity DESC, hire_cost DESC;

-- 4. 查看角色详细属性
SELECT 
    character_name,
    display_name,
    rarity,
    -- 基础属性
    strength, vitality, agility, intelligence, faith, luck,
    -- 精神属性
    loyalty, courage, patience, greed, wisdom, charisma,
    -- 技能
    trade_skill, venture_skill, negotiation_skill, analysis_skill, leadership_skill
FROM players
ORDER BY rarity DESC;

-- 5. 查看角色情绪状态
SELECT 
    p.character_name,
    p.rarity,
    m.happiness,
    m.stress,
    m.motivation,
    m.confidence,
    m.fatigue,
    m.focus,
    m.team_relationship,
    m.reputation
FROM players p
LEFT JOIN player_mood m ON p.player_id = m.player_id
ORDER BY m.happiness DESC;

-- ========== 个性特质查询 ==========

-- 6. 查看所有个性特质
SELECT 
    trait_name,
    trait_category,
    description,
    trade_modifier,
    venture_modifier,
    loyalty_modifier,
    stress_modifier,
    rarity
FROM personality_traits
ORDER BY trait_category, rarity DESC;

-- 7. 查看角色的个性特质（JSON解析）
SELECT 
    p.character_name,
    p.personality_traits,
    JSON_LENGTH(p.personality_traits) as '特质数量'
FROM players p
WHERE p.personality_traits IS NOT NULL
ORDER BY p.character_name;

-- ========== 资产查询 ==========

-- 8. 查看角色资产
SELECT 
    p.character_name,
    a.asset_type,
    a.asset_name,
    a.quantity,
    a.equipment_quality
FROM players p
LEFT JOIN player_assets a ON p.player_id = a.player_id
ORDER BY p.character_name, a.asset_type;

-- ========== 交易系统查询 ==========

-- 9. 查看所有商品
SELECT 
    commodity_name,
    commodity_symbol,
    category,
    rarity,
    base_price,
    current_price,
    ROUND((current_price - base_price) / base_price * 100, 2) AS '价格变化%',
    market_cap,
    volatility_index,
    is_active
FROM commodities
WHERE is_active = TRUE
ORDER BY current_price DESC;

-- 10. 查看活跃的交易订单
SELECT 
    p.character_name,
    c.commodity_name,
    t.order_type,
    t.quantity,
    t.price,
    t.status,
    t.order_time
FROM trade_orders t
JOIN players p ON t.player_id = p.player_id
JOIN commodities c ON t.commodity_id = c.commodity_id
WHERE t.status IN ('pending', 'partial')
ORDER BY t.order_time DESC;

-- ========== 冒险系统查询 ==========

-- 11. 查看所有冒险队伍
SELECT 
    team_name,
    team_leader,
    team_size,
    specialization,
    success_rate,
    base_cost,
    team_level,
    current_status,
    morale
FROM adventure_teams
ORDER BY success_rate DESC;

-- 12. 查看队伍成员
SELECT 
    t.team_name,
    p.character_name,
    p.character_class,
    m.role,
    m.contribution_score,
    m.joined_at
FROM adventure_teams t
JOIN team_members m ON t.team_id = m.team_id
JOIN players p ON m.player_id = p.player_id
ORDER BY t.team_name, m.role DESC;

-- 13. 查看冒险项目
SELECT 
    project_name,
    project_type,
    difficulty,
    required_team_size,
    base_investment,
    max_investment,
    expected_return_rate,
    risk_level,
    status
FROM adventure_projects
ORDER BY difficulty DESC, expected_return_rate DESC;

-- ========== 筛选查询示例 ==========

-- 14. 筛选高级角色（传奇和史诗）
SELECT 
    character_name,
    character_class,
    rarity,
    hire_cost,
    maintenance_cost
FROM players
WHERE rarity IN ('legendary', 'epic')
ORDER BY hire_cost DESC;

-- 15. 筛选特定技能强的角色
SELECT 
    character_name,
    character_class,
    trade_skill,
    venture_skill,
    negotiation_skill
FROM players
WHERE trade_skill >= 80 OR venture_skill >= 80
ORDER BY trade_skill DESC;

-- 16. 筛选有特定特质的角色
SELECT 
    character_name,
    personality_traits
FROM players
WHERE JSON_CONTAINS(personality_traits, '"贪婪"') 
   OR JSON_CONTAINS(personality_traits, '"勇敢"')
   OR JSON_CONTAINS(personality_traits, '"智慧"')
ORDER BY character_name;

-- ========== 复合查询示例 ==========

-- 17. 查看角色综合评分
SELECT 
    character_name,
    character_class,
    rarity,
    (strength + vitality + agility + intelligence + faith + luck) AS '属性总和',
    (trade_skill + venture_skill + negotiation_skill + analysis_skill + leadership_skill) AS '技能总和',
    current_level,
    hire_cost
FROM players
ORDER BY (strength + vitality + agility + intelligence + faith + luck) DESC;

-- 18. 查看最适合交易的角色
SELECT 
    character_name,
    character_class,
    trade_skill,
    negotiation_skill,
    analysis_skill,
    (trade_skill + negotiation_skill + analysis_skill) AS '交易总分',
    hire_cost
FROM players
WHERE trade_skill >= 70
ORDER BY (trade_skill + negotiation_skill + analysis_skill) DESC;

-- 19. 查看最适合冒险的角色
SELECT 
    character_name,
    character_class,
    venture_skill,
    leadership_skill,
    (strength + vitality + agility) AS '战斗属性',
    (venture_skill + leadership_skill) AS '冒险总分'
FROM players
WHERE venture_skill >= 70
ORDER BY (venture_skill + leadership_skill) DESC;

-- 20. 查看队伍配置分析
SELECT 
    t.team_name,
    t.specialization,
    COUNT(m.player_id) as '当前成员数',
    t.team_size as '目标规模',
    ROUND(AVG(p.current_level), 1) as '平均等级',
    GROUP_CONCAT(p.character_name ORDER BY m.role DESC) as '成员列表'
FROM adventure_teams t
LEFT JOIN team_members m ON t.team_id = m.team_id
LEFT JOIN players p ON m.player_id = p.player_id
GROUP BY t.team_id
ORDER BY t.team_name;

-- ========== 说明 ==========
-- 使用方法：
-- 1. 选择要执行的查询语句
-- 2. 在MySQL客户端中执行
-- 3. 查看结果 