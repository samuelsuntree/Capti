
-- Insert personality traits
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

-- Insert bulk commodities
INSERT INTO bulk_commodities (commodity_name, commodity_code, category, rarity, base_value, stack_limit, weight_per_unit, description, obtainable_from, is_main_currency, exchange_rate, can_exchange) VALUES
('金币', 'GOLD', 'currency', 'common', 1.00, 999999999, 0.01, '通用货币', '["quest", "trade", "adventure"]', 1, 1.00, 1),
('银币', 'SILVER', 'currency', 'common', 0.01, 999999999, 0.01, '零钱货币', '["quest", "trade", "adventure"]', 0, 0.01, 1);

-- Insert equipment types
INSERT INTO equipment_types (type_name, type_category, equip_slot, can_dual_wield, description) VALUES
('单手剑', 'weapon', 'main_hand', 1, '标准单手剑'),
('双手剑', 'weapon', 'both_hands', 0, '需要双手持握的大剑'),
('法杖', 'weapon', 'main_hand', 0, '魔法导器'),
('盾牌', 'weapon', 'off_hand', 0, '防御装备'),
('轻甲', 'armor', 'body', 0, '轻便的护甲'),
('重甲', 'armor', 'body', 0, '沉重但防御力强的护甲'),
('法袍', 'armor', 'body', 0, '适合法师的长袍'),
('戒指', 'accessory', 'ring', 0, '增益饰品'),
('项链', 'accessory', 'neck', 0, '增益饰品'),
('背包', 'accessory', 'back', 0, '增加携带容量'),
('采矿镐', 'tool', 'main_hand', 0, '用于采矿的工具'),
('长弓', 'weapon', 'both_hands', 0, '远程武器，需要双手持握');

-- Insert equipment templates
INSERT INTO equipment_templates (equipment_name, type_id, rarity, base_durability, base_value, level_requirement, base_attributes, possible_affixes, is_craftable, is_legendary, max_instances, lore, special_abilities, discovery_condition) VALUES
('铁剑', 1, 'common', 100, 500, 1, '{"damage": 10, "speed": 1.2}', '["锋利", "耐久", "迅捷"]', 1, 0, NULL, NULL, NULL, NULL),
('新手短剑', 1, 'common', 80, 300, 1, '{"damage": 8, "speed": 1.3}', '["锋利", "轻便"]', 1, 0, NULL, '适合初学者使用的短剑，重量轻巧，易于掌握。', NULL, NULL),
('学徒布甲', 5, 'common', 90, 400, 1, '{"defense": 10, "movement_speed": 0.15}', '["轻便", "灵活"]', 1, 0, NULL, '轻便的布制护甲，适合初学者穿戴。', NULL, NULL);

-- Insert players
INSERT INTO players (character_code, character_name, display_name, character_class, rarity, hire_cost, maintenance_cost, strength, vitality, agility, intelligence, faith, luck, loyalty, courage, patience, greed, wisdom, charisma, trade_skill, venture_skill, negotiation_skill, analysis_skill, leadership_skill, total_experience, current_level, skill_points, personality_traits, is_available) VALUES 
('AKS_WARRIOR_001', '龙血战士·阿克斯', '阿克斯', 'warrior', 'legendary', 50000, 1000, 18, 20, 14, 12, 16, 15, 85, 95, 60, 30, 70, 80, 60, 95, 70, 50, 85, 15000, 15, 5, '["勤奋", "坚韧", "领袖气质", "冷静"]', 1),
('LIA_ARCHER_001', '精灵弓手·莉雅', '莉雅', 'archer', 'epic', 25000, 500, 12, 14, 20, 16, 14, 15, 70, 75, 85, 60, 90, 75, 65, 80, 70, 85, 60, 8000, 10, 3, '["专注", "直觉敏锐", "冷静", "完美主义"]', 1),
('TOM_ARCHER_001', '弓箭手·汤姆', '汤姆', 'archer', 'common', 3000, 150, 12, 12, 16, 12, 10, 11, 65, 60, 60, 50, 45, 55, 40, 60, 50, 55, 30, 1200, 3, 0, '["勤奋", "专注"]', 1),
('ANNA_EXPLORER_001', '勇敢少女·安娜', '安娜', 'explorer', 'common', 2500, 120, 12, 14, 16, 12, 12, 10, 70, 75, 55, 45, 50, 60, 25, 70, 40, 45, 50, 800, 2, 0, '["乐观", "冲动"]', 1),
('VIC_WARRIOR_001', '叛剑士·维克', '维克', 'warrior', 'uncommon', 1500, 100, 16, 14, 14, 10, 8, 15, 20, 70, 40, 80, 45, 45, 35, 65, 50, 40, 25, 3500, 5, 1, '["背叛者", "冲动", "直觉敏锐"]', 1);

-- Insert player mood
INSERT INTO player_mood (player_id, happiness, stress, motivation, confidence, fatigue, focus, team_relationship, reputation) VALUES
(1, 75, 20, 85, 90, 10, 85, 80, 85),
(2, 70, 25, 80, 85, 15, 95, 75, 80),
(3, 60, 40, 70, 60, 30, 65, 65, 55),
(4, 85, 25, 80, 75, 20, 70, 80, 65),
(5, 50, 45, 75, 65, 35, 70, 40, 50);

-- Insert adventure teams
INSERT INTO adventure_teams (team_name, team_leader, team_size, specialization, success_rate, base_cost, team_level, team_description, current_status, morale) VALUES
('暗影突击队', '龙血战士·阿克斯', 5, 'combat', 75.00, 5000, 8, '专精于潜行和暗杀的精英队伍（当前成员：3/5）', 'available', 90.00),
('星光探索者', '智慧商人·莉雅', 5, 'exploration', 70.00, 4500, 7, '经验丰富的遗迹探索专家（当前成员：2/5）', 'available', 85.00);

-- Insert team members
INSERT INTO team_members (team_id, player_id, role, contribution_score) VALUES
(1, 1, 'leader', 100),
(1, 3, 'regular', 60),
(1, 4, 'regular', 70),
(2, 2, 'leader', 100),
(2, 5, 'regular', 50);

-- Insert adventure projects
INSERT INTO adventure_projects (project_name, project_type, difficulty, required_team_size, base_investment, max_investment, investment_goal, expected_duration_hours, risk_level, expected_return_rate, project_description, status) VALUES
('古代遗迹探索', 'exploration', 'normal', 4, 10000, 50000, 100000, 48, 0.30, 150.00, '探索失落文明的神秘遗迹', 'funding'),
('龙穴宝藏猎取', 'dungeon', 'hard', 6, 20000, 100000, 200000, 72, 0.50, 200.00, '深入巨龙巢穴寻找传说宝物', 'funding'),
('深海沉船打捞', 'exploration', 'normal', 3, 8000, 40000, 80000, 36, 0.25, 120.00, '打捞沉没在深海的宝藏船只', 'funding'),
('魔法矿脉开采', 'mining', 'easy', 3, 5000, 25000, 50000, 24, 0.15, 80.00, '开采蕴含魔法能量的稀有矿藏', 'funding'),
('禁忌森林探险', 'exploration', 'hard', 5, 15000, 75000, 150000, 60, 0.40, 180.00, '探索充满危险的神秘森林', 'funding');

-- Insert traders
INSERT INTO traders (trader_code, display_name, avatar_url, trade_level, trade_experience, trade_reputation, total_trades, successful_trades, gold_balance, total_asset_value, max_hired_players, max_trade_orders, daily_trade_limit, total_profit, best_trade_profit, biggest_loss) VALUES
('TRADER_001', '玩家', 'assets/images/default_avatar.svg', 1, 0, 50, 0, 0, 5000.00, 5000.00, 5, 10, 10000.00, 0.00, 0.00, 0.00);

-- Insert trader notifications
INSERT INTO trader_notifications (trader_id, notification_type, title, content, is_read) VALUES
(1, 'system', '欢迎来到游戏', '欢迎成为一名商人！你现在拥有5000金币的启动资金。你可以通过雇佣冒险者、交易装备来赚取利润。祝你在商途上一帆风顺！', 0);
