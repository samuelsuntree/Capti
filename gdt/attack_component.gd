# 攻击组件 - 可复用的攻击逻辑
class_name AttackComponent
extends Node

# 信号定义
signal attack_started(animation_name: String, direction: Vector2)
signal attack_finished()
signal pre_input_detected(next_animation: String)

# 攻击相关变量
var is_attacking: bool = false
var attack_cooldown: float = 0.0
var attack_duration: float = 0.6  # 攻击动画持续时间
var attack_cooldown_time: float = 0.8  # 攻击冷却时间
var current_attack_animation: String = "atk1"  # 当前攻击动画
var next_attack_animation: String = "atk2"  # 下一个攻击动画
var attack_timer: float = 0.0  # 当前攻击动画的计时器
var pre_input_window: float = 0.3  # 预输入窗口时间（攻击动画后半段）
var has_pre_input: bool = false  # 是否有预输入
var attack_direction: Vector2 = Vector2.RIGHT  # 攻击方向
var last_facing_direction: Vector2 = Vector2.RIGHT  # 上次面向的方向

# 动画精灵引用（由父节点设置）
var animated_sprite: AnimatedSprite2D = null

# 设置动画精灵引用
func set_animated_sprite(sprite: AnimatedSprite2D):
	animated_sprite = sprite

# 处理攻击输入
func handle_attack_input(input_direction: Vector2):
	# 更新攻击冷却时间
	if attack_cooldown > 0:
		attack_cooldown -= get_process_delta_time()
	
	# 如果正在攻击，更新攻击计时器
	if is_attacking:
		attack_timer += get_process_delta_time()
		
		# 检查是否在预输入窗口内
		if attack_timer >= attack_duration - pre_input_window:
			check_attack_input(input_direction)
		
		# 检查攻击动画是否结束
		if attack_timer >= attack_duration:
			end_attack()
		return
	
	# 检查攻击输入
	check_attack_input(input_direction)

# 检查攻击输入
func check_attack_input(input_direction: Vector2):
	# 检查是否按下攻击键（空格键）
	if Input.is_action_just_pressed("attack") and attack_cooldown <= 0:
		# 如果正在攻击且在预输入窗口内
		if is_attacking and attack_timer >= attack_duration - pre_input_window:
			has_pre_input = true
			print("预输入检测到! 将在当前攻击结束后执行: ", next_attack_animation)
			pre_input_detected.emit(next_attack_animation)
		else:
			# 正常开始攻击
			start_attack(input_direction)

# 开始攻击
func start_attack(input_direction: Vector2):
	is_attacking = true
	attack_timer = 0.0
	has_pre_input = false
	
	# 确定攻击方向
	if input_direction.length() > 0:
		# 如果有输入方向，使用输入方向
		attack_direction = input_direction.normalized()
		last_facing_direction = attack_direction
	else:
		# 如果没有输入方向（静止时攻击），使用上次面向的方向
		attack_direction = last_facing_direction
	
	# 根据攻击方向选择动画
	select_attack_animation()
	
	# 播放当前攻击动画
	if animated_sprite:
		animated_sprite.play(current_attack_animation)
	
	print("开始攻击! 方向: ", get_direction_name(attack_direction), " 使用动画: ", current_attack_animation)
	
	# 设置下一个攻击动画
	set_next_attack_animation()
	
	# 发出攻击开始信号
	attack_started.emit(current_attack_animation, attack_direction)

# 根据攻击方向选择动画
func select_attack_animation():
	var abs_x = abs(attack_direction.x)
	var abs_y = abs(attack_direction.y)
	
	# 水平攻击（左右）
	if abs_x > abs_y:
		if current_attack_animation == "atk1" or current_attack_animation == "atkup1" or current_attack_animation == "atkdown1":
			current_attack_animation = "atk1"
		else:
			current_attack_animation = "atk2"
	# 垂直攻击（上下）
	else:
		if attack_direction.y > 0:  # 向下攻击
			if current_attack_animation == "atkdown1":
				current_attack_animation = "atkdown1"
			else:
				current_attack_animation = "atkdown2"
		else:  # 向上攻击
			if current_attack_animation == "atkup1":
				current_attack_animation = "atkup1"
			else:
				current_attack_animation = "atkup2"

# 设置下一个攻击动画
func set_next_attack_animation():
	var abs_x = abs(attack_direction.x)
	var abs_y = abs(attack_direction.y)
	
	# 水平攻击
	if abs_x > abs_y:
		if current_attack_animation == "atk1":
			next_attack_animation = "atk2"
		else:
			next_attack_animation = "atk1"
	# 垂直攻击
	else:
		if attack_direction.y > 0:  # 向下攻击
			if current_attack_animation == "atkdown1":
				next_attack_animation = "atkdown2"
			else:
				next_attack_animation = "atkdown1"
		else:  # 向上攻击
			if current_attack_animation == "atkup1":
				next_attack_animation = "atkup2"
			else:
				next_attack_animation = "atkup1"

# 获取方向名称
func get_direction_name(direction: Vector2) -> String:
	var abs_x = abs(direction.x)
	var abs_y = abs(direction.y)
	
	if abs_x > abs_y:
		if direction.x > 0:
			return "右"
		else:
			return "左"
	else:
		if direction.y > 0:
			return "下"
		else:
			return "上"

# 结束攻击
func end_attack():
	is_attacking = false
	
	# 检查是否有预输入
	if has_pre_input:
		# 执行预输入的连招
		current_attack_animation = next_attack_animation
		start_attack(Vector2.ZERO)  # 使用当前方向
		print("执行连招!")
	else:
		# 重置为第一个攻击动画
		current_attack_animation = "atk1"
		next_attack_animation = "atk2"
		print("攻击结束!")
	
	# 发出攻击结束信号
	attack_finished.emit()

# 更新面向方向
func update_facing_direction(direction: Vector2):
	if direction.x != 0:
		last_facing_direction = Vector2(1 if direction.x > 0 else -1, 0)

# 检查是否正在攻击
func is_currently_attacking() -> bool:
	return is_attacking 