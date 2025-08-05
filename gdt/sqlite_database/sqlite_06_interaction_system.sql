-- Converted from MySQL to SQLite
-- Original file: database/schema/06_interaction_system.sql




CREATE TABLE market_events (
    event_id INTEGER PRIMARY KEY AUTOINCREMENT,
    event_type TEXT CHECK (event_type IN ('supply_change', 'demand_surge', 'economic_crisis', 'discovery', 'shortage', 'speculation')) NOT NULL,
    event_name VARCHAR(200) NOT NULL,
    affected_commodities TEXT NOT NULL,
    impact_magnitude DECIMAL(5,2) NOT NULL,
    duration_hours INTEGER NOT NULL,
    start_time DATETIME DEFAULT (datetime('now')),
    end_time DATETIME NULL,
    trigger_source TEXT CHECK (trigger_source IN ('adventure', 'trade', 'system', 'admin', 'random')) NOT NULL,
    trigger_data TEXT,
    price_impact TEXT,
    volume_impact TEXT,
    market_sentiment_change DECIMAL(5,2) DEFAULT 0,
    status TEXT CHECK (status IN ('active', 'completed', 'cancelled')) DEFAULT 'active',
    event_description TEXT,
    created_at DATETIME DEFAULT (datetime('now')),
    updated_at DATETIME DEFAULT (datetime('now'))
);


CREATE TABLE adventure_market_impacts (
    impact_id INTEGER PRIMARY KEY AUTOINCREMENT,
    result_id INTEGER NOT NULL,
    commodity_id INTEGER NOT NULL,
    impact_type TEXT CHECK (impact_type IN ('supply_increase', 'supply_decrease', 'demand_change', 'price_shock', 'market_disruption')) NOT NULL,
    quantity_change DECIMAL(30,8) NOT NULL,
    price_change_percent DECIMAL(10,4) NOT NULL,
    market_cap_change DECIMAL(30,2) DEFAULT 0,
    volume_change DECIMAL(30,8) DEFAULT 0,
    impact_duration_hours INTEGER NOT NULL,
    decay_rate DECIMAL(5,4) DEFAULT 0.1,
    start_time DATETIME DEFAULT (datetime('now')),
    end_time DATETIME NULL,
    is_active INTEGER DEFAULT 1,
    impact_description TEXT,
    FOREIGN KEY (result_id) REFERENCES adventure_results(result_id) ON DELETE CASCADE,
    FOREIGN KEY (commodity_id) REFERENCES bulk_commodities(commodity_id) ON DELETE CASCADE
);


CREATE TABLE market_adventure_impacts (
    impact_id INTEGER PRIMARY KEY AUTOINCREMENT,
    event_id INTEGER NOT NULL,
    commodity_id INTEGER NOT NULL,
    impact_type TEXT CHECK (impact_type IN ('team_attraction', 'investment_surge', 'risk_change', 'cost_change', 'opportunity_creation')) NOT NULL,
    affected_teams TEXT,
    affected_projects TEXT,
    investment_multiplier DECIMAL(5,2) DEFAULT 1.0,
    risk_modifier DECIMAL(5,2) DEFAULT 0,
    cost_modifier DECIMAL(5,2) DEFAULT 0,
    duration_hours INTEGER NOT NULL,
    start_time DATETIME DEFAULT (datetime('now')),
    end_time DATETIME NULL,
    is_active INTEGER DEFAULT 1,
    impact_description TEXT,
    FOREIGN KEY (event_id) REFERENCES market_events(event_id) ON DELETE CASCADE,
    FOREIGN KEY (commodity_id) REFERENCES bulk_commodities(commodity_id) ON DELETE CASCADE
);


CREATE TABLE ecosystem_balance (
    balance_id INTEGER PRIMARY KEY AUTOINCREMENT,
    commodity_id INTEGER NOT NULL,
    ecosystem_health DECIMAL(5,2) NOT NULL DEFAULT 100.00,
    exploitation_level DECIMAL(5,2) NOT NULL DEFAULT 0.00,
    regeneration_rate DECIMAL(5,4) NOT NULL DEFAULT 0.01,
    sustainability_threshold DECIMAL(5,2) NOT NULL DEFAULT 80.00,
    over_exploitation_penalty DECIMAL(5,2) DEFAULT 0,
    recovery_time_hours INTEGER DEFAULT 0,
    last_exploitation_time DATETIME NULL,
    environmental_events TEXT,
    protection_measures TEXT,
    status TEXT CHECK (status IN ('healthy', 'stressed', 'degraded', 'critical', 'recovering')) DEFAULT 'healthy',
    updated_at DATETIME DEFAULT (datetime('now')) ,
    FOREIGN KEY (commodity_id) REFERENCES bulk_commodities(commodity_id) ON DELETE CASCADE
);


CREATE TABLE economic_cycles (
    cycle_id INTEGER PRIMARY KEY AUTOINCREMENT,
    cycle_name VARCHAR(100) NOT NULL,
    cycle_type TEXT CHECK (cycle_type IN ('boom', 'bust', 'recession', 'recovery', 'stable')) NOT NULL,
    current_phase TEXT CHECK (current_phase IN ('early', 'peak', 'late', 'transition')) NOT NULL,
    duration_hours INTEGER NOT NULL,
    progress_percent DECIMAL(5,2) DEFAULT 0,
    market_multiplier DECIMAL(5,2) DEFAULT 1.0,
    adventure_multiplier DECIMAL(5,2) DEFAULT 1.0,
    risk_modifier DECIMAL(5,2) DEFAULT 0,
    affected_sectors TEXT,
    start_time DATETIME DEFAULT (datetime('now')),
    end_time DATETIME NULL,
    is_active INTEGER DEFAULT 1,
    cycle_description TEXT
);


CREATE TABLE player_behavior_impacts (
    impact_id INTEGER PRIMARY KEY AUTOINCREMENT,
    player_id INTEGER NOT NULL,
    behavior_type TEXT CHECK (behavior_type IN ('mass_buying', 'mass_selling', 'market_manipulation', 'speculation', 'hoarding')) NOT NULL,
    commodity_id INTEGER NOT NULL,
    action_volume DECIMAL(30,8) NOT NULL,
    market_impact_score DECIMAL(10,4) NOT NULL,
    price_influence DECIMAL(10,4) NOT NULL,
    volume_influence DECIMAL(10,4) NOT NULL,
    sentiment_influence DECIMAL(5,2) DEFAULT 0,
    trigger_threshold DECIMAL(20,8) NOT NULL,
    impact_duration_hours INTEGER NOT NULL,
    decay_start_time DATETIME NULL,
    action_time DATETIME DEFAULT (datetime('now')),
    is_active INTEGER DEFAULT 1,
    FOREIGN KEY (player_id) REFERENCES players(player_id) ON DELETE CASCADE,
    FOREIGN KEY (commodity_id) REFERENCES bulk_commodities(commodity_id) ON DELETE CASCADE
);


CREATE TABLE system_announcements (
    announcement_id INTEGER PRIMARY KEY AUTOINCREMENT,
    announcement_type TEXT CHECK (announcement_type IN ('market_update', 'adventure_news', 'system_maintenance', 'event_notification', 'warning')) NOT NULL,
    title VARCHAR(200) NOT NULL,
    content TEXT NOT NULL,
    priority TEXT CHECK (priority IN ('low', 'normal', 'high', 'urgent')) DEFAULT 'normal',
    target_audience TEXT CHECK (target_audience IN ('all', 'traders', 'investors', 'high_level', 'premium')) DEFAULT 'all',
    display_start DATETIME DEFAULT (datetime('now')),
    display_end DATETIME NULL,
    is_active INTEGER DEFAULT 1,
    view_count INTEGER DEFAULT 0,
    related_data TEXT,
    created_at DATETIME DEFAULT (datetime('now'))
); 