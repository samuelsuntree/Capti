-- Converted from MySQL to SQLite
-- Original file: database/schema/04_trade_module.sql

-- Trade模块相关表结构

-- =============================================
-- 1. 价格历史系统
-- =============================================

-- 价格历史记录表（大宗货品）
CREATE TABLE bulk_commodity_price_history (
    history_id INTEGER PRIMARY KEY AUTOINCREMENT,
    commodity_id INTEGER NOT NULL,
    timestamp DATETIME DEFAULT (datetime('now')),
    
    -- 价格信息
    buy_price DECIMAL(20,8) NOT NULL, -- 当前最高买入价
    sell_price DECIMAL(20,8) NOT NULL, -- 当前最低卖出价
    avg_price DECIMAL(20,8) NOT NULL, -- 当前成交均价
    
    -- 交易量信息
    buy_volume DECIMAL(30,8) DEFAULT 0, -- 买入总量
    sell_volume DECIMAL(30,8) DEFAULT 0, -- 卖出总量
    total_volume DECIMAL(30,8) DEFAULT 0, -- 总成交量
    turnover DECIMAL(30,2) DEFAULT 0, -- 总成交额
    
    -- 市值信息
    market_cap DECIMAL(30,2) DEFAULT 0, -- 总市值
    circulating_market_cap DECIMAL(30,2) DEFAULT 0, -- 流通市值
    
    -- 来源信息
    price_source TEXT CHECK (price_source IN ('market', 'adventure', 'event', 'admin')) NOT NULL,
    source_reference VARCHAR(100), -- 来源引用（如事件ID、冒险ID等）
    source_details TEXT, -- 详细来源信息
    
    -- 备注
    notes TEXT,
    
    FOREIGN KEY (commodity_id) REFERENCES bulk_commodities(commodity_id) ON DELETE CASCADE
);

-- 创建索引
CREATE INDEX idx_commodity_time ON bulk_commodity_price_history(commodity_id, timestamp);
CREATE INDEX idx_price_source ON bulk_commodity_price_history(price_source, timestamp);

-- 价格历史记录表（装备模板）
CREATE TABLE equipment_price_history (
    history_id INTEGER PRIMARY KEY AUTOINCREMENT,
    template_id INTEGER NOT NULL,
    timestamp DATETIME DEFAULT (datetime('now')),
    
    -- 价格信息
    buy_price DECIMAL(20,8) NOT NULL, -- 当前最高买入价
    sell_price DECIMAL(20,8) NOT NULL, -- 当前最低卖出价
    avg_price DECIMAL(20,8) NOT NULL, -- 当前成交均价
    
    -- 交易量信息
    buy_count INTEGER DEFAULT 0, -- 买入数量
    sell_count INTEGER DEFAULT 0, -- 卖出数量
    total_count INTEGER DEFAULT 0, -- 总成交数
    turnover DECIMAL(30,2) DEFAULT 0, -- 总成交额
    
    -- 市值信息
    market_cap DECIMAL(30,2) DEFAULT 0, -- 总市值（基于当前均价）
    circulating_market_cap DECIMAL(30,2) DEFAULT 0, -- 流通市值（未损坏装备）
    
    -- 来源信息
    price_source TEXT CHECK (price_source IN ('market', 'adventure', 'event', 'admin')) NOT NULL,
    source_reference VARCHAR(100),
    source_details TEXT,
    
    -- 备注
    notes TEXT,
    
    FOREIGN KEY (template_id) REFERENCES equipment_templates(template_id) ON DELETE CASCADE
);

-- 创建索引
CREATE INDEX idx_template_time ON equipment_price_history(template_id, timestamp);
CREATE INDEX idx_price_source_equipment ON equipment_price_history(price_source, timestamp);

-- =============================================
-- 2. 交易订单系统
-- =============================================

-- 订单主表（支持大宗货品和装备）
CREATE TABLE trade_orders (
    order_id INTEGER PRIMARY KEY AUTOINCREMENT,
    player_id INTEGER NOT NULL,
    item_type TEXT CHECK (item_type IN ('bulk_commodity', 'equipment')) NOT NULL, -- 交易物品类型
    item_id INTEGER NOT NULL, -- bulk_commodities.commodity_id 或 equipment_templates.template_id
    order_type TEXT CHECK (order_type IN ('buy', 'sell')) NOT NULL,
    
    -- 价格和数量
    price DECIMAL(20,8) NOT NULL, -- 单价
    quantity DECIMAL(20,8) NOT NULL, -- 总数量（装备类型固定为1）
    total_value DECIMAL(30,8) NOT NULL, -- 总价值
    filled_quantity DECIMAL(20,8) DEFAULT 0, -- 已成交数量
    remaining_quantity DECIMAL(20,8) NOT NULL, -- 剩余数量
    
    -- 订单状态
    status TEXT CHECK (status IN ('pending', 'partial', 'filled', 'cancelled', 'expired')) DEFAULT 'pending',
    
    -- 时间信息
    order_time DATETIME DEFAULT (datetime('now')),
    last_update_time DATETIME DEFAULT (datetime('now')),
    filled_time DATETIME NULL, -- 完全成交时间
    expires_at DATETIME NULL, -- 过期时间
    
    -- 费用计算
    base_fee_rate DECIMAL(8,6) NOT NULL, -- 基础费率
    discount_rate DECIMAL(8,6) DEFAULT 0, -- 折扣率
    final_fee_rate DECIMAL(8,6) NOT NULL, -- 最终费率
    estimated_fees DECIMAL(20,8) NOT NULL, -- 预估费用
    actual_fees DECIMAL(20,8) DEFAULT 0, -- 实际费用
    
    -- 盈亏计算（卖单用）
    avg_buy_price DECIMAL(20,8) NULL, -- 平均买入价（用于计算盈亏）
    profit_loss DECIMAL(20,8) DEFAULT 0, -- 盈亏金额
    profit_loss_rate DECIMAL(8,6) DEFAULT 0, -- 盈亏率
    
    -- 其他信息
    is_margin_trade INTEGER DEFAULT 0, -- 是否保证金交易
    is_auto_generated INTEGER DEFAULT 0, -- 是否自动生成的订单
    auto_rule_id INTEGER NULL, -- 关联的自动交易规则ID
    notes TEXT,
    
    FOREIGN KEY (player_id) REFERENCES players(player_id) ON DELETE CASCADE
);

-- 创建索引
CREATE INDEX idx_player_item ON trade_orders(player_id, item_type, item_id);
CREATE INDEX idx_order_type ON trade_orders(order_type, status);
CREATE INDEX idx_price ON trade_orders(price);
CREATE INDEX idx_time ON trade_orders(order_time, status);

-- 订单成交记录表
CREATE TABLE trade_executions (
    execution_id INTEGER PRIMARY KEY AUTOINCREMENT,
    buy_order_id INTEGER NOT NULL,
    sell_order_id INTEGER NOT NULL,
    executed_price DECIMAL(20,8) NOT NULL,
    executed_quantity DECIMAL(20,8) NOT NULL,
    execution_value DECIMAL(30,8) NOT NULL,
    execution_time DATETIME DEFAULT (datetime('now')),
    
    -- 买方信息
    buyer_id INTEGER NOT NULL,
    buyer_fee DECIMAL(20,8) NOT NULL,
    buyer_total DECIMAL(30,8) NOT NULL, -- 总支付金额（含费用）
    
    -- 卖方信息
    seller_id INTEGER NOT NULL,
    seller_fee DECIMAL(20,8) NOT NULL,
    seller_total DECIMAL(30,8) NOT NULL, -- 总收到金额（扣除费用）
    
    -- 其他信息
    market_price DECIMAL(20,8) NOT NULL, -- 成交时的市场价
    price_impact DECIMAL(8,6) DEFAULT 0, -- 价格影响
    
    FOREIGN KEY (buy_order_id) REFERENCES trade_orders(order_id),
    FOREIGN KEY (sell_order_id) REFERENCES trade_orders(order_id),
    FOREIGN KEY (buyer_id) REFERENCES players(player_id),
    FOREIGN KEY (seller_id) REFERENCES players(player_id)
);

-- 创建索引
CREATE INDEX idx_orders ON trade_executions(buy_order_id, sell_order_id);
CREATE INDEX idx_execution_time ON trade_executions(execution_time);

-- =============================================
-- 3. 自动交易规则系统
-- =============================================

-- 自动交易规则表
CREATE TABLE auto_trading_rules (
    rule_id INTEGER PRIMARY KEY AUTOINCREMENT,
    player_id INTEGER NOT NULL,
    item_type TEXT CHECK (item_type IN ('bulk_commodity', 'equipment')) NOT NULL,
    item_id INTEGER NOT NULL,
    
    -- 规则基本信息
    rule_name VARCHAR(100) NOT NULL,
    rule_type TEXT CHECK (rule_type IN ('stop_loss', 'take_profit', 'trailing_stop', 'grid_trading')) NOT NULL,
    
    -- 触发条件
    base_price DECIMAL(20,8) NOT NULL, -- 设置规则时的基准价格
    trigger_condition TEXT CHECK (trigger_condition IN ('price_above', 'price_below', 'percent_up', 'percent_down', 'volume_above', 'volume_below')) NOT NULL,
    trigger_value DECIMAL(20,8) NOT NULL, -- 触发值
    trigger_price DECIMAL(20,8) NULL, -- 实际触发价格（用于追踪止损）
    price_offset DECIMAL(20,8) DEFAULT 0, -- 价格偏移量（相对于触发价）
    
    -- 网格交易特有属性
    grid_upper_price DECIMAL(20,8) NULL, -- 网格上限
    grid_lower_price DECIMAL(20,8) NULL, -- 网格下限
    grid_quantity INTEGER NULL, -- 网格数量
    grid_investment DECIMAL(20,8) NULL, -- 每格投资金额
    
    -- 执行参数
    order_type TEXT CHECK (order_type IN ('buy', 'sell')) NOT NULL,
    quantity_type TEXT CHECK (quantity_type IN ('fixed', 'percent', 'dynamic')) NOT NULL,
    quantity_value DECIMAL(20,8) NOT NULL, -- 数量值（固定数量或百分比）
    max_quantity DECIMAL(20,8) NULL, -- 最大交易数量
    
    -- 执行限制
    max_triggers INTEGER NULL, -- 最大触发次数（NULL表示无限）
    trigger_interval INTEGER NULL, -- 两次触发的最小间隔（秒）
    valid_from DATETIME NULL, -- 生效时间
    valid_until DATETIME NULL, -- 失效时间
    
    -- 状态信息
    is_active INTEGER DEFAULT 1,
    execution_count INTEGER DEFAULT 0, -- 已执行次数
    last_trigger_time DATETIME NULL, -- 上次触发时间
    last_trigger_price DECIMAL(20,8) NULL, -- 上次触发价格
    created_at DATETIME DEFAULT (datetime('now')),
    updated_at DATETIME DEFAULT (datetime('now')),
    
    -- 其他信息
    description TEXT,
    notes TEXT,
    
    FOREIGN KEY (player_id) REFERENCES players(player_id) ON DELETE CASCADE
);

-- 创建索引
CREATE INDEX idx_player_item_rules ON auto_trading_rules(player_id, item_type, item_id);
CREATE INDEX idx_rule_type ON auto_trading_rules(rule_type);
CREATE INDEX idx_status ON auto_trading_rules(is_active, valid_from, valid_until);

-- 自动交易规则执行历史
CREATE TABLE auto_trading_rule_history (
    history_id INTEGER PRIMARY KEY AUTOINCREMENT,
    rule_id INTEGER NOT NULL,
    trigger_time DATETIME DEFAULT (datetime('now')),
    trigger_price DECIMAL(20,8) NOT NULL,
    market_price DECIMAL(20,8) NOT NULL,
    generated_order_id INTEGER NULL, -- 生成的订单ID
    execution_result TEXT CHECK (execution_result IN ('success', 'failed', 'ignored', 'error')) NOT NULL,
    error_message TEXT,
    execution_details TEXT, -- 详细执行信息
    
    FOREIGN KEY (rule_id) REFERENCES auto_trading_rules(rule_id),
    FOREIGN KEY (generated_order_id) REFERENCES trade_orders(order_id)
);

-- 创建索引
CREATE INDEX idx_rule_time ON auto_trading_rule_history(rule_id, trigger_time);
CREATE INDEX idx_result ON auto_trading_rule_history(execution_result);

-- =============================================
-- 4. 市场趋势分析系统
-- =============================================

-- 市场趋势分析表
CREATE TABLE market_trends (
    trend_id INTEGER PRIMARY KEY AUTOINCREMENT,
    item_type TEXT CHECK (item_type IN ('bulk_commodity', 'equipment')) NOT NULL,
    item_id INTEGER NOT NULL,
    
    -- 趋势基本信息
    trend_type TEXT CHECK (trend_type IN ('bullish', 'bearish', 'sideways', 'volatile')) NOT NULL, -- 看涨、看跌、横盘、波动
    strength DECIMAL(5,2) NOT NULL, -- 趋势强度（0-100）
    confidence_level DECIMAL(5,2) NOT NULL, -- 趋势可信度
    
    -- 时间信息
    start_time DATETIME NOT NULL DEFAULT (datetime('now')),
    last_update_time DATETIME NOT NULL DEFAULT (datetime('now')),
    expected_duration_hours INTEGER, -- 预期持续时间
    actual_duration_hours INTEGER, -- 实际持续时间（结束时更新）
    
    -- 价格变化记录
    start_price DECIMAL(20,8) NOT NULL,
    current_price DECIMAL(20,8) NOT NULL,
    peak_price DECIMAL(20,8),
    bottom_price DECIMAL(20,8),
    price_change_percent DECIMAL(10,4), -- 价格变化百分比
    
    -- 市场情绪指标
    market_sentiment DECIMAL(5,2), -- 市场情绪指数（-100到100）
    volume_change_percent DECIMAL(10,4), -- 成交量变化
    volatility_index DECIMAL(10,4), -- 波动率指数
    
    -- 影响因素
    impact_factors TEXT, -- 影响因素列表 [{factor: 'event', weight: 0.7}, {factor: 'seasonal', weight: 0.3}]
    technical_indicators TEXT, -- 技术指标 {ma: 100, rsi: 70, etc}
    related_events TEXT, -- 相关事件引用
    
    -- 状态
    is_active INTEGER DEFAULT 1,
    end_time DATETIME NULL,
    trend_status TEXT CHECK (trend_status IN ('forming', 'confirmed', 'weakening', 'broken', 'ended')) DEFAULT 'forming',
    
    -- 预测信息
    prediction_accuracy DECIMAL(5,2), -- 历史预测准确度
    next_target_price DECIMAL(20,8), -- 下一个目标价位
    risk_level DECIMAL(5,2), -- 风险等级
    
    -- 备注
    analysis_notes TEXT,
    update_history TEXT, -- 趋势更新历史
    
    -- 索引和约束
    FOREIGN KEY (item_id) REFERENCES bulk_commodities(commodity_id) ON DELETE CASCADE
);

-- 创建索引
CREATE INDEX idx_item ON market_trends(item_type, item_id);
CREATE INDEX idx_trend_type ON market_trends(trend_type, is_active);
CREATE INDEX idx_time ON market_trends(start_time, end_time);
CREATE INDEX idx_status ON market_trends(trend_status, is_active);

-- =============================================
-- 5. 交易手续费系统
-- =============================================

-- 交易手续费规则表
CREATE TABLE trading_fees (
    fee_id INTEGER PRIMARY KEY AUTOINCREMENT,
    fee_name VARCHAR(100) NOT NULL,
    fee_type TEXT CHECK (fee_type IN ('buy', 'sell')) NOT NULL,
    
    -- 基础费率设置
    base_rate DECIMAL(8,6) NOT NULL, -- 基础费率（百分比）
    min_fee DECIMAL(20,8) NOT NULL, -- 最低手续费
    max_fee DECIMAL(20,8) NOT NULL, -- 最高手续费
    
    -- 等级调整
    level_adjustment TEXT NOT NULL, -- 各等级的费率调整 [{level: 1, rate: 1.0}, {level: 10, rate: 0.9}]
    vip_discount DECIMAL(8,6) DEFAULT 0, -- VIP额外折扣
    
    -- 商品特定费率
    item_type TEXT CHECK (item_type IN ('bulk_commodity', 'equipment', 'all')) NOT NULL DEFAULT 'all',
    item_id INTEGER NULL, -- 特定商品ID，NULL表示适用于所有商品
    item_category VARCHAR(50) NULL, -- 商品类别，可以针对特定类别设置费率
    
    -- 时间限制
    valid_from DATETIME NOT NULL DEFAULT (datetime('now')),
    valid_until DATETIME NULL, -- NULL表示永久有效
    
    -- 其他规则
    min_trade_amount DECIMAL(20,8) NULL, -- 最低交易金额要求
    max_trade_amount DECIMAL(20,8) NULL, -- 最高交易金额限制
    daily_fee_cap DECIMAL(20,8) NULL, -- 每日手续费上限
    special_conditions TEXT, -- 特殊条件 {event_discount: 0.8, holiday_rate: 1.2}
    
    -- 状态
    is_active INTEGER DEFAULT 1,
    priority INTEGER DEFAULT 0, -- 优先级，用于处理多个规则重叠的情况
    created_at DATETIME DEFAULT (datetime('now')),
    updated_at DATETIME DEFAULT (datetime('now')),
    
    -- 备注
    description TEXT,
    
    -- 索引和约束
    FOREIGN KEY (item_id) REFERENCES bulk_commodities(commodity_id) ON DELETE CASCADE
);

-- 创建索引
CREATE INDEX idx_fee_type ON trading_fees(fee_type, is_active);
CREATE INDEX idx_item_fees ON trading_fees(item_type, item_id);
CREATE INDEX idx_validity ON trading_fees(valid_from, valid_until);
CREATE INDEX idx_priority ON trading_fees(priority, is_active);

-- 手续费计算历史表
CREATE TABLE fee_calculation_history (
    history_id INTEGER PRIMARY KEY AUTOINCREMENT,
    order_id INTEGER NOT NULL,
    fee_rule_id INTEGER NOT NULL,
    player_id INTEGER NOT NULL,
    
    -- 计算详情
    base_amount DECIMAL(20,8) NOT NULL, -- 交易基础金额
    base_fee DECIMAL(20,8) NOT NULL, -- 基础手续费
    final_fee DECIMAL(20,8) NOT NULL, -- 最终手续费
    
    -- 调整明细
    level_discount DECIMAL(8,6) NOT NULL, -- 等级折扣
    vip_discount DECIMAL(8,6) NOT NULL, -- VIP折扣
    special_discount DECIMAL(8,6) NOT NULL, -- 特殊折扣
    
    -- 计算时间
    calculated_at DATETIME DEFAULT (datetime('now')),
    
    -- 其他信息
    calculation_details TEXT, -- 详细计算过程
    notes TEXT,
    
    FOREIGN KEY (order_id) REFERENCES trade_orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (fee_rule_id) REFERENCES trading_fees(fee_id) ON DELETE CASCADE,
    FOREIGN KEY (player_id) REFERENCES players(player_id) ON DELETE CASCADE
);

-- 创建索引
CREATE INDEX idx_order_fees ON fee_calculation_history(order_id);
CREATE INDEX idx_player_fees ON fee_calculation_history(player_id);
CREATE INDEX idx_calculation_time ON fee_calculation_history(calculated_at); 