@echo off
title SQLite Data Import Tool
color 0A

echo ========================================
echo      SQLite Data Import Tool
echo ========================================
echo.
echo This tool imports sample data directly into SQLite database
echo without requiring PHP. Only SQLite3 command is needed.
echo.
echo Press any key to continue...
pause >nul
echo.

REM Check if sqlite3 command is available
sqlite3 --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] SQLite3 client not found in system PATH
    echo.
    echo Possible solutions:
    echo 1. Add SQLite3 bin directory to system PATH
    echo 2. Use full SQLite3 path like: C:\sqlite\sqlite3.exe
    echo 3. Install SQLite from https://www.sqlite.org/download.html
    echo.
    set /p sqlite_path="Enter full SQLite3 path or press Enter to skip: "
    if not "%sqlite_path%"=="" (
        "%sqlite_path%" --version >nul 2>&1
        if errorlevel 1 (
            echo [ERROR] Specified SQLite3 path is invalid
            pause
            exit /b 1
        ) else (
            set sqlite_cmd="%sqlite_path%"
            echo [OK] Using specified SQLite3 path
        )
    ) else (
        echo [SKIP] Will try to use sqlite3 command directly
        echo [WARNING] This may cause errors if SQLite3 is not in PATH
        set sqlite_cmd=sqlite3
        echo.
        pause
    )
) else (
    echo [OK] SQLite3 client found
    sqlite3 --version | findstr "SQLite"
    set sqlite_cmd=sqlite3
)

REM Set database path
set DB_PATH=..\..\sqlite_database\game_trade.db

REM Check if database exists
if not exist "%DB_PATH%" (
    echo [ERROR] SQLite database not found at: %DB_PATH%
    echo.
    echo Please ensure the database file exists or run database initialization first.
    echo.
    pause
    exit /b 1
) else (
    echo [OK] SQLite database found at: %DB_PATH%
)

echo.
echo Press any key to continue to main menu...
pause >nul

:menu
cls
echo ========================================
echo      SQLite Data Import Tool
echo ========================================
echo.
echo Current directory: %CD%
echo Database: %DB_PATH%
echo.
echo Please select data to import:
echo.
echo [1] Import Sample Characters (SQL)
echo [2] Import Sample Commodities (SQL)
echo [3] Import Sample Teams (SQL)
echo [4] Import Sample Projects (SQL)
echo [5] Import All Sample Data
echo [0] Exit
echo.
set /p choice="Enter your choice (0-5): "

if "%choice%"=="1" goto import_characters
if "%choice%"=="2" goto import_commodities
if "%choice%"=="3" goto import_teams
if "%choice%"=="4" goto import_projects
if "%choice%"=="5" goto import_all
if "%choice%"=="0" goto exit
echo [WARNING] Invalid choice, please try again
echo.
pause
goto menu

:import_characters
echo.
echo ========================================
echo Importing sample characters...
echo ========================================
echo.
if not exist "sample_characters.sql" (
    echo [INFO] Creating sample_characters.sql file...
    call :create_characters_sql
)
echo Executing SQL import...
echo Database: %DB_PATH%
echo.
%sqlite_cmd% "%DB_PATH%" < sample_characters.sql
if errorlevel 1 (
    echo.
    echo [ERROR] Import failed, please check error messages above
    echo.
) else (
    echo.
    echo [SUCCESS] Sample characters imported successfully!
    echo.
)
pause
goto menu

:import_commodities
echo.
echo ========================================
echo Importing sample commodities...
echo ========================================
echo.
if not exist "sample_commodities.sql" (
    echo [INFO] Creating sample_commodities.sql file...
    call :create_commodities_sql
)
echo Executing SQL import...
echo Database: %DB_PATH%
echo.
%sqlite_cmd% "%DB_PATH%" < sample_commodities.sql
if errorlevel 1 (
    echo.
    echo [ERROR] Import failed, please check error messages above
    echo.
) else (
    echo.
    echo [SUCCESS] Sample commodities imported successfully!
    echo.
)
pause
goto menu

:import_teams
echo.
echo ========================================
echo Importing sample teams...
echo ========================================
echo.
if not exist "sample_teams.sql" (
    echo [INFO] Creating sample_teams.sql file...
    call :create_teams_sql
)
echo Executing SQL import...
echo Database: %DB_PATH%
echo.
%sqlite_cmd% "%DB_PATH%" < sample_teams.sql
if errorlevel 1 (
    echo.
    echo [ERROR] Import failed, please check error messages above
    echo.
) else (
    echo.
    echo [SUCCESS] Sample teams imported successfully!
    echo.
)
pause
goto menu

:import_projects
echo.
echo ========================================
echo Importing sample projects...
echo ========================================
echo.
if not exist "sample_projects.sql" (
    echo [INFO] Creating sample_projects.sql file...
    call :create_projects_sql
)
echo Executing SQL import...
echo Database: %DB_PATH%
echo.
%sqlite_cmd% "%DB_PATH%" < sample_projects.sql
if errorlevel 1 (
    echo.
    echo [ERROR] Import failed, please check error messages above
    echo.
) else (
    echo.
    echo [SUCCESS] Sample projects imported successfully!
    echo.
)
pause
goto menu

:import_all
echo.
echo ========================================
echo Importing all sample data...
echo ========================================
echo.
set error_count=0

echo [1/4] Importing sample characters...
if exist "sample_characters.sql" (
    %sqlite_cmd% "%DB_PATH%" < sample_characters.sql
    if errorlevel 1 set /a error_count+=1
) else (
    echo [SKIP] sample_characters.sql not found
)
echo.

echo [2/4] Importing sample commodities...
if exist "sample_commodities.sql" (
    %sqlite_cmd% "%DB_PATH%" < sample_commodities.sql
    if errorlevel 1 set /a error_count+=1
) else (
    echo [SKIP] sample_commodities.sql not found
)
echo.

echo [3/4] Importing sample teams...
if exist "sample_teams.sql" (
    %sqlite_cmd% "%DB_PATH%" < sample_teams.sql
    if errorlevel 1 set /a error_count+=1
) else (
    echo [SKIP] sample_teams.sql not found
)
echo.

echo [4/4] Importing sample projects...
if exist "sample_projects.sql" (
    %sqlite_cmd% "%DB_PATH%" < sample_projects.sql
    if errorlevel 1 set /a error_count+=1
) else (
    echo [SKIP] sample_projects.sql not found
)
echo.

echo ========================================
if %error_count%==0 (
    echo [SUCCESS] All sample data imported successfully!
    color 0A
) else (
    echo [WARNING] Import completed with %error_count% errors
    color 0C
)
echo ========================================
echo.
pause
goto menu

:create_characters_sql
echo Creating sample characters SQL file...
(
echo -- Sample Characters Data
echo -- Generated automatically by import_sqlite.bat
echo.
echo INSERT OR REPLACE INTO players ^(name, rarity, class, level, health, attack, defense, description, special_ability, created_at^) VALUES
echo ^('Steel Knight Gavin', 'Rare', 'Warrior', 15, 120, 85, 90, 'A seasoned knight with steel armor', 'Steel Defense: +20 defense when health ^< 50%%', datetime^('now'^)^),
echo ^('Smart Merchant Rose', 'Epic', 'Trader', 12, 80, 45, 60, 'A clever merchant with sharp business sense', 'Trade Mastery: +30%% gold from sales', datetime^('now'^)^),
echo ^('Forest Ranger Aiden', 'Uncommon', 'Explorer', 10, 95, 70, 65, 'A skilled ranger of the forest', 'Nature Bond: +15%% health in wilderness', datetime^('now'^)^),
echo ^('Ancient Scholar Mira', 'Rare', 'Scholar', 18, 75, 55, 50, 'A wise scholar of ancient knowledge', 'Knowledge Power: +25%% experience gain', datetime^('now'^)^),
echo ^('Shadow Mage Karl', 'Epic', 'Mystic', 20, 85, 95, 40, 'A mysterious mage of shadow magic', 'Shadow Step: Can teleport short distances', datetime^('now'^)^),
echo ^('Wasteland Scavenger Jack', 'Common', 'Survivor', 8, 100, 60, 70, 'A tough survivor of the wasteland', 'Scavenger Eye: +20%% chance to find items', datetime^('now'^)^),
echo ^('Holy Priest Alice', 'Rare', 'Mystic', 14, 90, 50, 75, 'A devoted priest of light', 'Divine Healing: Can heal allies', datetime^('now'^)^),
echo ^('Berserker Grom', 'Uncommon', 'Warrior', 11, 110, 80, 65, 'A fierce berserker warrior', 'Rage Mode: +30%% attack when health ^< 30%%', datetime^('now'^)^),
echo ^('Thief Vera', 'Uncommon', 'Survivor', 9, 85, 75, 55, 'A skilled thief and rogue', 'Stealth Master: +25%% chance to avoid detection', datetime^('now'^)^),
echo ^('Wise Silas', 'Epic', 'Scholar', 16, 70, 60, 45, 'A wise old scholar', 'Ancient Wisdom: +40%% experience gain', datetime^('now'^)^),
echo ^('Lightning Mage Thor', 'Legendary', 'Mystic', 25, 95, 110, 60, 'A powerful mage of lightning', 'Lightning Storm: Area damage to all enemies', datetime^('now'^)^),
echo ^('Novice Swordsman Tommy', 'Common', 'Warrior', 5, 80, 65, 70, 'A young swordsman in training', 'Quick Learner: +15%% experience gain', datetime^('now'^)^),
echo ^('Caravan Guard Bruce', 'Common', 'Warrior', 7, 90, 70, 75, 'A reliable caravan guard', 'Guard Duty: +20%% defense when protecting others', datetime^('now'^)^),
echo ^('Apprentice Mage Luna', 'Common', 'Mystic', 6, 75, 60, 50, 'A young apprentice mage', 'Mana Sense: +10%% magic power', datetime^('now'^)^),
echo ^('Veteran Merchant Marcus', 'Rare', 'Trader', 13, 85, 50, 65, 'An experienced merchant', 'Trade Network: +25%% gold from sales', datetime^('now'^)^);
) > sample_characters.sql
echo [OK] sample_characters.sql created
goto :eof

:create_commodities_sql
echo Creating sample commodities SQL file...
(
echo -- Sample Commodities Data
echo -- Generated automatically by import_sqlite.bat
echo.
echo INSERT OR REPLACE INTO items ^(name, category, base_price, rarity, description, weight, volume, created_at^) VALUES
echo ^('Iron Ore', 'Raw Materials', 15.50, 'Common', 'Basic iron ore for crafting', 2.5, 1.0, datetime^('now'^)^),
echo ^('Gold Nugget', 'Precious Metals', 85.00, 'Rare', 'Pure gold nugget', 0.5, 0.2, datetime^('now'^)^),
echo ^('Herbs Bundle', 'Medicine', 12.00, 'Common', 'Medicinal herbs for healing', 0.8, 0.5, datetime^('now'^)^),
echo ^('Silk Fabric', 'Textiles', 45.00, 'Uncommon', 'Fine silk fabric', 0.3, 1.0, datetime^('now'^)^),
echo ^('Ancient Artifact', 'Antiques', 250.00, 'Epic', 'Mysterious ancient artifact', 1.2, 0.8, datetime^('now'^)^),
echo ^('Magic Crystal', 'Magical Items', 120.00, 'Rare', 'Crystal with magical properties', 0.4, 0.3, datetime^('now'^)^),
echo ^('Leather Hide', 'Raw Materials', 8.50, 'Common', 'Treated leather hide', 1.5, 0.8, datetime^('now'^)^),
echo ^('Silver Coin', 'Precious Metals', 35.00, 'Uncommon', 'Pure silver coin', 0.1, 0.05, datetime^('now'^)^),
echo ^('Healing Potion', 'Medicine', 25.00, 'Uncommon', 'Restores health when consumed', 0.2, 0.1, datetime^('now'^)^),
echo ^('Wool Cloth', 'Textiles', 18.00, 'Common', 'Warm wool cloth', 0.6, 0.7, datetime^('now'^)^);
) > sample_commodities.sql
echo [OK] sample_commodities.sql created
goto :eof

:create_teams_sql
echo Creating sample teams SQL file...
(
echo -- Sample Adventure Teams Data
echo -- Generated automatically by import_sqlite.bat
echo.
echo INSERT OR REPLACE INTO adventure_teams ^(name, leader_id, specialization, reputation, description, max_members, created_at^) VALUES
echo ^('Iron Brotherhood', 1, 'Combat', 75, 'Elite warriors specializing in heavy combat', 6, datetime^('now'^)^),
echo ^('Golden Traders', 2, 'Trade', 85, 'Experienced merchants and traders', 4, datetime^('now'^)^),
echo ^('Forest Explorers', 3, 'Exploration', 60, 'Rangers and scouts for wilderness exploration', 5, datetime^('now'^)^),
echo ^('Arcane Circle', 5, 'Magic', 90, 'Powerful mages and scholars', 4, datetime^('now'^)^),
echo ^('Wasteland Survivors', 6, 'Survival', 45, 'Tough survivors of harsh environments', 8, datetime^('now'^)^);
) > sample_teams.sql
echo [OK] sample_teams.sql created
goto :eof

:create_projects_sql
echo Creating sample projects SQL file...
(
echo -- Sample Adventure Projects Data
echo -- Generated automatically by import_sqlite.bat
echo.
echo INSERT OR REPLACE INTO adventure_projects ^(name, difficulty, reward_type, base_reward, description, duration_hours, required_level, created_at^) VALUES
echo ^('Clear Bandit Camp', 'Easy', 'Gold', 150, 'Clear a small bandit camp from the area', 4, 5, datetime^('now'^)^),
echo ^('Escort Merchant Caravan', 'Medium', 'Gold', 300, 'Protect a merchant caravan on their journey', 8, 8, datetime^('now'^)^),
echo ^('Explore Ancient Ruins', 'Hard', 'Experience', 500, 'Explore mysterious ancient ruins', 12, 12, datetime^('now'^)^),
echo ^('Defeat Dragon', 'Legendary', 'Gold', 1000, 'Face and defeat a powerful dragon', 24, 20, datetime^('now'^)^),
echo ^('Gather Rare Herbs', 'Easy', 'Items', 100, 'Collect rare medicinal herbs from the forest', 3, 3, datetime^('now'^)^);
) > sample_projects.sql
echo [OK] sample_projects.sql created
goto :eof

:exit
echo.
echo Thank you for using SQLite Data Import Tool!
echo Goodbye!
echo.
pause
exit /b 0 