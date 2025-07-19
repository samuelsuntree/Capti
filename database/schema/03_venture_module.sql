-- Venture模块相关表结构

-- 冒险队伍表
CREATE TABLE adventure_teams (
    team_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    team_name VARCHAR(100) NOT NULL,
    team_leader VARCHAR(100) NOT NULL,
    team_size INT NOT NULL DEFAULT 1,
    team_level INT NOT NULL DEFAULT 1,
    experience_points INT DEFAULT 0,
    success_rate DECIMAL(5,2) DEFAULT 50.00,
    specialization ENUM('combat', 'mining', 'exploration', 'magic', 'stealth', 'survival') NOT NULL,
    current_status ENUM('available', 'on_mission', 'resting', 'disbanded') DEFAULT 'available',
    base_cost DECIMAL(20,2) NOT NULL,
    reputation_score INT DEFAULT 0,
    total_missions INT DEFAULT 0,
    successful_missions INT DEFAULT 0,
    equipment_level INT DEFAULT 1,
    morale DECIMAL(5,2) DEFAULT 100.00,
    fatigue DECIMAL(5,2) DEFAULT 0.00,
    team_description TEXT,
    avatar_url VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_team_name (team_name),
    INDEX idx_specialization (specialization),
    INDEX idx_current_status (current_status),
    INDEX idx_success_rate (success_rate),
    INDEX idx_reputation_score (reputation_score)
);

-- 队伍成员关联表（添加唯一约束确保一个玩家只能在一个队伍中）
CREATE TABLE team_members (
    member_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    team_id BIGINT NOT NULL,
    player_id BIGINT NOT NULL,
    role ENUM('leader', 'regular', 'trainee') NOT NULL,
    contribution_score INT DEFAULT 0,
    joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (team_id) REFERENCES adventure_teams(team_id) ON DELETE CASCADE,
    FOREIGN KEY (player_id) REFERENCES players(player_id) ON DELETE CASCADE,
    UNIQUE KEY unique_player_team (player_id),  -- 新增：确保一个玩家只能在一个队伍中
    INDEX idx_team_id (team_id),
    INDEX idx_player_id (player_id),
    INDEX idx_role (role)
);

-- 冒险项目表
CREATE TABLE adventure_projects (
    project_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    project_name VARCHAR(200) NOT NULL,
    project_type ENUM('mining', 'dungeon', 'exploration', 'escort', 'investigation', 'special') NOT NULL,
    difficulty ENUM('easy', 'normal', 'hard', 'extreme', 'legendary') NOT NULL,
    required_team_size INT DEFAULT 1,
    required_specialization ENUM('combat', 'mining', 'exploration', 'magic', 'stealth', 'survival') NULL,
    base_investment DECIMAL(20,2) NOT NULL,
    max_investment DECIMAL(20,2) NOT NULL,
    current_investment DECIMAL(20,2) DEFAULT 0,
    investment_goal DECIMAL(20,2) NOT NULL,
    expected_duration_hours INT NOT NULL,
    risk_level DECIMAL(5,2) NOT NULL,
    expected_return_rate DECIMAL(5,2) NOT NULL,
    potential_rewards JSON,
    status ENUM('funding', 'ready', 'in_progress', 'completed', 'failed', 'cancelled') DEFAULT 'funding',
    assigned_team_id BIGINT NULL,
    start_time TIMESTAMP NULL,
    estimated_completion TIMESTAMP NULL,
    actual_completion TIMESTAMP NULL,
    location VARCHAR(200),
    project_description TEXT,
    special_requirements TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (assigned_team_id) REFERENCES adventure_teams(team_id) ON DELETE SET NULL,
    INDEX idx_project_type (project_type),
    INDEX idx_difficulty (difficulty),
    INDEX idx_status (status),
    INDEX idx_risk_level (risk_level),
    INDEX idx_expected_return_rate (expected_return_rate),
    INDEX idx_start_time (start_time)
);

-- 投资记录表
CREATE TABLE investments (
    investment_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    player_id BIGINT NOT NULL,
    project_id BIGINT NOT NULL,
    investment_amount DECIMAL(20,2) NOT NULL,
    investment_share DECIMAL(10,6) NOT NULL,
    investment_type ENUM('standard', 'premium', 'exclusive') DEFAULT 'standard',
    expected_return DECIMAL(20,2) NOT NULL,
    actual_return DECIMAL(20,2) DEFAULT 0,
    return_rate DECIMAL(10,4) DEFAULT 0,
    status ENUM('active', 'completed', 'failed', 'cancelled') DEFAULT 'active',
    investment_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    return_time TIMESTAMP NULL,
    bonus_multiplier DECIMAL(5,2) DEFAULT 1.00,
    risk_insurance BOOLEAN DEFAULT FALSE,
    auto_reinvest BOOLEAN DEFAULT FALSE,
    notes TEXT,
    FOREIGN KEY (player_id) REFERENCES players(player_id) ON DELETE CASCADE,
    FOREIGN KEY (project_id) REFERENCES adventure_projects(project_id) ON DELETE CASCADE,
    INDEX idx_player_id (player_id),
    INDEX idx_project_id (project_id),
    INDEX idx_status (status),
    INDEX idx_investment_time (investment_time),
    INDEX idx_return_rate (return_rate)
);

-- 冒险结果表
CREATE TABLE adventure_results (
    result_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    project_id BIGINT NOT NULL,
    team_id BIGINT NOT NULL,
    outcome ENUM('success', 'partial_success', 'failure', 'disaster', 'critical_success') NOT NULL,
    success_rate DECIMAL(5,2) NOT NULL,
    total_return DECIMAL(20,2) NOT NULL,
    resources_found JSON,
    casualties INT DEFAULT 0,
    equipment_damage DECIMAL(5,2) DEFAULT 0,
    experience_gained INT DEFAULT 0,
    reputation_change INT DEFAULT 0,
    special_events JSON,
    completion_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    duration_hours INT NOT NULL,
    result_description TEXT,
    loot_distribution JSON,
    market_impact JSON,
    FOREIGN KEY (project_id) REFERENCES adventure_projects(project_id) ON DELETE CASCADE,
    FOREIGN KEY (team_id) REFERENCES adventure_teams(team_id) ON DELETE CASCADE,
    INDEX idx_project_id (project_id),
    INDEX idx_team_id (team_id),
    INDEX idx_outcome (outcome),
    INDEX idx_completion_time (completion_time),
    INDEX idx_total_return (total_return)
);

-- 冒险队伍装备表
CREATE TABLE team_equipment (
    equipment_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    team_id BIGINT NOT NULL,
    equipment_type ENUM('weapon', 'armor', 'tool', 'magic_item', 'consumable', 'transport') NOT NULL,
    equipment_name VARCHAR(100) NOT NULL,
    equipment_level INT DEFAULT 1,
    durability DECIMAL(5,2) DEFAULT 100.00,
    enhancement_level INT DEFAULT 0,
    special_attributes JSON,
    purchase_cost DECIMAL(20,2) NOT NULL,
    maintenance_cost DECIMAL(20,2) DEFAULT 0,
    equipped_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_maintenance TIMESTAMP NULL,
    is_active BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (team_id) REFERENCES adventure_teams(team_id) ON DELETE CASCADE,
    INDEX idx_team_id (team_id),
    INDEX idx_equipment_type (equipment_type),
    INDEX idx_equipment_level (equipment_level),
    INDEX idx_durability (durability)
);

-- 冒险项目需求表
CREATE TABLE project_requirements (
    requirement_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    project_id BIGINT NOT NULL,
    requirement_type ENUM('team_level', 'specialization', 'equipment', 'investment', 'reputation') NOT NULL,
    requirement_value VARCHAR(200) NOT NULL,
    is_mandatory BOOLEAN DEFAULT TRUE,
    priority INT DEFAULT 1,
    description TEXT,
    FOREIGN KEY (project_id) REFERENCES adventure_projects(project_id) ON DELETE CASCADE,
    INDEX idx_project_id (project_id),
    INDEX idx_requirement_type (requirement_type),
    INDEX idx_priority (priority)
);

-- 投资收益分配表
CREATE TABLE investment_returns (
    return_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    investment_id BIGINT NOT NULL,
    result_id BIGINT NOT NULL,
    return_amount DECIMAL(20,2) NOT NULL,
    return_type ENUM('gold', 'commodity', 'special_item', 'experience', 'reputation') NOT NULL,
    commodity_id BIGINT NULL,
    quantity DECIMAL(20,8) DEFAULT 0,
    distribution_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    bonus_applied DECIMAL(5,2) DEFAULT 0,
    tax_deducted DECIMAL(20,2) DEFAULT 0,
    net_return DECIMAL(20,2) NOT NULL,
    FOREIGN KEY (investment_id) REFERENCES investments(investment_id) ON DELETE CASCADE,
    FOREIGN KEY (result_id) REFERENCES adventure_results(result_id) ON DELETE CASCADE,
    FOREIGN KEY (commodity_id) REFERENCES commodities(commodity_id) ON DELETE SET NULL,
    INDEX idx_investment_id (investment_id),
    INDEX idx_result_id (result_id),
    INDEX idx_return_type (return_type),
    INDEX idx_distribution_time (distribution_time)
); 