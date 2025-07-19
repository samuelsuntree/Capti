@echo off
title Game Data Import Tool
color 0A

echo ========================================
echo      Game Data Import Tool
echo ========================================
echo.

REM Create a temporary PowerShell script for file selection dialog
echo Add-Type -AssemblyName System.Windows.Forms > "%temp%\filedlg.ps1"
echo $dialog = New-Object System.Windows.Forms.OpenFileDialog >> "%temp%\filedlg.ps1"
echo $dialog.Filter = "CSV Files (*.csv)|*.csv|All Files (*.*)|*.*" >> "%temp%\filedlg.ps1"
echo $dialog.Title = "Select CSV File" >> "%temp%\filedlg.ps1"
echo $dialog.InitialDirectory = $pwd.Path >> "%temp%\filedlg.ps1"
echo if($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) { >> "%temp%\filedlg.ps1"
echo     Write-Host $dialog.FileName >> "%temp%\filedlg.ps1"
echo } >> "%temp%\filedlg.ps1"

REM Check common PHP paths
set PHP_PATHS=D:\DemandingSoftware\xampp\php\php.exe;C:\php\php.exe;php.exe

REM Try each PHP path
for %%p in (%PHP_PATHS:;= %) do (
    echo Checking PHP path: %%p
    "%%p" --version >nul 2>&1
    if not errorlevel 1 (
        set PHP_CMD="%%p"
        echo [OK] Found PHP at: %%p
        "%%p" --version | findstr "PHP"
        goto :php_found
    )
)

echo [ERROR] PHP not found in common paths
echo.
echo Please enter the full path to php.exe
echo Common locations:
echo - C:\xampp\php\php.exe (XAMPP)
echo - C:\wamp64\bin\php\phpX.X\php.exe (WAMP)
echo - C:\php\php.exe (Standalone PHP)
echo.
set /p PHP_CMD="Enter PHP path (or press Enter to exit): "

if "%PHP_CMD%"=="" (
    echo [ERROR] No PHP path provided
    echo Please install PHP or provide correct path
    pause
    exit /b 1
)

"%PHP_CMD%" --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Invalid PHP path: %PHP_CMD%
    pause
    exit /b 1
)

:php_found
echo.
echo [OK] Using PHP: %PHP_CMD%
echo.

REM Check if database config exists
if not exist "..\web_interface\config\database.php" (
    echo [ERROR] Database config file not found
    echo Please ensure web_interface\config\database.php exists
    echo.
    pause
    exit /b 1
)

:menu
cls
echo ========================================
echo      Game Data Import Tool
echo ========================================
echo.
echo Current directory: %CD%
echo PHP version: 
%PHP_CMD% --version 2>nul | findstr "PHP"
echo.
echo Please select data type to import:
echo.
echo [1] Import Characters (Select CSV file)
echo [2] Import Commodities (Select CSV file)
echo [3] Import Adventure Teams (Select CSV file)
echo [4] Import Adventure Projects (Select CSV file)
echo [5] Import All Data (Using default templates)
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
echo Importing character data...
echo ========================================
echo.
echo Please select the character CSV file...
for /f "delims=" %%a in ('powershell -ExecutionPolicy Bypass -File "%temp%\filedlg.ps1"') do set "CSV_FILE=%%a"
if "%CSV_FILE%"=="" (
    echo [INFO] No file selected
    echo.
    pause
    goto menu
)
echo Selected file: %CSV_FILE%
echo Starting import...
echo.
%PHP_CMD% ..\scripts\import_csv_data.php characters "%CSV_FILE%"
if errorlevel 1 (
    echo.
    echo [ERROR] Import failed, please check error messages above
    echo Common issues:
    echo - CSV file format incorrect
    echo - Database connection failed
    echo - Missing required fields
    echo.
) else (
    echo.
    echo [SUCCESS] Character data imported successfully!
)
echo.
pause
goto menu

:import_commodities
echo.
echo ========================================
echo Importing commodity data...
echo ========================================
echo.
echo Please select the commodities CSV file...
for /f "delims=" %%a in ('powershell -ExecutionPolicy Bypass -File "%temp%\filedlg.ps1"') do set "CSV_FILE=%%a"
if "%CSV_FILE%"=="" (
    echo [INFO] No file selected
    echo.
    pause
    goto menu
)
echo Selected file: %CSV_FILE%
echo Starting import...
echo.
%PHP_CMD% ..\scripts\import_csv_data.php commodities "%CSV_FILE%"
if errorlevel 1 (
    echo.
    echo [ERROR] Import failed, please check error messages above
    echo Common issues:
    echo - CSV file format incorrect
    echo - Database connection failed
    echo - Missing required fields
    echo.
) else (
    echo.
    echo [SUCCESS] Commodity data imported successfully!
)
echo.
pause
goto menu

:import_teams
echo.
echo ========================================
echo Importing adventure teams...
echo ========================================
echo.
echo Please select the teams CSV file...
for /f "delims=" %%a in ('powershell -ExecutionPolicy Bypass -File "%temp%\filedlg.ps1"') do set "CSV_FILE=%%a"
if "%CSV_FILE%"=="" (
    echo [INFO] No file selected
    echo.
    pause
    goto menu
)
echo Selected file: %CSV_FILE%
echo Starting import...
echo.
%PHP_CMD% ..\scripts\import_csv_data.php teams "%CSV_FILE%"
if errorlevel 1 (
    echo.
    echo [ERROR] Import failed, please check error messages above
    echo Common issues:
    echo - CSV file format incorrect
    echo - Database connection failed
    echo - Missing required fields
    echo.
) else (
    echo.
    echo [SUCCESS] Adventure teams imported successfully!
)
echo.
pause
goto menu

:import_projects
echo.
echo ========================================
echo Importing adventure projects...
echo ========================================
echo.
echo Please select the projects CSV file...
for /f "delims=" %%a in ('powershell -ExecutionPolicy Bypass -File "%temp%\filedlg.ps1"') do set "CSV_FILE=%%a"
if "%CSV_FILE%"=="" (
    echo [INFO] No file selected
    echo.
    pause
    goto menu
)
echo Selected file: %CSV_FILE%
echo Starting import...
echo.
%PHP_CMD% ..\scripts\import_csv_data.php projects "%CSV_FILE%"
if errorlevel 1 (
    echo.
    echo [ERROR] Import failed, please check error messages above
    echo Common issues:
    echo - CSV file format incorrect
    echo - Database connection failed
    echo - Missing required fields
    echo.
) else (
    echo.
    echo [SUCCESS] Adventure projects imported successfully!
)
echo.
pause
goto menu

:import_all
echo.
echo ========================================
echo Importing all data using templates...
echo ========================================
echo.
set error_count=0

echo [1/4] Importing character data...
if exist "test_characters.csv" (
    %PHP_CMD% ..\scripts\import_csv_data.php characters test_characters.csv
    if errorlevel 1 set /a error_count+=1
) else (
    echo [SKIP] test_characters.csv not found
)
echo.

echo [2/4] Importing commodity data...
if exist "commodities_template.csv" (
    %PHP_CMD% ..\scripts\import_csv_data.php commodities commodities_template.csv
    if errorlevel 1 set /a error_count+=1
) else (
    echo [SKIP] commodities_template.csv not found
)
echo.

echo [3/4] Importing adventure teams...
if exist "adventure_teams_template.csv" (
    %PHP_CMD% ..\scripts\import_csv_data.php teams adventure_teams_template.csv
    if errorlevel 1 set /a error_count+=1
) else (
    echo [SKIP] adventure_teams_template.csv not found
)
echo.

echo [4/4] Importing adventure projects...
if exist "adventure_projects_template.csv" (
    %PHP_CMD% ..\scripts\import_csv_data.php projects adventure_projects_template.csv
    if errorlevel 1 set /a error_count+=1
) else (
    echo [SKIP] adventure_projects_template.csv not found
)
echo.

echo ========================================
if %error_count%==0 (
    echo [SUCCESS] All data imported successfully!
    color 0A
) else (
    echo [WARNING] Import completed with %error_count% errors
    color 0C
)
echo ========================================
echo.
pause
goto menu

:exit
echo.
echo Thank you for using Game Data Import Tool!
echo Goodbye!
echo.
REM Clean up temporary script
if exist "%temp%\filedlg.ps1" del "%temp%\filedlg.ps1"
pause
exit /b 0 