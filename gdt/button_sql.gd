extends Control
var database : SQLite
var welcome_ui : Control  # 引用welcome_ui

func _ready():
	# 获取welcome_ui的引用
	welcome_ui = get_node("/root/Node/ControlsUI/WelcomePanel")
	print("button_sql: 已获取welcome_ui引用")

func _on_read_data_button_down() -> void:
	database = SQLite.new()
	database.path="res://sqlite_database/game_trade.db"
	database.open_db()
	var result = database.select_rows("adventure_projects","project_id > 0",["project_name"])
	print(result)
	
	# 直接调用welcome_ui的方法更新显示
	if welcome_ui:
		welcome_ui.receive_database_data(result)
		print("button_sql: 已发送数据到welcome_ui")
	pass # Replace with function body.
	
func _on_select_data_button_down() -> void:
	var result = database.select_rows("adventure_projects","project_id > 0",["project_name"])
	print(result)
	
	# 也可以直接设置自定义消息
	if welcome_ui:
		var custom_message = "[center][b]数据库查询结果：[/b][/center]\n\n"
		for i in range(min(5, result.size())):
			var project_name = result[i]["project_name"]
			custom_message += "[center]项目 " + str(i+1) + ": " + str(project_name) + "[/center]\n"
		welcome_ui.set_welcome_message(custom_message)
		print("button_sql: 已设置自定义欢迎语")
	pass # Replace with function body.
