-- =============================================
-- 创建MySQL用户脚本
-- 用于创建 'Tree' 用户并授予权限
-- =============================================

-- 注意：此脚本需要用root权限运行

-- 创建用户 'Tree'（无密码）
CREATE USER IF NOT EXISTS 'Tree'@'localhost';

-- 授予所有权限（适用于开发环境）
GRANT ALL PRIVILEGES ON *.* TO 'Tree'@'localhost' WITH GRANT OPTION;

-- 刷新权限
FLUSH PRIVILEGES;

-- 显示创建结果
SELECT 'Tree用户创建成功！' AS '状态';
SELECT User, Host FROM mysql.user WHERE User = 'Tree';

-- 显示用户权限
SHOW GRANTS FOR 'Tree'@'localhost'; 