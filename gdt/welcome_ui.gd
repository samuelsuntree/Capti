# 欢迎语UI脚本
extends Control

# 数据库相关变量
var database : SQLite
var welcome_label : RichTextLabel

# 信号定义
signal database_updated(projects: Array)

# _ready()函数在节点进入场景树时被调用一次
func _ready():
	print("欢迎语UI已加载!")
	print("欢迎语UI节点路径: ", get_path())
	
	# 设置UI为半透明，不阻挡游戏交互
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# 确保UI始终显示在最顶层
	z_index = 1000
	
	# 设置UI为半透明
	modulate.a = 0.9
	
	# 获取欢迎语标签节点
	welcome_label = get_node("WelcomeLabel")
	
	# 连接全局数据信号
	if get_node_or_null("/root/GlobalData"):
		get_node("/root/GlobalData").projects_updated.connect(_on_projects_updated)
	
	# 初始化数据库并更新欢迎语
	initialize_database()
	
	print("欢迎语UI: 已设置z_index为1000，确保在最顶层显示")
	print("欢迎语UI: 现在显示在主界面上方")

# 当全局数据更新时调用
func _on_projects_updated():
	var projects = get_node("/root/GlobalData").get_database_projects()
	update_welcome_with_projects(projects)

# 初始化数据库
func initialize_database():
	database = SQLite.new()
	database.path = "res://sqlite_database/game_trade.db"
	database.open_db()
	
	# 查询数据库并更新欢迎语
	update_welcome_message()

# 更新欢迎语显示
func update_welcome_message():
	if database and welcome_label:
		# 查询数据库
		var query_result = database.select_rows("adventure_projects", "project_id > 0", ["project_name"])
		
		# 发送信号
		emit_signal("database_updated", query_result)
		
		# 构建欢迎语文本
		var welcome_text = "[center][b]欢迎来到Capti游戏世界！[/b][/center]\n\n"
		welcome_text += "[center]这是一个充满冒险和挑战的奇幻世界。在这里，你可以自由探索广阔的地图，与NPC进行互动，体验丰富的游戏内容。[/center]\n\n"
		
		# 添加数据库查询结果
		if query_result.size() > 0:
			welcome_text += "[center][b]当前可用的冒险项目：[/b][/center]\n"
			for i in range(min(3, query_result.size())):  # 只显示前3个项目
				var project_name = query_result[i]["project_name"]
				welcome_text += "[center]• " + str(project_name) + "[/center]\n"
		else:
			welcome_text += "[center]暂无可用项目[/center]\n"
		
		welcome_text += "\n[center]使用WASD键移动角色，空格键进行攻击，E键与NPC交互。祝你游戏愉快！[/center]"
		
		# 更新标签文本
		welcome_label.text = welcome_text
		
		print("欢迎语已更新，包含数据库查询结果")

# 使用项目数据更新欢迎语
func update_welcome_with_projects(projects: Array):
	if welcome_label:
		var welcome_text = "[center][b]欢迎来到Capti游戏世界！[/b][/center]\n\n"
		welcome_text += "[center]这是一个充满冒险和挑战的奇幻世界。在这里，你可以自由探索广阔的地图，与NPC进行互动，体验丰富的游戏内容。[/center]\n\n"
		
		# 添加数据库查询结果
		if projects.size() > 0:
			welcome_text += "[center][b]当前可用的冒险项目：[/b][/center]\n"
			for i in range(min(3, projects.size())):  # 只显示前3个项目
				var project_name = projects[i]["project_name"]
				welcome_text += "[center]• " + str(project_name) + "[/center]\n"
		else:
			welcome_text += "[center]暂无可用项目[/center]\n"
		
		welcome_text += "\n[center]使用WASD键移动角色，空格键进行攻击，E键与NPC交互。祝你游戏愉快！[/center]"
		
		# 更新标签文本
		welcome_label.text = welcome_text
		
		print("欢迎语已通过全局数据更新")

# 公共方法：从外部更新欢迎语
func set_welcome_message(custom_message: String):
	if welcome_label:
		welcome_label.text = custom_message
		print("欢迎语已通过外部调用更新")

# 公共方法：获取数据库查询结果
func get_database_projects() -> Array:
	if database:
		return database.select_rows("adventure_projects", "project_id > 0", ["project_name"])
	return []

# 公共方法：接收数据库数据并更新显示
func receive_database_data(projects: Array):
	if welcome_label:
		var welcome_text = "[center][b]欢迎来到Capti游戏世界！[/b][/center]\n\n"
		welcome_text += "[center]这是一个充满冒险和挑战的奇幻世界。在这里，你可以自由探索广阔的地图，与NPC进行互动，体验丰富的游戏内容。[/center]\n\n"
		
		# 添加数据库查询结果
		if projects.size() > 0:
			welcome_text += "[center][b]当前可用的冒险项目：[/b][/center]\n"
			for i in range(min(3, projects.size())):  # 只显示前3个项目
				var project_name = projects[i]["project_name"]
				welcome_text += "[center]• " + str(project_name) + "[/center]\n"
		else:
			welcome_text += "[center]暂无可用项目[/center]\n"
		
		
		# 更新标签文本
		welcome_label.text = welcome_text
		
		print("欢迎语已通过接收数据更新") 
