# 继承自 CharacterBody2D
extends CharacterBody2D

# 使用@export可以让这个变量显示在Godot编辑器中，方便随时调整
@export var speed: float = 200.0

# 使用@onready可以在节点准备好时安全地获取其引用，比在_ready()中手动获取更简洁
# 注意：这里的"AnimatedSprite2D"必须和您场景树中的子节点名称完全一致
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_component: AttackComponent = $AttackComponent
@onready var interaction_component: InteractionComponent = $InteractionComponent

# _ready()函数在节点进入场景树时被调用一次，适合做初始化工作
func _ready():
	# 在这里加入打印语句
	print("脚本的_ready函数被调用了!")
	# @onready已经完成了节点的获取，这里直接打印检查结果
	print("获取到的动画节点是: ", animated_sprite)
	print("获取到的攻击组件是: ", attack_component)
	print("获取到的交互组件是: ", interaction_component)
	
	# 将Player添加到player组
	add_to_group("player")
	print("Player: 已添加到 'player' 组")
	
	# 设置攻击组件的动画精灵引用
	attack_component.set_animated_sprite(animated_sprite)
	
	# 设置交互组件的父节点引用
	interaction_component.set_parent_node(self)
	
	# 连接攻击组件的信号
	attack_component.attack_started.connect(_on_attack_started)
	attack_component.attack_finished.connect(_on_attack_finished)
	attack_component.pre_input_detected.connect(_on_pre_input_detected)
	
	# 连接交互组件的信号
	interaction_component.interaction_started.connect(_on_interaction_started)
	interaction_component.interaction_finished.connect(_on_interaction_finished)

# _physics_process()函数在每个物理帧被调用，所有物理相关的逻辑都应放在这里
func _physics_process(delta):
	# 1. 获取输入方向
	# Input.get_vector会根据输入映射返回一个方向向量，例如按下右方向键，它会是(1, 0)
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

	# 2. 处理攻击输入
	attack_component.handle_attack_input(direction)
	
	# 3. 处理交互输入
	interaction_component.handle_interaction_input()
	
	# 4. 如果正在攻击或交互，不处理移动
	if attack_component.is_currently_attacking() or interaction_component.is_currently_interacting():
		return

	# 5. 根据方向和速度设置速度
	velocity = direction * speed

	# 6. 调用内置的移动和碰撞函数
	move_and_slide()

	# 7. 更新动画
	update_animation()

	# 8. 更新精灵图朝向
	update_sprite_flip(direction)
	
	# 9. 更新攻击组件的面向方向
	attack_component.update_facing_direction(direction)

# 攻击开始回调
func _on_attack_started(animation_name: String, direction: Vector2):
	print("玩家开始攻击: ", animation_name, " 方向: ", direction)

# 攻击结束回调
func _on_attack_finished():
	print("玩家攻击结束")

# 预输入检测回调
func _on_pre_input_detected(next_animation: String):
	print("玩家预输入检测到: ", next_animation)

# 交互开始回调
func _on_interaction_started(interactor: Node2D, target: Node2D):
	print("玩家开始交互: ", target.name)

# 交互结束回调
func _on_interaction_finished():
	print("玩家交互结束")

func update_animation():
	# 如果正在攻击或交互，不更新移动动画
	if attack_component.is_currently_attacking() or interaction_component.is_currently_interacting():
		return
		
	# velocity.length() > 0 意味着角色正在移动
	if velocity.length() > 0:
		animated_sprite.play("walk")
		#print("Walking !")
	else:
		# 速度为0，意味着角色静止
		animated_sprite.play("idle")


func update_sprite_flip(direction: Vector2):
	# 如果有水平方向的移动
	if direction.x != 0:
		# direction.x < 0 意味着向左移动，此时需要水平翻转精灵图
		animated_sprite.flip_h = direction.x < 0


# func _process(delta):
# 	# 打印玩家的全局Y坐标。这是Y-Sort用来排序的主要依据。
# 	print("Player Global Y: ", global_position.y)

# 	# 打印玩家最终的渲染层级 (Z Index)。
# 	# Y-Sort就是通过动态修改这个值来实现排序的。
# 	# Y坐标越大，这个值也应该越大。
# 	print("Player Z Index: ", z_index)
