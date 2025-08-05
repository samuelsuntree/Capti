-- =============================================
-- 数据库重置脚本
-- 快速清理所有数据，回到初始状态
-- =============================================

-- ⚠️ 警告：此脚本会删除所有数据！
-- 使用前请确保已备份重要数据

-- 使用说明：
-- 1. 在 MySQL 客户端中运行此脚本
-- 2. 确认要重置数据库
-- 3. 查看重置结果

-- 设置字符集
SET NAMES utf8mb4;
SET character_set_client = utf8mb4;
SET character_set_connection = utf8mb4;
SET character_set_results = utf8mb4;

-- 显示警告信息
SELECT '⚠️ ========== 警告 ========== ⚠️' AS '重要提示';
SELECT '此操作将删除所有数据！' AS '警告1';
SELECT '请确保已备份重要数据！' AS '警告2';
SELECT '继续执行将无法恢复数据！' AS '警告3';

-- 显示重置开始信息
SELECT '========== 开始重置数据库 ==========' AS '信息';
SELECT CONCAT('重置时间: ', NOW()) AS '时间戳';

-- 检查数据库是否存在
SELECT 
    CASE 
        WHEN COUNT(*) > 0 THEN '数据库存在，开始重置'
        ELSE '数据库不存在，将创建新数据库'
    END AS '状态'
FROM information_schema.SCHEMATA 
WHERE SCHEMA_NAME = 'game_trade';

-- 如果数据库存在，显示当前数据量
SELECT '========== 当前数据量 ==========' AS '信息';
SELECT 
    COALESCE(
        (SELECT COUNT(*) FROM information_schema.TABLES WHERE TABLE_SCHEMA = 'game_trade'),
        0
    ) AS '表数量';

-- 删除现有数据库
DROP DATABASE IF EXISTS game_trade;
SELECT '✅ 旧数据库已删除' AS '步骤1';

-- 创建新数据库
CREATE DATABASE game_trade CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
SELECT '✅ 新数据库已创建' AS '步骤2';

-- 使用数据库
USE game_trade;

-- 创建用户和权限
CREATE USER IF NOT EXISTS 'game_user'@'localhost' IDENTIFIED BY 'game_password';
CREATE USER IF NOT EXISTS 'game_readonly'@'localhost' IDENTIFIED BY 'readonly_password';
GRANT ALL PRIVILEGES ON game_trade.* TO 'game_user'@'localhost';
GRANT SELECT ON game_trade.* TO 'game_readonly'@'localhost';
FLUSH PRIVILEGES;
SELECT '✅ 用户权限已设置' AS '步骤3';

-- 注意：此脚本仅重置数据库结构，需要手动运行以下脚本加载完整数据：
-- source E:/resource/github/Capti/scripts/init_database.sql

SELECT '========== 重置完成 ==========' AS '信息';
SELECT '数据库已重置为空状态' AS '状态';
SELECT '请运行 init_database.sql 加载完整的表结构和初始数据' AS '下一步';
SELECT CONCAT('完成时间: ', NOW()) AS '时间戳'; 