-- Venture模块查询脚本

-- 1. 查看所有冒险队伍及其状态
SELECT 
    team_name AS '队伍名称',
    team_leader AS '队长',
    team_size AS '队伍规模',
    team_level AS '等级',
    specialization AS '专精',
    current_status AS '当前状态',
    success_rate AS '成功率(%)',
    reputation_score AS '声望',
    total_missions AS '总任务数',
    successful_missions AS '成功任务',
    base_cost AS '基础费用',
    morale AS '士气',
    fatigue AS '疲劳度'
FROM adventure_teams
ORDER BY reputation_score DESC;

-- 2. 查看可投资的冒险项目
SELECT 
    project_name AS '项目名称',
    project_type AS '项目类型',
    difficulty AS '难度',
    required_specialization AS '需要专精',
    base_investment AS '基础投资',
    max_investment AS '最大投资',
    current_investment AS '当前投资',
    investment_goal AS '投资目标',
    (current_investment / investment_goal * 100) AS '进度(%)',
    expected_duration_hours AS '预计时长(小时)',
    risk_level AS '风险等级(%)',
    expected_return_rate AS '预期收益率(%)',
    status AS '项目状态',
    location AS '位置'
FROM adventure_projects
WHERE status IN ('funding', 'ready')
ORDER BY expected_return_rate DESC;

-- 3. 查看玩家的投资记录
SELECT 
    p.username AS '玩家',
    ap.project_name AS '项目名称',
    i.investment_amount AS '投资金额',
    i.investment_share AS '投资份额(%)',
    i.investment_type AS '投资类型',
    i.expected_return AS '预期收益',
    i.actual_return AS '实际收益',
    i.return_rate AS '收益率(%)',
    i.status AS '投资状态',
    i.investment_time AS '投资时间'
FROM investments i
JOIN players p ON i.player_id = p.player_id
JOIN adventure_projects ap ON i.project_id = ap.project_id
WHERE p.username = 'test_user' -- 替换为实际用户名
ORDER BY i.investment_time DESC;

-- 4. 查看冒险结果统计
SELECT 
    ap.project_name AS '项目名称',
    at.team_name AS '执行队伍',
    ar.outcome AS '结果',
    ar.success_rate AS '成功率(%)',
    ar.total_return AS '总收益',
    ar.casualties AS '伤亡',
    ar.equipment_damage AS '装备损坏(%)',
    ar.experience_gained AS '经验获得',
    ar.reputation_change AS '声望变化',
    ar.completion_time AS '完成时间',
    ar.duration_hours AS '实际用时(小时)'
FROM adventure_results ar
JOIN adventure_projects ap ON ar.project_id = ap.project_id
JOIN adventure_teams at ON ar.team_id = at.team_id
ORDER BY ar.completion_time DESC
LIMIT 20;

-- 5. 投资收益分析
SELECT 
    p.username AS '玩家',
    ap.project_name AS '项目',
    ir.return_type AS '收益类型',
    ir.return_amount AS '收益金额',
    ir.quantity AS '数量',
    c.commodity_name AS '商品名称',
    ir.bonus_applied AS '奖金(%)',
    ir.tax_deducted AS '税费',
    ir.net_return AS '净收益',
    ir.distribution_time AS '分配时间'
FROM investment_returns ir
JOIN investments i ON ir.investment_id = i.investment_id
JOIN players p ON i.player_id = p.player_id
JOIN adventure_projects ap ON i.project_id = ap.project_id
LEFT JOIN commodities c ON ir.commodity_id = c.commodity_id
ORDER BY ir.distribution_time DESC
LIMIT 50;

-- 6. 队伍装备统计
SELECT 
    at.team_name AS '队伍名称',
    te.equipment_type AS '装备类型',
    te.equipment_name AS '装备名称',
    te.equipment_level AS '装备等级',
    te.durability AS '耐久度(%)',
    te.enhancement_level AS '强化等级',
    te.purchase_cost AS '购买成本',
    te.maintenance_cost AS '维护成本',
    te.equipped_at AS '装备时间'
FROM team_equipment te
JOIN adventure_teams at ON te.team_id = at.team_id
WHERE te.is_active = TRUE
ORDER BY at.team_name, te.equipment_level DESC;

-- 7. 项目需求分析
SELECT 
    ap.project_name AS '项目名称',
    pr.requirement_type AS '需求类型',
    pr.requirement_value AS '需求值',
    pr.is_mandatory AS '是否必须',
    pr.priority AS '优先级',
    pr.description AS '描述'
FROM project_requirements pr
JOIN adventure_projects ap ON pr.project_id = ap.project_id
WHERE ap.status IN ('funding', 'ready')
ORDER BY ap.project_name, pr.priority;

-- 8. 队伍成功率统计
SELECT 
    team_name AS '队伍名称',
    specialization AS '专精',
    team_level AS '等级',
    total_missions AS '总任务',
    successful_missions AS '成功任务',
    ROUND(successful_missions * 100.0 / NULLIF(total_missions, 0), 2) AS '历史成功率(%)',
    success_rate AS '当前成功率(%)',
    reputation_score AS '声望',
    base_cost AS '基础费用',
    ROUND(reputation_score / base_cost, 2) AS '性价比'
FROM adventure_teams
WHERE total_missions > 0
ORDER BY (successful_missions * 100.0 / total_missions) DESC;

-- 9. 投资热门项目排行
SELECT 
    ap.project_name AS '项目名称',
    ap.project_type AS '项目类型',
    ap.difficulty AS '难度',
    COUNT(i.investment_id) AS '投资人数',
    SUM(i.investment_amount) AS '总投资额',
    ap.investment_goal AS '投资目标',
    ROUND(SUM(i.investment_amount) / ap.investment_goal * 100, 2) AS '完成度(%)',
    AVG(i.investment_amount) AS '平均投资额',
    ap.expected_return_rate AS '预期收益率(%)',
    ap.status AS '项目状态'
FROM adventure_projects ap
LEFT JOIN investments i ON ap.project_id = i.project_id
GROUP BY ap.project_id
ORDER BY COUNT(i.investment_id) DESC, SUM(i.investment_amount) DESC;

-- 10. 风险收益分析
SELECT 
    ap.project_name AS '项目名称',
    ap.difficulty AS '难度',
    ap.risk_level AS '风险等级(%)',
    ap.expected_return_rate AS '预期收益率(%)',
    CASE 
        WHEN ap.risk_level < 30 THEN '低风险'
        WHEN ap.risk_level < 60 THEN '中风险'
        WHEN ap.risk_level < 80 THEN '高风险'
        ELSE '极高风险'
    END AS '风险评级',
    ROUND(ap.expected_return_rate / ap.risk_level, 2) AS '风险调整收益比',
    ap.current_investment AS '当前投资',
    ap.investment_goal AS '投资目标',
    ap.status AS '项目状态'
FROM adventure_projects ap
WHERE ap.status IN ('funding', 'ready')
ORDER BY (ap.expected_return_rate / ap.risk_level) DESC; 