-- Trade模块相关表结构

-- 商品/资源信息表
CREATE TABLE commodities (
    commodity_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    commodity_name VARCHAR(100) UNIQUE NOT NULL,
    commodity_symbol VARCHAR(10) UNIQUE NOT NULL,
    category ENUM('metal', 'gem', 'herb', 'magic', 'rare', 'special') NOT NULL,
    rarity ENUM('common', 'uncommon', 'rare', 'epic', 'legendary') DEFAULT 'common',
    base_price DECIMAL(20,8) NOT NULL,
    current_price DECIMAL(20,8) NOT NULL,
    market_cap DECIMAL(30,2) DEFAULT 0,
    total_supply DECIMAL(30,8) DEFAULT 0,
    circulating_supply DECIMAL(30,8) DEFAULT 0,
    volatility_index DECIMAL(5,2) DEFAULT 0,
    price_change_24h DECIMAL(10,4) DEFAULT 0,
    volume_24h DECIMAL(30,8) DEFAULT 0,
    description TEXT,
    icon_url VARCHAR(255),
    is_tradeable BOOLEAN DEFAULT TRUE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_symbol (commodity_symbol),
    INDEX idx_category (category),
    INDEX idx_rarity (rarity),
    INDEX idx_current_price (current_price),
    INDEX idx_market_cap (market_cap),
    INDEX idx_volume_24h (volume_24h)
);

-- 价格历史记录表
CREATE TABLE price_history (
    history_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    commodity_id BIGINT NOT NULL,
    price DECIMAL(20,8) NOT NULL,
    volume DECIMAL(30,8) DEFAULT 0,
    market_cap DECIMAL(30,2) DEFAULT 0,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    price_source ENUM('market', 'adventure', 'event', 'admin') DEFAULT 'market',
    FOREIGN KEY (commodity_id) REFERENCES commodities(commodity_id) ON DELETE CASCADE,
    INDEX idx_commodity_id (commodity_id),
    INDEX idx_timestamp (timestamp),
    INDEX idx_price_source (price_source),
    INDEX idx_commodity_time (commodity_id, timestamp)
);

-- 交易订单表
CREATE TABLE trade_orders (
    order_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    player_id BIGINT NOT NULL,
    commodity_id BIGINT NOT NULL,
    order_type ENUM('buy', 'sell') NOT NULL,
    quantity DECIMAL(20,8) NOT NULL,
    price DECIMAL(20,8) NOT NULL,
    total_value DECIMAL(30,8) NOT NULL,
    filled_quantity DECIMAL(20,8) DEFAULT 0,
    remaining_quantity DECIMAL(20,8) NOT NULL,
    status ENUM('pending', 'partial', 'filled', 'cancelled', 'expired') DEFAULT 'pending',
    order_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    filled_time TIMESTAMP NULL,
    expires_at TIMESTAMP NULL,
    fees DECIMAL(20,8) DEFAULT 0,
    profit_loss DECIMAL(20,8) DEFAULT 0,
    notes TEXT,
    FOREIGN KEY (player_id) REFERENCES players(player_id) ON DELETE CASCADE,
    FOREIGN KEY (commodity_id) REFERENCES commodities(commodity_id) ON DELETE CASCADE,
    INDEX idx_player_id (player_id),
    INDEX idx_commodity_id (commodity_id),
    INDEX idx_order_type (order_type),
    INDEX idx_status (status),
    INDEX idx_order_time (order_time),
    INDEX idx_expires_at (expires_at)
);

-- 自动交易规则表
CREATE TABLE auto_trading_rules (
    rule_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    player_id BIGINT NOT NULL,
    commodity_id BIGINT NOT NULL,
    rule_name VARCHAR(100) NOT NULL,
    rule_type ENUM('stop_loss', 'take_profit', 'trailing_stop', 'grid_trading') NOT NULL,
    trigger_price DECIMAL(20,8),
    target_price DECIMAL(20,8),
    quantity DECIMAL(20,8) NOT NULL,
    max_quantity DECIMAL(20,8),
    is_active BOOLEAN DEFAULT TRUE,
    trigger_conditions JSON,
    execution_count INT DEFAULT 0,
    last_executed TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (player_id) REFERENCES players(player_id) ON DELETE CASCADE,
    FOREIGN KEY (commodity_id) REFERENCES commodities(commodity_id) ON DELETE CASCADE,
    INDEX idx_player_id (player_id),
    INDEX idx_commodity_id (commodity_id),
    INDEX idx_rule_type (rule_type),
    INDEX idx_is_active (is_active),
    INDEX idx_trigger_price (trigger_price)
);

-- 市场趋势分析表
CREATE TABLE market_trends (
    trend_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    commodity_id BIGINT NOT NULL,
    trend_type ENUM('bullish', 'bearish', 'sideways', 'volatile') NOT NULL,
    strength DECIMAL(5,2) NOT NULL,
    duration_hours INT NOT NULL,
    start_price DECIMAL(20,8) NOT NULL,
    end_price DECIMAL(20,8),
    volume_change DECIMAL(10,4) DEFAULT 0,
    market_sentiment DECIMAL(5,2) DEFAULT 0,
    contributing_factors JSON,
    start_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    end_time TIMESTAMP NULL,
    is_active BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (commodity_id) REFERENCES commodities(commodity_id) ON DELETE CASCADE,
    INDEX idx_commodity_id (commodity_id),
    INDEX idx_trend_type (trend_type),
    INDEX idx_start_time (start_time),
    INDEX idx_is_active (is_active)
);

-- 交易手续费设置表
CREATE TABLE trading_fees (
    fee_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    fee_type ENUM('maker', 'taker', 'withdrawal', 'deposit') NOT NULL,
    commodity_id BIGINT NULL,
    player_level INT DEFAULT 1,
    fee_rate DECIMAL(8,6) NOT NULL,
    minimum_fee DECIMAL(20,8) DEFAULT 0,
    maximum_fee DECIMAL(20,8) NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (commodity_id) REFERENCES commodities(commodity_id) ON DELETE CASCADE,
    INDEX idx_fee_type (fee_type),
    INDEX idx_commodity_id (commodity_id),
    INDEX idx_player_level (player_level)
); 