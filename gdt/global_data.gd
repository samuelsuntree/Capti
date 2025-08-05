# 全局数据管理脚本
extends Node

# 全局变量，用于存储数据库查询结果
var database_projects: Array = []

# 信号，当数据更新时发出
signal projects_updated

# 设置数据库项目数据
func set_database_projects(projects: Array):
	database_projects = projects
	emit_signal("projects_updated")
	print("全局数据: 数据库项目已更新，共", projects.size(), "个项目")

# 获取数据库项目数据
func get_database_projects() -> Array:
	return database_projects 