# 操作说明UI脚本
extends Control

var database : SQLite
# _ready()函数在节点进入场景树时被调用一次
func _ready():
	print("操作说明UI已加载!")
	print("操作说明UI节点路径: ", get_path())
	
	# 设置UI为半透明，不阻挡游戏交互
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# 确保UI始终显示在最顶层
	z_index = 999
	
	# 设置UI为半透明
	modulate.a = 0.8
	
	print("操作说明UI: 已设置z_index为999，确保在最顶层显示")
	print("操作说明UI: 现在跟随摄像机移动，显示在玩家视野左上角") 
	#database = SQLite.new()
	#database.path="res://sqlite_database/game_trade.db"
	#database.open_db()
	#print(database.select_rows("adventure_projects","project_id > 0",["project_name"]))
