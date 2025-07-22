-- =============================================
-- 交易员系统（真实玩家）相关表结构
-- =============================================

-- 交易员（玩家）基本信息表
CREATE TABLE traders (
    trader_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    trader_code VARCHAR(50) UNIQUE NOT NULL,     -- 交易员唯一编码
    display_name VARCHAR(100) NOT NULL,          -- 玩家昵称
    avatar_url VARCHAR(255),                     -- 头像URL
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- 创建时间

    -- 交易相关
    trade_level INT DEFAULT 1,                     -- 交易等级
    trade_experience INT DEFAULT 0,                -- 交易经验
    trade_reputation INT DEFAULT 50,               -- 交易信誉（0-100）
    total_trades INT DEFAULT 0,                    -- 总交易次数
    successful_trades INT DEFAULT 0,               -- 成功交易次数

    -- 资产相关
    gold_balance DECIMAL(20,2) DEFAULT 1000.00,    -- 金币余额
    total_asset_value DECIMAL(20,2) DEFAULT 0.00,  -- 总资产价值

    -- 限制相关
    max_hired_players INT DEFAULT 5,               -- 最大雇佣角色数
    max_trade_orders INT DEFAULT 10,               -- 最大挂单数
    daily_trade_limit DECIMAL(20,2),               -- 每日交易限额

    -- 统计信息
    total_profit DECIMAL(20,2) DEFAULT 0.00,       -- 总收益
    best_trade_profit DECIMAL(20,2) DEFAULT 0.00,  -- 最佳单笔收益
    biggest_loss DECIMAL(20,2) DEFAULT 0.00,       -- 最大单笔亏损

    INDEX idx_trader_code (trader_code),
    INDEX idx_display_name (display_name),
    INDEX idx_trade_level (trade_level),
    INDEX idx_trade_reputation (trade_reputation),
    INDEX idx_total_asset_value (total_asset_value)
);

-- 交易员等级表
CREATE TABLE trader_levels (
    level_id INT PRIMARY KEY AUTO_INCREMENT,
    level_number INT UNIQUE NOT NULL,
    required_experience INT NOT NULL,
    gold_reward DECIMAL(20,2) NOT NULL,            -- 升级奖励
    max_hired_players INT NOT NULL,                -- 该等级可雇佣的最大角色数
    max_trade_orders INT NOT NULL,                 -- 该等级可同时挂单数
    daily_trade_limit DECIMAL(20,2) NOT NULL,      -- 该等级每日交易限额
    commission_rate DECIMAL(5,4) NOT NULL,         -- 交易手续费率
    description TEXT,
    
    INDEX idx_level_number (level_number)
);

-- 交易员成就表
CREATE TABLE trader_achievements (
    achievement_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    trader_id BIGINT NOT NULL,
    achievement_type ENUM(
        'trade_volume',        -- 交易量
        'profit_milestone',    -- 盈利里程碑
        'player_collection',   -- 角色收集
        'equipment_master',    -- 装备大师
        'market_influence',    -- 市场影响力
        'special'             -- 特殊成就
    ) NOT NULL,
    achievement_name VARCHAR(100) NOT NULL,
    description TEXT,
    achieved_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    reward_gold DECIMAL(20,2) DEFAULT 0,           -- 金币奖励
    reward_experience INT DEFAULT 0,               -- 经验奖励
    reward_title VARCHAR(100),                     -- 称号奖励
    
    FOREIGN KEY (trader_id) REFERENCES traders(trader_id) ON DELETE CASCADE,
    INDEX idx_trader_achievement (trader_id, achievement_type)
);

-- 交易员当前雇佣的角色表
CREATE TABLE trader_hired_players (
    hire_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    trader_id BIGINT NOT NULL,
    player_id BIGINT NOT NULL,
    hired_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    contract_end_time TIMESTAMP NULL,              -- NULL表示无限期
    hire_cost DECIMAL(20,2) NOT NULL,             -- 雇佣成本
    daily_maintenance DECIMAL(20,2) NOT NULL,      -- 每日维护费
    total_paid DECIMAL(20,2) DEFAULT 0,           -- 总支付费用
    is_active BOOLEAN DEFAULT TRUE,               -- 是否在职
    performance_rating DECIMAL(3,2) DEFAULT 5.00,  -- 表现评分(0-5)
    notes TEXT,
    
    FOREIGN KEY (trader_id) REFERENCES traders(trader_id) ON DELETE CASCADE,
    FOREIGN KEY (player_id) REFERENCES players(player_id) ON DELETE CASCADE,
    UNIQUE KEY unique_player_hire (player_id, is_active),
    INDEX idx_trader_hired (trader_id, is_active)
);

-- 交易员操作日志表
CREATE TABLE trader_activity_logs (
    log_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    trader_id BIGINT NOT NULL,
    activity_type ENUM(
        'login',              -- 登录
        'hire_player',        -- 雇佣角色
        'fire_player',        -- 解雇角色
        'place_order',        -- 下单
        'cancel_order',       -- 取消订单
        'complete_trade',     -- 完成交易
        'level_up',          -- 升级
        'achievement',        -- 获得成就
        'system'             -- 系统操作
    ) NOT NULL,
    activity_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ip_address VARCHAR(45),                        -- IPv4或IPv6地址
    details JSON,                                  -- 详细信息
    status ENUM('success', 'failed', 'pending') NOT NULL,
    
    FOREIGN KEY (trader_id) REFERENCES traders(trader_id) ON DELETE CASCADE,
    INDEX idx_trader_activity (trader_id, activity_type),
    INDEX idx_activity_time (activity_time)
);

-- 交易员通知表
CREATE TABLE trader_notifications (
    notification_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    trader_id BIGINT NOT NULL,
    notification_type ENUM(
        'trade_complete',     -- 交易完成
        'order_matched',      -- 订单匹配
        'player_contract',    -- 角色合约相关
        'achievement',        -- 成就达成
        'system',            -- 系统通知
        'warning'            -- 警告信息
    ) NOT NULL,
    title VARCHAR(100) NOT NULL,
    content TEXT NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expire_at TIMESTAMP NULL,                      -- NULL表示永不过期
    
    FOREIGN KEY (trader_id) REFERENCES traders(trader_id) ON DELETE CASCADE,
    INDEX idx_trader_notification (trader_id, is_read),
    INDEX idx_notification_time (created_at)
);

-- 交易员设置表
CREATE TABLE trader_settings (
    setting_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    trader_id BIGINT NOT NULL,
    setting_key VARCHAR(50) NOT NULL,
    setting_value TEXT,
    setting_type ENUM('notification', 'display', 'trade', 'security') NOT NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (trader_id) REFERENCES traders(trader_id) ON DELETE CASCADE,
    UNIQUE KEY unique_trader_setting (trader_id, setting_key)
);

-- 玩家持有的装备表
CREATE TABLE trader_items (
    trader_item_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    trader_id BIGINT NOT NULL,
    equipment_instance_id BIGINT NOT NULL,         -- 改为关联equipment_instances表
    quantity INT DEFAULT 1,                        -- 持有数量
    acquired_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- 获得时间
    is_locked BOOLEAN DEFAULT FALSE,               -- 是否锁定（不可交易/出售）
    purchase_price DECIMAL(20,2),                  -- 购入价格
    notes TEXT,                                    -- 备注（如获得方式等）

    FOREIGN KEY (trader_id) REFERENCES traders(trader_id) ON DELETE CASCADE,
    FOREIGN KEY (equipment_instance_id) REFERENCES equipment_instances(instance_id) ON DELETE CASCADE,
    
    -- 索引优化查询性能
    INDEX idx_trader_equipment (trader_id, equipment_instance_id),
    INDEX idx_acquired_time (acquired_at)
);

-- 初始化交易员等级数据
INSERT INTO trader_levels 
(level_number, required_experience, gold_reward, max_hired_players, max_trade_orders, daily_trade_limit, commission_rate, description)
VALUES
(1, 0, 0, 5, 10, 10000.00, 0.0100, '初级交易员'),
(2, 1000, 1000.00, 7, 15, 20000.00, 0.0090, '见习交易员'),
(3, 3000, 2000.00, 10, 20, 50000.00, 0.0080, '熟练交易员'),
(4, 6000, 3000.00, 12, 25, 100000.00, 0.0070, '专业交易员'),
(5, 10000, 5000.00, 15, 30, 200000.00, 0.0060, '高级交易员'),
(6, 15000, 8000.00, 18, 40, 500000.00, 0.0050, '专家交易员'),
(7, 25000, 12000.00, 22, 50, 1000000.00, 0.0040, '精英交易员'),
(8, 40000, 20000.00, 26, 60, 2000000.00, 0.0030, '大师交易员'),
(9, 60000, 30000.00, 30, 80, 5000000.00, 0.0020, '宗师交易员'),
(10, 100000, 50000.00, 35, 100, 10000000.00, 0.0010, '传奇交易员'); 