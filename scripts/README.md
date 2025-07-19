# Scripts 文件夹说明

本文件夹包含游戏交易数据库的各种管理脚本。

## 当前有效脚本

### 1. init_database.sql ⭐
**功能**: 完整的数据库初始化脚本
- 创建数据库和用户
- 加载所有表结构
- 插入初始数据（角色、商品、队伍等）
- **使用**: `source E:/resource/github/Capti/scripts/init_database.sql`

### 2. add_new_characters.sql
**功能**: 添加新的可雇佣角色
- 批量添加10个新角色
- 自动设置情绪状态和初始资产
- 基于稀有度智能分配属性
- **使用**: `source E:/resource/github/Capti/scripts/add_new_characters.sql`

### 3. quick_queries.sql
**功能**: 快速查询示例集合
- 基础查询（角色、商品、队伍）
- 复合查询（综合评分、适配分析）
- 统计查询（队伍配置、资产分布）
- **使用**: 复制需要的查询语句执行

### 4. reset_database.sql ⚠️
**功能**: 重置数据库到空状态
- **警告**: 会删除所有数据
- 重新创建数据库和用户
- 需要配合 init_database.sql 使用
- **使用**: `source E:/resource/github/Capti/scripts/reset_database.sql`

### 5. backup_database.sql
**功能**: 数据库备份和状态查看
- 显示当前数据库状态
- 数据量统计
- 关键数据备份信息
- **使用**: `source E:/resource/github/Capti/scripts/backup_database.sql`

### 6. create_user.sql
**功能**: 创建特定用户
- 创建 'Tree' 用户（无密码）
- 授予完整权限
- **使用**: `source E:/resource/github/Capti/scripts/create_user.sql`

### 7. powershell_reset_mysql.ps1
**功能**: PowerShell MySQL密码重置工具
- Windows 环境下重置 MySQL root 密码
- 自动化服务重启流程
- **使用**: 在 PowerShell 中运行

## 已归档脚本 (oldfiles/)

### workbench_setup.sql.old
- 旧版本的数据库设置脚本
- 已被 init_database.sql 替代

### init_db.bat
- 旧版本的批处理初始化脚本
- 路径和结构已过时

## 推荐使用流程

### 首次设置
```sql
-- 1. 重置数据库（可选）
source E:/resource/github/Capti/scripts/reset_database.sql

-- 2. 初始化完整数据库
source E:/resource/github/Capti/scripts/init_database.sql

-- 3. 添加更多角色（可选）
source E:/resource/github/Capti/scripts/add_new_characters.sql
```

### 日常使用
```sql
-- 查看数据状态
source E:/resource/github/Capti/scripts/backup_database.sql

-- 执行各种查询
-- 从 quick_queries.sql 中复制需要的查询
```

### 开发测试
```sql
-- 快速重置并重新初始化
source E:/resource/github/Capti/scripts/reset_database.sql
source E:/resource/github/Capti/scripts/init_database.sql
```

## 注意事项

1. **路径设置**: 脚本中的文件路径基于 `E:/resource/github/Capti/`
2. **权限要求**: 某些脚本需要 MySQL root 权限
3. **数据安全**: reset_database.sql 会删除所有数据，使用前请备份
4. **编码格式**: 所有脚本使用 UTF-8 编码，支持中文
5. **依赖关系**: init_database.sql 是核心脚本，其他脚本基于其结构

## 维护建议

- 定期备份重要数据
- 测试新脚本前先在开发环境验证
- 保持脚本与最新的 schema 定义同步
- 记录重要的数据变更操作 