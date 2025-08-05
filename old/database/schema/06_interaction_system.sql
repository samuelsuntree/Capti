-- 模块联动系统相关表结构

-- 市场事件表
CREATE TABLE market_events (
    event_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    event_type ENUM('supply_change', 'demand_surge', 'economic_crisis', 'discovery', 'shortage', 'speculation') NOT NULL,
    event_name VARCHAR(200) NOT NULL,
    affected_commodities JSON NOT NULL,
    impact_magnitude DECIMAL(5,2) NOT NULL,
    duration_hours INT NOT NULL,
    start_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    end_time TIMESTAMP NULL,
    trigger_source ENUM('adventure', 'trade', 'system', 'admin', 'random') NOT NULL,
    trigger_data JSON,
    price_impact JSON,
    volume_impact JSON,
    market_sentiment_change DECIMAL(5,2) DEFAULT 0,
    status ENUM('active', 'completed', 'cancelled') DEFAULT 'active',
    event_description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_event_type (event_type),
    INDEX idx_start_time (start_time),
    INDEX idx_end_time (end_time),
    INDEX idx_trigger_source (trigger_source),
    INDEX idx_status (status)
);

-- 冒险对市场的影响记录表
CREATE TABLE adventure_market_impacts (
    impact_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    result_id BIGINT NOT NULL,
    commodity_id BIGINT NOT NULL,
    impact_type ENUM('supply_increase', 'supply_decrease', 'demand_change', 'price_shock', 'market_disruption') NOT NULL,
    quantity_change DECIMAL(30,8) NOT NULL,
    price_change_percent DECIMAL(10,4) NOT NULL,
    market_cap_change DECIMAL(30,2) DEFAULT 0,
    volume_change DECIMAL(30,8) DEFAULT 0,
    impact_duration_hours INT NOT NULL,
    decay_rate DECIMAL(5,4) DEFAULT 0.1,
    start_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    end_time TIMESTAMP NULL,
    is_active BOOLEAN DEFAULT TRUE,
    impact_description TEXT,
    FOREIGN KEY (result_id) REFERENCES adventure_results(result_id) ON DELETE CASCADE,
    FOREIGN KEY (commodity_id) REFERENCES bulk_commodities(commodity_id) ON DELETE CASCADE,
    INDEX idx_result_id (result_id),
    INDEX idx_commodity_id (commodity_id),
    INDEX idx_impact_type (impact_type),
    INDEX idx_start_time (start_time),
    INDEX idx_is_active (is_active)
);

-- 市场对冒险的影响记录表
CREATE TABLE market_adventure_impacts (
    impact_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    event_id BIGINT NOT NULL,
    commodity_id BIGINT NOT NULL,
    impact_type ENUM('team_attraction', 'investment_surge', 'risk_change', 'cost_change', 'opportunity_creation') NOT NULL,
    affected_teams JSON,
    affected_projects JSON,
    investment_multiplier DECIMAL(5,2) DEFAULT 1.0,
    risk_modifier DECIMAL(5,2) DEFAULT 0,
    cost_modifier DECIMAL(5,2) DEFAULT 0,
    duration_hours INT NOT NULL,
    start_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    end_time TIMESTAMP NULL,
    is_active BOOLEAN DEFAULT TRUE,
    impact_description TEXT,
    FOREIGN KEY (event_id) REFERENCES market_events(event_id) ON DELETE CASCADE,
    FOREIGN KEY (commodity_id) REFERENCES bulk_commodities(commodity_id) ON DELETE CASCADE,
    INDEX idx_event_id (event_id),
    INDEX idx_commodity_id (commodity_id),
    INDEX idx_impact_type (impact_type),
    INDEX idx_start_time (start_time),
    INDEX idx_is_active (is_active)
);

-- 生态系统平衡表
CREATE TABLE ecosystem_balance (
    balance_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    commodity_id BIGINT NOT NULL,
    ecosystem_health DECIMAL(5,2) NOT NULL DEFAULT 100.00,
    exploitation_level DECIMAL(5,2) NOT NULL DEFAULT 0.00,
    regeneration_rate DECIMAL(5,4) NOT NULL DEFAULT 0.01,
    sustainability_threshold DECIMAL(5,2) NOT NULL DEFAULT 80.00,
    over_exploitation_penalty DECIMAL(5,2) DEFAULT 0,
    recovery_time_hours INT DEFAULT 0,
    last_exploitation_time TIMESTAMP NULL,
    environmental_events JSON,
    protection_measures JSON,
    status ENUM('healthy', 'stressed', 'degraded', 'critical', 'recovering') DEFAULT 'healthy',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (commodity_id) REFERENCES bulk_commodities(commodity_id) ON DELETE CASCADE,
    INDEX idx_commodity_id (commodity_id),
    INDEX idx_ecosystem_health (ecosystem_health),
    INDEX idx_exploitation_level (exploitation_level),
    INDEX idx_status (status)
);

-- 经济周期表
CREATE TABLE economic_cycles (
    cycle_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    cycle_name VARCHAR(100) NOT NULL,
    cycle_type ENUM('boom', 'bust', 'recession', 'recovery', 'stable') NOT NULL,
    current_phase ENUM('early', 'peak', 'late', 'transition') NOT NULL,
    duration_hours INT NOT NULL,
    progress_percent DECIMAL(5,2) DEFAULT 0,
    market_multiplier DECIMAL(5,2) DEFAULT 1.0,
    adventure_multiplier DECIMAL(5,2) DEFAULT 1.0,
    risk_modifier DECIMAL(5,2) DEFAULT 0,
    affected_sectors JSON,
    start_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    end_time TIMESTAMP NULL,
    is_active BOOLEAN DEFAULT TRUE,
    cycle_description TEXT,
    INDEX idx_cycle_type (cycle_type),
    INDEX idx_current_phase (current_phase),
    INDEX idx_start_time (start_time),
    INDEX idx_is_active (is_active)
);

-- 玩家行为影响表
CREATE TABLE player_behavior_impacts (
    impact_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    player_id BIGINT NOT NULL,
    behavior_type ENUM('mass_buying', 'mass_selling', 'market_manipulation', 'speculation', 'hoarding') NOT NULL,
    commodity_id BIGINT NOT NULL,
    action_volume DECIMAL(30,8) NOT NULL,
    market_impact_score DECIMAL(10,4) NOT NULL,
    price_influence DECIMAL(10,4) NOT NULL,
    volume_influence DECIMAL(10,4) NOT NULL,
    sentiment_influence DECIMAL(5,2) DEFAULT 0,
    trigger_threshold DECIMAL(20,8) NOT NULL,
    impact_duration_hours INT NOT NULL,
    decay_start_time TIMESTAMP NULL,
    action_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (player_id) REFERENCES players(player_id) ON DELETE CASCADE,
    FOREIGN KEY (commodity_id) REFERENCES bulk_commodities(commodity_id) ON DELETE CASCADE,
    INDEX idx_player_id (player_id),
    INDEX idx_behavior_type (behavior_type),
    INDEX idx_commodity_id (commodity_id),
    INDEX idx_action_time (action_time),
    INDEX idx_is_active (is_active)
);

-- 系统公告表
CREATE TABLE system_announcements (
    announcement_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    announcement_type ENUM('market_update', 'adventure_news', 'system_maintenance', 'event_notification', 'warning') NOT NULL,
    title VARCHAR(200) NOT NULL,
    content TEXT NOT NULL,
    priority ENUM('low', 'normal', 'high', 'urgent') DEFAULT 'normal',
    target_audience ENUM('all', 'traders', 'investors', 'high_level', 'premium') DEFAULT 'all',
    display_start TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    display_end TIMESTAMP NULL,
    is_active BOOLEAN DEFAULT TRUE,
    view_count INT DEFAULT 0,
    related_data JSON,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_announcement_type (announcement_type),
    INDEX idx_priority (priority),
    INDEX idx_display_start (display_start),
    INDEX idx_is_active (is_active)
); 