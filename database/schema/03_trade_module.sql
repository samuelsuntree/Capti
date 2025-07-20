-- Trade模块相关表结构

-- =============================================
-- 1. 价格历史系统
-- =============================================

-- 价格历史记录表（大宗货品）
CREATE TABLE bulk_commodity_price_history (
    history_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    commodity_id BIGINT NOT NULL,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
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
    price_source ENUM('market', 'adventure', 'event', 'admin') NOT NULL,
    source_reference VARCHAR(100), -- 来源引用（如事件ID、冒险ID等）
    source_details JSON, -- 详细来源信息
    
    -- 备注
    notes TEXT,
    
    FOREIGN KEY (commodity_id) REFERENCES bulk_commodities(commodity_id) ON DELETE CASCADE,
    INDEX idx_commodity_time (commodity_id, timestamp),
    INDEX idx_price_source (price_source, timestamp)
);

-- 价格历史记录表（装备模板）
CREATE TABLE equipment_price_history (
    history_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    template_id BIGINT NOT NULL,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- 价格信息
    buy_price DECIMAL(20,8) NOT NULL, -- 当前最高买入价
    sell_price DECIMAL(20,8) NOT NULL, -- 当前最低卖出价
    avg_price DECIMAL(20,8) NOT NULL, -- 当前成交均价
    
    -- 交易量信息
    buy_count INT DEFAULT 0, -- 买入数量
    sell_count INT DEFAULT 0, -- 卖出数量
    total_count INT DEFAULT 0, -- 总成交数
    turnover DECIMAL(30,2) DEFAULT 0, -- 总成交额
    
    -- 市值信息
    market_cap DECIMAL(30,2) DEFAULT 0, -- 总市值（基于当前均价）
    circulating_market_cap DECIMAL(30,2) DEFAULT 0, -- 流通市值（未损坏装备）
    
    -- 来源信息
    price_source ENUM('market', 'adventure', 'event', 'admin') NOT NULL,
    source_reference VARCHAR(100),
    source_details JSON,
    
    -- 备注
    notes TEXT,
    
    FOREIGN KEY (template_id) REFERENCES equipment_templates(template_id) ON DELETE CASCADE,
    INDEX idx_template_time (template_id, timestamp),
    INDEX idx_price_source (price_source, timestamp)
);

-- 价格更新触发器（大宗货品）
DELIMITER //
CREATE TRIGGER after_bulk_price_update
AFTER INSERT ON bulk_commodity_price_history
FOR EACH ROW
BEGIN
    -- 更新商品当前价格
    UPDATE bulk_commodities
    SET current_value = NEW.avg_price,
        market_cap = NEW.market_cap,
        volume_24h = (
            SELECT COALESCE(SUM(total_volume), 0)
            FROM bulk_commodity_price_history
            WHERE commodity_id = NEW.commodity_id
            AND timestamp > DATE_SUB(NOW(), INTERVAL 24 HOUR)
        ),
        price_change_24h = (
            SELECT ((NEW.avg_price - first_price.avg_price) / first_price.avg_price) * 100
            FROM bulk_commodity_price_history first_price
            WHERE first_price.commodity_id = NEW.commodity_id
            AND first_price.timestamp <= DATE_SUB(NOW(), INTERVAL 24 HOUR)
            ORDER BY first_price.timestamp DESC
            LIMIT 1
        ),
        updated_at = NOW()
    WHERE commodity_id = NEW.commodity_id;
END //
DELIMITER ;

-- 价格更新触发器（装备）
DELIMITER //
CREATE TRIGGER after_equipment_price_update
AFTER INSERT ON equipment_price_history
FOR EACH ROW
BEGIN
    -- 更新装备模板当前价格
    UPDATE equipment_templates
    SET current_value = NEW.avg_price,
        market_cap = NEW.market_cap,
        volume_24h = (
            SELECT COALESCE(SUM(total_count), 0)
            FROM equipment_price_history
            WHERE template_id = NEW.template_id
            AND timestamp > DATE_SUB(NOW(), INTERVAL 24 HOUR)
        ),
        price_change_24h = (
            SELECT ((NEW.avg_price - first_price.avg_price) / first_price.avg_price) * 100
            FROM equipment_price_history first_price
            WHERE first_price.template_id = NEW.template_id
            AND first_price.timestamp <= DATE_SUB(NOW(), INTERVAL 24 HOUR)
            ORDER BY first_price.timestamp DESC
            LIMIT 1
        ),
        updated_at = NOW()
    WHERE template_id = NEW.template_id;
END //
DELIMITER ; 

-- =============================================
-- 2. 交易订单系统
-- =============================================

-- 订单主表（支持大宗货品和装备）
CREATE TABLE trade_orders (
    order_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    player_id BIGINT NOT NULL,
    item_type ENUM('bulk_commodity', 'equipment') NOT NULL, -- 交易物品类型
    item_id BIGINT NOT NULL, -- bulk_commodities.commodity_id 或 equipment_templates.template_id
    order_type ENUM('buy', 'sell') NOT NULL,
    
    -- 价格和数量
    price DECIMAL(20,8) NOT NULL, -- 单价
    quantity DECIMAL(20,8) NOT NULL, -- 总数量（装备类型固定为1）
    total_value DECIMAL(30,8) NOT NULL, -- 总价值
    filled_quantity DECIMAL(20,8) DEFAULT 0, -- 已成交数量
    remaining_quantity DECIMAL(20,8) NOT NULL, -- 剩余数量
    
    -- 订单状态
    status ENUM(
        'pending', -- 等待成交
        'partial', -- 部分成交
        'filled', -- 完全成交
        'cancelled', -- 已取消
        'expired' -- 已过期
    ) DEFAULT 'pending',
    
    -- 时间信息
    order_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    filled_time TIMESTAMP NULL, -- 完全成交时间
    expires_at TIMESTAMP NULL, -- 过期时间
    
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
    is_margin_trade BOOLEAN DEFAULT FALSE, -- 是否保证金交易
    is_auto_generated BOOLEAN DEFAULT FALSE, -- 是否自动生成的订单
    auto_rule_id BIGINT NULL, -- 关联的自动交易规则ID
    notes TEXT,
    
    FOREIGN KEY (player_id) REFERENCES players(player_id) ON DELETE CASCADE,
    -- 动态外键约束（通过触发器实现）
    -- item_type = 'bulk_commodity' 时，item_id 引用 bulk_commodities.commodity_id
    -- item_type = 'equipment' 时，item_id 引用 equipment_templates.template_id
    INDEX idx_player_item (player_id, item_type, item_id),
    INDEX idx_order_type (order_type, status),
    INDEX idx_price (price),
    INDEX idx_time (order_time, status)
);

-- 订单外键检查触发器
DELIMITER //
CREATE TRIGGER before_trade_order_insert
BEFORE INSERT ON trade_orders
FOR EACH ROW
BEGIN
    IF NEW.item_type = 'bulk_commodity' THEN
        IF NOT EXISTS (SELECT 1 FROM bulk_commodities WHERE commodity_id = NEW.item_id) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid bulk_commodity_id';
        END IF;
    ELSEIF NEW.item_type = 'equipment' THEN
        IF NOT EXISTS (SELECT 1 FROM equipment_templates WHERE template_id = NEW.item_id) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid equipment_template_id';
        END IF;
    END IF;
END //
DELIMITER ;

-- 订单成交记录表
CREATE TABLE trade_executions (
    execution_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    buy_order_id BIGINT NOT NULL,
    sell_order_id BIGINT NOT NULL,
    executed_price DECIMAL(20,8) NOT NULL,
    executed_quantity DECIMAL(20,8) NOT NULL,
    execution_value DECIMAL(30,8) NOT NULL,
    execution_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- 买方信息
    buyer_id BIGINT NOT NULL,
    buyer_fee DECIMAL(20,8) NOT NULL,
    buyer_total DECIMAL(30,8) NOT NULL, -- 总支付金额（含费用）
    
    -- 卖方信息
    seller_id BIGINT NOT NULL,
    seller_fee DECIMAL(20,8) NOT NULL,
    seller_total DECIMAL(30,8) NOT NULL, -- 总收到金额（扣除费用）
    
    -- 其他信息
    market_price DECIMAL(20,8) NOT NULL, -- 成交时的市场价
    price_impact DECIMAL(8,6) DEFAULT 0, -- 价格影响
    
    FOREIGN KEY (buy_order_id) REFERENCES trade_orders(order_id),
    FOREIGN KEY (sell_order_id) REFERENCES trade_orders(order_id),
    FOREIGN KEY (buyer_id) REFERENCES players(player_id),
    FOREIGN KEY (seller_id) REFERENCES players(player_id),
    INDEX idx_orders (buy_order_id, sell_order_id),
    INDEX idx_execution_time (execution_time)
);

-- =============================================
-- 3. 自动交易规则系统
-- =============================================

-- 自动交易规则表
CREATE TABLE auto_trading_rules (
    rule_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    player_id BIGINT NOT NULL,
    item_type ENUM('bulk_commodity', 'equipment') NOT NULL,
    item_id BIGINT NOT NULL,
    
    -- 规则基本信息
    rule_name VARCHAR(100) NOT NULL,
    rule_type ENUM(
        'stop_loss', -- 止损
        'take_profit', -- 止盈
        'trailing_stop', -- 追踪止损
        'grid_trading' -- 网格交易
    ) NOT NULL,
    
    -- 触发条件
    base_price DECIMAL(20,8) NOT NULL, -- 设置规则时的基准价格
    trigger_condition ENUM(
        'price_above', -- 价格高于
        'price_below', -- 价格低于
        'percent_up', -- 上涨百分比
        'percent_down', -- 下跌百分比
        'volume_above', -- 成交量高于
        'volume_below' -- 成交量低于
    ) NOT NULL,
    trigger_value DECIMAL(20,8) NOT NULL, -- 触发值
    trigger_price DECIMAL(20,8) NULL, -- 实际触发价格（用于追踪止损）
    price_offset DECIMAL(20,8) DEFAULT 0, -- 价格偏移量（相对于触发价）
    
    -- 网格交易特有属性
    grid_upper_price DECIMAL(20,8) NULL, -- 网格上限
    grid_lower_price DECIMAL(20,8) NULL, -- 网格下限
    grid_quantity INT NULL, -- 网格数量
    grid_investment DECIMAL(20,8) NULL, -- 每格投资金额
    
    -- 执行参数
    order_type ENUM('buy', 'sell') NOT NULL,
    quantity_type ENUM('fixed', 'percent', 'dynamic') NOT NULL,
    quantity_value DECIMAL(20,8) NOT NULL, -- 数量值（固定数量或百分比）
    max_quantity DECIMAL(20,8) NULL, -- 最大交易数量
    
    -- 执行限制
    max_triggers INT NULL, -- 最大触发次数（NULL表示无限）
    trigger_interval INT NULL, -- 两次触发的最小间隔（秒）
    valid_from TIMESTAMP NULL, -- 生效时间
    valid_until TIMESTAMP NULL, -- 失效时间
    
    -- 状态信息
    is_active BOOLEAN DEFAULT TRUE,
    execution_count INT DEFAULT 0, -- 已执行次数
    last_trigger_time TIMESTAMP NULL, -- 上次触发时间
    last_trigger_price DECIMAL(20,8) NULL, -- 上次触发价格
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- 其他信息
    description TEXT,
    notes TEXT,
    
    FOREIGN KEY (player_id) REFERENCES players(player_id) ON DELETE CASCADE,
    -- 动态外键约束（通过触发器实现）
    INDEX idx_player_item (player_id, item_type, item_id),
    INDEX idx_rule_type (rule_type),
    INDEX idx_status (is_active, valid_from, valid_until)
);

-- 规则外键检查触发器
DELIMITER //
CREATE TRIGGER before_trading_rule_insert
BEFORE INSERT ON auto_trading_rules
FOR EACH ROW
BEGIN
    IF NEW.item_type = 'bulk_commodity' THEN
        IF NOT EXISTS (SELECT 1 FROM bulk_commodities WHERE commodity_id = NEW.item_id) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid bulk_commodity_id';
        END IF;
    ELSEIF NEW.item_type = 'equipment' THEN
        IF NOT EXISTS (SELECT 1 FROM equipment_templates WHERE template_id = NEW.item_id) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid equipment_template_id';
        END IF;
    END IF;
END //
DELIMITER ;

-- 自动交易规则执行历史
CREATE TABLE auto_trading_rule_history (
    history_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    rule_id BIGINT NOT NULL,
    trigger_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    trigger_price DECIMAL(20,8) NOT NULL,
    market_price DECIMAL(20,8) NOT NULL,
    generated_order_id BIGINT NULL, -- 生成的订单ID
    execution_result ENUM(
        'success', -- 成功触发并创建订单
        'failed', -- 触发失败
        'ignored', -- 条件满足但被忽略（如间隔时间不足）
        'error' -- 执行出错
    ) NOT NULL,
    error_message TEXT,
    execution_details JSON, -- 详细执行信息
    
    FOREIGN KEY (rule_id) REFERENCES auto_trading_rules(rule_id),
    FOREIGN KEY (generated_order_id) REFERENCES trade_orders(order_id),
    INDEX idx_rule_time (rule_id, trigger_time),
    INDEX idx_result (execution_result)
); 

-- =============================================
-- 4. 市场趋势分析系统
-- =============================================

-- 市场趋势分析表
CREATE TABLE market_trends (
    trend_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    item_type ENUM('bulk_commodity', 'equipment') NOT NULL,
    item_id BIGINT NOT NULL,
    
    -- 趋势基本信息
    trend_type ENUM('bullish', 'bearish', 'sideways', 'volatile') NOT NULL, -- 看涨、看跌、横盘、波动
    strength DECIMAL(5,2) NOT NULL, -- 趋势强度（0-100）
    confidence_level DECIMAL(5,2) NOT NULL, -- 趋势可信度
    
    -- 时间信息
    start_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    last_update_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    expected_duration_hours INT, -- 预期持续时间
    actual_duration_hours INT, -- 实际持续时间（结束时更新）
    
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
    impact_factors JSON, -- 影响因素列表 [{factor: 'event', weight: 0.7}, {factor: 'seasonal', weight: 0.3}]
    technical_indicators JSON, -- 技术指标 {ma: 100, rsi: 70, etc}
    related_events JSON, -- 相关事件引用
    
    -- 状态
    is_active BOOLEAN DEFAULT TRUE,
    end_time TIMESTAMP NULL,
    trend_status ENUM('forming', 'confirmed', 'weakening', 'broken', 'ended') DEFAULT 'forming',
    
    -- 预测信息
    prediction_accuracy DECIMAL(5,2), -- 历史预测准确度
    next_target_price DECIMAL(20,8), -- 下一个目标价位
    risk_level DECIMAL(5,2), -- 风险等级
    
    -- 备注
    analysis_notes TEXT,
    update_history JSON, -- 趋势更新历史
    
    -- 索引和约束
    FOREIGN KEY (item_id) REFERENCES bulk_commodities(commodity_id) ON DELETE CASCADE,
    INDEX idx_item (item_type, item_id),
    INDEX idx_trend_type (trend_type, is_active),
    INDEX idx_time (start_time, end_time),
    INDEX idx_status (trend_status, is_active)
);

-- 趋势更新触发器
DELIMITER //
CREATE TRIGGER after_price_update_check_trend
AFTER INSERT ON bulk_commodity_price_history
FOR EACH ROW
BEGIN
    -- 更新现有趋势
    UPDATE market_trends
    SET 
        current_price = NEW.avg_price,
        price_change_percent = ((NEW.avg_price - start_price) / start_price) * 100,
        actual_duration_hours = TIMESTAMPDIFF(HOUR, start_time, NOW())
    WHERE 
        item_type = 'bulk_commodity' 
        AND item_id = NEW.commodity_id 
        AND is_active = TRUE;
        
    -- 记录峰值和低点
    UPDATE market_trends
    SET peak_price = GREATEST(COALESCE(peak_price, NEW.avg_price), NEW.avg_price),
        bottom_price = LEAST(COALESCE(bottom_price, NEW.avg_price), NEW.avg_price)
    WHERE 
        item_type = 'bulk_commodity' 
        AND item_id = NEW.commodity_id 
        AND is_active = TRUE;
END //
DELIMITER ; 

-- =============================================
-- 5. 交易手续费系统
-- =============================================

-- 交易手续费规则表
CREATE TABLE trading_fees (
    fee_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    fee_name VARCHAR(100) NOT NULL,
    fee_type ENUM('buy', 'sell') NOT NULL,
    
    -- 基础费率设置
    base_rate DECIMAL(8,6) NOT NULL, -- 基础费率（百分比）
    min_fee DECIMAL(20,8) NOT NULL, -- 最低手续费
    max_fee DECIMAL(20,8) NOT NULL, -- 最高手续费
    
    -- 等级调整
    level_adjustment JSON NOT NULL, -- 各等级的费率调整 [{level: 1, rate: 1.0}, {level: 10, rate: 0.9}]
    vip_discount DECIMAL(8,6) DEFAULT 0, -- VIP额外折扣
    
    -- 商品特定费率
    item_type ENUM('bulk_commodity', 'equipment', 'all') NOT NULL DEFAULT 'all',
    item_id BIGINT NULL, -- 特定商品ID，NULL表示适用于所有商品
    item_category VARCHAR(50) NULL, -- 商品类别，可以针对特定类别设置费率
    
    -- 时间限制
    valid_from TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    valid_until TIMESTAMP NULL, -- NULL表示永久有效
    
    -- 其他规则
    min_trade_amount DECIMAL(20,8) NULL, -- 最低交易金额要求
    max_trade_amount DECIMAL(20,8) NULL, -- 最高交易金额限制
    daily_fee_cap DECIMAL(20,8) NULL, -- 每日手续费上限
    special_conditions JSON, -- 特殊条件 {event_discount: 0.8, holiday_rate: 1.2}
    
    -- 状态
    is_active BOOLEAN DEFAULT TRUE,
    priority INT DEFAULT 0, -- 优先级，用于处理多个规则重叠的情况
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- 备注
    description TEXT,
    
    -- 索引和约束
    FOREIGN KEY (item_id) REFERENCES bulk_commodities(commodity_id) ON DELETE CASCADE,
    INDEX idx_fee_type (fee_type, is_active),
    INDEX idx_item (item_type, item_id),
    INDEX idx_validity (valid_from, valid_until),
    INDEX idx_priority (priority, is_active)
);

-- 手续费计算历史表
CREATE TABLE fee_calculation_history (
    history_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    order_id BIGINT NOT NULL,
    fee_rule_id BIGINT NOT NULL,
    player_id BIGINT NOT NULL,
    
    -- 计算详情
    base_amount DECIMAL(20,8) NOT NULL, -- 交易基础金额
    base_fee DECIMAL(20,8) NOT NULL, -- 基础手续费
    final_fee DECIMAL(20,8) NOT NULL, -- 最终手续费
    
    -- 调整明细
    level_discount DECIMAL(8,6) NOT NULL, -- 等级折扣
    vip_discount DECIMAL(8,6) NOT NULL, -- VIP折扣
    special_discount DECIMAL(8,6) NOT NULL, -- 特殊折扣
    
    -- 计算时间
    calculated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- 其他信息
    calculation_details JSON, -- 详细计算过程
    notes TEXT,
    
    FOREIGN KEY (order_id) REFERENCES trade_orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (fee_rule_id) REFERENCES trading_fees(fee_id) ON DELETE CASCADE,
    FOREIGN KEY (player_id) REFERENCES players(player_id) ON DELETE CASCADE,
    
    INDEX idx_order (order_id),
    INDEX idx_player (player_id),
    INDEX idx_calculation_time (calculated_at)
);

-- 手续费计算触发器
DELIMITER //
CREATE TRIGGER before_trade_order_fee_calculation
BEFORE INSERT ON trade_orders
FOR EACH ROW
BEGIN
    DECLARE v_fee_rule_id BIGINT;
    DECLARE v_base_fee DECIMAL(20,8);
    DECLARE v_final_fee DECIMAL(20,8);
    
    -- 查找适用的费率规则
    SELECT fee_id INTO v_fee_rule_id
    FROM trading_fees
    WHERE fee_type = NEW.order_type
    AND is_active = TRUE
    AND (item_type = 'all' OR (item_type = NEW.item_type AND (item_id IS NULL OR item_id = NEW.item_id)))
    AND CURRENT_TIMESTAMP BETWEEN valid_from AND COALESCE(valid_until, CURRENT_TIMESTAMP)
    ORDER BY priority DESC, fee_id DESC
    LIMIT 1;
    
    -- 如果找到规则，计算费用
    IF v_fee_rule_id IS NOT NULL THEN
        -- 设置基础费率（实际应用中需要更复杂的计算逻辑）
        SET v_base_fee = NEW.total_value * (SELECT base_rate FROM trading_fees WHERE fee_id = v_fee_rule_id);
        SET v_final_fee = v_base_fee;
        
        -- 更新订单的费用信息
        SET NEW.base_fee_rate = (SELECT base_rate FROM trading_fees WHERE fee_id = v_fee_rule_id);
        SET NEW.estimated_fees = v_final_fee;
    END IF;
END //
DELIMITER ; 