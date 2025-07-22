# Capti - 游戏交易与冒险系统

一个基于 MySQL 的游戏交易和冒险管理系统，包含角色管理、商品交易、团队冒险等功能。
具体功能详见 PROJECT_SUMMARY.md

## 系统要求

- MySQL 8.0 或更高版本
- PHP 7.4 或更高版本（用于 Web 界面）
- Web 服务器（Apache/Nginx）或 PHP 内置服务器

## 目录结构

```
Capti/
├── backups/                     # 数据库备份文件
│   └── game_trade_backup_*.sql  # 时间戳命名的备份文件
├── config/                      # 配置文件目录
├── database/                    # 数据库核心文件
│   ├── examples/                # 示例和测试
│   ├── queries/                 # SQL查询模板
│   │   ├── trade_queries.sql    # 交易相关查询
│   │   └── venture_queries.sql  # 冒险相关查询
│   └── schema/                  # 核心表结构
│       ├── 01_players.sql       # 玩家/角色系统
│       ├── 02_trade_module.sql  # 交易系统
│       ├── 03_venture_module.sql # 冒险系统
│       └── 04_interaction_system.sql # 交互系统
├── scripts/                     # 管理脚本
│   ├── backup_database.sql      # 数据库备份脚本
│   ├── create_user.sql          # 用户创建脚本
│   ├── reset_database.sql       # 数据库重置脚本
│   └── README.md                # 脚本使用说明
├── web_interface/               # Web界面
│   ├── api/                     # API接口
│   ├── config/                  # Web配置
│   ├── add_character.html       # 添加角色页面
│   ├── index.html               # 主页
│   ├── README.md                # Web界面说明
│   ├── update_config.php        # 配置更新
│   └── view_characters.php      # 角色列表页面
├── add_CSV_data/                # CSV数据导入相关
├── init_database.sql            # 数据库初始化脚本
├── PROJECT_SUMMARY.md           # 项目功能详细说明
└── README.md                    # 项目说明文档
```

## 安装步骤

### 1. 安装必要软件

#### MySQL 安装

1. 下载并安装 MySQL 8.0
   - Windows: 从 [MySQL 官网](https://dev.mysql.com/downloads/mysql/) 下载安装包
   - 安装时记住 root 密码
   - 确保 MySQL 服务已启动

#### PHP 安装

1. 下载并安装 PHP 7.4+
   - Windows: 可以使用 [XAMPP](https://www.apachefriends.org/) 或独立 PHP
   - 确保安装了以下 PHP 扩展：
     - mysqli
     - json
     - pdo_mysql

### 2. 数据库初始化

1. 打开命令行，进入项目目录：

```bash
cd path/to/Capti
```

2. 登录 MySQL（替换 your_password 为你的 root 密码）：

```bash
mysql -u root -p
```

3. 执行初始化脚本：

```sql
source init_database.sql
```

这将：

- 创建数据库和用户
- 导入表结构
- 添加示例数据

### 3. Web 界面设置

1. 配置数据库连接

   - 复制 `web_interface/config/database.php.example` 为 `database.php`
   - 编辑 `database.php`，设置正确的数据库连接信息：

   ```php
   $db_config = [
       'host' => 'localhost',
       'user' => 'game_user',
       'password' => 'capti_game',
       'database' => 'game_trade'
   ];
   ```

2. 启动 Web 服务器

   - 使用 PHP 内置服务器（开发环境）：

   ```bash
   cd web_interface
   php -S localhost:8000
   ```

   - 或配置 Apache/Nginx（生产环境）

3. 访问 Web 界面
   - 打开浏览器访问：`http://localhost:8000`

## 数据库备份

1. 创建备份：

```sql
source scripts/backup_database.sql
```

备份文件将保存在 `backups/` 目录，文件名包含时间戳。

2. 恢复备份：

```sql
mysql -u root -p game_trade < backups/[备份文件名].sql
```

## 主要功能

- 角色管理

  - 添加/编辑角色
  - 查看角色状态
  - 管理角色属性和技能

- 交易系统

  - 商品管理
  - 交易订单
  - 市场分析

- 冒险系统
  - 团队组建
  - 冒险项目管理
  - 投资管理

## 用户和权限

- `game_user`: 完整权限（密码：capti_game）
- `game_readonly`: 只读权限（密码：capti_readonly）

## 开发说明

- 数据库使用 UTF8MB4 编码
- 所有金额使用 DECIMAL 类型
- 使用软删除设计（待实现）
- 支持多语言（待实现）

## 注意事项

1. 首次使用请修改默认密码
2. 定期备份数据库
3. 生产环境部署时注意安全配置

## 常见问题

1. MySQL 连接错误

   - 检查 MySQL 服务是否运行
   - 验证用户名和密码
   - 确认数据库权限

2. Web 界面无法访问
   - 检查 PHP 服务是否运行
   - 确认端口是否被占用
   - 查看 PHP 错误日志
   - \*我用的 xampp，很省心，可以尝试安装

## 许可证

[许可证类型]

## 联系方式

[联系信息]

SQLite version:

cd web_interface
php -S localhost:8000
