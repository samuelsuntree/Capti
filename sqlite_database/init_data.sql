-- Converted game data for SQLite
-- Original file: init_database.sql







SET character_set_client = utf8mb4;
SET character_set_connection = utf8mb4;
SET character_set_results = utf8mb4;


DROP DATABASE IF EXISTS game_trade;























/*

ALTER TABLE players ADD COLUMN
    is_active BOOLEAN DEFAULT 1,
    deleted_at TIMESTAMP NULL DEFAULT NULL,
    deleted_by BIGINT NULL,
    archived_reason VARCHAR(255) NULL,
    player_status ENUM('active', 'inactive', 'archived', 'banned', 'retired') DEFAULT 'active';

ALTER TABLE adventure_teams ADD COLUMN
    is_active BOOLEAN DEFAULT 1,
    deleted_at TIMESTAMP NULL DEFAULT NULL,
    deleted_by BIGINT NULL,
    archived_reason VARCHAR(255) NULL,
    team_status ENUM('active', 'disbanded', 'merged', 'archived') DEFAULT 'active';

ALTER TABLE commodities ADD COLUMN
    is_active BOOLEAN DEFAULT 1,
    deleted_at TIMESTAMP NULL DEFAULT NULL,
    deleted_by BIGINT NULL,
    archived_reason VARCHAR(255) NULL,
    commodity_status ENUM('active', 'deprecated', 'archived', 'banned') DEFAULT 'active';


ALTER TABLE players ADD INDEX idx_player_status (player_status, deleted_at);
ALTER TABLE adventure_teams ADD INDEX idx_team_status (team_status, deleted_at);
ALTER TABLE commodities ADD INDEX idx_commodity_status (commodity_status, deleted_at);



*/










INSERT INTO bulk_commodities (
    commodity_name, commodity_code, category, rarity, base_value,
    stack_limit, weight_per_unit, description, obtainable_from,
    is_main_currency, exchange_rate, can_exchange
) VALUES
('金币', 'GOLD', 'currency', 'common', 1.00,
 999999999, 0.01, '通用货币', '[]',
 TRUE, 1.00, TRUE),
 
('银币', 'SILVER', 'currency', 'common', 0.01,
 999999999, 0.01, '零钱货币', '[]',
 FALSE, 0.01, TRUE);


INSERT INTO bulk_commodities (
    commodity_name, commodity_code, category, rarity, base_value,
    stack_limit, weight_per_unit, description, obtainable_from
) VALUES
('铁矿石', 'IRON_ORE', 'ore', 'common', 100.00,
 9999, 2.00, '基础金属矿石', '[]'),

('铜矿石', 'COPPER_ORE', 'ore', 'common', 150.00,
 9999, 2.00, '导电金属矿石', '[]'),

('黄金矿石', 'GOLD_ORE', 'ore', 'rare', 1000.00,
 999, 2.00, '贵重金属矿石', '[]'),

('白银矿石', 'SILVER_ORE', 'ore', 'uncommon', 500.00,
 999, 2.00, '贵重金属矿石', '[]'),

('钻石原石', 'RAW_DIAMOND', 'gem', 'rare', 5000.00,
 99, 0.10, '未经打磨的钻石', '[]');


INSERT INTO bulk_commodities (
    commodity_name, commodity_code, category, rarity, base_value,
    stack_limit, weight_per_unit, description, obtainable_from
) VALUES
('龙鳞', 'DRAGON_SCALE', 'material', 'epic', 10000.00,
 99, 0.50, '从巨龙身上掉落的鳞片', '[]'),

('月光精华', 'MOONLIGHT', 'material', 'rare', 5000.00,
 99, 0.05, '月圆之夜采集的神秘物质', '[]'),

('血玉原石', 'BLOOD_JADE', 'gem', 'rare', 3000.00,
 99, 0.20, '蕴含生命能量的宝石', '[]'),

('星辰碎片', 'STAR_SHARD', 'material', 'epic', 8000.00,
 99, 0.10, '陨石中发现的神秘碎片', '[]'),

('幽冥结晶', 'VOID_CRYSTAL', 'material', 'rare', 2000.00,
 99, 0.15, '深渊中生长的暗色晶体', '[]');




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
('采矿镐', 'tool', 'main_hand', FALSE, '用于采矿的工具'),
('长弓', 'weapon', 'both_hands', FALSE, '远程武器，需要双手持握');





INSERT INTO equipment_templates (
    equipment_name, type_id, rarity, base_durability, base_value,
    level_requirement, base_attributes, possible_affixes, is_craftable,
    is_legendary, max_instances, lore, special_abilities, discovery_condition
) VALUES

('铁剑', 1, 'common', 100, 500, 1,
 '{}',
 '[]',
 TRUE, FALSE, NULL, NULL, NULL, NULL),


('新手短剑', 1, 'common', 80, 300, 1,
 '{}',
 '[]',
 TRUE, FALSE, NULL,
 '适合初学者使用的短剑，重量轻巧，易于掌握。',
 NULL, NULL),

('学徒布甲', 5, 'common', 90, 400, 1,
 '{}',
 '[]',
 TRUE, FALSE, NULL,
 '轻便的布制护甲，适合初学者穿戴。',
 NULL, NULL),

('精钢大剑', 2, 'uncommon', 150, 1200, 5,
 '{}',
 '[]',
 TRUE, FALSE, NULL, NULL, NULL, NULL),

('智慧法杖', 3, 'rare', 80, 2000, 10,
 '{}',
 '[]',
 TRUE, FALSE, NULL, NULL, NULL, NULL),

('轻型皮甲', 5, 'common', 120, 800, 1,
 '{}',
 '[]',
 TRUE, FALSE, NULL, NULL, NULL, NULL),

('探险者背包', (SELECT type_id FROM equipment_types WHERE type_name = '背包'), 'uncommon', 200, 1500, 5,
 '{}',
 '[]',
 TRUE, FALSE, NULL, NULL, NULL, NULL),


('龙血圣剑', 2, 'legendary', 200, 50000, 30,
 '{}',
 NULL, 
 FALSE, 
 TRUE, 
 1, 
 '传说中由巨龙之血淬炼而成的神剑，蕴含着远古巨龙的力量。在上古之战中，一位无名英雄用它斩杀了毁灭之龙，但随后神剑就消失在历史长河中。',
 '{}',
 '{}'),


('月影精灵弓', (SELECT type_id FROM equipment_types WHERE type_name = '长弓'), 'epic', 100, 3000, 10,
 '{}',
 '[]',
 TRUE, FALSE, NULL,
 '由精灵工匠使用月光精华浸润的银木制成，弓身上铭刻着古老的精灵符文。在月光下，弓箭会散发出淡淡的银光。',
 NULL, NULL);





INSERT INTO players (
    character_code, character_name, display_name, character_class, rarity, hire_cost, maintenance_cost,
    strength, vitality, agility, intelligence, faith, luck,
    loyalty, courage, patience, greed, wisdom, charisma,
    trade_skill, venture_skill, negotiation_skill, analysis_skill, leadership_skill,
    total_experience, current_level, skill_points,
    personality_traits, is_available
) VALUES 
('AKS_WARRIOR_001', '龙血战士·阿克斯', '阿克斯', 'warrior', 'legendary', 50000, 1000,
 18, 20, 14, 12, 16, 15,
 85, 95, 60, 30, 70, 80,
 60, 95, 70, 50, 85,
 15000, 15, 5,
 '[]',
 TRUE),

('LIA_ARCHER_001', '精灵弓手·莉雅', '莉雅', 'archer', 'epic', 25000, 500,
 12, 14, 20, 16, 14, 15,      
 70, 75, 85, 60, 90, 75,
 65, 80, 70, 85, 60,         
 8000, 10, 3,
 '[]',
 TRUE),

('TOM_ARCHER_001', '弓箭手·汤姆', '汤姆', 'archer', 'common', 3000, 150,
 12, 12, 16, 12, 10, 11,      
 65, 60, 60, 50, 45, 55,
 40, 60, 50, 55, 30,         
 1200, 3, 0,
 '[]',
 TRUE),

('ANNA_EXPLORER_001', '勇敢少女·安娜', '安娜', 'explorer', 'common', 2500, 120,
 12, 14, 16, 12, 12, 10,
 70, 75, 55, 45, 50, 60,
 25, 70, 40, 45, 50,
 800, 2, 0,
 '[]',
 TRUE),

('VIC_WARRIOR_001', '叛剑士·维克', '维克', 'warrior', 'uncommon', 1500, 100,
 16, 14, 14, 10, 8, 15,       
 20, 70, 40, 80, 45, 45,
 35, 65, 50, 40, 25,         
 3500, 5, 1,
 '[]',
 TRUE);





INSERT INTO player_mood (player_id, happiness, stress, motivation, confidence, fatigue, focus, team_relationship, reputation) VALUES
(1, 75, 20, 85, 90, 10, 85, 80, 85),
(2, 70, 25, 80, 85, 15, 95, 75, 80),
(3, 60, 40, 70, 60, 30, 65, 65, 55),
(4, 85, 25, 80, 75, 20, 70, 80, 65),
(5, 50, 45, 75, 65, 35, 70, 40, 50);






INSERT INTO bulk_commodity_holdings (player_id, commodity_id, quantity) 
SELECT 1, (SELECT commodity_id FROM bulk_commodities WHERE commodity_code = ?), 5000
UNION ALL
SELECT 2, (SELECT commodity_id FROM bulk_commodities WHERE commodity_code = 'GOLD'), 8000
UNION ALL
SELECT 3, (SELECT commodity_id FROM bulk_commodities WHERE commodity_code = 'GOLD'), 1000
UNION ALL
SELECT 4, (SELECT commodity_id FROM bulk_commodities WHERE commodity_code = 'GOLD'), 500
UNION ALL
SELECT 5, (SELECT commodity_id FROM bulk_commodities WHERE commodity_code = 'GOLD'), 300;


INSERT INTO equipment_instances (
    template_id, current_owner_id, owner_type, durability, current_value,
    attributes, creation_type, creation_source,
    power_level, awakening_level, seal_level
) VALUES

(
    (SELECT template_id FROM equipment_templates WHERE equipment_name = '龙血圣剑'),
    (SELECT player_id FROM players WHERE character_code = 'AKS_WARRIOR_001'), 
    'player', 
    200, 
    50000,
    '{}',
    'discovery',
    'ancient_dragon_lair',
    5.0, 
    2,   
    0    
),


(
    (SELECT template_id FROM equipment_templates WHERE equipment_name = '月影精灵弓'),
    (SELECT player_id FROM players WHERE character_code = 'LIA_ARCHER_001'),
    'player', 
    100,
    3000.00,  
    '{}',
    'craft',
    'elven_craftmaster',
    NULL, NULL, NULL 
),


(
    (SELECT template_id FROM equipment_templates WHERE equipment_name = '轻型皮甲'),
    (SELECT player_id FROM players WHERE character_code = 'TOM_ARCHER_001'),
    'player', 
    120,
    800,
    '{}',
    'system',
    'initial_equipment',
    NULL, NULL, NULL
),


(
    (SELECT template_id FROM equipment_templates WHERE equipment_name = '探险者背包'),
    (SELECT player_id FROM players WHERE character_code = 'ANNA_EXPLORER_001'),
    'player', 
    200,
    1500,
    '{}',
    'quest_reward',
    'explorer_guild_quest',
    NULL, NULL, NULL
),


(
    (SELECT template_id FROM equipment_templates WHERE equipment_name = '铁剑'),
    (SELECT player_id FROM players WHERE character_code = 'VIC_WARRIOR_001'),
    'player', 
    100,
    500,
    '{}',
    'loot',
    'bandit_camp',
    NULL, NULL, NULL
);





INSERT INTO adventure_teams (
    team_name, team_leader, team_size, specialization, success_rate,
    base_cost, team_level, team_description, current_status, morale
) VALUES
('暗影突击队', '龙血战士·阿克斯', 5, 'stealth', 75.00,
 5000, 8, '专精于潜行和暗杀的精英队伍（当前成员：3/5）', 'available', 90.00),

('星光探索者', '智慧商人·莉雅', 5, 'exploration', 70.00,
 4500, 7, '经验丰富的遗迹探索专家（当前成员：2/5）', 'available', 85.00);





INSERT INTO team_members (team_id, player_id, role, contribution_score) 
SELECT 1, 1, 'leader', 100    
UNION ALL
SELECT 1, 3, 'regular', 60    
UNION ALL
SELECT 1, 4, 'regular', 70    
UNION ALL
SELECT 2, 2, 'leader', 100    
UNION ALL
SELECT 2, 5, 'regular', 50;   

















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






INSERT INTO traders (
    trader_code, display_name, avatar_url,
    trade_level, trade_experience, trade_reputation,
    total_trades, successful_trades,
    gold_balance, total_asset_value,
    max_hired_players, max_trade_orders, daily_trade_limit,
    total_profit, best_trade_profit, biggest_loss
) VALUES
('TRADER_001', '玩家', 'assets/images/default_avatar.svg',
 1, 0, 50,                     
 0, 0,                        
 5000.00, 5000.00,           
 5, 10, 10000.00,            
 0.00, 0.00, 0.00);          












INSERT INTO equipment_instances (
    template_id, current_owner_id, owner_type, durability, current_value,
    attributes, creation_type, creation_


INSERT INTO trader_items (
    trader_id, equipment_instance_id, quantity, purchase_price, is_locked, notes
) 
SELECT 
    @trader_id,
    instance_id,
    1,
    current_value,
    FALSE,
    CASE 
        WHEN template_id = (SELECT template_id FROM equipment_templates WHERE equipment_name = '新手短剑') 
        THEN '新手短剑 - 初始装备'
        ELSE '学徒布甲 - 初始装备'
    END
FROM equipment_instances 
WHERE current_owner_id = @trader_id 
AND owner_type = 'trader';


INSERT INTO bulk_commodity_holdings (
    player_id, commodity_id, quantity, average_acquisition_price
) VALUES

(@trader_id, 
 (SELECT commodity_id FROM bulk_commodities WHERE commodity_code = 'GOLD'),
 5000.00, 
 1.00),   


(@trader_id,
 (SELECT commodity_id FROM bulk_commodities WHERE commodity_code = 'IRON_ORE'),
 50,      
 100.00), 

(@trader_id,
 (SELECT commodity_id FROM bulk_commodities WHERE commodity_code = 'COPPER_ORE'),
 30,      
 150.00), 


(@trader_id,
 (SELECT commodity_id FROM bulk_commodities WHERE commodity_code = 'SILVER_ORE'),
 5,       
 500.00), 


(@trader_id,
 (SELECT commodity_id FROM bulk_commodities WHERE commodity_code = 'MOONLIGHT'),
 2,       
 5000.00), 

(@trader_id,
 (SELECT commodity_id FROM bulk_commodities WHERE commodity_code = 'BLOOD_JADE'),
 1,       
 3000.00), 

(@trader_id,
 (SELECT commodity_id FROM bulk_commodities WHERE commodity_code = 'VOID_CRYSTAL'),
 3,       
 2000.00) 
ON DUPLICATE KEY UPDATE
    quantity = VALUES(quantity),
    average_acquisition_price = VALUES(average_acquisition_price);


INSERT INTO trader_notifications (
    trader_id, notification_type, title, content, is_read
) VALUES
(@trader_id, 'system', '欢迎来到游戏', 
 '欢迎成为一名商人！你现在拥有5000金币的启动资金和一位助手（新手商人·汤姆）。
  你可以通过雇佣冒险者、交易装备来赚取利润。祝你在商途上一帆风顺！', FALSE);