# Capti - 2D RPG游戏项目

一个基于Godot 4引擎开发的2D RPG游戏项目，具有完整的角色控制系统、NPC交互和UI菜单系统。

## 🎮 游戏功能

### 角色控制系统
- **移动控制**：WASD键控制角色移动
- **攻击系统**：空格键触发攻击
  - 四方向攻击：水平（atk1/atk2）、向上（atkup1/atkup2）、向下（atkdown1/atkdown2）
  - 预输入连招：在攻击动画后半段再次按空格可触发连击
  - 智能方向：静止时攻击方向基于角色朝向，移动时基于移动方向

### NPC交互系统
- **Seller NPC**：具有idle动画的商人NPC
- **交互机制**：靠近NPC按E键打开商店菜单
- **交互范围**：80像素范围内的自动检测

### UI菜单系统
- **主菜单**：商店界面，包含购买、出售、对话、关闭选项
- **对话界面**：二级菜单，显示NPC对话内容
- **导航控制**：
  - ESC键：关闭当前界面
  - 返回按钮：返回上级菜单
  - E键：打开/关闭主菜单

## 🎯 操作指南

### 基础操作
- **WASD**：角色移动
- **空格键**：攻击
- **E键**：与NPC交互（打开/关闭菜单）

### 菜单操作
- **ESC键**：关闭当前菜单
- **鼠标点击**：选择菜单选项
- **对话界面**：点击"返回"按钮返回主菜单

### 攻击连招
1. 按空格键开始攻击
2. 在攻击动画后半段再次按空格键
3. 系统会自动触发连击（atk1→atk2 或 atk2→atk1）

## 🏗️ 技术架构

### 组件化设计
- **AttackComponent**：封装攻击逻辑，可复用
- **InteractionComponent**：封装交互逻辑，可复用
- **模块化UI**：菜单和对话界面独立组件

### 场景结构
```
CaptiUI.tscn
├── YSort_Container
│   ├── Player (CharacterBody2D)
│   │   ├── AttackComponent
│   │   ├── InteractionComponent
│   │   ├── AnimatedSprite2D
│   │   ├── CollisionShape2D
│   │   ├── Camera2D
│   │   └── ColorRect
│   ├── Seller (CharacterBody2D)
│   │   ├── AnimatedSprite2D
│   │   └── CollisionShape2D
│   └── Trees (StaticBody2D)
└── TileMap
```

### 文件结构
```
gdt/
├── CaptiUI.tscn          # 主场景
├── player.gd             # 玩家控制脚本
├── seller.gd             # NPC脚本
├── attack_component.gd   # 攻击组件
├── interaction_component.gd # 交互组件
├── menu_ui.tscn          # 主菜单场景
├── menu_ui.gd            # 主菜单脚本
├── dialogue_ui.tscn      # 对话界面场景
├── dialogue_ui.gd        # 对话界面脚本
├── project.godot         # 项目配置
└── README.md             # 项目说明
```

## 🎨 美术资源

项目使用了"Tiny Swords"美术包，包含：
- 角色精灵（战士、弓箭手、棋子等）
- 建筑资源（城堡、房屋、塔楼）
- 环境元素（树木、桥梁、水面）
- UI界面元素（按钮、横幅、图标）

## 🚀 开发特性

### 代码质量
- **组件化架构**：使用组合模式提高代码复用性
- **信号系统**：使用Godot信号进行组件间通信
- **调试友好**：详细的print语句和错误处理
- **输入优化**：智能的输入处理和事件传播控制

### 性能优化
- **CanvasLayer**：确保UI层级正确，避免渲染问题
- **节点分组**：使用add_to_group()便于节点查找
- **资源管理**：正确的场景实例化和清理机制

### 用户体验
- **响应式UI**：全屏覆盖和自适应布局
- **流畅动画**：角色动画和UI过渡效果
- **直观操作**：清晰的按键映射和视觉反馈

## 🔧 开发环境

- **引擎版本**：Godot 4.x
- **脚本语言**：GDScript
- **目标平台**：Windows (已测试)
- **美术工具**：Aseprite (精灵动画)

## 📝 更新日志

### 最新版本
- ✅ 实现完整的攻击系统（四方向+连招）
- ✅ 添加NPC交互和对话系统
- ✅ 创建多层UI菜单系统
- ✅ 重构代码为组件化架构
- ✅ 优化输入处理和用户体验

## 🤝 贡献指南

欢迎提交Issue和Pull Request来改进项目！

## 📄 许可证

本项目使用MIT许可证。

---

**注意**：这是一个开发中的项目，功能会持续更新和完善。 