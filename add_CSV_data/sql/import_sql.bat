@echo off
title SQL Data Import Tool
color 0A

echo ========================================
echo      SQL Data Import Tool
echo ========================================
echo.
echo This tool imports sample data directly into MySQL database
echo without requiring PHP. Only MySQL client is needed.
echo.
echo Press any key to continue...
pause >nul
echo.

REM Check if mysql command is available
mysql --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] MySQL client not found in system PATH
    echo.
    echo Possible solutions:
    echo 1. Add MySQL bin directory to system PATH
    echo 2. Use full MySQL path like: C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe
    echo 3. Install MySQL Workbench or XAMPP which includes MySQL client
    echo.
    set /p mysql_path="Enter full MySQL path or press Enter to skip: "
    if not "%mysql_path%"=="" (
        "%mysql_path%" --version >nul 2>&1
        if errorlevel 1 (
            echo [ERROR] Specified MySQL path is invalid
            pause
            exit /b 1
        ) else (
            set mysql_cmd="%mysql_path%"
            echo [OK] Using specified MySQL path
        )
    ) else (
        echo [SKIP] Will try to use mysql command directly
        echo [WARNING] This may cause errors if MySQL is not in PATH
        set mysql_cmd=mysql
        echo.
        pause
    )
) else (
    echo [OK] MySQL client found
    mysql --version | findstr "mysql"
    set mysql_cmd=mysql
)

echo.
echo Press any key to continue to main menu...
pause >nul

:menu
cls
echo ========================================
echo      SQL Data Import Tool
echo ========================================
echo.
echo Current directory: %CD%
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
echo Database: game_trade
echo User: game_user
echo.
set /p password="Enter database password (default: capti_game): "
if "%password%"=="" set password=capti_game
%mysql_cmd% -u game_user -p%password% -D game_trade < sample_characters.sql
if errorlevel 1 (
    echo.
    echo [ERROR] Import failed, please check error messages above
    echo Common issues:
    echo - Wrong database password
    echo - MySQL service not running
    echo - Database 'game_trade' does not exist
) else (
    echo.
    echo [SUCCESS] Sample characters imported successfully!
)
echo.
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
%mysql_cmd% -u game_user -p%password% -D game_trade < sample_commodities.sql
if errorlevel 1 (
    echo.
    echo [ERROR] Import failed, please check error messages above
    echo Common issues:
    echo - Wrong database password
    echo - MySQL service not running
    echo - Database 'game_trade' does not exist
) else (
    echo.
    echo [SUCCESS] Sample commodities imported successfully!
)
echo.
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
%mysql_cmd% -u game_user -p%password% -D game_trade < sample_teams.sql
if errorlevel 1 (
    echo.
    echo [ERROR] Import failed, please check error messages above
    echo Common issues:
    echo - Wrong database password
    echo - MySQL service not running
    echo - Database 'game_trade' does not exist
) else (
    echo.
    echo [SUCCESS] Sample teams imported successfully!
)
echo.
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
%mysql_cmd% -u game_user -p%password% -D game_trade < sample_projects.sql
if errorlevel 1 (
    echo.
    echo [ERROR] Import failed, please check error messages above
    echo Common issues:
    echo - Wrong database password
    echo - MySQL service not running
    echo - Database 'game_trade' does not exist
) else (
    echo.
    echo [SUCCESS] Sample projects imported successfully!
)
echo.
pause
goto menu

:import_all
echo.
echo ========================================
echo Importing all sample data...
echo ========================================
echo.
set /p password="Enter database password (default: capti_game): "
if "%password%"=="" set password=capti_game

echo [1/4] Creating SQL files if needed...
if not exist "sample_characters.sql" call :create_characters_sql
if not exist "sample_commodities.sql" call :create_commodities_sql
if not exist "sample_teams.sql" call :create_teams_sql
if not exist "sample_projects.sql" call :create_projects_sql

set error_count=0

echo [2/4] Importing characters...
%mysql_cmd% -u game_user -p%password% -D game_trade < sample_characters.sql
if errorlevel 1 set /a error_count+=1

echo [3/4] Importing commodities...
%mysql_cmd% -u game_user -p%password% -D game_trade < sample_commodities.sql
if errorlevel 1 set /a error_count+=1

echo [4/4] Importing teams and projects...
%mysql_cmd% -u game_user -p%password% -D game_trade < sample_teams.sql
if errorlevel 1 set /a error_count+=1
%mysql_cmd% -u game_user -p%password% -D game_trade < sample_projects.sql
if errorlevel 1 set /a error_count+=1

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
echo -- Sample Characters Data > sample_characters.sql
echo -- Generated by SQL Data Import Tool >> sample_characters.sql
echo. >> sample_characters.sql
echo -- Insert sample characters >> sample_characters.sql
echo INSERT INTO players ( >> sample_characters.sql
echo     character_name, display_name, character_class, rarity, hire_cost, maintenance_cost, >> sample_characters.sql
echo     strength, vitality, agility, intelligence, faith, luck, >> sample_characters.sql
echo     loyalty, courage, patience, greed, wisdom, charisma, >> sample_characters.sql
echo     trade_skill, venture_skill, negotiation_skill, analysis_skill, leadership_skill, >> sample_characters.sql
echo     total_experience, current_level, skill_points, >> sample_characters.sql
echo     personality_traits, is_available >> sample_characters.sql
echo ^) VALUES >> sample_characters.sql
echo ^('Steel Knight Gavin', 'Gavin', 'warrior', 'rare', 8000, 200, >> sample_characters.sql
echo  16, 18, 12, 10, 14, 11, >> sample_characters.sql
echo  80, 90, 70, 40, 60, 75, >> sample_characters.sql
echo  40, 85, 60, 45, 80, >> sample_characters.sql
echo  3500, 7, 2, >> sample_characters.sql
echo  JSON_ARRAY^('勤奋', '坚韧', '冷静'^), >> sample_characters.sql
echo  TRUE^), >> sample_characters.sql
echo ^('Smart Merchant Rose', 'Rose', 'trader', 'epic', 15000, 300, >> sample_characters.sql
echo  8, 10, 14, 18, 12, 16, >> sample_characters.sql
echo  75, 60, 85, 70, 85, 80, >> sample_characters.sql
echo  90, 45, 95, 90, 65, >> sample_characters.sql
echo  5500, 9, 3, >> sample_characters.sql
echo  JSON_ARRAY^('专注', '直觉敏锐', '学习能力强'^), >> sample_characters.sql
echo  TRUE^), >> sample_characters.sql
echo ^('Forest Ranger Aiden', 'Aiden', 'explorer', 'uncommon', 5000, 150, >> sample_characters.sql
echo  14, 16, 18, 12, 10, 14, >> sample_characters.sql
echo  70, 80, 75, 50, 65, 60, >> sample_characters.sql
echo  30, 80, 50, 60, 70, >> sample_characters.sql
echo  2800, 6, 1, >> sample_characters.sql
echo  JSON_ARRAY^('乐观', '谨慎'^), >> sample_characters.sql
echo  TRUE^); >> sample_characters.sql
echo. >> sample_characters.sql
echo -- Insert mood data for new characters >> sample_characters.sql
echo INSERT INTO player_mood ^(player_id, happiness, stress, motivation, confidence, fatigue, focus, team_relationship, reputation^) >> sample_characters.sql
echo SELECT p.player_id, 70, 25, 75, 70, 20, 75, 70, 65 >> sample_characters.sql
echo FROM players p >> sample_characters.sql
echo WHERE p.character_name IN ^('Steel Knight Gavin', 'Smart Merchant Rose', 'Forest Ranger Aiden'^) >> sample_characters.sql
echo   AND NOT EXISTS ^(SELECT 1 FROM player_mood pm WHERE pm.player_id = p.player_id^); >> sample_characters.sql
goto :eof

:create_commodities_sql
echo -- Sample Commodities Data > sample_commodities.sql
echo INSERT INTO commodities ^( >> sample_commodities.sql
echo     commodity_name, commodity_symbol, category, rarity, base_price, current_price, >> sample_commodities.sql
echo     market_cap, total_supply, circulating_supply, volatility_index, description, >> sample_commodities.sql
echo     is_tradeable, is_active >> sample_commodities.sql
echo ^) VALUES >> sample_commodities.sql
echo ^('Mithril Ore', 'MITHRIL', 'metal', 'epic', 2000.00, 2500.00, >> sample_commodities.sql
echo  2000000.00, 5000.00, 2000.00, 0.12, 'Legendary lightweight metal ore', >> sample_commodities.sql
echo  TRUE, TRUE^), >> sample_commodities.sql
echo ^('Phoenix Feather', 'PHOENIX', 'magic', 'legendary', 8000.00, 10000.00, >> sample_commodities.sql
echo  500000.00, 500.00, 100.00, 0.25, 'Rare feather with fire magic properties', >> sample_commodities.sql
echo  TRUE, TRUE^), >> sample_commodities.sql
echo ^('Crystal Shard', 'CRYSTAL', 'gem', 'rare', 1200.00, 1500.00, >> sample_commodities.sql
echo  1500000.00, 8000.00, 3000.00, 0.15, 'Energy-infused crystal fragments', >> sample_commodities.sql
echo  TRUE, TRUE^); >> sample_commodities.sql
goto :eof

:create_teams_sql
echo -- Sample Teams Data > sample_teams.sql
echo INSERT INTO adventure_teams ^( >> sample_teams.sql
echo     team_name, team_leader, team_size, specialization, success_rate, >> sample_teams.sql
echo     base_cost, team_level, team_description, current_status, morale >> sample_teams.sql
echo ^) VALUES >> sample_teams.sql
echo ^('Elite Guard Unit', 'Steel Knight Gavin', 4, 'combat', 80.00, >> sample_teams.sql
echo  6000, 8, 'Professional combat specialists', 'available', 85.00^), >> sample_teams.sql
echo ^('Merchant Caravan', 'Smart Merchant Rose', 3, 'trade', 75.00, >> sample_teams.sql
echo  4000, 6, 'Experienced trading expedition', 'available', 80.00^); >> sample_teams.sql
goto :eof

:create_projects_sql
echo -- Sample Projects Data > sample_projects.sql
echo INSERT INTO adventure_projects ^( >> sample_projects.sql
echo     project_name, project_type, difficulty, required_team_size, >> sample_projects.sql
echo     base_investment, max_investment, investment_goal, >> sample_projects.sql
echo     expected_duration_hours, risk_level, expected_return_rate, >> sample_projects.sql
echo     project_description, status >> sample_projects.sql
echo ^) VALUES >> sample_projects.sql
echo ^('Mountain Pass Survey', 'exploration', 'easy', 3, >> sample_projects.sql
echo  5000, 20000, 40000, >> sample_projects.sql
echo  24, 0.20, 100.00, >> sample_projects.sql
echo  'Survey and map mountain trade routes', 'funding'^), >> sample_projects.sql
echo ^('Bandit Camp Clearing', 'combat', 'normal', 4, >> sample_projects.sql
echo  8000, 40000, 80000, >> sample_projects.sql
echo  36, 0.35, 150.00, >> sample_projects.sql
echo  'Clear bandit camps threatening trade routes', 'funding'^); >> sample_projects.sql
goto :eof

:exit
echo.
echo Thank you for using SQL Data Import Tool!
echo Goodbye!
echo.
pause
exit /b 0 