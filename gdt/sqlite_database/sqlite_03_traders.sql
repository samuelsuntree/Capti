-- Converted from MySQL to SQLite
-- Original file: database/schema/03_traders.sql

-- =============================================
-- 交易员系统（真实玩家）相关表结构
-- =============================================

-- 交易员（玩家）基本信息表
CREATE TABLE traders (
    trader_id INTEGER PRIMARY KEY AUTOINCREMENT,
    trader_code VARCHAR(50) UNIQUE NOT NULL,     -- 交易员唯一编码
    display_name VARCHAR(100) NOT NULL,          -- 玩家昵称
    avatar_url VARCHAR(255),                     -- 头像URL
    created_at DATETIME DEFAULT (datetime('now')), -- 创建时间

    -- 交易相关
    trade_level INTEGER DEFAULT 1,                     -- 交易等级
    trade_experience INTEGER DEFAULT 0,                -- 交易经验
    trade_reputation INTEGER DEFAULT 50,               -- 交易信誉（0-100）
    total_trades INTEGER DEFAULT 0,                    -- 总交易次数
    successful_trades INTEGER DEFAULT 0,               -- 成功交易次数

    -- 资产相关
    gold_balance DECIMAL(20,2) DEFAULT 1000.00,    -- 金币余额
    total_asset_value DECIMAL(20,2) DEFAULT 0.00,  -- 总资产价值

    -- 限制相关
    max_hired_players INTEGER DEFAULT 5,               -- 最大雇佣角色数
    max_trade_orders INTEGER DEFAULT 10,               -- 最大挂单数
    daily_trade_limit DECIMAL(20,2),               -- 每日交易限额

    -- 统计信息
    total_profit DECIMAL(20,2) DEFAULT 0.00,       -- 总收益
    best_trade_profit DECIMAL(20,2) DEFAULT 0.00,  -- 最佳单笔收益
    biggest_loss DECIMAL(20,2) DEFAULT 0.00        -- 最大单笔亏损
);

-- 创建索引
CREATE INDEX idx_trader_code ON traders(trader_code);
CREATE INDEX idx_display_name ON traders(display_name);
CREATE INDEX idx_trade_level ON traders(trade_level);
CREATE INDEX idx_trade_reputation ON traders(trade_reputation);
CREATE INDEX idx_total_asset_value ON traders(total_asset_value);

-- 交易员等级表
CREATE TABLE trader_levels (
    level_id INTEGER PRIMARY KEY AUTOINCREMENT,
    level_number INTEGER UNIQUE NOT NULL,
    required_experience INTEGER NOT NULL,
    gold_reward DECIMAL(20,2) NOT NULL,            -- 升级奖励
    max_hired_players INTEGER NOT NULL,                -- 该等级可雇佣的最大角色数
    max_trade_orders INTEGER NOT NULL,                 -- 该等级可同时挂单数
    daily_trade_limit DECIMAL(20,2) NOT NULL,      -- 该等级每日交易限额
    commission_rate DECIMAL(5,4) NOT NULL,         -- 交易手续费率
    description TEXT
);

-- 创建索引
CREATE INDEX idx_level_number ON trader_levels(level_number);

-- 交易员成就表
CREATE TABLE trader_achievements (
    achievement_id INTEGER PRIMARY KEY AUTOINCREMENT,
    trader_id INTEGER NOT NULL,
    achievement_type TEXT CHECK (achievement_type IN ('trade_volume', 'profit_milestone', 'player_collection', 'equipment_master', 'market_influence', 'special')) NOT NULL,
    achievement_name VARCHAR(100) NOT NULL,
    description TEXT,
    achieved_at DATETIME DEFAULT (datetime('now')),
    reward_gold DECIMAL(20,2) DEFAULT 0,           -- 金币奖励
    reward_experience INTEGER DEFAULT 0,               -- 经验奖励
    reward_title VARCHAR(100),                     -- 称号奖励
    
    FOREIGN KEY (trader_id) REFERENCES traders(trader_id) ON DELETE CASCADE
);

-- 创建索引
CREATE INDEX idx_trader_achievement ON trader_achievements(trader_id, achievement_type);

-- 交易员当前雇佣的角色表
CREATE TABLE trader_hired_players (
    hire_id INTEGER PRIMARY KEY AUTOINCREMENT,
    trader_id INTEGER NOT NULL,
    player_id INTEGER NOT NULL,
    hired_at DATETIME DEFAULT (datetime('now')),
    contract_end_time DATETIME NULL,              -- NULL表示无限期
    hire_cost DECIMAL(20,2) NOT NULL,             -- 雇佣成本
    daily_maintenance DECIMAL(20,2) NOT NULL,      -- 每日维护费
    total_paid DECIMAL(20,2) DEFAULT 0,           -- 总支付费用
    is_active INTEGER DEFAULT 1,               -- 是否在职
    performance_rating DECIMAL(3,2) DEFAULT 5.00,  -- 表现评分(0-5)
    notes TEXT,
    
    FOREIGN KEY (trader_id) REFERENCES traders(trader_id) ON DELETE CASCADE,
    FOREIGN KEY (player_id) REFERENCES players(player_id) ON DELETE CASCADE
);

-- 创建唯一约束和索引
CREATE UNIQUE INDEX unique_player_hire ON trader_hired_players(player_id, is_active);
CREATE INDEX idx_trader_hired ON trader_hired_players(trader_id, is_active);

-- 交易员操作日志表
CREATE TABLE trader_activity_logs (
    log_id INTEGER PRIMARY KEY AUTOINCREMENT,
    trader_id INTEGER NOT NULL,
    activity_type TEXT CHECK (activity_type IN ('login', 'hire_player', 'fire_player', 'place_order', 'cancel_order', 'complete_trade', 'level_up', 'achievement', 'system')) NOT NULL,
    activity_time DATETIME DEFAULT (datetime('now')),
    ip_address VARCHAR(45),                        -- IPv4或IPv6地址
    details TEXT,                                  -- 详细信息
    status TEXT CHECK (status IN ('success', 'failed', 'pending')) NOT NULL,
    
    FOREIGN KEY (trader_id) REFERENCES traders(trader_id) ON DELETE CASCADE
);

-- 创建索引
CREATE INDEX idx_trader_activity ON trader_activity_logs(trader_id, activity_type);
CREATE INDEX idx_activity_time ON trader_activity_logs(activity_time);

-- 交易员通知表
CREATE TABLE trader_notifications (
    notification_id INTEGER PRIMARY KEY AUTOINCREMENT,
    trader_id INTEGER NOT NULL,
    notification_type TEXT CHECK (notification_type IN ('trade_complete', 'order_matched', 'player_contract', 'achievement', 'system', 'warning')) NOT NULL,
    title VARCHAR(100) NOT NULL,
    content TEXT NOT NULL,
    is_read INTEGER DEFAULT 0,
    created_at DATETIME DEFAULT (datetime('now')),
    expire_at DATETIME NULL,                      -- NULL表示永不过期
    
    FOREIGN KEY (trader_id) REFERENCES traders(trader_id) ON DELETE CASCADE
);

-- 创建索引
CREATE INDEX idx_trader_notification ON trader_notifications(trader_id, is_read);
CREATE INDEX idx_notification_time ON trader_notifications(created_at);

-- 交易员设置表
CREATE TABLE trader_settings (
    setting_id INTEGER PRIMARY KEY AUTOINCREMENT,
    trader_id INTEGER NOT NULL,
    setting_key VARCHAR(50) NOT NULL,
    setting_value TEXT,
    setting_type TEXT CHECK (setting_type IN ('notification', 'display', 'trade', 'security')) NOT NULL,
    updated_at DATETIME DEFAULT (datetime('now')),
    
    FOREIGN KEY (trader_id) REFERENCES traders(trader_id) ON DELETE CASCADE
);

-- 创建唯一约束
CREATE UNIQUE INDEX unique_trader_setting ON trader_settings(trader_id, setting_key);

-- 玩家持有的装备表
CREATE TABLE trader_items (
    trader_item_id INTEGER PRIMARY KEY AUTOINCREMENT,
    trader_id INTEGER NOT NULL,
    equipment_instance_id INTEGER NOT NULL,         -- 改为关联equipment_instances表
    quantity INTEGER DEFAULT 1,                        -- 持有数量
    acquired_at DATETIME DEFAULT (datetime('now')), -- 获得时间
    is_locked INTEGER DEFAULT 0,               -- 是否锁定（不可交易/出售）
    purchase_price DECIMAL(20,2),                  -- 购入价格
    notes TEXT,                                    -- 备注（如获得方式等）

    FOREIGN KEY (trader_id) REFERENCES traders(trader_id) ON DELETE CASCADE,
    FOREIGN KEY (equipment_instance_id) REFERENCES equipment_instances(instance_id) ON DELETE CASCADE
);

-- 创建索引
CREATE INDEX idx_trader_equipment ON trader_items(trader_id, equipment_instance_id);
CREATE INDEX idx_acquired_time ON trader_items(acquired_at);

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