-- Simple SQLite Database Initialization
PRAGMA foreign_keys = ON;

-- Load schema
.read simple_schema.sql

-- Load data
.read simple_data.sql
