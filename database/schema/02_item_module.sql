-- 物品系统相关表结构

-- =============================================
-- 1. 装备类型定义表
-- =============================================
CREATE TABLE equipment_types (
    type_id INT PRIMARY KEY AUTO_INCREMENT,
    type_name VARCHAR(50) UNIQUE NOT NULL,
    type_category ENUM('weapon', 'armor', 'accessory', 'tool') NOT NULL,
    equip_slot VARCHAR(50) NOT NULL, -- 装备槽位
    can_dual_wield BOOLEAN DEFAULT FALSE, -- 是否可以双持
    description TEXT,
    INDEX idx_type_category (type_category)
);

-- =============================================
-- 2. 大宗货品定义表
-- =============================================
CREATE TABLE bulk_commodities (
    commodity_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    commodity_name VARCHAR(100) UNIQUE NOT NULL,
    commodity_code VARCHAR(20) UNIQUE NOT NULL,
    category ENUM('currency', 'ore', 'herb', 'material', 'gem', 'other') NOT NULL,
    rarity ENUM('common', 'uncommon', 'rare', 'epic') NOT NULL DEFAULT 'common',
    
    -- 基础属性
    weight_per_unit DECIMAL(10,2) DEFAULT 0.00,
    description TEXT,
    obtainable_from JSON,
    stack_limit INT NOT NULL,  -- 堆叠上限（按类别区分）
    
    -- 货币(currency)特有属性
    is_main_currency BOOLEAN DEFAULT FALSE,  -- 是否主要货币（如金币）
    exchange_rate DECIMAL(20,8) DEFAULT 1.00, -- 相对于主要货币的汇率
    can_exchange BOOLEAN DEFAULT TRUE,       -- 是否可兑换
    
    -- 宝石(gem)特有属性
    purity DECIMAL(5,2) DEFAULT 100.00,     -- 纯度
    can_embed BOOLEAN DEFAULT FALSE,        -- 是否可镶嵌
    gem_effects JSON,                       -- 宝石效果
    
    -- 矿石(ore)特有属性
    refine_ratio DECIMAL(5,2) DEFAULT 1.00, -- 提炼比率
    by_products JSON,                       -- 副产品
    
    -- 材料(material)特有属性
    crafting_uses JSON,                     -- 可用于制作的物品类型
    preservation_days INT DEFAULT NULL,      -- 保质期（天）
    
    -- 草药(herb)特有属性
    effect_duration INT DEFAULT NULL,        -- 效果持续时间
    potency DECIMAL(5,2) DEFAULT 1.00,      -- 药效强度
    
    -- 价格信息
    base_value DECIMAL(20,2) NOT NULL,
    current_value DECIMAL(20,2) NOT NULL DEFAULT 0,
    market_cap DECIMAL(30,2) DEFAULT 0,
    
    -- 供应信息
    total_supply DECIMAL(30,8) DEFAULT 0,
    circulating_supply DECIMAL(30,8) DEFAULT 0,
    
    -- 市场指标
    volatility_index DECIMAL(5,2) DEFAULT 0, -- 波动指数
    price_change_24h DECIMAL(10,4) DEFAULT 0, -- 24小时价格变化百分比
    volume_24h DECIMAL(30,8) DEFAULT 0, -- 24小时交易量
    last_trade_price DECIMAL(20,2) DEFAULT 0, -- 最后成交价
    last_trade_time TIMESTAMP NULL, -- 最后成交时间
    
    -- 状态标记
    is_tradeable BOOLEAN DEFAULT TRUE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- 约束和索引
    CONSTRAINT check_stack_limit CHECK (
        -- 货币类：无限堆叠
        (category = 'currency' AND stack_limit = 999999999) OR
        -- 矿石类：按稀有度区分
        (category = 'ore' AND (
            (rarity = 'common' AND stack_limit <= 9999) OR
            (rarity = 'uncommon' AND stack_limit <= 999) OR
            (rarity = 'rare' AND stack_limit <= 999) OR
            (rarity = 'epic' AND stack_limit <= 99)
        )) OR
        -- 宝石类：按稀有度区分
        (category = 'gem' AND (
            (rarity = 'common' AND stack_limit <= 9999) OR
            (rarity = 'uncommon' AND stack_limit <= 999) OR
            (rarity = 'rare' AND stack_limit <= 99) OR
            (rarity = 'epic' AND stack_limit <= 99)
        )) OR
        -- 材料类：按稀有度区分
        (category = 'material' AND (
            (rarity = 'common' AND stack_limit <= 9999) OR
            (rarity = 'uncommon' AND stack_limit <= 999) OR
            (rarity = 'rare' AND stack_limit <= 99) OR
            (rarity = 'epic' AND stack_limit <= 99)
        )) OR
        -- 草药类：按稀有度区分
        (category = 'herb' AND (
            (rarity = 'common' AND stack_limit <= 9999) OR
            (rarity = 'uncommon' AND stack_limit <= 999) OR
            (rarity = 'rare' AND stack_limit <= 99) OR
            (rarity = 'epic' AND stack_limit <= 99)
        )) OR
        -- 其他类：统一9999
        (category = 'other' AND stack_limit <= 9999)
    ),
    INDEX idx_category_rarity (category, rarity),
    INDEX idx_commodity_code (commodity_code),
    INDEX idx_current_value (current_value),
    INDEX idx_market_cap (market_cap),
    INDEX idx_volume_24h (volume_24h),
    INDEX idx_tradeable_active (is_tradeable, is_active)
);

-- 货币兑换规则表（预留）
CREATE TABLE currency_exchange_rules (
    rule_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    from_currency_id BIGINT NOT NULL,
    to_currency_id BIGINT NOT NULL,
    exchange_rate DECIMAL(20,8) NOT NULL,
    min_amount DECIMAL(20,2) DEFAULT 0,
    max_amount DECIMAL(20,2) DEFAULT NULL,
    fee_percentage DECIMAL(5,2) DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (from_currency_id) REFERENCES bulk_commodities(commodity_id),
    FOREIGN KEY (to_currency_id) REFERENCES bulk_commodities(commodity_id),
    UNIQUE KEY unique_currency_pair (from_currency_id, to_currency_id)
);

-- 宝石镶嵌规则表（预留）
CREATE TABLE gem_embedding_rules (
    rule_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    gem_id BIGINT NOT NULL,
    equipment_type_id INT NOT NULL,
    max_slots INT DEFAULT 1,
    effect_multiplier DECIMAL(5,2) DEFAULT 1.00,
    requirements JSON,
    FOREIGN KEY (gem_id) REFERENCES bulk_commodities(commodity_id),
    FOREIGN KEY (equipment_type_id) REFERENCES equipment_types(type_id)
);

-- 材料合成规则表（预留）
CREATE TABLE material_synthesis_rules (
    rule_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    result_item_id BIGINT NOT NULL,
    ingredients JSON NOT NULL,  -- {item_id: quantity}
    success_rate DECIMAL(5,2) DEFAULT 100.00,
    min_crafting_level INT DEFAULT 1,
    energy_cost INT DEFAULT 0,
    FOREIGN KEY (result_item_id) REFERENCES bulk_commodities(commodity_id)
);

-- 大宗货品库存记录表
CREATE TABLE bulk_commodity_holdings (
    holding_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    player_id BIGINT NOT NULL,
    commodity_id BIGINT NOT NULL,
    quantity DECIMAL(20,8) NOT NULL DEFAULT 0,
    average_acquisition_price DECIMAL(20,2) DEFAULT 0,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    -- 材料和草药特有
    expiry_date TIMESTAMP NULL,  -- 过期时间
    quality_level DECIMAL(5,2) DEFAULT 100.00,  -- 品质等级
    -- 宝石特有
    purity_level DECIMAL(5,2) DEFAULT 100.00,  -- 纯度等级
    FOREIGN KEY (player_id) REFERENCES players(player_id) ON DELETE CASCADE,
    FOREIGN KEY (commodity_id) REFERENCES bulk_commodities(commodity_id) ON DELETE CASCADE,
    UNIQUE KEY unique_player_commodity (player_id, commodity_id),
    INDEX idx_quantity (quantity)
);

-- 大宗货品交易历史
CREATE TABLE bulk_commodity_transactions (
    transaction_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    commodity_id BIGINT NOT NULL,
    from_player_id BIGINT NULL,
    to_player_id BIGINT NULL,
    quantity DECIMAL(20,8) NOT NULL,
    unit_price DECIMAL(20,2) NOT NULL,
    total_value DECIMAL(20,2) NOT NULL,
    transaction_type ENUM('trade', 'loot', 'craft', 'quest_reward', 'system', 'exchange', 'synthesis', 'refine') NOT NULL,
    source_reference VARCHAR(100),
    transaction_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    -- 货币兑换特有
    exchange_rate DECIMAL(20,8) NULL,
    exchange_fee DECIMAL(20,2) NULL,
    -- 材料合成特有
    synthesis_success BOOLEAN NULL,
    quality_change DECIMAL(5,2) NULL,
    -- 矿石提炼特有
    refine_output_quantity DECIMAL(20,8) NULL,
    by_products JSON NULL,
    FOREIGN KEY (commodity_id) REFERENCES bulk_commodities(commodity_id) ON DELETE CASCADE,
    FOREIGN KEY (from_player_id) REFERENCES players(player_id) ON DELETE SET NULL,
    FOREIGN KEY (to_player_id) REFERENCES players(player_id) ON DELETE SET NULL,
    INDEX idx_transaction_time (transaction_time),
    INDEX idx_from_player (from_player_id),
    INDEX idx_to_player (to_player_id)
);

-- =============================================
-- 2. 普通装备系统
-- =============================================

-- =============================================
-- 2. 装备系统
-- =============================================

-- 装备模板表（定义装备的基础属性）
CREATE TABLE equipment_templates (
    template_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    equipment_name VARCHAR(100) NOT NULL,
    type_id INT NOT NULL,
    rarity ENUM('common', 'uncommon', 'rare', 'epic', 'legendary') NOT NULL,
    
    -- 基础装备属性
    base_durability INT NOT NULL,
    level_requirement INT DEFAULT 1,
    base_attributes JSON, -- 基础属性
    possible_affixes JSON, -- 可能出现的词缀（传说装备为null）
    description TEXT,
    
    -- 镶嵌相关属性（基础定义）
    gem_slots INT DEFAULT 0, -- 基础宝石槽数量
    max_gem_slots INT DEFAULT 0, -- 最大可开启宝石槽数量
    gem_slot_types JSON, -- 每个槽位支持的宝石类型 [{slot_index: 1, allowed_types: ['red', 'purple']}]
    
    -- 制造相关属性
    is_craftable BOOLEAN DEFAULT TRUE,
    craft_recipe JSON, -- 制作配方（传说装备为null）
    craft_requirements JSON, -- 合成要求（等级、声望等）
    craft_stations JSON, -- 可用于合成的工作台
    craft_time INT DEFAULT 0, -- 合成时间（秒）
    craft_exp INT DEFAULT 0, -- 合成获得经验
    craft_critical_chance DECIMAL(5,2) DEFAULT 0, -- 完美合成概率
    craft_critical_bonus JSON, -- 完美合成额外属性
    
    -- 传说装备特有属性
    is_legendary BOOLEAN DEFAULT FALSE,
    max_instances INT DEFAULT NULL, -- NULL=无限，0=已达上限，1=传说装备
    lore TEXT, -- 传说装备的背景故事
    special_abilities JSON, -- 特殊能力
    discovery_condition JSON, -- 发现条件
    
    -- 价格信息
    base_value DECIMAL(20,2) NOT NULL,
    current_value DECIMAL(20,2) NOT NULL DEFAULT 0,
    market_cap DECIMAL(30,2) DEFAULT 0,
    
    -- 供应信息
    total_supply INT DEFAULT 0, -- 已创建的总实例数
    circulating_supply INT DEFAULT 0, -- 当前流通的实例数（未损坏）
    max_supply INT DEFAULT NULL, -- 最大供应量（NULL表示无限）
    
    -- 市场指标
    volatility_index DECIMAL(5,2) DEFAULT 0,
    price_change_24h DECIMAL(10,4) DEFAULT 0,
    volume_24h INT DEFAULT 0, -- 24小时交易次数
    last_trade_value DECIMAL(20,2) DEFAULT 0,
    last_trade_time TIMESTAMP NULL,
    
    -- 状态标记
    is_tradeable BOOLEAN DEFAULT TRUE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- 外键和索引
    FOREIGN KEY (type_id) REFERENCES equipment_types(type_id),
    UNIQUE KEY unique_equipment_name (equipment_name, rarity),
    INDEX idx_type_rarity (type_id, rarity),
    INDEX idx_legendary (is_legendary),
    INDEX idx_current_value (current_value),
    INDEX idx_market_cap (market_cap),
    INDEX idx_volume_24h (volume_24h),
    INDEX idx_tradeable_active (is_tradeable, is_active)
);

-- 装备实例表（记录每个具体的装备实例）
CREATE TABLE equipment_instances (
    instance_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    template_id BIGINT NOT NULL,
    current_owner_id BIGINT NULL, -- NULL表示未被拥有
    owner_type ENUM('player', 'trader', 'world') NOT NULL DEFAULT 'world', -- 拥有者类型
    durability INT NOT NULL,
    current_value DECIMAL(20,2) NOT NULL,
    attributes JSON, -- 实际属性（包含随机词缀）
    creation_type ENUM('craft', 'loot', 'quest_reward', 'system', 'discovery') NOT NULL,
    creation_source VARCHAR(100), -- 创建来源（任务ID、冒险ID等）
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_modified TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    is_bound BOOLEAN DEFAULT FALSE, -- 是否绑定
    is_broken BOOLEAN DEFAULT FALSE, -- 是否损坏
    enhancement_level INT NOT NULL DEFAULT 0, -- 装备强化等级
    -- 传说装备特有
    power_level DECIMAL(10,2) DEFAULT NULL, -- 传说装备的力量等级
    awakening_level INT DEFAULT NULL, -- 传说装备的觉醒等级
    seal_level INT DEFAULT NULL, -- 传说装备的封印等级
    
    -- 镶嵌相关（基础状态）
    active_gem_slots INT DEFAULT 0, -- 当前已开启的宝石槽数量
    
    FOREIGN KEY (template_id) REFERENCES equipment_templates(template_id),
    INDEX idx_current_owner (current_owner_id, owner_type),
    INDEX idx_creation_type (creation_type),
    INDEX idx_enhancement_level (enhancement_level)
);

-- 装备历史记录表
CREATE TABLE equipment_history (
    history_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    instance_id BIGINT NOT NULL,
    event_type ENUM(
        'created',           -- 创建
        'discovered',        -- 发现（传说装备）
        'traded',           -- 交易
        'equipped',         -- 装备
        'unequipped',       -- 卸下
        'repaired',         -- 修理
        'broken',           -- 损坏
        'destroyed',        -- 销毁
        'sealed',           -- 封印（传说装备）
        'unsealed',         -- 解除封印（传说装备）
        'awakened',         -- 觉醒（传说装备）
        'quest_involved',   -- 参与任务
        'adventure_used'    -- 参与冒险
    ) NOT NULL,
    from_owner_type ENUM('player', 'container', 'system', 'adventure') NULL,
    from_owner_id BIGINT NULL,
    to_owner_type ENUM('player', 'container', 'system', 'adventure') NULL,
    to_owner_id BIGINT NULL,
    adventure_id BIGINT NULL, -- 相关的冒险ID
    durability_change INT DEFAULT 0,
    value_change DECIMAL(20,2) DEFAULT 0,
    -- 传说装备特有
    power_change DECIMAL(10,2) DEFAULT NULL,
    awakening_change INT DEFAULT NULL,
    seal_change INT DEFAULT NULL,
    event_location VARCHAR(200) NULL, -- 事件发生地点（主要用于传说装备）
    event_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    details JSON, -- 额外的事件详情
    FOREIGN KEY (instance_id) REFERENCES equipment_instances(instance_id),
    INDEX idx_instance_id (instance_id),
    INDEX idx_event_time (event_time),
    INDEX idx_owner_from (from_owner_type, from_owner_id),
    INDEX idx_owner_to (to_owner_type, to_owner_id)
);

-- =============================================
-- 3. 装备词缀系统
-- =============================================

-- 装备词缀池
CREATE TABLE equipment_affixes (
    affix_id INT PRIMARY KEY AUTO_INCREMENT,
    affix_name VARCHAR(50) NOT NULL,
    affix_type ENUM('prefix', 'suffix') NOT NULL,
    rarity ENUM('common', 'uncommon', 'rare', 'epic') NOT NULL,
    applicable_types JSON, -- 可应用的装备类型
    attribute_modifiers JSON, -- 属性修改器
    weight INT DEFAULT 100, -- 出现权重
    description TEXT,
    INDEX idx_affix_type_rarity (affix_type, rarity)
);

-- =============================================
-- 4. 装备强化系统
-- =============================================

-- 强化记录表
CREATE TABLE equipment_enhancements (
    enhancement_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    instance_id BIGINT NOT NULL,
    enhancement_type ENUM('upgrade', 'reforge', 'enchant') NOT NULL,
    materials_used JSON, -- 使用的材料
    cost_gold DECIMAL(20,2) NOT NULL,
    success_rate DECIMAL(5,2) NOT NULL,
    result_status ENUM('success', 'fail', 'critical_success', 'destroyed') NOT NULL,
    old_attributes JSON,
    new_attributes JSON,
    enhancement_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (instance_id) REFERENCES equipment_instances(instance_id),
    INDEX idx_instance_id (instance_id),
    INDEX idx_enhancement_time (enhancement_time)
); 

DELIMITER //

-- 强化成功时更新装备等级的触发器
CREATE TRIGGER after_enhancement_insert
AFTER INSERT ON equipment_enhancements
FOR EACH ROW
BEGIN
    IF NEW.result_status IN ('success', 'critical_success') THEN
        UPDATE equipment_instances
        SET enhancement_level = enhancement_level + 1,
            last_modified = CURRENT_TIMESTAMP
        WHERE instance_id = NEW.instance_id;
    END IF;
END//

-- 强化失败且装备损坏时的触发器
CREATE TRIGGER after_enhancement_destroy
AFTER INSERT ON equipment_enhancements
FOR EACH ROW
BEGIN
    IF NEW.result_status = 'destroyed' THEN
        UPDATE equipment_instances
        SET is_broken = TRUE,
            enhancement_level = 0,
            last_modified = CURRENT_TIMESTAMP
        WHERE instance_id = NEW.instance_id;
    END IF;
END//

DELIMITER ;

-- =============================================
-- 5. 物品位置和容器系统
-- =============================================

-- 容器定义表（背包、宝箱、仓库等）
CREATE TABLE containers (
    container_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    container_type ENUM('bag', 'chest', 'storage', 'bank', 'guild_storage') NOT NULL,
    owner_type ENUM('player', 'adventure', 'system', 'guild') NOT NULL,
    owner_id BIGINT NULL,  -- 对应owner_type的ID
    container_name VARCHAR(100) NOT NULL,
    max_slots INT NOT NULL,
    is_locked BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP NULL,  -- NULL表示永久容器
    INDEX idx_owner (owner_type, owner_id),
    INDEX idx_container_type (container_type)
);

-- 物品位置表（记录物品当前位置）
CREATE TABLE item_locations (
    location_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    item_type ENUM('equipment', 'bulk_commodity') NOT NULL,
    item_id BIGINT NOT NULL,  -- equipment_instances.instance_id 或 bulk_commodity_holdings.holding_id
    container_id BIGINT NOT NULL,
    slot_number INT NOT NULL,  -- 在容器中的位置
    quantity DECIMAL(20,8) DEFAULT 1,  -- 对于可堆叠物品
    is_equipped BOOLEAN DEFAULT FALSE,  -- 是否装备在角色身上
    equip_slot VARCHAR(50) NULL,  -- 装备在哪个槽位
    last_modified TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (container_id) REFERENCES containers(container_id),
    UNIQUE KEY unique_slot (container_id, slot_number),
    INDEX idx_item (item_type, item_id)
);

-- =============================================
-- 6. 物品历史记录系统
-- =============================================

-- 物品历史记录表（统一记录所有物品的历史）
CREATE TABLE item_history (
    history_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    item_type ENUM('equipment', 'bulk_commodity') NOT NULL,
    item_id BIGINT NOT NULL,
    event_type ENUM(
        'created',           -- 物品创建
        'obtained',          -- 获得物品
        'traded',           -- 交易
        'equipped',         -- 装备
        'unequipped',       -- 卸下装备
        'stored',           -- 存入容器
        'withdrawn',        -- 从容器取出
        'used',             -- 使用（消耗品）
        'enhanced',         -- 强化
        'repaired',         -- 修理
        'broken',           -- 损坏
        'destroyed'         -- 销毁
    ) NOT NULL,
    from_owner_type ENUM('player', 'container', 'system', 'adventure') NULL,
    from_owner_id BIGINT NULL,
    to_owner_type ENUM('player', 'container', 'system', 'adventure') NULL,
    to_owner_id BIGINT NULL,
    quantity DECIMAL(20,8) DEFAULT 1,
    event_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    event_source VARCHAR(100),  -- 事件来源（任务ID、冒险ID等）
    additional_data JSON,  -- 额外信息（如强化参数、修理程度等）
    INDEX idx_item (item_type, item_id),
    INDEX idx_event_time (event_time)
);

-- 冒险物品记录表（记录物品参与的冒险）
CREATE TABLE adventure_item_records (
    record_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    adventure_id BIGINT NOT NULL,
    item_type ENUM('equipment', 'bulk_commodity') NOT NULL,
    item_id BIGINT NOT NULL,
    player_id BIGINT NOT NULL,  -- 使用者
    role_in_adventure ENUM('equipment', 'consume', 'reward', 'material') NOT NULL,
    quantity_used DECIMAL(20,8) DEFAULT 1,
    effectiveness_score DECIMAL(5,2) NULL,  -- 物品在冒险中的表现评分
    durability_loss INT NULL,  -- 装备耐久损失
    adventure_start TIMESTAMP NOT NULL,
    adventure_end TIMESTAMP NULL,
    notes TEXT,
    INDEX idx_adventure (adventure_id),
    INDEX idx_item (item_type, item_id),
    INDEX idx_player (player_id)
);

-- 物品效果记录表（记录物品产生的效果）
CREATE TABLE item_effect_records (
    effect_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    item_type ENUM('equipment', 'bulk_commodity') NOT NULL,
    item_id BIGINT NOT NULL,
    effect_type VARCHAR(50) NOT NULL,  -- 效果类型
    effect_value JSON NOT NULL,  -- 效果值
    target_type ENUM('player', 'adventure', 'container', 'other') NOT NULL,
    target_id BIGINT NOT NULL,
    start_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    duration_seconds INT NULL,  -- NULL表示永久效果
    is_active BOOLEAN DEFAULT TRUE,
    created_by_adventure_id BIGINT NULL,  -- 在哪个冒险中产生的效果
    INDEX idx_item (item_type, item_id),
    INDEX idx_target (target_type, target_id),
    INDEX idx_active_effects (is_active, start_time)
); 

-- 宝石镶嵌记录表
CREATE TABLE gem_embeddings (
    embedding_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    equipment_instance_id BIGINT NOT NULL,
    gem_holding_id BIGINT NOT NULL, -- 对应bulk_commodity_holdings中的宝石
    slot_index INT NOT NULL, -- 镶嵌在第几个槽位
    embedded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    removed_at TIMESTAMP NULL, -- 宝石被移除的时间，NULL表示当前镶嵌中
    removal_reason ENUM('replace', 'extract', 'destroy') NULL, -- 移除原因
    is_active BOOLEAN DEFAULT TRUE, -- 是否处于激活状态
    
    -- 镶嵌效果
    original_attributes JSON, -- 宝石原始属性
    bonus_attributes JSON, -- 槽位加成后的实际属性
    synergy_effects JSON, -- 与其他宝石的协同效果
    
    -- 记录信息
    embedding_cost DECIMAL(20,2) NOT NULL, -- 镶嵌花费
    performed_by BIGINT NULL, -- 操作者ID（如果是NPC则为NULL）
    notes TEXT,
    
    FOREIGN KEY (equipment_instance_id) REFERENCES equipment_instances(instance_id),
    FOREIGN KEY (gem_holding_id) REFERENCES bulk_commodity_holdings(holding_id),
    FOREIGN KEY (performed_by) REFERENCES players(player_id),
    
    INDEX idx_equipment (equipment_instance_id),
    INDEX idx_gem (gem_holding_id),
    INDEX idx_status (is_active),
    UNIQUE KEY unique_active_slot (equipment_instance_id, slot_index, is_active)
);

-- 宝石协同效果表
CREATE TABLE gem_synergies (
    synergy_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    gem_types JSON NOT NULL, -- 需要的宝石类型组合 ['red', 'blue']
    min_gem_count INT DEFAULT 2, -- 触发效果需要的最少宝石数
    level_requirement INT DEFAULT 1,
    rarity ENUM('common', 'uncommon', 'rare', 'epic', 'legendary') NOT NULL,
    
    -- 效果
    synergy_effects JSON NOT NULL, -- 协同效果属性
    activation_conditions JSON, -- 触发条件
    special_effects JSON, -- 特殊效果
    
    -- 状态
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_rarity (rarity),
    INDEX idx_level (level_requirement)
);

-- 宝石镶嵌历史记录表
CREATE TABLE gem_embedding_history (
    history_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    embedding_id BIGINT NOT NULL,
    event_type ENUM(
        'embed', -- 镶嵌
        'remove', -- 移除
        'activate', -- 激活
        'deactivate', -- 停用
        'upgrade', -- 升级
        'synergy_trigger', -- 触发协同效果
        'synergy_end' -- 协同效果结束
    ) NOT NULL,
    event_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    performed_by BIGINT NULL,
    old_state JSON,
    new_state JSON,
    cost_gold DECIMAL(20,2) DEFAULT 0,
    success_rate DECIMAL(5,2) DEFAULT 100.00,
    event_details JSON,
    
    FOREIGN KEY (embedding_id) REFERENCES gem_embeddings(embedding_id),
    FOREIGN KEY (performed_by) REFERENCES players(player_id),
    
    INDEX idx_embedding (embedding_id),
    INDEX idx_event_time (event_time),
    INDEX idx_event_type (event_type)
); 