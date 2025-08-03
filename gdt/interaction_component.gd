# 交互组件 - 处理角色之间的交互
class_name InteractionComponent
extends Node

# 信号定义
signal interaction_started(interactor: Node2D, target: Node2D)
signal interaction_finished()

# 交互相关变量
var is_interacting: bool = false
var interaction_cooldown: float = 0.0
var interaction_cooldown_time: float = 0.5  # 交互冷却时间
var interaction_range: float = 80.0  # 交互范围
var current_target: Node2D = null  # 当前交互目标

# 父节点引用
var parent_node: CharacterBody2D = null

# 设置父节点引用
func set_parent_node(node: CharacterBody2D):
	parent_node = node
	print("交互组件: 父节点设置为 ", node.name)

# 处理交互输入
func handle_interaction_input():
	# 如果游戏暂停（菜单打开），不处理交互
	if get_tree().paused:
		print("交互组件: 游戏暂停，跳过交互处理")
		return
	
	# 更新交互冷却时间
	if interaction_cooldown > 0:
		interaction_cooldown -= get_process_delta_time()
	
	# 检查是否按下交互键（E键）
	if Input.is_action_just_pressed("interact") and interaction_cooldown <= 0:
		print("交互组件: 检测到E键按下")
		check_for_interaction_targets()
	else:
		# 调试：显示当前冷却时间
		if interaction_cooldown > 0:
			print("交互组件: 冷却中，剩余时间: ", interaction_cooldown)

# 检查交互目标
func check_for_interaction_targets():
	if not parent_node:
		print("交互组件: 错误 - 父节点未设置")
		return
	
	print("交互组件: 开始检查交互目标")
	print("交互组件: 当前交互状态 - is_interacting: ", is_interacting)
	
	# 获取附近的交互目标
	var targets = get_interaction_targets()
	
	print("交互组件: 找到 ", targets.size(), " 个交互目标")
	
	if targets.size() > 0:
		# 选择最近的交互目标
		var nearest_target = get_nearest_target(targets)
		print("交互组件: 选择最近的交互目标: ", nearest_target.name)
		start_interaction(nearest_target)
	else:
		print("交互组件: 没有找到可交互的目标")

# 获取交互目标
func get_interaction_targets() -> Array:
	var targets = []
	
	# 获取所有可能的交互目标
	var potential_targets = get_tree().get_nodes_in_group("interactable")
	
	print("交互组件: 在 'interactable' 组中找到 ", potential_targets.size(), " 个节点")
	
	for target in potential_targets:
		print("交互组件: 检查目标 ", target.name, " (", target.get_class(), ")")
		if target != parent_node and is_in_interaction_range(target):
			targets.append(target)
			print("123")
		else:
			if target == parent_node:
				print("交互组件: 跳过自己")
			else:
				var distance = parent_node.global_position.distance_to(target.global_position)
				print("交互组件: 目标 ", target.name, " 距离太远: ", distance, " > ", interaction_range)
	
	return targets

# 检查是否在交互范围内
func is_in_interaction_range(target: Node2D) -> bool:
	if not parent_node or not target:
		print("交互组件: 错误 - 父节点或目标为空")
		return false
	
	var distance = parent_node.global_position.distance_to(target.global_position)
	var in_range = distance <= interaction_range
	
	print("交互组件: 目标 ", target.name, " 距离: ", distance, " 在范围内: ", in_range)
	
	return in_range

# 获取最近的交互目标
func get_nearest_target(targets: Array) -> Node2D:
	if targets.size() == 0:
		return null
	
	var nearest_target = targets[0]
	var nearest_distance = parent_node.global_position.distance_to(nearest_target.global_position)
	
	for target in targets:
		var distance = parent_node.global_position.distance_to(target.global_position)
		if distance < nearest_distance:
			nearest_distance = distance
			nearest_target = target
	
	print("交互组件: 最近目标: ", nearest_target.name, " 距离: ", nearest_distance)
	return nearest_target

# 开始交互
func start_interaction(target: Node2D):
	print("交互组件: 尝试开始交互")
	print("交互组件: is_interacting = ", is_interacting, ", target = ", target)
	
	if is_interacting or not target:
		print("交互组件: 无法开始交互 - 正在交互或目标为空")
		return
	
	is_interacting = true
	current_target = target
	interaction_cooldown = interaction_cooldown_time
	
	print("开始交互: ", parent_node.name, " 与 ", target.name)
	
	# 发出交互开始信号
	interaction_started.emit(parent_node, target)
	
	# 如果目标有交互方法，调用它
	if target.has_method("interact_with_player"):
		print("交互组件: 调用目标的 interact_with_player 方法")
		target.interact_with_player(parent_node)
	else:
		print("交互组件: 目标没有 interact_with_player 方法")

# 结束交互
func end_interaction():
	print("交互组件: 结束交互")
	is_interacting = false
	current_target = null
	
	print("结束交互")
	
	# 发出交互结束信号
	interaction_finished.emit()

# 检查是否正在交互
func is_currently_interacting() -> bool:
	return is_interacting

# 获取当前交互目标
func get_current_target() -> Node2D:
	return current_target

# 强制重置交互状态（用于调试）
func force_reset_interaction():
	print("交互组件: 强制重置交互状态")
	is_interacting = false
	current_target = null
	interaction_cooldown = 0.0 
