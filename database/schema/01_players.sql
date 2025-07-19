-- 雇佣角色系统相关表结构
-- 这些"玩家"实际上是游戏内可雇佣的角色，由真实玩家雇佣和管理

-- 雇佣角色基本信息表
CREATE TABLE players (
    player_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    character_name VARCHAR(100) NOT NULL,
    display_name VARCHAR(100),
    avatar_url VARCHAR(255),
    character_class ENUM('warrior', 'trader', 'explorer', 'scholar', 'mystic', 'survivor') NOT NULL,
    rarity ENUM('common', 'uncommon', 'rare', 'epic', 'legendary') DEFAULT 'common',
    hire_cost DECIMAL(20,2) NOT NULL DEFAULT 1000.00,
    maintenance_cost DECIMAL(20,2) NOT NULL DEFAULT 100.00,
    current_owner_id BIGINT NULL, -- 当前雇佣该角色的真实玩家ID
    is_available BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    hired_at TIMESTAMP NULL,
    
    -- 基础属性（参考黑暗之魂）
    strength INT DEFAULT 10,        -- 力量：影响交易谈判和冒险战斗
    vitality INT DEFAULT 10,        -- 体力：影响持续工作能力和生存力
    agility INT DEFAULT 10,         -- 敏捷：影响反应速度和市场敏感度
    intelligence INT DEFAULT 10,    -- 智力：影响分析能力和学习速度
    faith INT DEFAULT 10,           -- 信仰：影响风险承受能力和决策坚定性
    luck INT DEFAULT 10,            -- 幸运：影响意外收获和危机化解
    
    -- 精神属性
    loyalty INT DEFAULT 50,         -- 忠诚度：影响是否会背叛雇主
    courage INT DEFAULT 50,         -- 勇气：影响面对高风险项目的表现
    patience INT DEFAULT 50,        -- 耐心：影响长期投资和等待能力
    greed INT DEFAULT 50,           -- 贪婪：影响对利润的追求和风险偏好
    wisdom INT DEFAULT 50,          -- 智慧：影响经验积累和决策质量
    charisma INT DEFAULT 50,        -- 魅力：影响与团队和商人的关系
    
    -- 专业技能
    trade_skill INT DEFAULT 10,     -- 交易技能
    venture_skill INT DEFAULT 10,   -- 冒险技能
    negotiation_skill INT DEFAULT 10, -- 谈判技能
    analysis_skill INT DEFAULT 10,  -- 分析技能
    leadership_skill INT DEFAULT 10, -- 领导技能
    
    -- 经验和成长
    total_experience INT DEFAULT 0,
    current_level INT DEFAULT 1,
    skill_points INT DEFAULT 0,
    
    -- 性格特质（JSON存储，参考环世界）
    personality_traits JSON,
    
    -- 索引
    INDEX idx_character_name (character_name),
    INDEX idx_character_class (character_class),
    INDEX idx_rarity (rarity),
    INDEX idx_owner (current_owner_id),
    INDEX idx_available (is_available),
    INDEX idx_level (current_level),
    INDEX idx_hire_cost (hire_cost)
);

-- 雇佣角色资产表
CREATE TABLE player_assets (
    asset_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    player_id BIGINT NOT NULL,
    asset_type ENUM('gold', 'commodity', 'venture_share', 'equipment', 'knowledge') NOT NULL,
    asset_name VARCHAR(100) NOT NULL,
    quantity DECIMAL(20,8) NOT NULL DEFAULT 0,
    average_cost DECIMAL(20,8) DEFAULT 0,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    is_locked BOOLEAN DEFAULT FALSE,
    equipment_quality ENUM('poor', 'common', 'good', 'excellent', 'masterwork') DEFAULT 'common',
    FOREIGN KEY (player_id) REFERENCES players(player_id) ON DELETE CASCADE,
    UNIQUE KEY unique_player_asset (player_id, asset_type, asset_name),
    INDEX idx_player_id (player_id),
    INDEX idx_asset_type (asset_type),
    INDEX idx_quantity (quantity)
);

-- 角色等级和能力解锁表
CREATE TABLE player_levels (
    level_id INT PRIMARY KEY AUTO_INCREMENT,
    level_number INT UNIQUE NOT NULL,
    required_exp INT NOT NULL,
    max_trade_orders INT DEFAULT 10,
    max_venture_investments INT DEFAULT 5,
    unlock_auto_trading BOOLEAN DEFAULT FALSE,
    unlock_advanced_analysis BOOLEAN DEFAULT FALSE,
    unlock_team_influence BOOLEAN DEFAULT FALSE,
    skill_points_reward INT DEFAULT 1,
    attribute_points_reward INT DEFAULT 0,
    level_rewards JSON,
    description TEXT,
    INDEX idx_level_number (level_number),
    INDEX idx_required_exp (required_exp)
);

-- 角色能力解锁状态表
CREATE TABLE player_unlocks (
    unlock_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    player_id BIGINT NOT NULL,
    feature_name VARCHAR(100) NOT NULL,
    unlocked_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE,
    unlock_cost INT DEFAULT 0, -- 解锁所需技能点
    FOREIGN KEY (player_id) REFERENCES players(player_id) ON DELETE CASCADE,
    UNIQUE KEY unique_player_feature (player_id, feature_name),
    INDEX idx_player_id (player_id),
    INDEX idx_feature_name (feature_name)
);

-- 角色成就表
CREATE TABLE player_achievements (
    achievement_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    player_id BIGINT NOT NULL,
    achievement_type ENUM('trade', 'venture', 'wealth', 'level', 'loyalty', 'special') NOT NULL,
    achievement_name VARCHAR(100) NOT NULL,
    description TEXT,
    reward_gold DECIMAL(20,2) DEFAULT 0,
    reward_exp INT DEFAULT 0,
    reward_skill_points INT DEFAULT 0,
    achieved_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    progress_data JSON,
    FOREIGN KEY (player_id) REFERENCES players(player_id) ON DELETE CASCADE,
    INDEX idx_player_id (player_id),
    INDEX idx_achievement_type (achievement_type),
    INDEX idx_achieved_at (achieved_at)
);

-- 角色状态和设置表
CREATE TABLE player_settings (
    setting_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    player_id BIGINT NOT NULL,
    setting_name VARCHAR(100) NOT NULL,
    setting_value TEXT,
    setting_type ENUM('boolean', 'number', 'string', 'json') DEFAULT 'string',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (player_id) REFERENCES players(player_id) ON DELETE CASCADE,
    UNIQUE KEY unique_player_setting (player_id, setting_name),
    INDEX idx_player_id (player_id),
    INDEX idx_setting_name (setting_name)
);

-- 性格特质定义表
CREATE TABLE personality_traits (
    trait_id INT PRIMARY KEY AUTO_INCREMENT,
    trait_name VARCHAR(100) UNIQUE NOT NULL,
    trait_category ENUM('positive', 'negative', 'neutral') NOT NULL,
    description TEXT,
    
    -- 特质对各种活动的影响
    trade_modifier DECIMAL(4,2) DEFAULT 0.00,
    venture_modifier DECIMAL(4,2) DEFAULT 0.00,
    loyalty_modifier DECIMAL(4,2) DEFAULT 0.00,
    stress_modifier DECIMAL(4,2) DEFAULT 0.00,
    
    -- 特质之间的冲突和协同
    conflicting_traits JSON,
    synergy_traits JSON,
    
    rarity ENUM('common', 'uncommon', 'rare') DEFAULT 'common',
    INDEX idx_trait_name (trait_name),
    INDEX idx_category (trait_category),
    INDEX idx_rarity (rarity)
);

-- 角色特质关联表
CREATE TABLE player_traits (
    player_trait_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    player_id BIGINT NOT NULL,
    trait_id INT NOT NULL,
    acquired_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    trait_intensity DECIMAL(3,2) DEFAULT 1.00, -- 特质强度 0.1-3.0
    is_active BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (player_id) REFERENCES players(player_id) ON DELETE CASCADE,
    FOREIGN KEY (trait_id) REFERENCES personality_traits(trait_id) ON DELETE CASCADE,
    UNIQUE KEY unique_player_trait (player_id, trait_id),
    INDEX idx_player_id (player_id),
    INDEX idx_trait_id (trait_id)
);

-- 角色情绪和状态表
CREATE TABLE player_mood (
    mood_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    player_id BIGINT NOT NULL,
    
    -- 情绪状态
    happiness INT DEFAULT 50,       -- 快乐度 0-100
    stress INT DEFAULT 30,          -- 压力值 0-100
    motivation INT DEFAULT 70,      -- 动力值 0-100
    confidence INT DEFAULT 50,      -- 自信度 0-100
    
    -- 工作状态
    fatigue INT DEFAULT 0,          -- 疲劳度 0-100
    focus INT DEFAULT 80,           -- 专注度 0-100
    
    -- 社交状态
    team_relationship INT DEFAULT 50, -- 团队关系 0-100
    reputation INT DEFAULT 50,      -- 声誉 0-100
    
    -- 状态更新时间
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (player_id) REFERENCES players(player_id) ON DELETE CASCADE,
    INDEX idx_player_id (player_id),
    INDEX idx_last_updated (last_updated)
);

-- 角色工作记录表
CREATE TABLE player_work_history (
    work_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    player_id BIGINT NOT NULL,
    work_type ENUM('trade', 'venture', 'rest', 'training', 'social') NOT NULL,
    work_description TEXT,
    start_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    end_time TIMESTAMP NULL,
    duration_minutes INT DEFAULT 0,
    
    -- 工作结果
    success_rate DECIMAL(5,2) DEFAULT 0.00,
    experience_gained INT DEFAULT 0,
    mood_change JSON, -- 各种情绪的变化
    
    -- 相关ID
    related_trade_id BIGINT NULL,
    related_investment_id BIGINT NULL,
    
    FOREIGN KEY (player_id) REFERENCES players(player_id) ON DELETE CASCADE,
    INDEX idx_player_id (player_id),
    INDEX idx_work_type (work_type),
    INDEX idx_start_time (start_time)
); 