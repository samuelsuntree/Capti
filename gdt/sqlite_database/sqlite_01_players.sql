-- Converted from MySQL to SQLite
-- Original file: database/schema/01_players.sql





CREATE TABLE players (
    player_id INTEGER PRIMARY KEY AUTOINCREMENT,
    character_code VARCHAR(50) UNIQUE NOT NULL,  
    character_name VARCHAR(100) NOT NULL,
    display_name VARCHAR(100),
    avatar_url VARCHAR(255),
    character_class TEXT CHECK (character_class IN ('warrior', 'archer', 'explorer', 'scholar', 'mystic', 'survivor')) NOT NULL,
    rarity TEXT CHECK (rarity IN ('common', 'uncommon', 'rare', 'epic', 'legendary')) DEFAULT 'common',
    hire_cost DECIMAL(20,2) NOT NULL DEFAULT 1000.00,
    maintenance_cost DECIMAL(20,2) NOT NULL DEFAULT 100.00,
    employer_id VARCHAR(50) NULL, 
    is_available INTEGER DEFAULT 1,
    created_at DATETIME DEFAULT (datetime('now')),
    hired_at DATETIME NULL,
    
    
    strength INTEGER DEFAULT 10,        
    vitality INTEGER DEFAULT 10,        
    agility INTEGER DEFAULT 10,         
    intelligence INTEGER DEFAULT 10,    
    faith INTEGER DEFAULT 10,           
    luck INTEGER DEFAULT 10,            
    
    
    loyalty INTEGER DEFAULT 50,         
    courage INTEGER DEFAULT 50,         
    patience INTEGER DEFAULT 50,        
    greed INTEGER DEFAULT 50,           
    wisdom INTEGER DEFAULT 50,          
    charisma INTEGER DEFAULT 50,        
    
    
    trade_skill INTEGER DEFAULT 10,     
    venture_skill INTEGER DEFAULT 10,   
    negotiation_skill INTEGER DEFAULT 10, 
    analysis_skill INTEGER DEFAULT 10,  
    leadership_skill INTEGER DEFAULT 10, 
    
    
    total_experience INTEGER DEFAULT 0,
    current_level INTEGER DEFAULT 1,
    skill_points INTEGER DEFAULT 0,
    
    -- 性格特质（JSON存储，参考环世界）
    personality_traits TEXT
);


CREATE TABLE player_assets (
    asset_id INTEGER PRIMARY KEY AUTOINCREMENT,
    player_id INTEGER NOT NULL,
    asset_type TEXT CHECK (asset_type IN ('gold', 'commodity', 'venture_share', 'equipment', 'knowledge')) NOT NULL,
    asset_name VARCHAR(100) NOT NULL,
    quantity DECIMAL(20,8) NOT NULL DEFAULT 0,
    average_cost DECIMAL(20,8) DEFAULT 0,
    last_updated DATETIME DEFAULT (datetime('now')) ,
    is_locked INTEGER DEFAULT 0,
    equipment_quality TEXT CHECK (equipment_quality IN ('poor', 'common', 'good', 'excellent', 'masterwork')) DEFAULT 'common',
    FOREIGN KEY (player_id) REFERENCES players(player_id) ON DELETE CASCADE
);


CREATE TABLE player_levels (
    level_id INTEGER PRIMARY KEY AUTOINCREMENT,
    level_number INTEGER UNIQUE NOT NULL,
    required_exp INTEGER NOT NULL,
    max_trade_orders INTEGER DEFAULT 10,
    max_venture_investments INTEGER DEFAULT 5,
    unlock_auto_trading INTEGER DEFAULT 0,
    unlock_advanced_analysis INTEGER DEFAULT 0,
    unlock_team_influence INTEGER DEFAULT 0,
    skill_points_reward INTEGER DEFAULT 1,
    attribute_points_reward INTEGER DEFAULT 0,
    level_rewards TEXT,
    description TEXT
);


CREATE TABLE player_unlocks (
    unlock_id INTEGER PRIMARY KEY AUTOINCREMENT,
    player_id INTEGER NOT NULL,
    feature_name VARCHAR(100) NOT NULL,
    unlocked_at DATETIME DEFAULT (datetime('now')),
    is_active INTEGER DEFAULT 1,
    unlock_cost INTEGER DEFAULT 0, 
    FOREIGN KEY (player_id) REFERENCES players(player_id) ON DELETE CASCADE
);


CREATE TABLE player_achievements (
    achievement_id INTEGER PRIMARY KEY AUTOINCREMENT,
    player_id INTEGER NOT NULL,
    achievement_type TEXT CHECK (achievement_type IN ('trade', 'venture', 'wealth', 'level', 'loyalty', 'special')) NOT NULL,
    achievement_name VARCHAR(100) NOT NULL,
    description TEXT,
    reward_gold DECIMAL(20,2) DEFAULT 0,
    reward_exp INTEGER DEFAULT 0,
    reward_skill_points INTEGER DEFAULT 0,
    achieved_at DATETIME DEFAULT (datetime('now')),
    progress_data TEXT,
    FOREIGN KEY (player_id) REFERENCES players(player_id) ON DELETE CASCADE
);


CREATE TABLE player_settings (
    setting_id INTEGER PRIMARY KEY AUTOINCREMENT,
    player_id INTEGER NOT NULL,
    setting_name VARCHAR(100) NOT NULL,
    setting_value TEXT,
    setting_type TEXT CHECK (setting_type IN ('boolean', 'number', 'string', 'json')) DEFAULT 'string',
    created_at DATETIME DEFAULT (datetime('now')),
    updated_at DATETIME DEFAULT (datetime('now')) ,
    FOREIGN KEY (player_id) REFERENCES players(player_id) ON DELETE CASCADE
);


CREATE TABLE personality_traits (
    trait_id INTEGER PRIMARY KEY AUTOINCREMENT,
    trait_name VARCHAR(100) UNIQUE NOT NULL,
    trait_category TEXT CHECK (trait_category IN ('positive', 'negative', 'neutral')) NOT NULL,
    description TEXT,
    
    
    trade_modifier DECIMAL(4,2) DEFAULT 0.00,
    venture_modifier DECIMAL(4,2) DEFAULT 0.00,
    loyalty_modifier DECIMAL(4,2) DEFAULT 0.00,
    stress_modifier DECIMAL(4,2) DEFAULT 0.00,
    
    
    conflicting_traits TEXT,
    synergy_traits TEXT,
    
    rarity TEXT CHECK (rarity IN ('common', 'uncommon', 'rare')) DEFAULT 'common'
);


CREATE TABLE player_traits (
    player_trait_id INTEGER PRIMARY KEY AUTOINCREMENT,
    player_id INTEGER NOT NULL,
    trait_id INTEGER NOT NULL,
    acquired_at DATETIME DEFAULT (datetime('now')),
    trait_intensity DECIMAL(3,2) DEFAULT 1.00, 
    is_active INTEGER DEFAULT 1,
    FOREIGN KEY (player_id) REFERENCES players(player_id) ON DELETE CASCADE,
    FOREIGN KEY (trait_id) REFERENCES personality_traits(trait_id) ON DELETE CASCADE
);


CREATE TABLE player_mood (
    mood_id INTEGER PRIMARY KEY AUTOINCREMENT,
    player_id INTEGER NOT NULL,
    
    
    happiness INTEGER DEFAULT 50,       
    stress INTEGER DEFAULT 30,          
    motivation INTEGER DEFAULT 70,      
    confidence INTEGER DEFAULT 50,      
    
    
    fatigue INTEGER DEFAULT 0,          
    focus INTEGER DEFAULT 80,           
    
    
    team_relationship INTEGER DEFAULT 50, 
    reputation INTEGER DEFAULT 50,      
    
    
    last_updated DATETIME DEFAULT (datetime('now')) ,
    
    FOREIGN KEY (player_id) REFERENCES players(player_id) ON DELETE CASCADE
);


CREATE TABLE player_work_history (
    work_id INTEGER PRIMARY KEY AUTOINCREMENT,
    player_id INTEGER NOT NULL,
    work_type TEXT CHECK (work_type IN ('trade', 'venture', 'rest', 'training', 'social')) NOT NULL,
    work_description TEXT,
    start_time DATETIME DEFAULT (datetime('now')),
    end_time DATETIME NULL,
    duration_minutes INTEGER DEFAULT 0,
    
    
    success_rate DECIMAL(5,2) DEFAULT 0.00,
    experience_gained INTEGER DEFAULT 0,
    mood_change TEXT, 
    
    
    related_trade_id INTEGER NULL,
    related_investment_id INTEGER NULL,
    
    FOREIGN KEY (player_id) REFERENCES players(player_id) ON DELETE CASCADE
); 