<?php
// 更新数据库配置文件
echo "<h2>🔧 更新数据库配置文件</h2>";

if ($_POST) {
    $host = $_POST['host'] ?? 'localhost';
    $port = $_POST['port'] ?? '3306';
    $user = $_POST['user'] ?? 'root';
    $pass = $_POST['pass'] ?? '';
    
    echo "<p>正在更新配置文件...</p>";
    echo "<p><strong>新的连接参数：</strong></p>";
    echo "<ul>";
    echo "<li>主机: $host</li>";
    echo "<li>端口: $port</li>";
    echo "<li>用户: $user</li>";
    echo "<li>密码: " . ($pass ? str_repeat('*', strlen($pass)) : '空密码') . "</li>";
    echo "</ul>";
    
    // 生成新的配置文件内容
    $configContent = '<?php
// 数据库配置
define(\'DB_HOST\', \'' . $host . '\');
define(\'DB_PORT\', \'' . $port . '\');
define(\'DB_NAME\', \'game_trade\');
define(\'DB_USER\', \'' . $user . '\');
define(\'DB_PASS\', \'' . $pass . '\');' . ($pass ? '' : ' // 空密码') . '

// 创建数据库连接
function getDBConnection() {
    try {
        $dsn = "mysql:host=" . DB_HOST . ";port=" . DB_PORT . ";dbname=" . DB_NAME . ";charset=utf8mb4";
        $options = [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::ATTR_EMULATE_PREPARES => false,
        ];
        
        return new PDO($dsn, DB_USER, DB_PASS, $options);
    } catch (PDOException $e) {
        die("数据库连接失败: " . $e->getMessage());
    }
}

// 测试数据库连接
function testConnection() {
    try {
        $pdo = getDBConnection();
        return true;
    } catch (Exception $e) {
        return false;
    }
}
?>';
    
    // 写入配置文件
    $configFile = 'config/database.php';
    if (file_put_contents($configFile, $configContent)) {
        echo "<p style='color: green; font-weight: bold;'>✓ 配置文件更新成功！</p>";
        
        // 测试新配置
        echo "<h3>📋 测试新配置</h3>";
        try {
            $dsn = "mysql:host=$host;port=$port;charset=utf8mb4";
            $pdo = new PDO($dsn, $user, $pass);
            $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
            
            echo "<p style='color: green;'>✓ 基本连接测试成功！</p>";
            
            // 检查数据库是否存在
            $stmt = $pdo->prepare("SHOW DATABASES LIKE ?");
            $stmt->execute(['game_trade']);
            
            if ($stmt->rowCount() > 0) {
                echo "<p style='color: green;'>✓ 数据库 'game_trade' 存在！</p>";
                
                // 连接到游戏数据库
                $dsn = "mysql:host=$host;port=$port;dbname=game_trade;charset=utf8mb4";
                $pdo = new PDO($dsn, $user, $pass);
                
                // 检查表结构
                $stmt = $pdo->query("SHOW TABLES");
                $tables = $stmt->fetchAll(PDO::FETCH_COLUMN);
                
                echo "<p><strong>数据库中的表：</strong></p>";
                echo "<ul>";
                foreach ($tables as $table) {
                    $countStmt = $pdo->query("SELECT COUNT(*) FROM $table");
                    $count = $countStmt->fetchColumn();
                    echo "<li>📋 $table ($count 条记录)</li>";
                }
                echo "</ul>";
                
                echo "<h3>🎉 配置完成！</h3>";
                echo "<p>数据库连接已修复。现在你可以：</p>";
                echo "<ul>";
                echo "<li><a href='view_characters.php' style='background: #3498db; color: white; padding: 10px 20px; text-decoration: none; border-radius: 5px; margin: 5px;'>查看角色列表</a></li>";
                echo "<li><a href='add_character.html' style='background: #27ae60; color: white; padding: 10px 20px; text-decoration: none; border-radius: 5px; margin: 5px;'>添加新角色</a></li>";
                echo "<li><a href='index.html' style='background: #9b59b6; color: white; padding: 10px 20px; text-decoration: none; border-radius: 5px; margin: 5px;'>返回主页</a></li>";
                echo "</ul>";
                
            } else {
                echo "<p style='color: orange;'>⚠ 数据库 'game_trade' 不存在</p>";
                echo "<p>需要创建游戏数据库吗？</p>";
                echo "<a href='fix_database.php' style='background: #e74c3c; color: white; padding: 10px 20px; text-decoration: none; border-radius: 5px;'>创建游戏数据库</a>";
            }
            
        } catch (PDOException $e) {
            echo "<p style='color: red;'>✗ 测试连接失败: " . $e->getMessage() . "</p>";
        }
        
    } else {
        echo "<p style='color: red;'>✗ 无法写入配置文件</p>";
        echo "<p>请检查文件权限，或者手动创建配置文件。</p>";
    }
    
} else {
    echo "<p style='color: red;'>✗ 没有收到配置参数</p>";
    echo "<p><a href='mysql_diagnosis.php'>返回诊断页面</a></p>";
}

// 显示当前配置文件内容
echo "<hr>";
echo "<h3>📋 当前配置文件内容</h3>";
$configFile = 'config/database.php';
if (file_exists($configFile)) {
    echo "<pre style='background: #f8f9fa; padding: 15px; border-radius: 5px; overflow-x: auto;'>";
    echo htmlspecialchars(file_get_contents($configFile));
    echo "</pre>";
} else {
    echo "<p style='color: red;'>配置文件不存在</p>";
}
?> 