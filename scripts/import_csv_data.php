<?php
/**
 * CSV Data Import Script for SQLite Database
 * 
 * Usage: php import_csv_data.php <data_type> <csv_file>
 * 
 * Data types:
 * - characters: Import character data
 * - commodities: Import commodity data  
 * - teams: Import adventure teams
 * - projects: Import adventure projects
 */

// Include SQLite database configuration
require_once __DIR__ . '/../web_interface/config/database_sqlite.php';

// Check command line arguments
if ($argc < 3) {
    echo "Usage: php import_csv_data.php <data_type> <csv_file>\n";
    echo "Data types: characters, commodities, teams, projects\n";
    exit(1);
}

$dataType = strtolower($argv[1]);
$csvFile = $argv[2];

// Validate data type
$validTypes = ['characters', 'commodities', 'teams', 'projects'];
if (!in_array($dataType, $validTypes)) {
    echo "Error: Invalid data type '$dataType'. Valid types: " . implode(', ', $validTypes) . "\n";
    exit(1);
}

// Check if CSV file exists
if (!file_exists($csvFile)) {
    echo "Error: CSV file '$csvFile' not found.\n";
    exit(1);
}

try {
    // Get database connection
    $pdo = getDBConnection();
    echo "Connected to SQLite database: " . DB_PATH . "\n";
    
    // Import data based on type
    switch ($dataType) {
        case 'characters':
            importCharacters($pdo, $csvFile);
            break;
        case 'commodities':
            importCommodities($pdo, $csvFile);
            break;
        case 'teams':
            importTeams($pdo, $csvFile);
            break;
        case 'projects':
            importProjects($pdo, $csvFile);
            break;
    }
    
    echo "Import completed successfully!\n";
    
} catch (Exception $e) {
    echo "Error: " . $e->getMessage() . "\n";
    exit(1);
}

/**
 * Map character class to valid database value
 */
function mapCharacterClass($class) {
    $classMapping = [
        'warrior' => 'warrior',
        'trader' => 'scholar', // Map trader to scholar as closest match
        'explorer' => 'explorer',
        'scholar' => 'scholar',
        'mystic' => 'mystic',
        'survivor' => 'survivor',
        'archer' => 'archer'
    ];
    
    $class = strtolower(trim($class));
    return isset($classMapping[$class]) ? $classMapping[$class] : 'survivor';
}

/**
 * Import character data
 */
function importCharacters($pdo, $csvFile) {
    echo "Importing character data from: $csvFile\n";
    
    $data = readCSV($csvFile);
    $count = 0;
    
    foreach ($data as $row) {
        // Map Chinese field names to English equivalents
        $mappedRow = mapCharacterFields($row);
        
        // Validate required fields
        $required = ['character_name', 'character_class', 'rarity'];
        foreach ($required as $field) {
            if (!isset($mappedRow[$field]) || empty($mappedRow[$field])) {
                echo "Warning: Skipping row with missing required field '$field': " . json_encode($row) . "\n";
                continue 2;
            }
        }
        
        // Prepare data
        $characterCode = generateCharacterCode($mappedRow['character_name']);
        $characterName = trim($mappedRow['character_name']);
        $displayName = isset($mappedRow['display_name']) ? trim($mappedRow['display_name']) : $characterName;
        $characterClass = mapCharacterClass($mappedRow['character_class']);
        $rarity = trim($mappedRow['rarity']);
        $hireCost = isset($mappedRow['hire_cost']) ? (float)$mappedRow['hire_cost'] : 1000.0;
        $maintenanceCost = isset($mappedRow['maintenance_cost']) ? (float)$mappedRow['maintenance_cost'] : 100.0;
        $strength = isset($mappedRow['strength']) ? (int)$mappedRow['strength'] : 10;
        $vitality = isset($mappedRow['vitality']) ? (int)$mappedRow['vitality'] : 10;
        $agility = isset($mappedRow['agility']) ? (int)$mappedRow['agility'] : 10;
        $intelligence = isset($mappedRow['intelligence']) ? (int)$mappedRow['intelligence'] : 10;
        $faith = isset($mappedRow['faith']) ? (int)$mappedRow['faith'] : 10;
        $luck = isset($mappedRow['luck']) ? (int)$mappedRow['luck'] : 10;
        $loyalty = isset($mappedRow['loyalty']) ? (int)$mappedRow['loyalty'] : 50;
        $courage = isset($mappedRow['courage']) ? (int)$mappedRow['courage'] : 50;
        $patience = isset($mappedRow['patience']) ? (int)$mappedRow['patience'] : 50;
        $greed = isset($mappedRow['greed']) ? (int)$mappedRow['greed'] : 50;
        $wisdom = isset($mappedRow['wisdom']) ? (int)$mappedRow['wisdom'] : 50;
        $charisma = isset($mappedRow['charisma']) ? (int)$mappedRow['charisma'] : 50;
        $tradeSkill = isset($mappedRow['trade_skill']) ? (int)$mappedRow['trade_skill'] : 10;
        $ventureSkill = isset($mappedRow['venture_skill']) ? (int)$mappedRow['venture_skill'] : 10;
        $negotiationSkill = isset($mappedRow['negotiation_skill']) ? (int)$mappedRow['negotiation_skill'] : 10;
        $analysisSkill = isset($mappedRow['analysis_skill']) ? (int)$mappedRow['analysis_skill'] : 10;
        $leadershipSkill = isset($mappedRow['leadership_skill']) ? (int)$mappedRow['leadership_skill'] : 10;
        $personalityTraits = isset($mappedRow['personality_traits']) ? trim($mappedRow['personality_traits']) : '';
        $isAvailable = isset($mappedRow['available']) && strtolower($mappedRow['available']) === 'true' ? 1 : 1;
        
        // Insert into database
        $sql = "INSERT OR REPLACE INTO players (
            character_code, character_name, display_name, avatar_url, character_class, rarity, 
            hire_cost, maintenance_cost, employer_id, is_available, created_at, hired_at,
            strength, vitality, agility, intelligence, faith, luck, loyalty, courage, patience, 
            greed, wisdom, charisma, trade_skill, venture_skill, negotiation_skill, analysis_skill, 
            leadership_skill, total_experience, current_level, skill_points, personality_traits
        ) VALUES (
            ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, datetime('now'), ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?
        )";
        
        $stmt = $pdo->prepare($sql);
        $stmt->execute([
            $characterCode, $characterName, $displayName, null, $characterClass, $rarity,
            $hireCost, $maintenanceCost, null, $isAvailable, null,
            $strength, $vitality, $agility, $intelligence, $faith, $luck, $loyalty, $courage, $patience,
            $greed, $wisdom, $charisma, $tradeSkill, $ventureSkill, $negotiationSkill, $analysisSkill,
            $leadershipSkill, 0, 1, 0, $personalityTraits
        ]);
        
        $count++;
    }
    
    echo "Imported $count characters successfully.\n";
}

/**
 * Generate a unique character code from character name
 */
function generateCharacterCode($characterName) {
    // Remove special characters and spaces, convert to uppercase
    $code = preg_replace('/[^a-zA-Z0-9]/', '', $characterName);
    $code = strtoupper($code);
    
    // If code is empty, use a default
    if (empty($code)) {
        $code = 'CHAR_' . uniqid();
    }
    
    // Ensure it's not too long
    if (strlen($code) > 20) {
        $code = substr($code, 0, 20);
    }
    
    return $code;
}

/**
 * Map Chinese character field names to English
 */
function mapCharacterFields($row) {
    $mapped = [];
    
    // Map Chinese field names to English
    $fieldMapping = [
        '角色名称' => 'character_name',
        '显示名称' => 'display_name', 
        '职业' => 'character_class',
        '稀有度' => 'rarity',
        '雇佣费用' => 'hire_cost',
        '维护费用' => 'maintenance_cost',
        '力量' => 'strength',
        '体力' => 'vitality',
        '敏捷' => 'agility',
        '智力' => 'intelligence',
        '信仰' => 'faith',
        '幸运' => 'luck',
        '忠诚' => 'loyalty',
        '勇气' => 'courage',
        '耐心' => 'patience',
        '贪婪' => 'greed',
        '智慧' => 'wisdom',
        '魅力' => 'charisma',
        '交易技能' => 'trade_skill',
        '冒险技能' => 'venture_skill',
        '谈判技能' => 'negotiation_skill',
        '分析技能' => 'analysis_skill',
        '领导技能' => 'leadership_skill',
        '性格特质' => 'personality_traits',
        '可用状态' => 'available'
    ];
    
    foreach ($row as $chineseKey => $value) {
        if (isset($fieldMapping[$chineseKey])) {
            $mapped[$fieldMapping[$chineseKey]] = $value;
        } else {
            $mapped[$chineseKey] = $value; // Keep original if no mapping found
        }
    }
    
    return $mapped;
}

/**
 * Import commodity data
 */
function importCommodities($pdo, $csvFile) {
    echo "Importing commodity data from: $csvFile\n";
    
    $data = readCSV($csvFile);
    $count = 0;
    
    foreach ($data as $row) {
        // Map Chinese field names to English equivalents
        $mappedRow = mapCommodityFields($row);
        
        // Validate required fields
        $required = ['name', 'category', 'base_price', 'rarity'];
        foreach ($required as $field) {
            if (!isset($mappedRow[$field]) || empty($mappedRow[$field])) {
                echo "Warning: Skipping row with missing required field '$field': " . json_encode($row) . "\n";
                continue 2;
            }
        }
        
        // Prepare data
        $name = trim($mappedRow['name']);
        $category = trim($mappedRow['category']);
        $base_price = (float)$mappedRow['base_price'];
        $rarity = trim($mappedRow['rarity']);
        $description = isset($mappedRow['description']) ? trim($mappedRow['description']) : '';
        $weight = isset($mappedRow['weight']) ? (float)$mappedRow['weight'] : 1.0;
        $volume = isset($mappedRow['volume']) ? (float)$mappedRow['volume'] : 1.0;
        
        // Insert into database
        $sql = "INSERT OR REPLACE INTO items (name, category, base_price, rarity, description, weight, volume, created_at) 
                VALUES (?, ?, ?, ?, ?, ?, ?, datetime('now'))";
        
        $stmt = $pdo->prepare($sql);
        $stmt->execute([$name, $category, $base_price, $rarity, $description, $weight, $volume]);
        
        $count++;
    }
    
    echo "Imported $count commodities successfully.\n";
}

/**
 * Map Chinese commodity field names to English
 */
function mapCommodityFields($row) {
    $mapped = [];
    
    // Map Chinese field names to English
    $fieldMapping = [
        '商品名称' => 'name',
        '类别' => 'category',
        '基础价格' => 'base_price',
        '稀有度' => 'rarity',
        '描述' => 'description',
        '重量' => 'weight',
        '体积' => 'volume'
    ];
    
    foreach ($row as $chineseKey => $value) {
        if (isset($fieldMapping[$chineseKey])) {
            $mapped[$fieldMapping[$chineseKey]] = $value;
        } else {
            $mapped[$chineseKey] = $value; // Keep original if no mapping found
        }
    }
    
    return $mapped;
}

/**
 * Import adventure teams data
 */
function importTeams($pdo, $csvFile) {
    echo "Importing adventure teams from: $csvFile\n";
    
    $data = readCSV($csvFile);
    $count = 0;
    
    foreach ($data as $row) {
        // Map Chinese field names to English equivalents
        $mappedRow = mapTeamFields($row);
        
        // Validate required fields
        $required = ['name', 'leader_id', 'specialization', 'reputation'];
        foreach ($required as $field) {
            if (!isset($mappedRow[$field]) || empty($mappedRow[$field])) {
                echo "Warning: Skipping row with missing required field '$field': " . json_encode($row) . "\n";
                continue 2;
            }
        }
        
        // Prepare data
        $name = trim($mappedRow['name']);
        $leader_id = (int)$mappedRow['leader_id'];
        $specialization = trim($mappedRow['specialization']);
        $reputation = (int)$mappedRow['reputation'];
        $description = isset($mappedRow['description']) ? trim($mappedRow['description']) : '';
        $max_members = isset($mappedRow['max_members']) ? (int)$mappedRow['max_members'] : 5;
        
        // Insert into database
        $sql = "INSERT OR REPLACE INTO adventure_teams (name, leader_id, specialization, reputation, description, max_members, created_at) 
                VALUES (?, ?, ?, ?, ?, ?, datetime('now'))";
        
        $stmt = $pdo->prepare($sql);
        $stmt->execute([$name, $leader_id, $specialization, $reputation, $description, $max_members]);
        
        $count++;
    }
    
    echo "Imported $count adventure teams successfully.\n";
}

/**
 * Map Chinese team field names to English
 */
function mapTeamFields($row) {
    $mapped = [];
    
    // Map Chinese field names to English
    $fieldMapping = [
        '团队名称' => 'name',
        '队长ID' => 'leader_id',
        '专长' => 'specialization',
        '声望' => 'reputation',
        '描述' => 'description',
        '最大成员数' => 'max_members'
    ];
    
    foreach ($row as $chineseKey => $value) {
        if (isset($fieldMapping[$chineseKey])) {
            $mapped[$fieldMapping[$chineseKey]] = $value;
        } else {
            $mapped[$chineseKey] = $value; // Keep original if no mapping found
        }
    }
    
    return $mapped;
}

/**
 * Import adventure projects data
 */
function importProjects($pdo, $csvFile) {
    echo "Importing adventure projects from: $csvFile\n";
    
    $data = readCSV($csvFile);
    $count = 0;
    
    foreach ($data as $row) {
        // Map Chinese field names to English equivalents
        $mappedRow = mapProjectFields($row);
        
        // Validate required fields
        $required = ['name', 'difficulty', 'reward_type', 'base_reward'];
        foreach ($required as $field) {
            if (!isset($mappedRow[$field]) || empty($mappedRow[$field])) {
                echo "Warning: Skipping row with missing required field '$field': " . json_encode($row) . "\n";
                continue 2;
            }
        }
        
        // Prepare data
        $name = trim($mappedRow['name']);
        $difficulty = trim($mappedRow['difficulty']);
        $reward_type = trim($mappedRow['reward_type']);
        $base_reward = (int)$mappedRow['base_reward'];
        $description = isset($mappedRow['description']) ? trim($mappedRow['description']) : '';
        $duration_hours = isset($mappedRow['duration_hours']) ? (int)$mappedRow['duration_hours'] : 24;
        $required_level = isset($mappedRow['required_level']) ? (int)$mappedRow['required_level'] : 1;
        
        // Insert into database
        $sql = "INSERT OR REPLACE INTO adventure_projects (name, difficulty, reward_type, base_reward, description, duration_hours, required_level, created_at) 
                VALUES (?, ?, ?, ?, ?, ?, ?, datetime('now'))";
        
        $stmt = $pdo->prepare($sql);
        $stmt->execute([$name, $difficulty, $reward_type, $base_reward, $description, $duration_hours, $required_level]);
        
        $count++;
    }
    
    echo "Imported $count adventure projects successfully.\n";
}

/**
 * Map Chinese project field names to English
 */
function mapProjectFields($row) {
    $mapped = [];
    
    // Map Chinese field names to English
    $fieldMapping = [
        '项目名称' => 'name',
        '难度' => 'difficulty',
        '奖励类型' => 'reward_type',
        '基础奖励' => 'base_reward',
        '描述' => 'description',
        '持续时间' => 'duration_hours',
        '要求等级' => 'required_level'
    ];
    
    foreach ($row as $chineseKey => $value) {
        if (isset($fieldMapping[$chineseKey])) {
            $mapped[$fieldMapping[$chineseKey]] = $value;
        } else {
            $mapped[$chineseKey] = $value; // Keep original if no mapping found
        }
    }
    
    return $mapped;
}

/**
 * Read CSV file and return array of data
 */
function readCSV($filename) {
    $data = [];
    
    if (($handle = fopen($filename, "r")) !== FALSE) {
        // Read header row with escape parameter to fix PHP deprecation warning
        $headers = fgetcsv($handle, 0, ',', '"', '\\');
        if (!$headers) {
            throw new Exception("Could not read CSV headers from $filename");
        }
        
        // Read data rows with escape parameter
        while (($row = fgetcsv($handle, 0, ',', '"', '\\')) !== FALSE) {
            if (count($row) == count($headers)) {
                $data[] = array_combine($headers, $row);
            }
        }
        
        fclose($handle);
    } else {
        throw new Exception("Could not open CSV file: $filename");
    }
    
    return $data;
}
?> 