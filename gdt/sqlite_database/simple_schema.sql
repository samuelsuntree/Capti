
-- Simplified SQLite Schema for Capti Game Database

PRAGMA foreign_keys = ON;

-- Players table
CREATE TABLE players (
    player_id INTEGER PRIMARY KEY AUTOINCREMENT,
    character_code TEXT UNIQUE NOT NULL,
    character_name TEXT NOT NULL,
    display_name TEXT,
    avatar_url TEXT,
    character_class TEXT CHECK (character_class IN ('warrior', 'archer', 'explorer', 'scholar', 'mystic', 'survivor')) NOT NULL,
    rarity TEXT CHECK (rarity IN ('common', 'uncommon', 'rare', 'epic', 'legendary')) DEFAULT 'common',
    hire_cost REAL NOT NULL DEFAULT 1000.00,
    maintenance_cost REAL NOT NULL DEFAULT 100.00,
    employer_id TEXT NULL,
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
    personality_traits TEXT
);

-- Personality traits table
CREATE TABLE personality_traits (
    trait_id INTEGER PRIMARY KEY AUTOINCREMENT,
    trait_name TEXT UNIQUE NOT NULL,
    trait_category TEXT CHECK (trait_category IN ('positive', 'negative', 'neutral')) NOT NULL,
    description TEXT,
    trade_modifier REAL DEFAULT 0.00,
    venture_modifier REAL DEFAULT 0.00,
    loyalty_modifier REAL DEFAULT 0.00,
    stress_modifier REAL DEFAULT 0.00,
    conflicting_traits TEXT,
    synergy_traits TEXT,
    rarity TEXT CHECK (rarity IN ('common', 'uncommon', 'rare')) DEFAULT 'common'
);

-- Player mood table
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
    last_updated DATETIME DEFAULT (datetime('now')),
    FOREIGN KEY (player_id) REFERENCES players(player_id) ON DELETE CASCADE
);

-- Bulk commodities table
CREATE TABLE bulk_commodities (
    commodity_id INTEGER PRIMARY KEY AUTOINCREMENT,
    commodity_name TEXT UNIQUE NOT NULL,
    commodity_code TEXT UNIQUE NOT NULL,
    category TEXT CHECK (category IN ('currency', 'ore', 'herb', 'material', 'gem', 'other')) NOT NULL,
    rarity TEXT CHECK (rarity IN ('common', 'uncommon', 'rare', 'epic')) NOT NULL DEFAULT 'common',
    weight_per_unit REAL DEFAULT 0.00,
    description TEXT,
    obtainable_from TEXT,
    stack_limit INTEGER NOT NULL,
    is_main_currency INTEGER DEFAULT 0,
    exchange_rate REAL DEFAULT 1.00,
    can_exchange INTEGER DEFAULT 1,
    purity REAL DEFAULT 100.00,
    can_embed INTEGER DEFAULT 0,
    gem_effects TEXT,
    refine_ratio REAL DEFAULT 1.00,
    by_products TEXT,
    crafting_uses TEXT,
    preservation_days INTEGER DEFAULT NULL,
    effect_duration INTEGER DEFAULT NULL,
    potency REAL DEFAULT 1.00,
    base_value REAL NOT NULL,
    current_value REAL NOT NULL DEFAULT 0,
    market_cap REAL DEFAULT 0,
    total_supply REAL DEFAULT 0,
    circulating_supply REAL DEFAULT 0,
    volatility_index REAL DEFAULT 0,
    price_change_24h REAL DEFAULT 0,
    volume_24h REAL DEFAULT 0,
    last_trade_price REAL DEFAULT 0,
    last_trade_time DATETIME NULL,
    is_tradeable INTEGER DEFAULT 1,
    is_active INTEGER DEFAULT 1,
    created_at DATETIME DEFAULT (datetime('now')),
    updated_at DATETIME DEFAULT (datetime('now'))
);

-- Equipment types table
CREATE TABLE equipment_types (
    type_id INTEGER PRIMARY KEY AUTOINCREMENT,
    type_name TEXT UNIQUE NOT NULL,
    type_category TEXT CHECK (type_category IN ('weapon', 'armor', 'accessory', 'tool')) NOT NULL,
    equip_slot TEXT NOT NULL,
    can_dual_wield INTEGER DEFAULT 0,
    description TEXT
);

-- Equipment templates table
CREATE TABLE equipment_templates (
    template_id INTEGER PRIMARY KEY AUTOINCREMENT,
    equipment_name TEXT UNIQUE NOT NULL,
    type_id INTEGER NOT NULL,
    rarity TEXT CHECK (rarity IN ('common', 'uncommon', 'rare', 'epic', 'legendary')) NOT NULL,
    base_durability INTEGER NOT NULL,
    base_value REAL NOT NULL,
    level_requirement INTEGER DEFAULT 1,
    base_attributes TEXT,
    possible_affixes TEXT,
    is_craftable INTEGER DEFAULT 1,
    is_legendary INTEGER DEFAULT 0,
    max_instances INTEGER DEFAULT NULL,
    lore TEXT,
    special_abilities TEXT,
    discovery_condition TEXT,
    FOREIGN KEY (type_id) REFERENCES equipment_types(type_id)
);

-- Equipment instances table
CREATE TABLE equipment_instances (
    instance_id INTEGER PRIMARY KEY AUTOINCREMENT,
    template_id INTEGER NOT NULL,
    current_owner_id INTEGER NOT NULL,
    owner_type TEXT CHECK (owner_type IN ('player', 'trader', 'team')) NOT NULL,
    durability INTEGER NOT NULL,
    current_value REAL NOT NULL,
    attributes TEXT,
    creation_type TEXT CHECK (creation_type IN ('craft', 'loot', 'quest', 'discovery', 'system')) NOT NULL,
    creation_source TEXT,
    power_level REAL DEFAULT NULL,
    awakening_level INTEGER DEFAULT NULL,
    seal_level INTEGER DEFAULT NULL,
    FOREIGN KEY (template_id) REFERENCES equipment_templates(template_id)
);

-- Adventure teams table
CREATE TABLE adventure_teams (
    team_id INTEGER PRIMARY KEY AUTOINCREMENT,
    team_name TEXT UNIQUE NOT NULL,
    team_leader TEXT NOT NULL,
    team_size INTEGER NOT NULL,
    specialization TEXT CHECK (specialization IN ('combat', 'mining', 'exploration', 'trade', 'mixed')) NOT NULL,
    success_rate REAL DEFAULT 50.00,
    base_cost REAL NOT NULL,
    team_level INTEGER DEFAULT 1,
    team_description TEXT,
    current_status TEXT CHECK (current_status IN ('available', 'busy', 'disbanded')) DEFAULT 'available',
    morale REAL DEFAULT 50.00
);

-- Team members table
CREATE TABLE team_members (
    team_member_id INTEGER PRIMARY KEY AUTOINCREMENT,
    team_id INTEGER NOT NULL,
    player_id INTEGER NOT NULL,
    role TEXT CHECK (role IN ('leader', 'regular', 'specialist')) NOT NULL,
    contribution_score INTEGER DEFAULT 0,
    FOREIGN KEY (team_id) REFERENCES adventure_teams(team_id) ON DELETE CASCADE,
    FOREIGN KEY (player_id) REFERENCES players(player_id) ON DELETE CASCADE,
    UNIQUE(team_id, player_id)
);

-- Adventure projects table
CREATE TABLE adventure_projects (
    project_id INTEGER PRIMARY KEY AUTOINCREMENT,
    project_name TEXT UNIQUE NOT NULL,
    project_type TEXT CHECK (project_type IN ('exploration', 'dungeon', 'mining', 'trade', 'special')) NOT NULL,
    difficulty TEXT CHECK (difficulty IN ('easy', 'normal', 'hard', 'epic')) NOT NULL,
    required_team_size INTEGER NOT NULL,
    base_investment REAL NOT NULL,
    max_investment REAL NOT NULL,
    investment_goal REAL NOT NULL,
    expected_duration_hours INTEGER NOT NULL,
    risk_level REAL DEFAULT 0.30,
    expected_return_rate REAL DEFAULT 100.00,
    project_description TEXT,
    status TEXT CHECK (status IN ('funding', 'active', 'completed', 'failed')) DEFAULT 'funding'
);

-- Traders table
CREATE TABLE traders (
    trader_id INTEGER PRIMARY KEY AUTOINCREMENT,
    trader_code TEXT UNIQUE NOT NULL,
    display_name TEXT NOT NULL,
    avatar_url TEXT,
    trade_level INTEGER DEFAULT 1,
    trade_experience INTEGER DEFAULT 0,
    trade_reputation INTEGER DEFAULT 50,
    total_trades INTEGER DEFAULT 0,
    successful_trades INTEGER DEFAULT 0,
    gold_balance REAL DEFAULT 0.00,
    total_asset_value REAL DEFAULT 0.00,
    max_hired_players INTEGER DEFAULT 5,
    max_trade_orders INTEGER DEFAULT 10,
    daily_trade_limit REAL DEFAULT 10000.00,
    total_profit REAL DEFAULT 0.00,
    best_trade_profit REAL DEFAULT 0.00,
    biggest_loss REAL DEFAULT 0.00
);

-- Trader items table
CREATE TABLE trader_items (
    item_id INTEGER PRIMARY KEY AUTOINCREMENT,
    trader_id INTEGER NOT NULL,
    equipment_instance_id INTEGER NOT NULL,
    quantity INTEGER DEFAULT 1,
    purchase_price REAL NOT NULL,
    is_locked INTEGER DEFAULT 0,
    notes TEXT,
    FOREIGN KEY (trader_id) REFERENCES traders(trader_id) ON DELETE CASCADE,
    FOREIGN KEY (equipment_instance_id) REFERENCES equipment_instances(instance_id) ON DELETE CASCADE
);

-- Bulk commodity holdings table
CREATE TABLE bulk_commodity_holdings (
    holding_id INTEGER PRIMARY KEY AUTOINCREMENT,
    player_id INTEGER NOT NULL,
    commodity_id INTEGER NOT NULL,
    quantity REAL NOT NULL DEFAULT 0,
    average_acquisition_price REAL DEFAULT 0,
    FOREIGN KEY (player_id) REFERENCES players(player_id) ON DELETE CASCADE,
    FOREIGN KEY (commodity_id) REFERENCES bulk_commodities(commodity_id) ON DELETE CASCADE,
    UNIQUE(player_id, commodity_id)
);

-- Trader notifications table
CREATE TABLE trader_notifications (
    notification_id INTEGER PRIMARY KEY AUTOINCREMENT,
    trader_id INTEGER NOT NULL,
    notification_type TEXT CHECK (notification_type IN ('system', 'trade', 'venture', 'achievement')) NOT NULL,
    title TEXT NOT NULL,
    content TEXT NOT NULL,
    is_read INTEGER DEFAULT 0,
    created_at DATETIME DEFAULT (datetime('now')),
    FOREIGN KEY (trader_id) REFERENCES traders(trader_id) ON DELETE CASCADE
);

-- Create indexes
CREATE INDEX idx_players_character_class ON players(character_class);
CREATE INDEX idx_players_rarity ON players(rarity);
CREATE INDEX idx_players_employer ON players(employer_id);
CREATE INDEX idx_players_available ON players(is_available);
CREATE INDEX idx_commodities_category ON bulk_commodities(category);
CREATE INDEX idx_commodities_rarity ON bulk_commodities(rarity);
CREATE INDEX idx_equipment_templates_type ON equipment_templates(type_id);
CREATE INDEX idx_equipment_templates_rarity ON equipment_templates(rarity);
CREATE INDEX idx_teams_specialization ON adventure_teams(specialization);
CREATE INDEX idx_teams_status ON adventure_teams(current_status);
CREATE INDEX idx_projects_type ON adventure_projects(project_type);
CREATE INDEX idx_projects_status ON adventure_projects(status);
