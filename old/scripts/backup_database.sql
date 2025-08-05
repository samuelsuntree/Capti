-- =============================================
-- Simple Database Backup Script
-- =============================================
-- mysqldump -u root -p --single-transaction --routines --triggers game_trade > game_trade_backup_$(Get-Date -Format "yyyyMMdd_HHmmss").sql

-- Show backup command with current timestamp
SELECT CONCAT(
    '!mysqldump -u root -p --single-transaction --routines --triggers game_trade > game_trade_backup_',
    DATE_FORMAT(NOW(), '%Y%m%d_%H%i%s'),
    '.sql'
) AS '';

-- Show restore instructions
SELECT '========== Restore Instructions ==========' AS '';
SELECT 'To restore, use command like:' AS 'Note';
SELECT 'mysql -u root -p game_trade < game_trade_backup_[timestamp].sql' AS 'Example'; 