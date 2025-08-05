-- Converted from MySQL to SQLite
-- Original file: database/schema/02_item_module.sql






CREATE TABLE equipment_types (
    type_id INTEGER PRIMARY KEY AUTOINCREMENT,
    type_name VARCHAR(50) UNIQUE NOT NULL,
    type_category TEXT CHECK (type_category IN ('weapon', 'armor', 'accessory', 'tool')) NOT NULL,
    equip_slot VARCHAR(50) NOT NULL, 
    can_dual_wield INTEGER DEFAULT 0, 
    description TEXT
);




CREATE TABLE bulk_commodities (
    commodity_id INTEGER PRIMARY KEY AUTOINCREMENT,
    commodity_name VARCHAR(100) UNIQUE NOT NULL,
    commodity_code VARCHAR(20) UNIQUE NOT NULL,
    category TEXT CHECK (category IN ('currency', 'ore', 'herb', 'material', 'gem', 'other')) NOT NULL,
    rarity TEXT CHECK (rarity IN ('common', 'uncommon', 'rare', 'epic')) NOT NULL DEFAULT 'common',
    
    -- 基础属性
    weight_per_unit DECIMAL(10,2) DEFAULT 0.00,
    description TEXT,
    obtainable_from TEXT,
    stack_limit INTEGER NOT NULL,  -- 堆叠上限（按类别区分）
    
    -- 货币(currency)特有属性
    is_main_currency INTEGER DEFAULT 0,  -- 是否主要货币（如金币）
    exchange_rate DECIMAL(20,8) DEFAULT 1.00, -- 相对于主要货币的汇率
    can_exchange INTEGER DEFAULT 1,       -- 是否可兑换
    
    -- 宝石(gem)特有属性
    purity DECIMAL(5,2) DEFAULT 100.00,     -- 纯度
    can_embed INTEGER DEFAULT 0,        -- 是否可镶嵌
    gem_effects TEXT,                       -- 宝石效果
    
    -- 矿石(ore)特有属性
    refine_ratio DECIMAL(5,2) DEFAULT 1.00, -- 提炼比率
    by_products TEXT,                       -- 副产品
    
    -- 材料(material)特有属性
    crafting_uses TEXT,                     -- 可用于制作的物品类型
    preservation_days INTEGER DEFAULT NULL,      -- 保质期（天）
    
    -- 草药(herb)特有属性
    effect_duration INTEGER DEFAULT NULL,        -- 效果持续时间
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
    last_trade_time DATETIME NULL, -- 最后成交时间
    
    -- 状态标记
    is_tradeable INTEGER DEFAULT 1,
    is_active INTEGER DEFAULT 1,
    created_at DATETIME DEFAULT (datetime('now')),
    updated_at DATETIME DEFAULT (datetime('now'))
);

-- 货币兑换规则表（预留）
CREATE TABLE currency_exchange_rules (
    rule_id INTEGER PRIMARY KEY AUTOINCREMENT,
    from_currency_id INTEGER NOT NULL,
    to_currency_id INTEGER NOT NULL,
    exchange_rate DECIMAL(20,8) NOT NULL,
    min_amount DECIMAL(20,2) DEFAULT 0,
    max_amount DECIMAL(20,2) DEFAULT NULL,
    fee_percentage DECIMAL(5,2) DEFAULT 0,
    is_active INTEGER DEFAULT 1,
    last_updated DATETIME DEFAULT (datetime('now')),
    FOREIGN KEY (from_currency_id) REFERENCES bulk_commodities(commodity_id),
    FOREIGN KEY (to_currency_id) REFERENCES bulk_commodities(commodity_id)
);


CREATE TABLE gem_embedding_rules (
    rule_id INTEGER PRIMARY KEY AUTOINCREMENT,
    gem_id INTEGER NOT NULL,
    equipment_type_id INTEGER NOT NULL,
    max_slots INTEGER DEFAULT 1,
    effect_multiplier DECIMAL(5,2) DEFAULT 1.00,
    requirements TEXT,
    FOREIGN KEY (gem_id) REFERENCES bulk_commodities(commodity_id),
    FOREIGN KEY (equipment_type_id) REFERENCES equipment_types(type_id)
);


CREATE TABLE material_synthesis_rules (
    rule_id INTEGER PRIMARY KEY AUTOINCREMENT,
    result_item_id INTEGER NOT NULL,
    ingredients TEXT NOT NULL,  
    success_rate DECIMAL(5,2) DEFAULT 100.00,
    min_crafting_level INTEGER DEFAULT 1,
    energy_cost INTEGER DEFAULT 0,
    FOREIGN KEY (result_item_id) REFERENCES bulk_commodities(commodity_id)
);


CREATE TABLE bulk_commodity_holdings (
    holding_id INTEGER PRIMARY KEY AUTOINCREMENT,
    player_id INTEGER NOT NULL,
    commodity_id INTEGER NOT NULL,
    quantity DECIMAL(20,8) NOT NULL DEFAULT 0,
    average_acquisition_price DECIMAL(20,2) DEFAULT 0,
    last_updated DATETIME DEFAULT (datetime('now')) ,
    
    expiry_date DATETIME NULL,  
    quality_level DECIMAL(5,2) DEFAULT 100.00,  
    
    purity_level DECIMAL(5,2) DEFAULT 100.00,  
    FOREIGN KEY (player_id) REFERENCES players(player_id) ON DELETE CASCADE,
    FOREIGN KEY (commodity_id) REFERENCES bulk_commodities(commodity_id) ON DELETE CASCADE
);


CREATE TABLE bulk_commodity_transactions (
    transaction_id INTEGER PRIMARY KEY AUTOINCREMENT,
    commodity_id INTEGER NOT NULL,
    from_player_id INTEGER NULL,
    to_player_id INTEGER NULL,
    quantity DECIMAL(20,8) NOT NULL,
    unit_price DECIMAL(20,2) NOT NULL,
    total_value DECIMAL(20,2) NOT NULL,
    transaction_type TEXT CHECK (transaction_type IN ('trade', 'loot', 'craft', 'quest_reward', 'system', 'exchange', 'synthesis', 'refine')) NOT NULL,
    source_reference VARCHAR(100),
    transaction_time DATETIME DEFAULT (datetime('now')),
    
    exchange_rate DECIMAL(20,8) NULL,
    exchange_fee DECIMAL(20,2) NULL,
    
    synthesis_success INTEGER NULL,
    quality_change DECIMAL(5,2) NULL,
    
    refine_output_quantity DECIMAL(20,8) NULL,
    by_products TEXT NULL,
    FOREIGN KEY (commodity_id) REFERENCES bulk_commodities(commodity_id) ON DELETE CASCADE,
    FOREIGN KEY (from_player_id) REFERENCES players(player_id) ON DELETE SET NULL,
    FOREIGN KEY (to_player_id) REFERENCES players(player_id) ON DELETE SET NULL
);










CREATE TABLE equipment_templates (
    template_id INTEGER PRIMARY KEY AUTOINCREMENT,
    equipment_name VARCHAR(100) NOT NULL,
    type_id INTEGER NOT NULL,
    rarity TEXT CHECK (rarity IN ('common', 'uncommon', 'rare', 'epic', 'legendary')) NOT NULL,
    
    
    base_durability INTEGER NOT NULL,
    level_requirement INTEGER DEFAULT 1,
    base_attributes TEXT, 
    possible_affixes TEXT, 
    description TEXT,
    
    
    gem_slots INTEGER DEFAULT 0, 
    max_gem_slots INTEGER DEFAULT 0, 
    gem_slot_types TEXT, 
    
    
    is_craftable INTEGER DEFAULT 1,
    craft_recipe TEXT, 
    craft_requirements TEXT, 
    craft_stations TEXT, 
    craft_time INTEGER DEFAULT 0, 
    craft_exp INTEGER DEFAULT 0, 
    craft_critical_chance DECIMAL(5,2) DEFAULT 0, 
    craft_critical_bonus TEXT, 
    
    
    is_legendary INTEGER DEFAULT 0,
    max_instances INTEGER DEFAULT NULL, 
    lore TEXT, 
    special_abilities TEXT, 
    discovery_condition TEXT, 
    
    
    base_value DECIMAL(20,2) NOT NULL,
    current_value DECIMAL(20,2) NOT NULL DEFAULT 0,
    market_cap DECIMAL(30,2) DEFAULT 0,
    
    
    total_supply INTEGER DEFAULT 0, 
    circulating_supply INTEGER DEFAULT 0, 
    max_supply INTEGER DEFAULT NULL, 
    
    
    volatility_index DECIMAL(5,2) DEFAULT 0,
    price_change_24h DECIMAL(10,4) DEFAULT 0,
    volume_24h INTEGER DEFAULT 0, 
    last_trade_value DECIMAL(20,2) DEFAULT 0,
    last_trade_time DATETIME NULL,
    
    
    is_tradeable INTEGER DEFAULT 1,
    is_active INTEGER DEFAULT 1,
    created_at DATETIME DEFAULT (datetime('now')),
    updated_at DATETIME DEFAULT (datetime('now')) ,
    
    
    FOREIGN KEY (type_id) REFERENCES equipment_types(type_id)
);


CREATE TABLE equipment_instances (
    instance_id INTEGER PRIMARY KEY AUTOINCREMENT,
    template_id INTEGER NOT NULL,
    current_owner_id INTEGER NULL, 
    owner_type TEXT CHECK (owner_type IN ('player', 'trader', 'world')) NOT NULL DEFAULT 'world', 
    durability INTEGER NOT NULL,
    current_value DECIMAL(20,2) NOT NULL,
    attributes TEXT, 
    creation_type TEXT CHECK (creation_type IN ('craft', 'loot', 'quest_reward', 'system', 'discovery')) NOT NULL,
    creation_source VARCHAR(100) NULL,
    created_at DATETIME DEFAULT (datetime('now')),
    last_modified DATETIME DEFAULT (datetime('now')),
    is_bound INTEGER DEFAULT 0,
    is_broken INTEGER DEFAULT 0,
    enhancement_level INTEGER DEFAULT 0,
    power_level DECIMAL(10,2) DEFAULT NULL,
    awakening_level INTEGER DEFAULT NULL,
    seal_level INTEGER DEFAULT NULL,
    active_gem_slots INTEGER DEFAULT 0,
    FOREIGN KEY (template_id) REFERENCES equipment_templates(template_id)
);


CREATE TABLE equipment_history (
    history_id INTEGER PRIMARY KEY AUTOINCREMENT,
    instance_id INTEGER NOT NULL,
    event_type TEXT CHECK (event_type IN ('created', 'discovered', 'traded', 'equipped', 'unequipped', 'repaired', 'broken', 'destroyed', 'sealed', 'unsealed', 'awakened', 'quest_involved', 'adventure_used')) NOT NULL,
    from_owner_type TEXT CHECK (from_owner_type IN ('player', 'container', 'system', 'adventure')) NULL,
    from_owner_id INTEGER NULL,
    to_owner_type TEXT CHECK (to_owner_type IN ('player', 'container', 'system', 'adventure')) NULL,
    to_owner_id INTEGER NULL,
    adventure_id INTEGER NULL, 
    durability_change INTEGER DEFAULT 0,
    value_change DECIMAL(20,2) DEFAULT 0,
    
    power_change DECIMAL(10,2) DEFAULT NULL,
    awakening_change INTEGER DEFAULT NULL,
    seal_change INTEGER DEFAULT NULL,
    event_location VARCHAR(200) NULL, 
    event_time DATETIME DEFAULT (datetime('now')),
    details TEXT, 
    FOREIGN KEY (instance_id) REFERENCES equipment_instances(instance_id)
);






CREATE TABLE equipment_affixes (
    affix_id INTEGER PRIMARY KEY AUTOINCREMENT,
    affix_name VARCHAR(50) NOT NULL,
    affix_type TEXT CHECK (affix_type IN ('prefix', 'suffix')) NOT NULL,
    rarity TEXT CHECK (rarity IN ('common', 'uncommon', 'rare', 'epic')) NOT NULL,
    applicable_types TEXT, 
    attribute_modifiers TEXT, 
    weight INTEGER DEFAULT 100, 
    description TEXT
);






CREATE TABLE equipment_enhancements (
    enhancement_id INTEGER PRIMARY KEY AUTOINCREMENT,
    instance_id INTEGER NOT NULL,
    enhancement_type TEXT CHECK (enhancement_type IN ('upgrade', 'reforge', 'enchant')) NOT NULL,
    materials_used TEXT, 
    cost_gold DECIMAL(20,2) NOT NULL,
    success_rate DECIMAL(5,2) NOT NULL,
    result_status TEXT CHECK (result_status IN ('success', 'fail', 'critical_success', 'destroyed')) NOT NULL,
    old_attributes TEXT,
    new_attributes TEXT,
    enhancement_time DATETIME DEFAULT (datetime('now')),
    FOREIGN KEY (instance_id) REFERENCES equipment_instances(instance_id)
); 








CREATE TABLE containers (
    container_id INTEGER PRIMARY KEY AUTOINCREMENT,
    container_type TEXT CHECK (container_type IN ('bag', 'chest', 'storage', 'bank', 'guild_storage')) NOT NULL,
    owner_type TEXT CHECK (owner_type IN ('player', 'adventure', 'system', 'guild')) NOT NULL,
    owner_id INTEGER NULL,  
    container_name VARCHAR(100) NOT NULL,
    max_slots INTEGER NOT NULL,
    is_locked INTEGER DEFAULT 0,
    created_at DATETIME DEFAULT (datetime('now')),
    expires_at DATETIME NULL
);


CREATE TABLE item_locations (
    location_id INTEGER PRIMARY KEY AUTOINCREMENT,
    item_type TEXT CHECK (item_type IN ('equipment', 'bulk_commodity')) NOT NULL,
    item_id INTEGER NOT NULL,  
    container_id INTEGER NOT NULL,
    slot_number INTEGER NOT NULL,  
    quantity DECIMAL(20,8) DEFAULT 1,  
    is_equipped INTEGER DEFAULT 0,  
    equip_slot VARCHAR(50) NULL,  
    last_modified DATETIME DEFAULT (datetime('now')) ,
    FOREIGN KEY (container_id) REFERENCES containers(container_id)
);






CREATE TABLE item_history (
    history_id INTEGER PRIMARY KEY AUTOINCREMENT,
    item_type TEXT CHECK (item_type IN ('equipment', 'bulk_commodity')) NOT NULL,
    item_id INTEGER NOT NULL,
    event_type TEXT CHECK (event_type IN ('created', 'obtained', 'traded', 'equipped', 'unequipped', 'stored', 'withdrawn', 'used', 'enhanced', 'repaired', 'broken', 'destroyed')) NOT NULL,
    from_owner_type TEXT CHECK (from_owner_type IN ('player', 'container', 'system', 'adventure')) NULL,
    from_owner_id INTEGER NULL,
    to_owner_type TEXT CHECK (to_owner_type IN ('player', 'container', 'system', 'adventure')) NULL,
    to_owner_id INTEGER NULL,
    quantity DECIMAL(20,8) DEFAULT 1,
    event_time DATETIME DEFAULT (datetime('now')),
    event_source VARCHAR(100),
    additional_data TEXT
);


CREATE TABLE adventure_item_records (
    record_id INTEGER PRIMARY KEY AUTOINCREMENT,
    adventure_id INTEGER NOT NULL,
    item_type TEXT CHECK (item_type IN ('equipment', 'bulk_commodity')) NOT NULL,
    item_id INTEGER NOT NULL,
    player_id INTEGER NOT NULL,  
    role_in_adventure TEXT CHECK (role_in_adventure IN ('equipment', 'consume', 'reward', 'material')) NOT NULL,
    quantity_used DECIMAL(20,8) DEFAULT 1,
    effectiveness_score DECIMAL(5,2) NULL,  
    durability_loss INTEGER NULL,  
    adventure_start DATETIME NOT NULL,
    adventure_end DATETIME NULL,
    notes TEXT
);


CREATE TABLE item_effect_records (
    effect_id INTEGER PRIMARY KEY AUTOINCREMENT,
    item_type TEXT CHECK (item_type IN ('equipment', 'bulk_commodity')) NOT NULL,
    item_id INTEGER NOT NULL,
    effect_type VARCHAR(50) NOT NULL,  
    effect_value TEXT NOT NULL,  
    target_type TEXT CHECK (target_type IN ('player', 'adventure', 'container', 'other')) NOT NULL,
    target_id INTEGER NOT NULL,
    start_time DATETIME DEFAULT (datetime('now')),
    duration_seconds INTEGER NULL,  
    is_active INTEGER DEFAULT 1,
    created_by_adventure_id INTEGER NULL
); 


CREATE TABLE gem_embeddings (
    embedding_id INTEGER PRIMARY KEY AUTOINCREMENT,
    equipment_instance_id INTEGER NOT NULL,
    gem_holding_id INTEGER NOT NULL, 
    slot_index INTEGER NOT NULL, 
    embedded_at DATETIME DEFAULT (datetime('now')),
    removed_at DATETIME NULL, 
    removal_reason TEXT CHECK (removal_reason IN ('replace', 'extract', 'destroy')) NULL, 
    is_active INTEGER DEFAULT 1, 
    
    
    original_attributes TEXT, 
    bonus_attributes TEXT, 
    synergy_effects TEXT, 
    
    
    embedding_cost DECIMAL(20,2) NOT NULL, 
    performed_by INTEGER NULL, 
    notes TEXT,
    
    FOREIGN KEY (equipment_instance_id) REFERENCES equipment_instances(instance_id),
    FOREIGN KEY (gem_holding_id) REFERENCES bulk_commodity_holdings(holding_id),
    FOREIGN KEY (performed_by) REFERENCES players(player_id)
);


CREATE TABLE gem_synergies (
    synergy_id INTEGER PRIMARY KEY AUTOINCREMENT,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    gem_types TEXT NOT NULL, 
    min_gem_count INTEGER DEFAULT 2, 
    level_requirement INTEGER DEFAULT 1,
    rarity TEXT CHECK (rarity IN ('common', 'uncommon', 'rare', 'epic', 'legendary')) NOT NULL,
    
    
    synergy_effects TEXT NOT NULL, 
    activation_conditions TEXT, 
    special_effects TEXT, 
    
    
    is_active INTEGER DEFAULT 1,
    created_at DATETIME DEFAULT (datetime('now'))
);


CREATE TABLE gem_embedding_history (
    history_id INTEGER PRIMARY KEY AUTOINCREMENT,
    embedding_id INTEGER NOT NULL,
    event_type TEXT CHECK (event_type IN ('embed', 'remove', 'activate', 'deactivate', 'upgrade', 'synergy_trigger', 'synergy_end')) NOT NULL,
    event_time DATETIME DEFAULT (datetime('now')),
    performed_by INTEGER NULL,
    old_state TEXT,
    new_state TEXT,
    cost_gold DECIMAL(20,2) DEFAULT 0,
    success_rate DECIMAL(5,2) DEFAULT 100.00,
    event_details TEXT,
    
    FOREIGN KEY (embedding_id) REFERENCES gem_embeddings(embedding_id),
    FOREIGN KEY (performed_by) REFERENCES players(player_id)
); 