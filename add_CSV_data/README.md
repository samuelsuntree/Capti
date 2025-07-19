# 📊 CSV数据模板使用指南

这个文件夹包含了用于批量导入游戏数据的CSV模板文件，让不懂代码的用户也能轻松添加大量数据。

## 📁 文件说明

### 模板文件
- `characters_template.csv` - 角色数据模板
- `commodities_template.csv` - 商品数据模板  
- `adventure_teams_template.csv` - 冒险队伍模板
- `adventure_projects_template.csv` - 冒险项目模板

### 导入脚本
- `../scripts/import_csv_data.php` - 数据导入脚本

## 🚀 快速开始

### 1. 准备数据文件
1. 复制对应的模板文件
2. 用Excel、WPS或记事本打开
3. 按照模板格式填写数据
4. 保存为CSV格式

### 2. 导入数据
在项目根目录下运行：

```bash
# 导入角色数据
php scripts/import_csv_data.php characters templates/characters_template.csv

# 导入商品数据
php scripts/import_csv_data.php commodities templates/commodities_template.csv

# 导入队伍数据
php scripts/import_csv_data.php teams templates/adventure_teams_template.csv

# 导入项目数据
php scripts/import_csv_data.php projects templates/adventure_projects_template.csv
```

## 📋 详细使用说明

### 角色数据 (characters_template.csv)

#### 必填字段
- **角色名称**: 角色的完整名称，例如：钢铁骑士·加文
- **职业**: warrior/trader/explorer/scholar/mystic/survivor
- **稀有度**: common/uncommon/rare/epic/legendary

#### 属性范围
- **基础属性** (力量、体力等): 1-20
- **精神属性** (忠诚、勇气等): 1-100  
- **技能** (交易技能、冒险技能等): 1-100

#### 性格特质
用分号(;)分隔，最多5个：
- **积极**: 勤奋;冷静;幸运;专注;乐观;谨慎;领袖气质;直觉敏锐;坚韧;学习能力强
- **消极**: 冲动;贪婪;懒惰;焦虑;背叛者
- **中性**: 完美主义;独行侠;神秘主义

#### 示例
```csv
角色名称,显示名称,职业,稀有度,雇佣费用,维护费用,力量,体力,敏捷,智力,信仰,幸运,忠诚,勇气,耐心,贪婪,智慧,魅力,交易技能,冒险技能,谈判技能,分析技能,领导技能,性格特质,可用状态
钢铁骑士·加文,加文,warrior,rare,18000,400,18,19,13,12,15,14,80,90,70,25,65,75,50,85,60,55,80,勤奋;坚韧;领袖气质,TRUE
```

### 商品数据 (commodities_template.csv)

#### 必填字段
- **商品名称**: 商品的完整名称
- **商品代码**: 3-10个大写字母，不能重复
- **分类**: metal/gem/herb/magic/rare/special
- **稀有度**: common/uncommon/rare/epic/legendary

#### 价格设置
- **基础价格**: 商品的基准价格
- **当前价格**: 建议为基础价格±20%
- **波动性指数**: 0.01-0.50，数值越高价格波动越大

#### 示例
```csv
商品名称,商品代码,分类,稀有度,基础价格,当前价格,市值,总供应量,流通供应量,波动性指数,描述,可交易
秘银矿石,MITHRIL,metal,rare,2500.00,2800.00,2800000.00,5000.00,1000.00,0.12,传说中的轻盈金属，魔法传导性极佳,TRUE
```

### 冒险队伍 (adventure_teams_template.csv)

#### 必填字段
- **队伍名称**: 队伍的名称
- **队长名称**: 队长的名字
- **专精**: combat/mining/exploration/magic/stealth/survival
- **状态**: available/on_mission/resting/disbanded

#### 数值范围
- **成功率**: 0-100的百分比
- **士气**: 0-100，影响队伍表现
- **疲劳度**: 0-100，数值越高表现越差

### 冒险项目 (adventure_projects_template.csv)

#### 必填字段
- **项目名称**: 项目的名称
- **项目类型**: mining/dungeon/exploration/escort/investigation/special
- **难度**: easy/normal/hard/extreme/legendary
- **状态**: funding/ready/in_progress/completed/failed/cancelled

#### 投资设置
- **风险等级**: 0.1-0.9，数值越高风险越大
- **预期回报率**: 建议50-300之间

## ⚠️ 注意事项

### 数据格式
1. **CSV编码**: 使用UTF-8编码保存
2. **分隔符**: 使用逗号(,)分隔
3. **文本包含逗号**: 用双引号包围
4. **布尔值**: 使用TRUE/FALSE

### 常见错误
1. **重复的商品代码**: 每个商品代码必须唯一
2. **无效的枚举值**: 职业、稀有度等必须使用指定选项
3. **数值超出范围**: 属性值必须在指定范围内
4. **性格特质过多**: 最多只能选择5个特质

### 数据验证
导入前系统会自动验证：
- 必填字段是否完整
- 数值是否在有效范围内
- 枚举值是否正确
- 外键关系是否存在

## 🔧 高级功能

### 批量操作
可以在一个CSV文件中包含多行数据，系统会批量导入。

### 自动生成
导入角色时，系统会自动：
- 根据稀有度和性格特质生成情绪状态
- 根据职业和稀有度分配初始资产
- 设置合适的经验值和等级

### 错误处理
如果导入过程中出现错误：
- 整个导入会回滚，不会产生部分数据
- 会显示具体的错误信息和行号
- 可以修复后重新导入

## 📞 支持

如果在使用过程中遇到问题：
1. 检查CSV文件格式是否正确
2. 确认数据是否符合要求
3. 查看错误信息进行调试
4. 参考模板文件中的示例数据

## 📈 数据扩展

您可以：
1. 复制模板文件创建自己的数据集
2. 添加更多行来批量导入
3. 根据游戏需要调整属性值
4. 创建有趣的角色背景和故事 