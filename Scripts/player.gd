extends CharacterBody2D

# 玩家腳本
@export var speed: float
var expression_drain_rate: float = 5.0  # 每秒掉多少 san

var run_status: bool = false
var run_direction

var current_expression: GameManager.MaskType = GameManager.MaskType.NEUTRAL
var is_using_expression: bool = false
var game_manager: Node

# 取餐送餐
var take_status = false
var take_food = ["", 0]
signal take_meal_to_customer(take_food)

func _ready():
	game_manager = get_tree().get_first_node_in_group("GameManager")

func _physics_process(delta):
	# 檢查遊戲結束
	if LevelManager and LevelManager.is_ended():
		velocity = Vector2.ZERO
		return
	
	## 移動控制
	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	if Input.is_action_just_pressed("run"):
		run_status = true
	else:
		run_status = false
	if input_dir.x > 0:
		$AnimatedSprite2D.play("WalkLeft")
		$AnimatedSprite2D.flip_h = true
		if take_status:
			$Tray_left.visible = false
			$Tray_right.visible = true
	elif input_dir.x < 0:
		$AnimatedSprite2D.play("WalkLeft")
		$AnimatedSprite2D.flip_h = false
		if take_status:
			$Tray_left.visible = true
			$Tray_right.visible = false
	elif input_dir.y < 0:
		$AnimatedSprite2D.play("WalkUp")
		$AnimatedSprite2D.flip_h = false
		$Tray_left.visible = false
		$Tray_right.visible = false
	elif input_dir.y > 0:
		$AnimatedSprite2D.play("WalkDown")
		$AnimatedSprite2D.flip_h = false
		$Tray_left.visible = false
		$Tray_right.visible = false
	else:
		$AnimatedSprite2D.play("Down")
		$AnimatedSprite2D.flip_h = false
		$Tray_left.visible = false
		$Tray_right.visible = false
	
	input_dir = input_dir.normalized()
	if run_status:
		velocity = input_dir * speed * 10
	else:
		velocity = input_dir * speed
	
	move_and_slide()
	# 表情控制	
	if Input.is_action_pressed("expression_happy"):
		current_expression = GameManager.MaskType.HAPPY
		expression_drain_rate = 2.0
		is_using_expression = true
	elif Input.is_action_pressed("expression_neutral"):
		current_expression = GameManager.MaskType.NEUTRAL
		expression_drain_rate = 5.0
		is_using_expression = true
	elif Input.is_action_pressed("expression_sad"):
		current_expression = GameManager.MaskType.SAD
		expression_drain_rate = 10.0
		is_using_expression = true
	else:
		current_expression = GameManager.MaskType.NEUTRAL
		is_using_expression = false
	
	# 如果正在使用表情，持續掉 san
	if is_using_expression and game_manager:
		game_manager.drain_san(expression_drain_rate * delta)

func get_current_expression() -> GameManager.MaskType:
	return current_expression

func is_expressing() -> bool:
	return is_using_expression

func take_it(food_name, order_number):
	if food_name != "":
		print("玩家拿到", food_name)
		take_food = [food_name, order_number]
		take_status = true
		
func to_customer():
	print("送餐完畢" ,take_food)
	emit_signal("take_meal_to_customer", take_food)
	take_status = false
	$Tray_left.visible = false
	$Tray_right.visible = false
