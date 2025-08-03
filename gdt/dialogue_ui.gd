# 对话界面脚本
extends Control

# 父菜单的引用
var parent_menu: Control = null

# _ready()函数在节点进入场景树时被调用一次
func _ready():
	print("对话界面已加载!")
	print("对话界面节点路径: ", get_path())
	print("对话界面可见性: ", visible)
	
	# 设置菜单为模态（阻止背景交互）
	mouse_filter = Control.MOUSE_FILTER_STOP
	
	# 确保菜单可以接收输入
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# 确保界面可见
	visible = true
	print("对话界面: 已设置可见性为true")

# 设置父菜单引用
func set_parent_menu(menu: Control):
	parent_menu = menu
	print("对话界面: 已设置父菜单引用")

# 返回按钮回调
func _on_back_button_pressed():
	print("对话界面: 返回按钮被点击")
	close_dialogue()

# 处理输入
func _input(event):
	# 如果按下ESC键，关闭对话
	if event.is_action_pressed("ui_cancel"):
		print("对话界面: 检测到ESC键")
		close_dialogue()
		# 阻止事件继续传播，避免触发父菜单的ESC处理
		get_viewport().set_input_as_handled()

# 关闭对话界面
func close_dialogue():
	print("对话界面: 开始关闭对话")
	
	# 获取CanvasLayer并清理
	var canvas_layer = get_meta("canvas_layer", null)
	if canvas_layer:
		print("对话界面: 清理CanvasLayer")
		canvas_layer.queue_free()
	
	# 重新显示父菜单
	if parent_menu:
		parent_menu.visible = true
		print("对话界面: 已重新显示父菜单")
	
	# 销毁对话界面
	print("对话界面: 准备销毁对话节点")
	queue_free()
	print("对话界面: 销毁命令已发送")

# 节点即将退出时的回调
func _exit_tree():
	print("对话界面: 节点即将退出")
	
	# 确保父菜单重新显示
	if parent_menu:
		parent_menu.visible = true
		print("对话界面: 退出时重新显示父菜单") 