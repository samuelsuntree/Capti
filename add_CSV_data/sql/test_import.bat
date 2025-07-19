@echo off
title Test Character Import
color 0B

echo =======================================
echo        Test Character Data Import
echo =======================================
echo.

REM Display current directory
echo Current directory: %CD%
echo.

REM Check necessary files
echo Checking necessary files...
if not exist "test_characters.csv" (
    echo [ERROR] test_characters.csv file not found
    echo Please ensure the file exists in templates directory
    echo.
    pause
    exit /b 1
) else (
    echo [OK] test_characters.csv file exists
)

if not exist "..\scripts\import_csv_data.php" (
    echo [ERROR] Import script not found
    echo Please ensure scripts\import_csv_data.php file exists
    echo.
    pause
    exit /b 1
) else (
    echo [OK] Import script exists
)

if not exist "..\web_interface\config\database.php" (
    echo [ERROR] Database config file not found
    echo Please ensure web_interface\config\database.php file exists
    echo.
    pause
    exit /b 1
) else (
    echo [OK] Database config file exists
)

echo.

REM Check PHP
echo Checking PHP environment...
php --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] PHP not found or not in PATH
    echo.
    echo Please try the following solutions:
    echo 1. Install PHP and add to system PATH
    echo 2. Use XAMPP, WAMP or similar integrated environment
    echo 3. Manually specify PHP path
    echo.
    set /p php_path="Enter full PHP path (e.g. C:\xampp\php\php.exe) or press Enter to skip: "
    if not "%php_path%"=="" (
        "%php_path%" --version >nul 2>&1
        if errorlevel 1 (
            echo [ERROR] Specified PHP path is invalid
            pause
            exit /b 1
        ) else (
            set php_cmd="%php_path%"
            echo [OK] Using specified PHP path
        )
    ) else (
        echo [SKIP] Will try to use php command directly
        set php_cmd=php
    )
) else (
    echo [OK] PHP environment is normal
    php --version | findstr "PHP"
    set php_cmd=php
)

echo.
echo =======================================
echo Starting test data import...
echo =======================================
echo.

echo Import command: %php_cmd% ..\scripts\import_csv_data.php characters test_characters.csv
echo.

REM Execute import
%php_cmd% ..\scripts\import_csv_data.php characters test_characters.csv

REM Check result
if errorlevel 1 (
    echo.
    echo =======================================
    echo [FAILED] Error occurred during import
    echo =======================================
    echo.
    echo Possible causes:
    echo 1. Database connection failed - Check database config and service status
    echo 2. CSV file format error - Check file encoding and format
    echo 3. Data validation failed - Check if data meets requirements
    echo 4. Permission issues - Ensure database write permissions
    echo.
) else (
    echo.
    echo =======================================
    echo [SUCCESS] Test data import completed!
    echo =======================================
    echo.
    echo Imported characters include:
    echo - Steel Knight Gavin (Rare Warrior)
    echo - Smart Merchant Rose (Epic Trader)  
    echo - Forest Ranger Aiden (Uncommon Explorer)
    echo - Ancient Scholar Mira (Rare Scholar)
    echo - Shadow Mage Karl (Epic Mystic)
    echo - Wasteland Scavenger Jack (Common Survivor)
    echo - Holy Priest Alice (Rare Mystic)
    echo - Berserker Grom (Uncommon Warrior)
    echo - Thief Vera (Uncommon Survivor)
    echo - Wise Silas (Epic Scholar)
    echo - Lightning Mage Thor (Legendary Mystic)
    echo - Novice Swordsman Tommy (Common Warrior)
    echo - Caravan Guard Bruce (Common Warrior)
    echo - Apprentice Mage Luna (Common Mystic)
    echo - Veteran Merchant Marcus (Rare Trader)
    echo.
    echo Total imported: 15 characters!
    echo.
)

echo You can view the import results through:
echo 1. Visit Web interface to view character list
echo 2. Directly query database players table
echo 3. Use queries in quick_queries.sql
echo.

pause 