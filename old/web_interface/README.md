# 游戏角色管理系统 - Web界面

## 🎮 系统简介

这是一个基于Web的游戏角色管理系统，提供用户友好的界面来管理游戏数据库中的角色信息。无需SQL知识，即可轻松添加、查看和管理角色。

## 📋 功能特点

### ✅ 主要功能
- **角色管理**: 添加、查看、编辑、删除角色
- **可视化界面**: 美观的现代化Web界面
- **搜索筛选**: 支持按名称、稀有度、职业筛选
- **实时统计**: 角色数量、等级、价值统计
- **响应式设计**: 适配各种设备屏幕

### 🎯 角色属性
- **基础信息**: 名称、职业、稀有度、费用
- **基础属性**: 力量、体力、敏捷、智力、信仰、幸运 (1-20)
- **精神属性**: 忠诚、勇气、耐心、贪婪、智慧、魅力 (1-100)
- **专业技能**: 交易、冒险、谈判、分析、领导 (1-100)
- **个性特质**: 16种不同的性格特质

## 🛠️ 安装要求

### 服务器要求
- **PHP 7.4+** 
- **MySQL 5.7+** 或 **MariaDB 10.2+**
- **Web服务器** (Apache/Nginx)

### 推荐环境
- **XAMPP** (适合Windows开发)
- **WAMP** (适合Windows)
- **LAMP** (适合Linux)
- **MAMP** (适合Mac)

## 🚀 安装步骤

### 1. 准备数据库
```sql
-- 首先运行 scripts/workbench_setup.sql 创建数据库
-- 或者运行 scripts/add_new_characters.sql 添加更多角色
```

### 2. 配置数据库连接
编辑 `config/database.php` 文件：
```php
define('DB_HOST', 'localhost');
define('DB_PORT', '3306');
define('DB_NAME', 'game_trade');
define('DB_USER', 'root');
define('DB_PASS', '您的MySQL密码');
```

### 3. 部署到Web服务器
将 `web_interface` 文件夹复制到Web服务器目录：
- **XAMPP**: `htdocs/game_manager/`
- **WAMP**: `www/game_manager/`
- **Linux**: `/var/www/html/game_manager/`

### 4. 设置权限 (Linux/Mac)
```bash
chmod -R 755 web_interface/
chmod -R 777 web_interface/uploads/ (如果有上传功能)
```

### 5. 访问系统
在浏览器中打开：
```
http://localhost/game_manager/
```

## 📁 文件结构

```
web_interface/
├── index.html                 # 主页
├── add_character.html         # 添加角色表单
├── view_characters.php        # 查看角色列表
├── config/
│   └── database.php          # 数据库配置
├── api/
│   ├── add_character.php     # 添加角色API
│   ├── stats.php             # 统计信息API
│   └── delete_character.php  # 删除角色API
└── README.md                 # 使用说明
```

## 🎯 使用指南

### 1. 主页 (index.html)
- 显示系统概览和统计信息
- 快速导航到各个功能模块

### 2. 添加角色 (add_character.html)
- 填写角色基本信息
- 调整属性滑块
- 选择个性特质
- 点击"创建角色"提交

### 3. 查看角色 (view_characters.php)
- 表格形式显示所有角色
- 支持搜索和筛选
- 可视化技能条显示
- 点击列标题排序

### 4. 管理角色 (manage_characters.php)
- 编辑角色信息
- 删除角色
- 批量操作

## 🔧 技术细节

### 前端技术
- **HTML5**: 页面结构
- **CSS3**: 样式和动画
- **JavaScript**: 交互功能
- **Fetch API**: 与后端通信

### 后端技术
- **PHP**: 服务器端逻辑
- **PDO**: 数据库操作
- **MySQL**: 数据存储
- **JSON**: 数据交换格式

### 安全特性
- **SQL注入防护**: 使用预处理语句
- **XSS防护**: HTML实体转义
- **CSRF保护**: 表单令牌验证
- **输入验证**: 前后端双重验证

## 🐛 故障排除

### 常见问题

#### 1. 数据库连接失败
```
错误: 数据库连接失败
解决: 检查 config/database.php 中的连接信息
```

#### 2. 权限错误
```
错误: 403 Forbidden
解决: 检查文件权限，确保Web服务器有读取权限
```

#### 3. PHP错误
```
错误: Parse error 或 Fatal error
解决: 检查PHP版本，确保支持所需语法
```

#### 4. 表不存在
```
错误: Table 'game_trade.players' doesn't exist
解决: 运行 scripts/workbench_setup.sql 创建数据库表
```

### 调试技巧
1. **检查PHP错误日志**
2. **使用浏览器开发者工具**
3. **查看数据库连接状态**
4. **验证文件权限**

## 🔄 数据备份

### 备份数据库
```bash
mysqldump -u root -p game_trade > backup_$(date +%Y%m%d).sql
```

### 恢复数据库
```bash
mysql -u root -p game_trade < backup_20231201.sql
```

## 📈 性能优化

### 数据库优化
- 添加适当索引
- 定期清理无用数据
- 优化查询语句

### 前端优化
- 压缩CSS/JS文件
- 启用浏览器缓存
- 优化图片大小

## 🎨 自定义配置

### 修改界面主题
编辑CSS文件中的颜色变量：
```css
:root {
    --primary-color: #3498db;
    --secondary-color: #2c3e50;
    --success-color: #27ae60;
    --danger-color: #e74c3c;
}
```

### 添加新的角色属性
1. 修改数据库表结构
2. 更新PHP API
3. 调整HTML表单
4. 更新CSS样式

## 📞 技术支持

如果遇到问题，请检查：
1. **PHP版本兼容性**
2. **MySQL服务状态**
3. **Web服务器配置**
4. **文件权限设置**
5. **数据库连接信息**

## 📄 许可证

本项目基于MIT许可证开源。

## 🙏 致谢

感谢所有为此项目贡献代码和建议的开发者！ 