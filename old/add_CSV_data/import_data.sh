#!/bin/bash

# Game Data Import Tool for Unix/Linux/macOS
# SQLite Version

echo "========================================"
echo "      Game Data Import Tool"
echo "========================================"
echo

# Check if PHP is available
if ! command -v php &> /dev/null; then
    echo "[ERROR] PHP not found"
    echo "Please install PHP and ensure it's in your PATH"
    exit 1
fi

echo "[OK] PHP found: $(php --version | head -n1)"
echo

# Check if database config exists
if [ ! -f "../web_interface/config/database_sqlite.php" ]; then
    echo "[ERROR] SQLite database config file not found"
    echo "Please ensure web_interface/config/database_sqlite.php exists"
    exit 1
fi

echo "[OK] SQLite database config found"
echo

# Function to show menu
show_menu() {
    clear
    echo "========================================"
    echo "      Game Data Import Tool"
    echo "========================================"
    echo
    echo "Current directory: $(pwd)"
    echo "PHP version: $(php --version | head -n1)"
    echo
    echo "Please select data type to import:"
    echo
    echo "[1] Import Characters (Select CSV file)"
    echo "[2] Import Commodities (Select CSV file)"
    echo "[3] Import Adventure Teams (Select CSV file)"
    echo "[4] Import Adventure Projects (Select CSV file)"
    echo "[5] Import All Data (Using default templates)"
    echo "[0] Exit"
    echo
}

# Function to import data
import_data() {
    local data_type=$1
    local csv_file=$2
    
    echo
    echo "========================================"
    echo "Importing $data_type data..."
    echo "========================================"
    echo
    
    if [ ! -f "$csv_file" ]; then
        echo "[ERROR] CSV file not found: $csv_file"
        return 1
    fi
    
    echo "Selected file: $csv_file"
    echo "Starting import..."
    echo
    
    php ../scripts/import_csv_data.php "$data_type" "$csv_file"
    
    if [ $? -eq 0 ]; then
        echo
        echo "[SUCCESS] $data_type data imported successfully!"
    else
        echo
        echo "[ERROR] Import failed, please check error messages above"
        echo "Common issues:"
        echo "- CSV file format incorrect"
        echo "- Database connection failed"
        echo "- Missing required fields"
    fi
    
    echo
    read -p "Press Enter to continue..."
}

# Function to import all data
import_all() {
    echo
    echo "========================================"
    echo "Importing all data using templates..."
    echo "========================================"
    echo
    
    local error_count=0
    
    echo "[1/4] Importing character data..."
    if [ -f "characters_template.csv" ]; then
        php ../scripts/import_csv_data.php characters characters_template.csv
        if [ $? -ne 0 ]; then
            ((error_count++))
        fi
    else
        echo "[SKIP] characters_template.csv not found"
    fi
    echo
    
    echo "[2/4] Importing commodity data..."
    if [ -f "commodities_template.csv" ]; then
        php ../scripts/import_csv_data.php commodities commodities_template.csv
        if [ $? -ne 0 ]; then
            ((error_count++))
        fi
    else
        echo "[SKIP] commodities_template.csv not found"
    fi
    echo
    
    echo "[3/4] Importing adventure teams..."
    if [ -f "adventure_teams_template.csv" ]; then
        php ../scripts/import_csv_data.php teams adventure_teams_template.csv
        if [ $? -ne 0 ]; then
            ((error_count++))
        fi
    else
        echo "[SKIP] adventure_teams_template.csv not found"
    fi
    echo
    
    echo "[4/4] Importing adventure projects..."
    if [ -f "adventure_projects_template.csv" ]; then
        php ../scripts/import_csv_data.php projects adventure_projects_template.csv
        if [ $? -ne 0 ]; then
            ((error_count++))
        fi
    else
        echo "[SKIP] adventure_projects_template.csv not found"
    fi
    echo
    
    echo "========================================"
    if [ $error_count -eq 0 ]; then
        echo "[SUCCESS] All data imported successfully!"
    else
        echo "[WARNING] Import completed with $error_count errors"
    fi
    echo "========================================"
    echo
    read -p "Press Enter to continue..."
}

# Function to select file
select_file() {
    local file_type=$1
    echo "Please select the $file_type CSV file..."
    
    # Try to use zenity if available (Linux)
    if command -v zenity &> /dev/null; then
        local file=$(zenity --file-selection --title="Select $file_type CSV file" --file-filter="CSV files (*.csv) | *.csv")
        if [ -n "$file" ]; then
            echo "$file"
            return 0
        fi
    fi
    
    # Fallback to command line input
    read -p "Enter path to $file_type CSV file: " file
    if [ -n "$file" ]; then
        echo "$file"
        return 0
    fi
    
    return 1
}

# Main menu loop
while true; do
    show_menu
    read -p "Enter your choice (0-5): " choice
    
    case $choice in
        1)
            csv_file=$(select_file "character")
            if [ $? -eq 0 ]; then
                import_data "characters" "$csv_file"
            else
                echo "[INFO] No file selected"
                read -p "Press Enter to continue..."
            fi
            ;;
        2)
            csv_file=$(select_file "commodity")
            if [ $? -eq 0 ]; then
                import_data "commodities" "$csv_file"
            else
                echo "[INFO] No file selected"
                read -p "Press Enter to continue..."
            fi
            ;;
        3)
            csv_file=$(select_file "team")
            if [ $? -eq 0 ]; then
                import_data "teams" "$csv_file"
            else
                echo "[INFO] No file selected"
                read -p "Press Enter to continue..."
            fi
            ;;
        4)
            csv_file=$(select_file "project")
            if [ $? -eq 0 ]; then
                import_data "projects" "$csv_file"
            else
                echo "[INFO] No file selected"
                read -p "Press Enter to continue..."
            fi
            ;;
        5)
            import_all
            ;;
        0)
            echo
            echo "Thank you for using Game Data Import Tool!"
            echo "Goodbye!"
            echo
            exit 0
            ;;
        *)
            echo "[WARNING] Invalid choice, please try again"
            echo
            read -p "Press Enter to continue..."
            ;;
    esac
done 