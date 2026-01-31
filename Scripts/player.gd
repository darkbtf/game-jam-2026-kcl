extends CharacterBody2D

# 玩家腳本
@export var speed: float
@export var expression_drain_rate: float = 1.0  # 每秒掉多少 san

var run_status: bool = false
var run_direction

var current_expression: GameManager.ExpressionType = GameManager.ExpressionType.NEUTRAL
var is_using_expression: bool = false
var game_manager: Node

func _ready():
	add_to_group("player")
	game_manager = get_node("/root/GameManager")
	if not game_manager:
		game_manager = get_node("/root/Main/GameManager")
	if not game_manager:
		game_manager = get_tree().get_first_node_in_group("game_manager")

func _physics_process(delta):
	# 檢查遊戲結束
	if game_manager and game_manager.is_game_over:
		velocity = Vector2.ZERO
		return
	
	## 移動控制
	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
		
	if Input.is_action_just_pressed("run"):
		run_status = true
	else:
		run_status = false
	
	input_dir = input_dir.normalized()
	if run_status:
		velocity = input_dir * speed * 10
	else:
		velocity = input_dir * speed
	
	move_and_slide()
	# 表情控制	
	if Input.is_action_pressed("expression_happy"):
		current_expression = GameManager.ExpressionType.HAPPY
		is_using_expression = true
	elif Input.is_action_pressed("expression_neutral"):
		current_expression = GameManager.ExpressionType.NEUTRAL
		is_using_expression = true
	elif Input.is_action_pressed("expression_sad"):
		current_expression = GameManager.ExpressionType.SAD
		is_using_expression = true
	else:
		current_expression = GameManager.ExpressionType.NEUTRAL
		is_using_expression = false
	
	# 如果正在使用表情，持續掉 san
	if is_using_expression and game_manager:
		game_manager.drain_san(expression_drain_rate * delta)

func get_current_expression() -> GameManager.ExpressionType:
	return current_expression

func is_expressing() -> bool:
	return is_using_expression
