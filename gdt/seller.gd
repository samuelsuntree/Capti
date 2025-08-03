# Seller NPC脚本
extends CharacterBody2D

# 使用@onready获取动画精灵节点
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

# 菜单界面引用
var menu_scene: Control = null
var is_menu_open: bool = false

# _ready()函数在节点进入场景树时被调用一次
func _ready():
	print("Seller NPC已加载!")
	print("Seller的动画节点: ", animated_sprite)
	
	# 确保播放idle动画
	animated_sprite.play("idle")
	
	# 将Seller添加到交互组
	add_to_group("interactable")
	print("Seller: 已添加到 'interactable' 组")

# _physics_process()函数在每个物理帧被调用
func _physics_process(delta):
	# Seller是静态NPC，不需要移动逻辑
	# 只需要保持idle动画播放
	pass

# 与玩家交互的方法
func interact_with_player(player: Node2D):
	print("Seller: 欢迎光临！有什么需要帮助的吗？")
	print("Seller: 当前菜单状态 - is_menu_open: ", is_menu_open)
	
	# 如果菜单已经打开，关闭它
	if is_menu_open:
		print("Seller: 菜单已打开，准备关闭")
		close_menu()
	else:
		# 否则打开菜单
		print("Seller: 菜单未打开，准备打开")
		open_menu()

# 打开菜单界面
func open_menu():
	print("Seller: 开始打开菜单")
	
	if is_menu_open:
		print("Seller: 菜单已经打开，跳过")
		return
		
	# 创建菜单场景
	print("Seller: 预加载菜单场景")
	menu_scene = preload("res://menu_ui.tscn").instantiate()
	print("Seller: 菜单场景已实例化: ", menu_scene)
	
	# 创建CanvasLayer来确保菜单在最顶层
	print("Seller: 创建CanvasLayer来放置菜单")
	var canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 1000  # 设置非常高的层级，确保在最顶层
	get_tree().current_scene.add_child(canvas_layer)
	
	# 将菜单添加到CanvasLayer
	print("Seller: 将菜单添加到CanvasLayer")
	canvas_layer.add_child(menu_scene)
	
	# 设置菜单为全屏覆盖
	menu_scene.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	print("Seller: 菜单设置为全屏覆盖")
	
	# 确保菜单显示在最顶层
	menu_scene.z_index = 1000
	print("Seller: 设置菜单z_index为1000，确保在最顶层")
	
	# 保存CanvasLayer引用以便后续清理
	menu_scene.set_meta("canvas_layer", canvas_layer)
	
	# 连接菜单关闭信号
	menu_scene.tree_exiting.connect(_on_menu_closed)
	print("Seller: 菜单关闭信号已连接")
	
	is_menu_open = true
	print("Seller: 菜单已打开! is_menu_open = true")
	
	# 暂停游戏
	get_tree().paused = true
	print("Seller: 游戏已暂停")

# 关闭菜单
func close_menu():
	print("Seller: 开始关闭菜单")
	print("Seller: is_menu_open = ", is_menu_open, ", menu_scene = ", menu_scene)
	
	if not is_menu_open or not menu_scene:
		print("Seller: 无法关闭菜单 - 菜单未打开或场景为空")
		return
		
	print("Seller: 销毁菜单场景")
	
	# 获取CanvasLayer并清理
	var canvas_layer = menu_scene.get_meta("canvas_layer", null)
	if canvas_layer:
		print("Seller: 清理CanvasLayer")
		canvas_layer.queue_free()
	
	menu_scene.queue_free()
	menu_scene = null
	is_menu_open = false
	print("Seller: 菜单已关闭! is_menu_open = false")
	
	# 恢复游戏
	get_tree().paused = false
	print("Seller: 游戏已恢复")
	
	# 重置交互状态
	reset_interaction_state()

# 菜单关闭回调
func _on_menu_closed():
	print("Seller: 收到菜单关闭信号")
	
	# 获取CanvasLayer并清理
	var canvas_layer = menu_scene.get_meta("canvas_layer", null) if menu_scene else null
	if canvas_layer:
		print("Seller: 清理CanvasLayer (通过信号)")
		canvas_layer.queue_free()
	
	is_menu_open = false
	menu_scene = null
	print("Seller: 菜单已关闭 (通过信号)")
	
	# 恢复游戏
	get_tree().paused = false
	print("Seller: 游戏已恢复 (通过信号)")
	
	# 重置交互状态
	reset_interaction_state()

# 重置交互状态
func reset_interaction_state():
	print("Seller: 重置交互状态")
	# 查找玩家的交互组件并重置状态
	var player = get_tree().get_nodes_in_group("player")
	if player.size() > 0:
		var player_node = player[0]
		var interaction_component = player_node.get_node("InteractionComponent")
		if interaction_component:
			interaction_component.force_reset_interaction()
			print("Seller: 已重置玩家交互状态")
		else:
			print("Seller: 未找到玩家交互组件")
	else:
		print("Seller: 未找到玩家节点") 
