-- =============================================
-- 数据库初始化主脚本
-- =============================================

-- 设置字符集
SET NAMES utf8mb4;
SET character_set_client = utf8mb4;
SET character_set_connection = utf8mb4;
SET character_set_results = utf8mb4;

-- 创建数据库
DROP DATABASE IF EXISTS game_trade;
CREATE DATABASE game_trade CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 使用数据库
USE game_trade;

-- =============================================
-- 1. 创建用户和权限
-- =============================================

-- 创建游戏用户
CREATE USER IF NOT EXISTS 'game_user'@'localhost' IDENTIFIED BY 'capti_game';
CREATE USER IF NOT EXISTS 'game_readonly'@'localhost' IDENTIFIED BY 'capti_readonly';

-- 授予权限
GRANT ALL PRIVILEGES ON game_trade.* TO 'game_user'@'localhost';
GRANT SELECT ON game_trade.* TO 'game_readonly'@'localhost';
FLUSH PRIVILEGES;

-- =============================================
-- 2. 加载基础表结构
-- =============================================

-- 软删除功能预留（待实现）
/*
-- 为主要表添加软删除支持：
ALTER TABLE players ADD COLUMN
    is_active BOOLEAN DEFAULT TRUE,
    deleted_at TIMESTAMP NULL DEFAULT NULL,
    deleted_by BIGINT NULL,
    archived_reason VARCHAR(255) NULL,
    player_status ENUM('active', 'inactive', 'archived', 'banned', 'retired') DEFAULT 'active';

ALTER TABLE adventure_teams ADD COLUMN
    is_active BOOLEAN DEFAULT TRUE,
    deleted_at TIMESTAMP NULL DEFAULT NULL,
    deleted_by BIGINT NULL,
    archived_reason VARCHAR(255) NULL,
    team_status ENUM('active', 'disbanded', 'merged', 'archived') DEFAULT 'active';

ALTER TABLE commodities ADD COLUMN
    is_active BOOLEAN DEFAULT TRUE,
    deleted_at TIMESTAMP NULL DEFAULT NULL,
    deleted_by BIGINT NULL,
    archived_reason VARCHAR(255) NULL,
    commodity_status ENUM('active', 'deprecated', 'archived', 'banned') DEFAULT 'active';

-- 添加相关索引
ALTER TABLE players ADD INDEX idx_player_status (player_status, deleted_at);
ALTER TABLE adventure_teams ADD INDEX idx_team_status (team_status, deleted_at);
ALTER TABLE commodities ADD INDEX idx_commodity_status (commodity_status, deleted_at);

-- 注意：实现软删除后，需要修改所有查询以包含状态检查
-- 例如：WHERE is_active = TRUE 或 WHERE deleted_at IS NULL
*/

-- 按照依赖关系顺序加载各模块
-- 1. 先加载玩家系统（基础表）
source E:/resource/github/Capti/database/schema/01_players.sql

-- 2. 加载物品系统（依赖players表）
source E:/resource/github/Capti/database/schema/02_item_module.sql

-- 3. 加载交易模块（依赖players和item_module）
source E:/resource/github/Capti/database/schema/03_trade_module.sql

-- 4. 加载冒险模块（依赖前面所有模块）
source E:/resource/github/Capti/database/schema/04_venture_module.sql

-- 5. 加载交互系统（依赖所有其他模块）
source E:/resource/github/Capti/database/schema/05_interaction_system.sql

-- =============================================
-- 3. 初始化游戏数据
-- =============================================

-- =============================================
-- 3.1 插入性格特质数据 - 用于角色个性化
-- =============================================

INSERT INTO personality_traits (trait_name, trait_category, description, trade_modifier, venture_modifier, loyalty_modifier, stress_modifier, rarity) VALUES
('勤奋', 'positive', '工作效率更高，获得经验更快', 0.15, 0.10, 0.05, -0.10, 'common'),
('冷静', 'positive', '在高压情况下表现更好', 0.20, 0.15, 0.10, -0.30, 'uncommon'),
('幸运', 'positive', '更容易获得意外收获', 0.05, 0.20, 0.00, -0.05, 'rare'),
('专注', 'positive', '注意力集中，工作质量更高', 0.25, 0.10, 0.05, -0.15, 'common'),
('乐观', 'positive', '积极面对挫折，恢复能力强', 0.10, 0.15, 0.15, -0.20, 'common'),
('谨慎', 'positive', '降低风险，避免重大损失', 0.10, -0.05, 0.20, -0.10, 'common'),
('领袖气质', 'positive', '团队合作能力强', 0.15, 0.25, 0.15, -0.05, 'uncommon'),
('直觉敏锐', 'positive', '能快速识别机会和风险', 0.30, 0.20, 0.10, 0.05, 'rare'),
('坚韧', 'positive', '面对困难不轻易放弃', 0.05, 0.30, 0.25, -0.25, 'uncommon'),
('学习能力强', 'positive', '快速掌握新技能', 0.20, 0.20, 0.05, -0.10, 'common'),
('冲动', 'negative', '容易做出不理智的决定', -0.15, 0.10, -0.10, 0.20, 'common'),
('贪婪', 'negative', '过度追求利润，忽视风险', 0.20, -0.20, -0.30, 0.15, 'common'),
('懒惰', 'negative', '工作效率低下', -0.25, -0.15, -0.05, 0.10, 'common'),
('焦虑', 'negative', '容易在压力下崩溃', -0.10, -0.25, -0.15, 0.40, 'common'),
('背叛者', 'negative', '极易背叛雇主', -0.05, 0.05, -0.80, 0.10, 'rare'),
('完美主义', 'neutral', '工作质量高但速度慢', 0.20, 0.10, 0.05, 0.15, 'common'),
('独行侠', 'neutral', '独自工作效率高，团队合作差', 0.15, 0.20, 0.10, -0.05, 'uncommon'),
('神秘主义', 'neutral', '对超自然事物敏感', -0.05, 0.25, 0.00, 0.10, 'uncommon');

-- =============================================
-- 3.2 插入大宗货品数据
-- =============================================

-- 基础货币
INSERT INTO bulk_commodities (
    commodity_name, commodity_code, category, rarity, base_value,
    stack_limit, weight_per_unit, description, obtainable_from,
    is_main_currency, exchange_rate, can_exchange
) VALUES
('金币', 'GOLD', 'currency', 'common', 1.00,
 999999999, 0.01, '通用货币', JSON_ARRAY('quest', 'trade', 'adventure'),
 TRUE, 1.00, TRUE),
 
('银币', 'SILVER', 'currency', 'common', 0.01,
 999999999, 0.01, '零钱货币', JSON_ARRAY('quest', 'trade', 'adventure'),
 FALSE, 0.01, TRUE);

-- 基础材料
INSERT INTO bulk_commodities (
    commodity_name, commodity_code, category, rarity, base_value,
    stack_limit, weight_per_unit, description, obtainable_from
) VALUES
('铁矿石', 'IRON_ORE', 'ore', 'common', 100.00,
 9999, 2.00, '基础金属矿石', JSON_ARRAY('mining', 'trade')),

('铜矿石', 'COPPER_ORE', 'ore', 'common', 150.00,
 9999, 2.00, '导电金属矿石', JSON_ARRAY('mining', 'trade')),

('黄金矿石', 'GOLD_ORE', 'ore', 'rare', 1000.00,
 999, 2.00, '贵重金属矿石', JSON_ARRAY('mining', 'trade')),

('白银矿石', 'SILVER_ORE', 'ore', 'uncommon', 500.00,
 999, 2.00, '贵重金属矿石', JSON_ARRAY('mining', 'trade')),

('钻石原石', 'RAW_DIAMOND', 'gem', 'rare', 5000.00,
 99, 0.10, '未经打磨的钻石', JSON_ARRAY('mining', 'adventure'));

-- 稀有材料
INSERT INTO bulk_commodities (
    commodity_name, commodity_code, category, rarity, base_value,
    stack_limit, weight_per_unit, description, obtainable_from
) VALUES
('龙鳞', 'DRAGON_SCALE', 'material', 'epic', 10000.00,
 99, 0.50, '从巨龙身上掉落的鳞片', JSON_ARRAY('adventure', 'boss_drop')),

('月光精华', 'MOONLIGHT', 'material', 'rare', 5000.00,
 99, 0.05, '月圆之夜采集的神秘物质', JSON_ARRAY('adventure', 'time_event')),

('血玉原石', 'BLOOD_JADE', 'gem', 'rare', 3000.00,
 99, 0.20, '蕴含生命能量的宝石', JSON_ARRAY('mining', 'adventure')),

('星辰碎片', 'STAR_SHARD', 'material', 'epic', 8000.00,
 99, 0.10, '陨石中发现的神秘碎片', JSON_ARRAY('adventure', 'special_event')),

('幽冥结晶', 'VOID_CRYSTAL', 'material', 'rare', 2000.00,
 99, 0.15, '深渊中生长的暗色晶体', JSON_ARRAY('mining', 'adventure'));

-- =============================================
-- 3.3 插入装备类型数据
-- =============================================
INSERT INTO equipment_types (
    type_name, type_category, equip_slot, can_dual_wield, description
) VALUES
('单手剑', 'weapon', 'main_hand', TRUE, '标准单手剑'),
('双手剑', 'weapon', 'both_hands', FALSE, '需要双手持握的大剑'),
('法杖', 'weapon', 'main_hand', FALSE, '魔法导器'),
('盾牌', 'weapon', 'off_hand', FALSE, '防御装备'),
('轻甲', 'armor', 'body', FALSE, '轻便的护甲'),
('重甲', 'armor', 'body', FALSE, '沉重但防御力强的护甲'),
('法袍', 'armor', 'body', FALSE, '适合法师的长袍'),
('戒指', 'accessory', 'ring', FALSE, '增益饰品'),
('项链', 'accessory', 'neck', FALSE, '增益饰品'),
('背包', 'accessory', 'back', FALSE, '增加携带容量'),
('采矿镐', 'tool', 'main_hand', FALSE, '用于采矿的工具');

-- =============================================
-- 3.4 插入装备模板
-- =============================================

INSERT INTO equipment_templates (
    equipment_name, type_id, rarity, base_durability, base_value,
    level_requirement, base_attributes, possible_affixes, is_craftable,
    is_legendary, max_instances, lore, special_abilities, discovery_condition
) VALUES
-- 普通装备模板
('铁剑', 1, 'common', 100, 500, 1,
 JSON_OBJECT('damage', 10, 'speed', 1.2),
 JSON_ARRAY('锋利', '耐久', '迅捷'),
 TRUE, FALSE, NULL, NULL, NULL, NULL),

('精钢大剑', 2, 'uncommon', 150, 1200, 5,
 JSON_OBJECT('damage', 25, 'speed', 0.8),
 JSON_ARRAY('锋利', '重击', '坚固'),
 TRUE, FALSE, NULL, NULL, NULL, NULL),

('智慧法杖', 3, 'rare', 80, 2000, 10,
 JSON_OBJECT('magic_damage', 30, 'intelligence', 5),
 JSON_ARRAY('魔力', '智慧', '法术强化'),
 TRUE, FALSE, NULL, NULL, NULL, NULL),

('轻型皮甲', 5, 'common', 120, 800, 1,
 JSON_OBJECT('defense', 15, 'movement_speed', 0.1),
 JSON_ARRAY('坚固', '轻便', '敏捷'),
 TRUE, FALSE, NULL, NULL, NULL, NULL),

('探险者背包', (SELECT type_id FROM equipment_types WHERE type_name = '背包'), 'uncommon', 200, 1500, 5,
 JSON_OBJECT('inventory_slots', 8, 'movement_speed', -0.05),
 JSON_ARRAY('容量', '耐久', '轻便'),
 TRUE, FALSE, NULL, NULL, NULL, NULL),

-- 传说装备模板
('龙血圣剑', 2, 'legendary', 200, 50000, 30,
 JSON_OBJECT('damage', 100, 'strength', 20, 'fire_damage', 50),
 NULL, -- 传说装备没有随机词缀
 FALSE, -- 不可制作
 TRUE, -- 是传说装备
 1, -- 全服唯一
 '传说中由巨龙之血淬炼而成的神剑，蕴含着远古巨龙的力量。在上古之战中，一位无名英雄用它斩杀了毁灭之龙，但随后神剑就消失在历史长河中。',
 JSON_OBJECT(
    'dragon_slayer', '对龙类生物造成300%伤害',
    'flame_burst', '有机率释放龙息攻击',
    'blood_resonance', '击杀敌人时有机率回复生命值'
 ),
 JSON_OBJECT(
    'condition', '在龙穴中击败守护者',
    'required_level', 30,
    'required_reputation', 1000
 ));

-- =============================================
-- 3.4 插入示例雇佣角色数据 - 初始可雇佣角色
-- =============================================

INSERT INTO players (
    character_name, display_name, character_class, rarity, hire_cost, maintenance_cost,
    strength, vitality, agility, intelligence, faith, luck,
    loyalty, courage, patience, greed, wisdom, charisma,
    trade_skill, venture_skill, negotiation_skill, analysis_skill, leadership_skill,
    total_experience, current_level, skill_points,
    personality_traits, is_available
) VALUES 
('龙血战士·阿克斯', '阿克斯', 'warrior', 'legendary', 50000, 1000,
 18, 20, 14, 12, 16, 15,
 85, 95, 60, 30, 70, 80,
 60, 95, 70, 50, 85,
 15000, 15, 5,
 JSON_ARRAY('勤奋', '坚韧', '领袖气质', '冷静'),
 TRUE),

('智慧商人·莉雅', '莉雅', 'trader', 'epic', 25000, 500,
 10, 12, 16, 20, 14, 13,
 70, 55, 85, 60, 90, 75,
 95, 40, 90, 95, 60,
 8000, 10, 3,
 JSON_ARRAY('专注', '直觉敏锐', '学习能力强', '完美主义'),
 TRUE),

('新手商人·汤姆', '汤姆', 'trader', 'common', 3000, 150,
 10, 10, 12, 14, 10, 11,
 65, 50, 60, 70, 45, 55,
 50, 20, 60, 55, 30,
 1200, 3, 0,
 JSON_ARRAY('勤奋', '贪婪'),
 TRUE),

('勇敢少女·安娜', '安娜', 'explorer', 'common', 2500, 120,
 12, 14, 16, 12, 12, 10,
 70, 75, 55, 45, 50, 60,
 25, 70, 40, 45, 50,
 800, 2, 0,
 JSON_ARRAY('乐观', '冲动'),
 TRUE),

('背叛者·维克', '维克', 'trader', 'uncommon', 1500, 100,
 10, 10, 14, 16, 8, 15,
 20, 60, 40, 80, 65, 45,
 75, 35, 80, 70, 25,
 3500, 5, 1,
 JSON_ARRAY('背叛者', '贪婪', '直觉敏锐'),
 TRUE);

-- =============================================
-- 3.5 为角色初始化情绪状态
-- =============================================

INSERT INTO player_mood (player_id, happiness, stress, motivation, confidence, fatigue, focus, team_relationship, reputation) VALUES
(1, 75, 20, 85, 90, 10, 85, 80, 85),
(2, 70, 25, 80, 85, 15, 95, 75, 80),
(3, 60, 40, 70, 60, 30, 65, 65, 55),
(4, 85, 25, 80, 75, 20, 70, 80, 65),
(5, 50, 45, 75, 65, 35, 70, 40, 50);

-- =============================================
-- 3.6 为角色提供初始资产
-- =============================================

-- 插入大宗货品持有记录（金币）
INSERT INTO bulk_commodity_holdings (player_id, commodity_id, quantity) 
SELECT 1, (SELECT commodity_id FROM bulk_commodities WHERE commodity_code = 'GOLD'), 5000
UNION ALL
SELECT 2, (SELECT commodity_id FROM bulk_commodities WHERE commodity_code = 'GOLD'), 8000
UNION ALL
SELECT 3, (SELECT commodity_id FROM bulk_commodities WHERE commodity_code = 'GOLD'), 1000
UNION ALL
SELECT 4, (SELECT commodity_id FROM bulk_commodities WHERE commodity_code = 'GOLD'), 500
UNION ALL
SELECT 5, (SELECT commodity_id FROM bulk_commodities WHERE commodity_code = 'GOLD'), 300;

-- 创建并分配装备实例
INSERT INTO equipment_instances (
    template_id, current_owner_id, durability, current_value,
    attributes, creation_type, creation_source,
    power_level, awakening_level, seal_level
) VALUES
-- 龙血战士·阿克斯的传说装备
(
    (SELECT template_id FROM equipment_templates WHERE equipment_name = '龙血圣剑'),
    1, -- 阿克斯
    200, -- 满耐久度
    50000,
    JSON_OBJECT(
        'damage', 100,
        'strength', 20,
        'fire_damage', 50,
        'critical_chance', 15,
        'dragon_slayer_bonus', 300
    ),
    'discovery',
    'ancient_dragon_lair',
    5.0, -- 当前力量等级
    2,   -- 觉醒等级
    0    -- 未被封印
),

-- 智慧商人·莉雅的装备
(
    (SELECT template_id FROM equipment_templates WHERE equipment_name = '智慧法杖'),
    2, -- 莉雅
    80,
    2000,
    JSON_OBJECT(
        'magic_damage', 35,
        'intelligence', 7,
        'mana_regen', 10,
        'spell_critical', 5
    ),
    'craft',
    'master_craftsman',
    NULL, NULL, NULL -- 非传说装备
),

-- 新手商人·汤姆的装备
(
    (SELECT template_id FROM equipment_templates WHERE equipment_name = '轻型皮甲'),
    3, -- 汤姆
    120,
    800,
    JSON_OBJECT(
        'defense', 15,
        'movement_speed', 0.1,
        'dodge_chance', 3
    ),
    'system',
    'initial_equipment',
    NULL, NULL, NULL
),

-- 勇敢少女·安娜的装备
(
    (SELECT template_id FROM equipment_templates WHERE equipment_name = '探险者背包'),
    4, -- 安娜
    200,
    1500,
    JSON_OBJECT(
        'inventory_slots', 8,
        'movement_speed', -0.05,
        'item_find_luck', 5
    ),
    'quest_reward',
    'explorer_guild_quest',
    NULL, NULL, NULL
),

-- 背叛者·维克的装备
(
    (SELECT template_id FROM equipment_templates WHERE equipment_name = '铁剑'),
    5, -- 维克
    100,
    500,
    JSON_OBJECT(
        'damage', 12,
        'speed', 1.3,
        'backstab_bonus', 5
    ),
    'loot',
    'bandit_camp',
    NULL, NULL, NULL
);

-- =============================================
-- 3.7 插入冒险队伍数据 - 预设队伍
-- =============================================

INSERT INTO adventure_teams (
    team_name, team_leader, team_size, specialization, success_rate,
    base_cost, team_level, team_description, current_status, morale
) VALUES
('暗影突击队', '龙血战士·阿克斯', 5, 'stealth', 75.00,
 5000, 8, '专精于潜行和暗杀的精英队伍（当前成员：3/5）', 'available', 90.00),

('星光探索者', '智慧商人·莉雅', 5, 'exploration', 70.00,
 4500, 7, '经验丰富的遗迹探索专家（当前成员：2/5）', 'available', 85.00);

-- =============================================
-- 3.8 为现有队伍添加示例成员（预留扩充空间）
-- =============================================

INSERT INTO team_members (team_id, player_id, role, contribution_score) 
SELECT 1, 1, 'leader', 100    -- 暗影突击队 - 龙血战士·阿克斯(队长)
UNION ALL
SELECT 1, 3, 'regular', 60    -- 暗影突击队 - 新手商人·汤姆(成员)
UNION ALL
SELECT 1, 4, 'regular', 70    -- 暗影突击队 - 勇敢少女·安娜(成员)
UNION ALL
SELECT 2, 2, 'leader', 100    -- 星光探索者 - 智慧商人·莉雅(队长)
UNION ALL
SELECT 2, 5, 'regular', 50;   -- 星光探索者 - 背叛者·维克(成员)

-- 注意：每个玩家只能在一个队伍中，这是由team_members表的unique_player_team约束保证的
-- 队伍成员分配说明：
-- 暗影突击队(ID=1): [规模：5人，当前：3人]
--   - 龙血战士·阿克斯 (队长, 战士)
--   - 新手商人·汤姆 (成员, 商人)
--   - 勇敢少女·安娜 (成员, 探险家)
--   - [空缺位置 2个]
-- 星光探索者(ID=2): [规模：5人，当前：2人]
--   - 智慧商人·莉雅 (队长, 商人)
--   - 背叛者·维克 (成员, 商人)
--   - [空缺位置 3个]

-- =============================================
-- 3.9 插入冒险项目数据 - 可投资项目
-- =============================================

INSERT INTO adventure_projects (
    project_name, project_type, difficulty, required_team_size,
    base_investment, max_investment, investment_goal,
    expected_duration_hours, risk_level, expected_return_rate,
    project_description, status
) VALUES
('古代遗迹探索', 'exploration', 'normal', 4,
 10000, 50000, 100000,
 48, 0.30, 150.00,
 '探索失落文明的神秘遗迹', 'funding'),

('龙穴宝藏猎取', 'dungeon', 'hard', 6,
 20000, 100000, 200000,
 72, 0.50, 200.00,
 '深入巨龙巢穴寻找传说宝物', 'funding'),

('深海沉船打捞', 'exploration', 'normal', 3,
 8000, 40000, 80000,
 36, 0.25, 120.00,
 '打捞沉没在深海的宝藏船只', 'funding'),

('魔法矿脉开采', 'mining', 'easy', 3,
 5000, 25000, 50000,
 24, 0.15, 80.00,
 '开采蕴含魔法能量的稀有矿藏', 'funding'),

('禁忌森林探险', 'exploration', 'hard', 5,
 15000, 75000, 150000,
 60, 0.40, 180.00,
 '探索充满危险的神秘森林', 'funding');