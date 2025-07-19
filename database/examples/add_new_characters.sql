-- =============================================
-- 添加新角色脚本
-- =============================================

USE game_trade;

-- 1. 插入新角色基础信息
INSERT INTO players (
    character_name, display_name, character_class, rarity, hire_cost, maintenance_cost,
    strength, vitality, agility, intelligence, faith, luck,
    loyalty, courage, patience, greed, wisdom, charisma,
    trade_skill, venture_skill, negotiation_skill, analysis_skill, leadership_skill,
    total_experience, current_level, skill_points,
    personality_traits, is_available
) VALUES 
('影刃刺客·凯恩', '凯恩', 'warrior', 'epic', 30000, 600,
 16, 14, 20, 15, 12, 18, 75, 85, 70, 40, 65, 60,
 45, 90, 55, 70, 75, 10000, 12, 4,
 JSON_ARRAY('冷静', '独行侠', '直觉敏锐'), TRUE),

('圣光牧师·艾莉丝', '艾莉丝', 'mystic', 'rare', 18000, 400,
 12, 16, 14, 18, 20, 14, 90, 80, 85, 20, 85, 80,
 60, 65, 85, 75, 70, 6000, 8, 2,
 JSON_ARRAY('乐观', '坚韧', '学习能力强'), TRUE),

('狂战士·格罗姆', '格罗姆', 'warrior', 'rare', 20000, 450,
 20, 18, 12, 10, 14, 16, 60, 95, 40, 50, 45, 55,
 30, 85, 40, 35, 65, 7500, 9, 3,
 JSON_ARRAY('冲动', '勇敢', '坚韧'), TRUE),

('学者·塞拉斯', '塞拉斯', 'scholar', 'epic', 25000, 500,
 10, 12, 14, 20, 16, 15, 80, 50, 90, 35, 95, 75,
 85, 55, 80, 95, 60, 9000, 11, 3,
 JSON_ARRAY('专注', '完美主义', '学习能力强'), TRUE),

('盗贼·薇拉', '薇拉', 'survivor', 'uncommon', 12000, 300,
 14, 12, 18, 16, 10, 20, 65, 70, 55, 75, 60, 65,
 80, 75, 85, 70, 45, 4000, 6, 1,
 JSON_ARRAY('贪婪', '直觉敏锐', '独行侠'), TRUE),

('驯兽师·奥拉夫', '奥拉夫', 'survivor', 'rare', 16000, 350,
 15, 16, 16, 14, 12, 18, 70, 75, 80, 45, 70, 70,
 50, 80, 60, 65, 80, 5500, 7, 2,
 JSON_ARRAY('坚韧', '领袖气质', '勤奋'), TRUE),

('火法师·伊格尼斯', '伊格尼斯', 'mystic', 'epic', 28000, 550,
 12, 14, 16, 20, 18, 14, 75, 80, 60, 40, 80, 70,
 65, 70, 70, 85, 65, 8500, 10, 3,
 JSON_ARRAY('冲动', '专注', '学习能力强'), TRUE),

('商人·马库斯', '马库斯', 'trader', 'uncommon', 15000, 350,
 11, 13, 15, 17, 13, 16, 80, 60, 75, 70, 75, 85,
 90, 45, 95, 90, 55, 5000, 7, 2,
 JSON_ARRAY('贪婪', '直觉敏锐', '谨慎'), TRUE),

('游侠·阿尔忒弥斯', '阿尔忒弥斯', 'explorer', 'rare', 19000, 400,
 16, 15, 18, 15, 14, 17, 75, 80, 70, 35, 75, 65,
 55, 85, 65, 75, 70, 6500, 8, 2,
 JSON_ARRAY('冷静', '独行侠', '坚韧'), TRUE),

('新手法师·露娜', '露娜', 'mystic', 'common', 8000, 200,
 10, 11, 13, 16, 15, 12, 70, 55, 65, 45, 60, 60,
 40, 50, 55, 65, 45, 2000, 4, 1,
 JSON_ARRAY('学习能力强', '焦虑'), TRUE);

-- 2. 为新角色添加情绪状态
INSERT INTO player_mood (
    player_id, happiness, stress, motivation, confidence, 
    fatigue, focus, team_relationship, reputation
)
SELECT 
    p.player_id,
    -- 基础心情值基于稀有度
    CASE p.rarity 
        WHEN 'legendary' THEN 80 WHEN 'epic' THEN 75
        WHEN 'rare' THEN 70 WHEN 'uncommon' THEN 65
        ELSE 60 
    END + 
    -- 根据性格特质调整
    CASE 
        WHEN JSON_CONTAINS(p.personality_traits, '"乐观"') THEN 10
        WHEN JSON_CONTAINS(p.personality_traits, '"焦虑"') THEN -10
        ELSE 0
    END as happiness,
    
    CASE p.rarity 
        WHEN 'legendary' THEN 15 WHEN 'epic' THEN 20
        WHEN 'rare' THEN 25 WHEN 'uncommon' THEN 30
        ELSE 35 
    END +
    CASE 
        WHEN JSON_CONTAINS(p.personality_traits, '"冷静"') THEN -10
        WHEN JSON_CONTAINS(p.personality_traits, '"焦虑"') THEN 15
        ELSE 0
    END as stress,
    
    CASE p.rarity 
        WHEN 'legendary' THEN 90 WHEN 'epic' THEN 85
        WHEN 'rare' THEN 80 WHEN 'uncommon' THEN 75
        ELSE 70 
    END +
    CASE 
        WHEN JSON_CONTAINS(p.personality_traits, '"勤奋"') THEN 10
        WHEN JSON_CONTAINS(p.personality_traits, '"懒惰"') THEN -10
        ELSE 0
    END as motivation,
    
    CASE p.rarity 
        WHEN 'legendary' THEN 95 WHEN 'epic' THEN 85
        WHEN 'rare' THEN 75 WHEN 'uncommon' THEN 65
        ELSE 55 
    END as confidence,
    
    CASE p.rarity 
        WHEN 'legendary' THEN 10 WHEN 'epic' THEN 15
        WHEN 'rare' THEN 20 WHEN 'uncommon' THEN 25
        ELSE 30 
    END as fatigue,
    
    CASE p.rarity 
        WHEN 'legendary' THEN 90 WHEN 'epic' THEN 85
        WHEN 'rare' THEN 80 WHEN 'uncommon' THEN 75
        ELSE 70 
    END +
    CASE 
        WHEN JSON_CONTAINS(p.personality_traits, '"专注"') THEN 10
        ELSE 0
    END as focus,
    
    CASE p.rarity 
        WHEN 'legendary' THEN 85 WHEN 'epic' THEN 80
        WHEN 'rare' THEN 75 WHEN 'uncommon' THEN 70
        ELSE 65 
    END +
    CASE 
        WHEN JSON_CONTAINS(p.personality_traits, '"领袖气质"') THEN 15
        WHEN JSON_CONTAINS(p.personality_traits, '"独行侠"') THEN -10
        ELSE 0
    END as team_relationship,
    
    CASE p.rarity 
        WHEN 'legendary' THEN 90 WHEN 'epic' THEN 80
        WHEN 'rare' THEN 70 WHEN 'uncommon' THEN 60
        ELSE 50 
    END as reputation
FROM players p 
WHERE p.player_id NOT IN (SELECT player_id FROM player_mood);

-- 3. 为新角色添加初始资产和装备
INSERT INTO player_assets (player_id, asset_type, asset_name, quantity, equipment_quality)
-- 基础金币
SELECT p.player_id, 'gold', '金币', 
    CASE p.rarity 
        WHEN 'legendary' THEN 10000 
        WHEN 'epic' THEN 5000 
        WHEN 'rare' THEN 2000 
        WHEN 'uncommon' THEN 1000 
        ELSE 500 
    END,
    'common'
FROM players p 
WHERE p.player_id NOT IN (SELECT DISTINCT player_id FROM player_assets WHERE asset_type = 'gold')

UNION ALL

-- 职业特定装备
SELECT 
    p.player_id, 
    'equipment',
    CASE p.character_class
        WHEN 'warrior' THEN '战士之剑'
        WHEN 'mystic' THEN '法师法杖'
        WHEN 'scholar' THEN '学者之笔'
        WHEN 'explorer' THEN '探险背包'
        WHEN 'trader' THEN '商人账本'
        WHEN 'survivor' THEN '生存工具'
    END,
    1,
    CASE p.rarity
        WHEN 'legendary' THEN 'masterwork'
        WHEN 'epic' THEN 'excellent'
        WHEN 'rare' THEN 'good'
        ELSE 'common'
    END
FROM players p
WHERE p.player_id NOT IN (SELECT DISTINCT player_id FROM player_assets WHERE asset_type = 'equipment');

-- 4. 显示添加结果
SELECT '新角色添加完成！' AS '状态';
SELECT 
    p.character_name AS '角色名称',
    p.character_class AS '职业',
    p.rarity AS '稀有度',
    p.hire_cost AS '雇佣费用',
    m.happiness AS '心情',
    m.stress AS '压力',
    COUNT(a.asset_id) AS '资产数量'
FROM players p
LEFT JOIN player_mood m ON p.player_id = m.player_id
LEFT JOIN player_assets a ON p.player_id = a.player_id
WHERE p.player_id NOT IN (
    SELECT player_id FROM players 
    WHERE player_id <= (SELECT MIN(player_id) + 4 FROM players)
)
GROUP BY p.player_id
ORDER BY p.player_id DESC; 