-- =============================================
-- 装备查询相关SQL
-- =============================================

-- 查询所有装备及其拥有者
SELECT 
    CASE 
        WHEN ei.owner_type = 'player' THEN p.character_name
        WHEN ei.owner_type = 'trader' THEN t.display_name
    END as owner_name,
    ei.owner_type,
    et.equipment_name,
    et.rarity,
    ei.durability,
    ei.current_value
FROM equipment_instances ei
LEFT JOIN players p ON ei.current_owner_id = p.player_id AND ei.owner_type = 'player'
LEFT JOIN traders t ON ei.current_owner_id = t.trader_id AND ei.owner_type = 'trader'
JOIN equipment_templates et ON ei.template_id = et.template_id
ORDER BY ei.owner_type, owner_name;

-- 查询特定玩家的装备
-- 使用方法: 将 :player_id 替换为实际的玩家ID
SELECT 
    p.character_name,
    et.equipment_name,
    et.rarity,
    ei.durability,
    ei.current_value,
    ei.attributes,
    ei.enhancement_level
FROM equipment_instances ei
JOIN players p ON ei.current_owner_id = p.player_id
JOIN equipment_templates et ON ei.template_id = et.template_id
WHERE ei.current_owner_id = :player_id
AND ei.owner_type = 'player';

-- 查询特定trader的装备
-- 使用方法: 将 :trader_id 替换为实际的trader ID
SELECT 
    t.display_name,
    et.equipment_name,
    et.rarity,
    ei.durability,
    ei.current_value,
    ei.attributes,
    ei.enhancement_level,
    ti.purchase_price,
    ti.acquired_at,
    ti.is_locked
FROM equipment_instances ei
JOIN traders t ON ei.current_owner_id = t.trader_id
JOIN equipment_templates et ON ei.template_id = et.template_id
JOIN trader_items ti ON ei.instance_id = ti.equipment_instance_id
WHERE ei.current_owner_id = :trader_id
AND ei.owner_type = 'trader'; 