-- =============================================
-- 添加新角色脚本 - 完整版
-- =============================================

USE game_trade;

-- 1. 插入新角色基础信息（跳过已存在的角色）
INSERT INTO players (
    character_code, character_name, display_name, character_class, rarity,
    hire_cost, maintenance_cost,
    strength, vitality, agility, intelligence, faith, luck,
    loyalty, courage, patience, greed, wisdom, charisma,
    trade_skill, venture_skill, negotiation_skill, analysis_skill, leadership_skill,
    total_experience, current_level, skill_points,
    personality_traits, is_available,
    avatar_url
) 
SELECT * FROM (
    SELECT 
    'KANE_WARRIOR_001' as character_code, 
    '影刃刺客·凯恩' as character_name, 
    '凯恩' as display_name, 
    'warrior' as character_class, 
    'epic' as rarity, 
    30000 as hire_cost, 
    600 as maintenance_cost,
    16 as strength, 
    14 as vitality, 
    20 as agility, 
    15 as intelligence, 
    12 as faith, 
    18 as luck,
    75 as loyalty, 
    85 as courage, 
    70 as patience, 
    40 as greed, 
    65 as wisdom, 
    60 as charisma,
    45 as trade_skill, 
    90 as venture_skill, 
    55 as negotiation_skill, 
    70 as analysis_skill, 
    75 as leadership_skill,
    10000 as total_experience, 
    12 as current_level, 
    4 as skill_points,
    JSON_ARRAY('冷静', '独行侠', '直觉敏锐') as personality_traits, 
    TRUE as is_available,
    '/assets/avatars/kane.png' as avatar_url

    UNION ALL

    SELECT 
    'ALICE_MYSTIC_001', 
    '圣光牧师·艾莉丝', 
    '艾莉丝', 
    'mystic', 
    'rare', 
    18000, 
    400,
    12, 16, 14, 18, 20, 14, 
    90, 80, 85, 20, 85, 80,
    60, 65, 85, 75, 70, 
    6000, 8, 2,
    JSON_ARRAY('乐观', '坚韧', '学习能力强'), 
    TRUE,
    '/assets/avatars/alice.png'

    UNION ALL

    SELECT 
    'GROM_WARRIOR_001', 
    '狂战士·格罗姆', 
    '格罗姆', 
    'warrior', 
    'rare', 
    20000, 
    450,
    20, 18, 12, 10, 14, 16, 
    60, 95, 40, 50, 45, 55,
    30, 85, 40, 35, 65, 
    7500, 9, 3,
    JSON_ARRAY('冲动', '勇敢', '坚韧'), 
    TRUE,
    '/assets/avatars/grom.png'

    UNION ALL

    SELECT 
    'SILAS_SCHOLAR_001', 
    '学者·塞拉斯', 
    '塞拉斯', 
    'scholar', 
    'epic', 
    25000, 
    500,
    10, 12, 14, 20, 16, 15, 
    80, 50, 90, 35, 95, 75,
    85, 55, 80, 95, 60, 
    9000, 11, 3,
    JSON_ARRAY('专注', '完美主义', '学习能力强'), 
    TRUE,
    '/assets/avatars/silas.png'

    UNION ALL

    SELECT 
    'VERA_SURVIVOR_001', 
    '盗贼·薇拉', 
    '薇拉', 
    'survivor', 
    'uncommon', 
    12000, 
    300,
    14, 12, 18, 16, 10, 20, 
    65, 70, 55, 75, 60, 65,
    80, 75, 85, 70, 45, 
    4000, 6, 1,
    JSON_ARRAY('贪婪', '直觉敏锐', '独行侠'), 
    TRUE,
    '/assets/avatars/vera.png'

    UNION ALL

    SELECT 
    'OLAF_SURVIVOR_001', 
    '驯兽师·奥拉夫', 
    '奥拉夫', 
    'survivor', 
    'rare', 
    16000, 
    350,
    15, 16, 16, 14, 12, 18, 
    70, 75, 80, 45, 70, 70,
    50, 80, 60, 65, 80, 
    5500, 7, 2,
    JSON_ARRAY('坚韧', '领袖气质', '勤奋'), 
    TRUE,
    '/assets/avatars/olaf.png'

    UNION ALL

    SELECT 
    'IGNIS_MYSTIC_001', 
    '火法师·伊格尼斯', 
    '伊格尼斯', 
    'mystic', 
    'epic', 
    28000, 
    550,
    12, 14, 16, 20, 18, 14, 
    75, 80, 60, 40, 80, 70,
    65, 70, 70, 85, 65, 
    8500, 10, 3,
    JSON_ARRAY('冲动', '专注', '学习能力强'), 
    TRUE,
    '/assets/avatars/ignis.png'

    UNION ALL

    SELECT 
    'MARCUS_ARCHER_001', 
    '神射手·马库斯', 
    '马库斯', 
    'archer', 
    'uncommon', 
    15000, 
    350,
    14, 13, 18, 15, 13, 16,      -- 调整属性，提高敏捷
    70, 75, 70, 50, 65, 70,      -- 调整个性，减少贪婪倾向
    60, 75, 65, 70, 55,          -- 调整技能，增加战斗相关能力
    5000, 7, 2,
    JSON_ARRAY('专注', '直觉敏锐', '冷静'), 
    TRUE,
    '/assets/avatars/marcus.png'

    UNION ALL

    SELECT 
    'ARTEMIS_ARCHER_001', 
    '游侠射手·阿尔忒弥斯', 
    '阿尔忒弥斯', 
    'archer', 
    'rare', 
    19000, 
    400,
    16, 15, 18, 15, 14, 17, 
    75, 80, 70, 35, 75, 65,
    55, 85, 65, 75, 70, 
    6500, 8, 2,
    JSON_ARRAY('冷静', '独行侠', '专注'), 
    TRUE,
    '/assets/avatars/artemis.png'

    UNION ALL

    SELECT 
    'LUNA_MYSTIC_001', 
    '新手法师·露娜', 
    '露娜', 
    'mystic', 
    'common', 
    8000, 
    200,
    10, 11, 13, 16, 15, 12, 
    70, 55, 65, 45, 60, 60,
    40, 50, 55, 65, 45, 
    2000, 4, 1,
    JSON_ARRAY('学习能力强', '焦虑'), 
    TRUE,
    '/assets/avatars/luna.png'
) AS new_players (
    character_code, character_name, display_name, character_class, rarity,
    hire_cost, maintenance_cost,
    strength, vitality, agility, intelligence, faith, luck,
    loyalty, courage, patience, greed, wisdom, charisma,
    trade_skill, venture_skill, negotiation_skill, analysis_skill, leadership_skill,
    total_experience, current_level, skill_points,
    personality_traits, is_available,
    avatar_url
)
WHERE character_code NOT IN (SELECT character_code FROM players);

-- 2. 创建冒险队伍（如果不存在）
INSERT INTO adventure_teams (
    team_name, team_leader, team_size, specialization,
    team_level, experience_points, success_rate,
    current_status, base_cost, reputation_score,
    team_description, avatar_url
)
SELECT * FROM (
    SELECT 
    '暗影猎手小队' as team_name, '凯恩' as team_leader, 3 as team_size, 'combat' as specialization,
    10, 8000, 75.50, 'available', 5000, 800,
    '由凯恩领导的精锐战斗小队，专精于高风险任务。擅长突袭和精确打击，有着出色的团队配合。',
    '/assets/teams/shadow_hunters.png'
    UNION ALL
    SELECT 
    '圣光守护者', '艾莉丝', 4, 'magic', 8, 6000, 82.00, 'available', 4000, 650,
    '艾莉丝带领的魔法团队，专注于探索和支援。团队成员各有所长，配合默契。',
    '/assets/teams/light_guardians.png'
) AS new_teams
WHERE team_name NOT IN (SELECT team_name FROM adventure_teams);

-- 3. 为新角色添加情绪状态
INSERT INTO player_mood (player_id, happiness, stress, motivation, confidence)
SELECT 
    p.player_id,
    CASE p.rarity 
        WHEN 'legendary' THEN 80 WHEN 'epic' THEN 75
        WHEN 'rare' THEN 70 WHEN 'uncommon' THEN 65
        ELSE 60 
    END,
    CASE p.rarity 
        WHEN 'legendary' THEN 15 WHEN 'epic' THEN 20
        WHEN 'rare' THEN 25 WHEN 'uncommon' THEN 30
        ELSE 35 
    END,
    70,
    65
FROM players p 
WHERE p.player_id NOT IN (SELECT player_id FROM player_mood);

-- 4. 关联角色和特质（使用已有特质）
INSERT INTO player_traits (player_id, trait_id, trait_intensity)
SELECT DISTINCT p.player_id, t.trait_id, 
    CASE 
        WHEN p.rarity = 'epic' THEN 2.0
        WHEN p.rarity = 'rare' THEN 1.5
        ELSE 1.0
    END as trait_intensity
FROM players p 
CROSS JOIN personality_traits t
WHERE p.character_code IN ('KANE_WARRIOR_001', 'ALICE_MYSTIC_001')
AND t.trait_name IN (
    SELECT JSON_UNQUOTE(trait) 
    FROM players p2,
    JSON_TABLE(p2.personality_traits, '$[*]' COLUMNS (trait VARCHAR(50) PATH '$')) traits
    WHERE p2.player_id = p.player_id
)
AND NOT EXISTS (
    SELECT 1 
    FROM player_traits pt 
    WHERE pt.player_id = p.player_id 
    AND pt.trait_id = t.trait_id
);

-- 5. 创建基础装备类型
INSERT INTO equipment_types (
    type_name, type_category, equip_slot, can_dual_wield, description
) VALUES 
('sword', 'weapon', 'main_hand', TRUE, '剑类武器，适合近战战斗'),
('staff', 'weapon', 'main_hand', FALSE, '法杖类武器，增强魔法能力'),
('armor', 'armor', 'body', FALSE, '护甲，提供基础防护'),
('accessory', 'accessory', 'neck', FALSE, '饰品，提供特殊加成效果'),
('axe', 'weapon', 'main_hand', TRUE, '斧类武器，适合强力劈砍'),
('robe', 'armor', 'body', FALSE, '法师长袍，增强魔法能力'),
('dagger', 'weapon', 'main_hand', TRUE, '匕首，适合敏捷作战'),
('bow', 'weapon', 'main_hand', FALSE, '弓箭，适合远程攻击'),
('book', 'weapon', 'main_hand', FALSE, '魔法书，增强法术效果'),
('light_armor', 'armor', 'body', FALSE, '轻甲，提供灵活防护');

-- 6. 创建装备模板
INSERT INTO equipment_templates (
    equipment_name, type_id, rarity,
    base_durability, level_requirement,
    base_attributes, possible_affixes,
    description, gem_slots,
    is_craftable, base_value, current_value,
    is_tradeable, is_active
) VALUES 
-- 已有的四件装备
('精钢长剑', (SELECT type_id FROM equipment_types WHERE type_name = 'sword'), 'epic',
 100, 10,
 JSON_OBJECT('damage', 50, 'critical_rate', 10),
 JSON_ARRAY('锋利的', '坚固的', '迅捷的'),
 '精心打造的长剑，锋利无比',
 2, TRUE, 3000, 3000, TRUE, TRUE),

('秘法法杖', (SELECT type_id FROM equipment_types WHERE type_name = 'staff'), 'rare',
 80, 8,
 JSON_OBJECT('magic_damage', 45, 'mana_regen', 5),
 JSON_ARRAY('智慧的', '魔力充沛的'),
 '蕴含强大魔力的法杖',
 2, TRUE, 2000, 2000, TRUE, TRUE),

-- 防具
('战术护甲', (SELECT type_id FROM equipment_types WHERE type_name = 'armor'), 'epic',
 120, 10,
 JSON_OBJECT('defense', 40, 'health', 100),
 JSON_ARRAY('坚固的', '守护的'),
 '提供优秀防护的战术护甲',
 1, TRUE, 2500, 2500, TRUE, TRUE),

('魔法护符', (SELECT type_id FROM equipment_types WHERE type_name = 'accessory'), 'rare',
 60, 8,
 JSON_OBJECT('magic_defense', 30, 'spell_power', 20),
 JSON_ARRAY('魔力的', '防护的'),
 '增强魔法能力的护符',
 1, TRUE, 1500, 1500, TRUE, TRUE),

-- 新增装备
('狂战斧', (SELECT type_id FROM equipment_types WHERE type_name = 'axe'), 'rare',
 90, 9,
 JSON_OBJECT('damage', 55, 'strength', 15),
 JSON_ARRAY('狂暴的', '沉重的', '坚韧的'),
 '沉重的战斧，蕴含狂暴之力',
 1, TRUE, 2000, 2000, TRUE, TRUE),

('战士胸甲', (SELECT type_id FROM equipment_types WHERE type_name = 'armor'), 'rare',
 100, 9,
 JSON_OBJECT('defense', 35, 'strength', 10),
 JSON_ARRAY('坚固的', '厚重的'),
 '坚固的战士胸甲，提供可靠防护',
 1, TRUE, 1800, 1800, TRUE, TRUE),

('学者长袍', (SELECT type_id FROM equipment_types WHERE type_name = 'robe'), 'epic',
 70, 11,
 JSON_OBJECT('magic_defense', 35, 'intelligence', 20),
 JSON_ARRAY('智慧的', '专注的'),
 '蕴含智慧之力的长袍',
 2, TRUE, 2500, 2500, TRUE, TRUE),

('知识宝典', (SELECT type_id FROM equipment_types WHERE type_name = 'book'), 'epic',
 60, 11,
 JSON_OBJECT('spell_power', 45, 'wisdom', 15),
 JSON_ARRAY('博学的', '睿智的'),
 '记载着古老知识的宝典',
 2, TRUE, 2800, 2800, TRUE, TRUE),

('影刃匕首', (SELECT type_id FROM equipment_types WHERE type_name = 'dagger'), 'uncommon',
 70, 6,
 JSON_OBJECT('damage', 30, 'agility', 15),
 JSON_ARRAY('敏捷的', '锋利的'),
 '轻巧的匕首，适合隐秘行动',
 1, TRUE, 1200, 1200, TRUE, TRUE),

('轻型皮甲', (SELECT type_id FROM equipment_types WHERE type_name = 'light_armor'), 'uncommon',
 80, 6,
 JSON_OBJECT('defense', 25, 'agility', 10),
 JSON_ARRAY('灵活的', '轻盈的'),
 '轻便的皮甲，不影响行动',
 1, TRUE, 1000, 1000, TRUE, TRUE),

('驯兽长弓', (SELECT type_id FROM equipment_types WHERE type_name = 'bow'), 'rare',
 85, 7,
 JSON_OBJECT('damage', 40, 'accuracy', 15),
 JSON_ARRAY('精准的', '迅捷的'),
 '可靠的长弓，便于远程狩猎',
 1, TRUE, 1800, 1800, TRUE, TRUE),

('守护护符', (SELECT type_id FROM equipment_types WHERE type_name = 'accessory'), 'rare',
 50, 7,
 JSON_OBJECT('defense', 20, 'vitality', 15),
 JSON_ARRAY('守护的', '活力的'),
 '增强生存能力的护符',
 1, TRUE, 1500, 1500, TRUE, TRUE),

('火焰法杖', (SELECT type_id FROM equipment_types WHERE type_name = 'staff'), 'epic',
 75, 10,
 JSON_OBJECT('fire_damage', 50, 'spell_power', 25),
 JSON_ARRAY('炽热的', '魔力的'),
 '蕴含火焰之力的法杖',
 2, TRUE, 2800, 2800, TRUE, TRUE),

('法师长袍', (SELECT type_id FROM equipment_types WHERE type_name = 'robe'), 'epic',
 70, 10,
 JSON_OBJECT('magic_defense', 30, 'mana', 100),
 JSON_ARRAY('魔力的', '智慧的'),
 '增强法力的长袍',
 1, TRUE, 2500, 2500, TRUE, TRUE),

('商人账册', (SELECT type_id FROM equipment_types WHERE type_name = 'book'), 'uncommon',
 50, 7,
 JSON_OBJECT('charisma', 20, 'luck', 15),
 JSON_ARRAY('幸运的', '交际的'),
 '记载交易秘诀的账册',
 1, TRUE, 1200, 1200, TRUE, TRUE),

('幸运护符', (SELECT type_id FROM equipment_types WHERE type_name = 'accessory'), 'uncommon',
 40, 7,
 JSON_OBJECT('luck', 25, 'charisma', 10),
 JSON_ARRAY('幸运的', '魅力的'),
 '带来好运的护符',
 1, TRUE, 1000, 1000, TRUE, TRUE),

('见习法杖', (SELECT type_id FROM equipment_types WHERE type_name = 'staff'), 'common',
 60, 4,
 JSON_OBJECT('magic_damage', 25, 'mana', 50),
 JSON_ARRAY('初学的', '基础的'),
 '适合初学者的法杖',
 1, TRUE, 800, 800, TRUE, TRUE),

('学徒长袍', (SELECT type_id FROM equipment_types WHERE type_name = 'robe'), 'common',
 50, 4,
 JSON_OBJECT('magic_defense', 20, 'mana', 40),
 JSON_ARRAY('学习的', '基础的'),
 '适合学徒的长袍',
 1, TRUE, 600, 600, TRUE, TRUE);

-- 7. 创建装备实例并分配给角色
INSERT INTO equipment_instances (
    template_id, current_owner_id,
    durability, current_value,
    attributes, creation_type,
    creation_source, is_bound,
    is_broken, enhancement_level
)
SELECT 
    t.template_id,
    p.player_id,
    t.base_durability,
    t.current_value,
    t.base_attributes,
    'system',
    'initial_equipment',
    FALSE,
    FALSE,
    0
FROM equipment_templates t
CROSS JOIN players p
WHERE 
    -- 已有的装备分配
    (t.equipment_name = '精钢长剑' AND p.character_code = 'KANE_WARRIOR_001')
    OR (t.equipment_name = '秘法法杖' AND p.character_code = 'ALICE_MYSTIC_001')
    OR (t.equipment_name = '战术护甲' AND p.character_code = 'KANE_WARRIOR_001')
    OR (t.equipment_name = '魔法护符' AND p.character_code = 'ALICE_MYSTIC_001')
    -- 新增的装备分配
    OR (t.equipment_name = '狂战斧' AND p.character_code = 'GROM_WARRIOR_001')
    OR (t.equipment_name = '战士胸甲' AND p.character_code = 'GROM_WARRIOR_001')
    OR (t.equipment_name = '知识宝典' AND p.character_code = 'SILAS_SCHOLAR_001')
    OR (t.equipment_name = '学者长袍' AND p.character_code = 'SILAS_SCHOLAR_001')
    OR (t.equipment_name = '影刃匕首' AND p.character_code = 'VERA_SURVIVOR_001')
    OR (t.equipment_name = '轻型皮甲' AND p.character_code = 'VERA_SURVIVOR_001')
    OR (t.equipment_name = '驯兽长弓' AND p.character_code = 'OLAF_SURVIVOR_001')
    OR (t.equipment_name = '守护护符' AND p.character_code = 'OLAF_SURVIVOR_001')
    OR (t.equipment_name = '火焰法杖' AND p.character_code = 'IGNIS_MYSTIC_001')
    OR (t.equipment_name = '法师长袍' AND p.character_code = 'IGNIS_MYSTIC_001')
    OR (t.equipment_name = '驯兽长弓' AND p.character_code = 'MARCUS_ARCHER_001')
    OR (t.equipment_name = '轻型皮甲' AND p.character_code = 'MARCUS_ARCHER_001')
    OR (t.equipment_name = '见习法杖' AND p.character_code = 'LUNA_MYSTIC_001')
    OR (t.equipment_name = '学徒长袍' AND p.character_code = 'LUNA_MYSTIC_001')
    OR (t.equipment_name = '驯兽长弓' AND p.character_code = 'ARTEMIS_ARCHER_001')
    OR (t.equipment_name = '守护护符' AND p.character_code = 'ARTEMIS_ARCHER_001');

-- 8. 记录装备历史
INSERT INTO equipment_history (
    instance_id, event_type,
    from_owner_type, from_owner_id,
    to_owner_type, to_owner_id,
    event_time, details
)
SELECT 
    i.instance_id,
    'created',
    'system', NULL,
    'player', i.current_owner_id,
    CURRENT_TIMESTAMP,
    JSON_OBJECT('source', 'initial_equipment', 'quality', 'perfect')
FROM equipment_instances i
WHERE i.creation_source = 'initial_equipment';

-- 9. 分配队伍成员（在players和teams都创建完成后）
INSERT INTO team_members (team_id, player_id, role, contribution_score, joined_at)
SELECT 
    t.team_id,
    p.player_id, 
    CASE 
        WHEN p.character_code = 'KANE_WARRIOR_001' THEN 'leader'
        WHEN p.character_code = 'ALICE_MYSTIC_001' THEN 'leader'
        ELSE 'regular'
    END as role,
    CASE p.rarity
        WHEN 'epic' THEN 800
        WHEN 'rare' THEN 600
        WHEN 'uncommon' THEN 400
        ELSE 200
    END as contribution_score,
    CURRENT_TIMESTAMP as joined_at
FROM players p
CROSS JOIN adventure_teams t
WHERE 
    -- 暗影猎手小队成员
    (t.team_name = '暗影猎手小队' AND p.character_code IN (
        'KANE_WARRIOR_001',  -- 队长
        'GROM_WARRIOR_001',  -- 狂战士
        'VERA_SURVIVOR_001', -- 盗贼
        'ARTEMIS_ARCHER_001'  -- 游侠
    ))
    OR
    -- 圣光守护者成员
    (t.team_name = '圣光守护者' AND p.character_code IN (
        'ALICE_MYSTIC_001',  -- 队长
        'SILAS_SCHOLAR_001', -- 学者
        'IGNIS_MYSTIC_001',  -- 火法师
        'MARCUS_ARCHER_001', -- 商人
        'OLAF_SURVIVOR_001', -- 驯兽师
        'LUNA_MYSTIC_001'    -- 新手法师
    ))
    AND NOT EXISTS (
        SELECT 1 
        FROM team_members tm2 
        WHERE tm2.player_id = p.player_id
    );

-- 更新队伍规模
UPDATE adventure_teams 
SET team_size = (
    SELECT COUNT(*) 
    FROM team_members tm 
    WHERE tm.team_id = adventure_teams.team_id
)
WHERE team_name IN ('暗影猎手小队', '圣光守护者');

-- 10. 显示添加结果（只显示新添加的角色）
SELECT 
    p.character_code AS '角色代码',
    p.character_name AS '角色名称',
    p.character_class AS '职业',
    p.rarity AS '稀有度',
    p.current_level AS '等级',
    MAX(m.happiness) AS '心情',
    MAX(m.stress) AS '压力',
    MAX(t.team_name) AS '所属队伍',
    GROUP_CONCAT(DISTINCT e.equipment_name) AS '装备',
    GROUP_CONCAT(DISTINCT pt.trait_name) AS '特质'
FROM players p
LEFT JOIN player_mood m ON p.player_id = m.player_id
LEFT JOIN team_members tm ON p.player_id = tm.player_id
LEFT JOIN adventure_teams t ON tm.team_id = t.team_id
LEFT JOIN equipment_instances ei ON p.player_id = ei.current_owner_id
LEFT JOIN equipment_templates e ON ei.template_id = e.template_id
LEFT JOIN player_traits ptr ON p.player_id = ptr.player_id
LEFT JOIN personality_traits pt ON ptr.trait_id = pt.trait_id
WHERE p.character_code NOT IN (
    'AKS_WARRIOR_001', 'LIA_TRADER_001', 'TOM_TRADER_001', 
    'ANNA_EXPLORER_001', 'VIC_TRADER_001'
)
GROUP BY 
    p.player_id,
    p.character_code,
    p.character_name,
    p.character_class,
    p.rarity,
    p.current_level
ORDER BY p.player_id; 