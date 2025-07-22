# SQLite Migration Summary

This document summarizes the changes made to update the import scripts to use SQLite instead of MySQL.

## Changes Made

### 1. Created New Import Script

- **File**: `scripts/import_csv_data.php`
- **Purpose**: Main PHP script for importing CSV data into SQLite database
- **Features**:
  - Supports all data types: characters, commodities, teams, projects
  - Uses SQLite database configuration
  - Includes data validation and error handling
  - Uses `INSERT OR REPLACE` for SQLite compatibility

### 2. Updated Batch Files

- **File**: `add_CSV_data/import_data.bat`

  - Updated to check for `database_sqlite.php` instead of `database.php`
  - Now uses SQLite database configuration

- **File**: `add_CSV_data/sql/test_import.bat`
  - Updated to check for `database_sqlite.php` instead of `database.php`
  - Now uses SQLite database configuration

### 3. Created New SQLite Import Tool

- **File**: `add_CSV_data/sql/import_sqlite.bat`
- **Purpose**: Direct SQLite import tool that doesn't require PHP
- **Features**:
  - Uses SQLite3 command line tool
  - Generates sample SQL files automatically
  - Supports all data types
  - Includes sample data for testing

### 4. Created Unix/Linux/macOS Shell Script

- **File**: `add_CSV_data/import_data.sh`
- **Purpose**: Cross-platform import tool for Unix-like systems
- **Features**:
  - Bash script compatible with macOS, Linux, Unix
  - File selection dialog (zenity on Linux)
  - Same functionality as Windows batch file
  - Made executable with `chmod +x`

### 5. Updated Documentation

- **File**: `add_CSV_data/README.md`
  - Added SQLite import methods
  - Updated usage instructions
  - Added cross-platform support information
  - Improved formatting and clarity

## Database Configuration

The scripts now use the SQLite database configuration from:

- `web_interface/config/database_sqlite.php`

This configuration:

- Automatically detects the SQLite database path
- Uses proper SQLite DSN format
- Enables foreign key constraints
- Provides error handling

## Usage

### Method 1: PHP Script (Recommended)

```bash
php scripts/import_csv_data.php <data_type> <csv_file>
```

### Method 2: SQLite Direct Import

```bash
cd add_CSV_data/sql
import_sqlite.bat
```

### Method 3: Graphical Interface

**Windows:**

```bash
cd add_CSV_data
import_data.bat
```

**Unix/Linux/macOS:**

```bash
cd add_CSV_data
./import_data.sh
```

## Data Types Supported

1. **Characters** (`characters`)

   - Required fields: name, rarity, class, level, health, attack, defense
   - Optional fields: description, special_ability

2. **Commodities** (`commodities`)

   - Required fields: name, category, base_price, rarity
   - Optional fields: description, weight, volume

3. **Adventure Teams** (`teams`)

   - Required fields: name, leader_id, specialization, reputation
   - Optional fields: description, max_members

4. **Adventure Projects** (`projects`)
   - Required fields: name, difficulty, reward_type, base_reward
   - Optional fields: description, duration_hours, required_level

## Error Handling

The scripts include comprehensive error handling:

- Validates required fields
- Checks file existence
- Validates data types and ranges
- Provides detailed error messages
- Skips invalid rows and continues processing

## Sample Data

The SQLite import tool includes sample data for testing:

- 15 sample characters with various rarities and classes
- 10 sample commodities with different categories
- 5 sample adventure teams
- 5 sample adventure projects

## Migration Notes

- All scripts now use SQLite syntax (`INSERT OR REPLACE` instead of `INSERT ... ON DUPLICATE KEY UPDATE`)
- Database path is automatically detected relative to project structure
- No MySQL-specific features are used
- All timestamps use SQLite's `datetime('now')` function
- Foreign key constraints are enabled for data integrity

## Testing

To test the migration:

1. Ensure SQLite database exists at `sqlite_database/game_trade.db`
2. Run the import scripts with sample data
3. Verify data is correctly imported into SQLite database
4. Check web interface displays data correctly
