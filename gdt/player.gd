# 继承自 CharacterBody2D
extends CharacterBody2D

# 使用@export可以让这个变量显示在Godot编辑器中，方便随时调整
@export var speed: float = 200.0

# 使用@onready可以在节点准备好时安全地获取其引用，比在_ready()中手动获取更简洁
# 注意：这里的"AnimatedSprite2D"必须和您场景树中的子节点名称完全一致
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

# _ready()函数在节点进入场景树时被调用一次，适合做初始化工作
func _ready():
	# 在这里加入打印语句
	print("脚本的_ready函数被调用了!")
	# @onready已经完成了节点的获取，这里直接打印检查结果
	print("获取到的动画节点是: ", animated_sprite)

# _physics_process()函数在每个物理帧被调用，所有物理相关的逻辑都应放在这里
func _physics_process(delta):
	# 1. 获取输入方向
	# Input.get_vector会根据输入映射返回一个方向向量，例如按下右方向键，它会是(1, 0)
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

	# 2. 根据方向和速度设置速度
	velocity = direction * speed

	# 3. 调用内置的移动和碰撞函数
	move_and_slide()

	# 4. 更新动画
	update_animation()

	# 5. 更新精灵图朝向
	update_sprite_flip(direction)


func update_animation():
	# velocity.length() > 0 意味着角色正在移动
	if velocity.length() > 0:
		animated_sprite.play("walk")
		print("Walking !")
	else:
		# 速度为0，意味着角色静止
		animated_sprite.play("idle")


func update_sprite_flip(direction: Vector2):
	# 如果有水平方向的移动
	if direction.x != 0:
		# direction.x < 0 意味着向左移动，此时需要水平翻转精灵图
		animated_sprite.flip_h = direction.x < 0


func _process(delta):
	# 打印玩家的全局Y坐标。这是Y-Sort用来排序的主要依据。
	print("Player Global Y: ", global_position.y)

	# 打印玩家最终的渲染层级 (Z Index)。
	# Y-Sort就是通过动态修改这个值来实现排序的。
	# Y坐标越大，这个值也应该越大。
	print("Player Z Index: ", z_index)
