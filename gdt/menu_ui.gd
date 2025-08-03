# 菜单界面脚本
extends Control

# 对话界面引用
var dialogue_scene: Control = null

# _ready()函数在节点进入场景树时被调用一次
func _ready():
	print("菜单界面已加载!")
	print("菜单节点路径: ", get_path())
	
	# 设置菜单为模态（阻止背景交互）
	mouse_filter = Control.MOUSE_FILTER_STOP
	
	# 确保菜单可以接收输入
	process_mode = Node.PROCESS_MODE_ALWAYS

# 关闭按钮回调
func _on_close_button_pressed():
	print("菜单: 关闭按钮被点击")
	close_menu()

# 对话按钮回调
func _on_dialogue_button_pressed():
	print("菜单: 对话按钮被点击")
	open_dialogue()

# 打开对话界面
func open_dialogue():
	print("菜单: 开始打开对话界面")
	
	# 创建对话场景
	dialogue_scene = preload("res://dialogue_ui.tscn").instantiate()
	print("菜单: 对话场景已实例化")
	
	# 创建CanvasLayer来确保对话界面在最顶层
	var canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 1000
	get_tree().current_scene.add_child(canvas_layer)
	canvas_layer.add_child(dialogue_scene)
	
	# 设置对话界面为全屏覆盖
	dialogue_scene.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dialogue_scene.z_index = 1000
	
	# 保存CanvasLayer引用
	dialogue_scene.set_meta("canvas_layer", canvas_layer)
	
	# 设置对话界面的父菜单引用
	dialogue_scene.set_parent_menu(self)
	print("菜单: 对话界面已设置父菜单引用")
	
	# 隐藏当前菜单
	visible = false
	print("菜单: 当前菜单已隐藏")

# 处理输入
func _input(event):
	# print("菜单: 接收到输入事件: ", event)  # 注释掉鼠标移动等事件的输出
	
	# 如果按下ESC键，关闭菜单
	if event.is_action_pressed("ui_cancel"):
		print("菜单: 检测到ESC键")
		close_menu()
	# 移除E键关闭菜单的功能，让E键可以用于其他用途

# 关闭菜单
func close_menu():
	print("菜单: 开始关闭菜单")
	print("菜单: 当前暂停状态: ", get_tree().paused)
	
	# 恢复游戏
	get_tree().paused = false
	print("菜单: 游戏已恢复")
	
	# 销毁菜单
	print("菜单: 准备销毁菜单节点")
	queue_free()
	print("菜单: 销毁命令已发送")

# 节点即将退出时的回调
func _exit_tree():
	print("菜单: 节点即将退出") 
