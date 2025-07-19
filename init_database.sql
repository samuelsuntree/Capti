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

-- 先加载不依赖其他表的基础表
source E:/resource/github/Capti/database/schema/01_players.sql

-- 加载交易模块（依赖players表）
source E:/resource/github/Capti/database/schema/02_trade_module.sql

-- 加载冒险模块（依赖players和trade_module）
source E:/resource/github/Capti/database/schema/03_venture_module.sql



-- 加载交互系统（依赖其他所有模块）
source E:/resource/github/Capti/database/schema/04_interaction_system.sql

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
-- 3.2 插入商品数据 - 稀有和传说级别商品
-- =============================================

INSERT INTO commodities (
    commodity_name, commodity_symbol, category, rarity, base_price, current_price,
    market_cap, total_supply, circulating_supply, volatility_index, price_change_24h,
    volume_24h, description, is_tradeable, is_active
) VALUES
('龙鳞金', 'DRAGON', 'rare', 'legendary', 10000.00, 15000.00,
 1000000.00, 1000.00, 100.00, 0.15, 0.00,
 1000.00, '传说中的龙鳞锻造而成的珍贵金属', TRUE, TRUE),

('月光银', 'MOON', 'magic', 'epic', 5000.00, 8000.00,
 500000.00, 2000.00, 500.00, 0.12, 0.00,
 2000.00, '在月圆之夜采集的神秘银矿', TRUE, TRUE),

('血玉', 'BLOODJADE', 'gem', 'rare', 3000.00, 4500.00,
 300000.00, 3000.00, 1000.00, 0.18, 0.00,
 1500.00, '蕴含生命力的稀有宝石', TRUE, TRUE),

('星辰石', 'STARSTONE', 'magic', 'epic', 8000.00, 12000.00,
 800000.00, 1500.00, 300.00, 0.20, 0.00,
 1200.00, '从天外陨石中提取的能量结晶', TRUE, TRUE),

('幽冥水晶', 'NETHER', 'magic', 'rare', 2000.00, 3500.00,
 200000.00, 4000.00, 2000.00, 0.25, 0.00,
 2500.00, '来自地底深处的黑暗水晶', TRUE, TRUE);

-- =============================================
-- 3.3 插入商品数据 - 基础商品
-- =============================================

INSERT INTO commodities (
    commodity_name, commodity_symbol, category, rarity, base_price, current_price,
    market_cap, total_supply, circulating_supply, volatility_index, description,
    is_tradeable, is_active
) VALUES
('铁矿石', 'IRON', 'metal', 'common', 100.00, 100.00,
 1000000.00, 100000.00, 50000.00, 0.05, '基础金属矿石',
 TRUE, TRUE),

('铜矿石', 'COPPER', 'metal', 'common', 150.00, 150.00,
 1500000.00, 80000.00, 40000.00, 0.06, '导电金属矿石',
 TRUE, TRUE),

('黄金', 'GOLD', 'metal', 'rare', 1000.00, 1000.00,
 10000000.00, 10000.00, 5000.00, 0.10, '贵重金属',
 TRUE, TRUE),

('白银', 'SILVER', 'metal', 'uncommon', 500.00, 500.00,
 5000000.00, 20000.00, 10000.00, 0.08, '贵重金属',
 TRUE, TRUE),

('钻石', 'DIAMOND', 'gem', 'rare', 5000.00, 5000.00,
 50000000.00, 5000.00, 2000.00, 0.15, '稀有宝石',
 TRUE, TRUE);

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

INSERT INTO player_assets (player_id, asset_type, asset_name, quantity, equipment_quality) VALUES
(1, 'equipment', '龙鳞盔甲', 1, 'masterwork'),
(1, 'equipment', '烈焰之剑', 1, 'excellent'),
(1, 'gold', '金币', 5000, 'common'),
(2, 'equipment', '智慧法杖', 1, 'excellent'),
(2, 'equipment', '商人长袍', 1, 'good'),
(2, 'gold', '金币', 8000, 'common'),
(3, 'gold', '金币', 1000, 'common'),
(4, 'gold', '金币', 500, 'common'),
(5, 'gold', '金币', 300, 'common');

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