-- SQLite Database Initialization Script
-- Converted from MySQL

-- Enable foreign keys
PRAGMA foreign_keys = ON;

-- Load schema files in order
.read sqlite_01_players.sql
.read sqlite_02_item_module.sql
.read sqlite_03_traders.sql
.read sqlite_04_trade_module.sql
.read sqlite_05_venture_module.sql
.read sqlite_06_interaction_system.sql

-- Initialize game data
.read init_data.sql
