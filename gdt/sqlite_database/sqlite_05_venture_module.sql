-- Converted from MySQL to SQLite
-- Original file: database/schema/05_venture_module.sql




CREATE TABLE adventure_teams (
    team_id INTEGER PRIMARY KEY AUTOINCREMENT,
    team_name VARCHAR(100) NOT NULL,
    team_leader VARCHAR(100) NOT NULL,
    team_size INTEGER NOT NULL DEFAULT 1,
    team_level INTEGER NOT NULL DEFAULT 1,
    experience_points INTEGER DEFAULT 0,
    success_rate DECIMAL(5,2) DEFAULT 50.00,
    specialization TEXT CHECK (specialization IN ('combat', 'mining', 'exploration', 'magic', 'stealth', 'survival')) NOT NULL,
    current_status TEXT CHECK (current_status IN ('available', 'on_mission', 'resting', 'disbanded')) DEFAULT 'available',
    base_cost DECIMAL(20,2) NOT NULL,
    reputation_score INTEGER DEFAULT 0,
    total_missions INTEGER DEFAULT 0,
    successful_missions INTEGER DEFAULT 0,
    equipment_level INTEGER DEFAULT 1,
    morale DECIMAL(5,2) DEFAULT 100.00,
    fatigue DECIMAL(5,2) DEFAULT 0.00,
    team_description TEXT,
    avatar_url VARCHAR(255),
    created_at DATETIME DEFAULT (datetime('now')),
    updated_at DATETIME DEFAULT (datetime('now')) 
);


CREATE TABLE team_members (
    member_id INTEGER PRIMARY KEY AUTOINCREMENT,
    team_id INTEGER NOT NULL,
    player_id INTEGER NOT NULL,
    role TEXT CHECK (role IN ('leader', 'regular', 'trainee')) NOT NULL,
    contribution_score INTEGER DEFAULT 0,
    joined_at DATETIME DEFAULT (datetime('now')),
    FOREIGN KEY (team_id) REFERENCES adventure_teams(team_id) ON DELETE CASCADE,
    FOREIGN KEY (player_id) REFERENCES players(player_id) ON DELETE CASCADE
);


CREATE TABLE adventure_projects (
    project_id INTEGER PRIMARY KEY AUTOINCREMENT,
    project_name VARCHAR(200) NOT NULL,
    project_type TEXT CHECK (project_type IN ('mining', 'dungeon', 'exploration', 'escort', 'investigation', 'special')) NOT NULL,
    difficulty TEXT CHECK (difficulty IN ('easy', 'normal', 'hard', 'extreme', 'legendary')) NOT NULL,
    required_team_size INTEGER DEFAULT 1,
    required_specialization TEXT CHECK (required_specialization IN ('combat', 'mining', 'exploration', 'magic', 'stealth', 'survival')) NULL,
    base_investment DECIMAL(20,2) NOT NULL,
    max_investment DECIMAL(20,2) NOT NULL,
    current_investment DECIMAL(20,2) DEFAULT 0,
    investment_goal DECIMAL(20,2) NOT NULL,
    expected_duration_hours INTEGER NOT NULL,
    risk_level DECIMAL(5,2) NOT NULL,
    expected_return_rate DECIMAL(5,2) NOT NULL,
    potential_rewards TEXT,
    status TEXT CHECK (status IN ('funding', 'ready', 'in_progress', 'completed', 'failed', 'cancelled')) DEFAULT 'funding',
    assigned_team_id INTEGER NULL,
    start_time DATETIME NULL,
    estimated_completion DATETIME NULL,
    actual_completion DATETIME NULL,
    location VARCHAR(200),
    project_description TEXT,
    special_requirements TEXT,
    created_at DATETIME DEFAULT (datetime('now')),
    updated_at DATETIME DEFAULT (datetime('now')) ,
    FOREIGN KEY (assigned_team_id) REFERENCES adventure_teams(team_id) ON DELETE SET NULL
);


CREATE TABLE investments (
    investment_id INTEGER PRIMARY KEY AUTOINCREMENT,
    player_id INTEGER NOT NULL,
    project_id INTEGER NOT NULL,
    investment_amount DECIMAL(20,2) NOT NULL,
    investment_share DECIMAL(10,6) NOT NULL,
    investment_type TEXT CHECK (investment_type IN ('standard', 'premium', 'exclusive')) DEFAULT 'standard',
    expected_return DECIMAL(20,2) NOT NULL,
    actual_return DECIMAL(20,2) DEFAULT 0,
    return_rate DECIMAL(10,4) DEFAULT 0,
    status TEXT CHECK (status IN ('active', 'completed', 'failed', 'cancelled')) DEFAULT 'active',
    investment_time DATETIME DEFAULT (datetime('now')),
    return_time DATETIME NULL,
    bonus_multiplier DECIMAL(5,2) DEFAULT 1.00,
    risk_insurance INTEGER DEFAULT 0,
    auto_reinvest INTEGER DEFAULT 0,
    notes TEXT,
    FOREIGN KEY (player_id) REFERENCES players(player_id) ON DELETE CASCADE,
    FOREIGN KEY (project_id) REFERENCES adventure_projects(project_id) ON DELETE CASCADE
);


CREATE TABLE adventure_results (
    result_id INTEGER PRIMARY KEY AUTOINCREMENT,
    project_id INTEGER NOT NULL,
    team_id INTEGER NOT NULL,
    outcome TEXT CHECK (outcome IN ('success', 'partial_success', 'failure', 'disaster', 'critical_success')) NOT NULL,
    success_rate DECIMAL(5,2) NOT NULL,
    total_return DECIMAL(20,2) NOT NULL,
    resources_found TEXT,
    casualties INTEGER DEFAULT 0,
    equipment_damage DECIMAL(5,2) DEFAULT 0,
    experience_gained INTEGER DEFAULT 0,
    reputation_change INTEGER DEFAULT 0,
    special_events TEXT,
    completion_time DATETIME DEFAULT (datetime('now')),
    duration_hours INTEGER NOT NULL,
    result_description TEXT,
    loot_distribution TEXT,
    market_impact TEXT,
    FOREIGN KEY (project_id) REFERENCES adventure_projects(project_id) ON DELETE CASCADE,
    FOREIGN KEY (team_id) REFERENCES adventure_teams(team_id) ON DELETE CASCADE
);


CREATE TABLE team_equipment (
    equipment_id INTEGER PRIMARY KEY AUTOINCREMENT,
    team_id INTEGER NOT NULL,
    equipment_type TEXT CHECK (equipment_type IN ('weapon', 'armor', 'tool', 'magic_item', 'consumable', 'transport')) NOT NULL,
    equipment_name VARCHAR(100) NOT NULL,
    equipment_level INTEGER DEFAULT 1,
    durability DECIMAL(5,2) DEFAULT 100.00,
    enhancement_level INTEGER DEFAULT 0,
    special_attributes TEXT,
    purchase_cost DECIMAL(20,2) NOT NULL,
    maintenance_cost DECIMAL(20,2) DEFAULT 0,
    equipped_at DATETIME DEFAULT (datetime('now')),
    last_maintenance DATETIME NULL,
    is_active INTEGER DEFAULT 1,
    FOREIGN KEY (team_id) REFERENCES adventure_teams(team_id) ON DELETE CASCADE
);


CREATE TABLE project_requirements (
    requirement_id INTEGER PRIMARY KEY AUTOINCREMENT,
    project_id INTEGER NOT NULL,
    requirement_type TEXT CHECK (requirement_type IN ('team_level', 'specialization', 'equipment', 'investment', 'reputation')) NOT NULL,
    requirement_value VARCHAR(200) NOT NULL,
    is_mandatory INTEGER DEFAULT 1,
    priority INTEGER DEFAULT 1,
    description TEXT,
    FOREIGN KEY (project_id) REFERENCES adventure_projects(project_id) ON DELETE CASCADE
);


CREATE TABLE investment_returns (
    return_id INTEGER PRIMARY KEY AUTOINCREMENT,
    investment_id INTEGER NOT NULL,
    result_id INTEGER NOT NULL,
    return_amount DECIMAL(20,2) NOT NULL,
    return_type TEXT CHECK (return_type IN ('gold', 'commodity', 'special_item', 'experience', 'reputation')) NOT NULL,
    commodity_id INTEGER NULL,
    quantity DECIMAL(20,8) DEFAULT 0,
    distribution_time DATETIME DEFAULT (datetime('now')),
    bonus_applied DECIMAL(5,2) DEFAULT 0,
    tax_deducted DECIMAL(20,2) DEFAULT 0,
    net_return DECIMAL(20,2) NOT NULL,
    FOREIGN KEY (investment_id) REFERENCES investments(investment_id) ON DELETE CASCADE,
    FOREIGN KEY (result_id) REFERENCES adventure_results(result_id) ON DELETE CASCADE,
    FOREIGN KEY (commodity_id) REFERENCES bulk_commodities(commodity_id) ON DELETE SET NULL
); 