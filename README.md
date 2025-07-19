# 🎮 GameTrade MySQL Project

一个基于MySQL的游戏数据库项目，支持交易和冒险投资两大核心玩法。

## 🎯 游戏概念

### A模块：Trade（主玩法1）
- **核心玩法**：虚拟币交易系统
- **操作**：买入/卖出，自动止盈止损
- **循环**：情报获取 → 市场判断 → 买入卖出 → 等待波动 → 收益结算

### B模块：Venture（主玩法2）
- **核心玩法**：投资冒险队伍远征
- **操作**：观察项目 → 风险评估 → 投资决策 → 等待结果 → 收益结算
- **特色**：高风险高收益，后期可影响冒险队伍决策

### 模块联动机制
- 冒险成功 → 资源供应增加 → 价格下跌
- 商品价格暴涨 → 吸引更多相关冒险队伍
- 稀有战利品超预期 → 投资热度提升
- 资源过度开采 → 生态破坏 → 市场转向

## 📁 项目结构

```
GameTrade_MySQL_Project/
├── .vscode/              # VS Code 配置
├── database/
│   ├── schema/           # 数据库表结构
│   ├── data/             # 初始数据和测试数据
│   ├── migrations/       # 数据库迁移脚本
│   ├── queries/          # 常用查询脚本
│   └── procedures/       # 存储过程和函数
├── scripts/              # 工具脚本
├── docs/                 # 文档
├── config/               # 配置文件
└── README.md
```

## 🗄️ 数据库设计

### 核心表结构

#### 玩家系统
- `players` - 玩家基本信息
- `player_assets` - 玩家资产
- `player_levels` - 玩家等级和解锁功能

#### Trade模块
- `commodities` - 商品/资源信息
- `price_history` - 价格历史记录
- `trade_orders` - 交易订单
- `auto_trading_rules` - 自动交易规则

#### Venture模块
- `adventure_teams` - 冒险队伍
- `adventure_projects` - 冒险项目
- `investments` - 投资记录
- `adventure_results` - 冒险结果

#### 联动系统
- `market_events` - 市场事件
- `adventure_market_impacts` - 冒险对市场的影响

## 🚀 使用方法

1. **环境配置**
   ```bash
   # 安装MySQL
   # 配置数据库连接
   ```

2. **数据库初始化**
   ```bash
   mysql -u root -p < scripts/init_database.sql
   ```

3. **运行迁移**
   ```bash
   mysql -u root -p game_trade < database/migrations/001_initial_schema.sql
   ```

4. **插入测试数据**
   ```bash
   mysql -u root -p game_trade < database/data/sample_data.sql
   ```

## 🔧 开发工具

- **MySQL Workbench** - 数据库设计和管理
- **VS Code** - 代码编辑（安装MySQL扩展）
- **phpMyAdmin** - Web界面管理（可选）

## 📈 功能特色

### 实时交易系统
- 动态价格波动
- 自动止盈止损
- 历史数据分析
- 市场趋势预测

### 冒险投资系统
- 多样化冒险项目
- 风险收益评估
- 投资组合管理
- 实时结果追踪

### 智能联动机制
- 市场-冒险双向影响
- 经济生态模拟
- 事件驱动的价格变动
- 玩家行为影响市场

## 🎪 游戏平衡

通过精心设计的算法确保：
- 市场波动的真实感
- 冒险项目的多样性
- 风险与收益的平衡
- 长期游戏的可持续性 