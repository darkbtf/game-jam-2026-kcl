extends CharacterBody2D

# 內場人員腳本
@export var staff_id: int = 1
@export var available_foods: Array[GameManager.FoodType] = []
@export var mood: float = 50.0
@export var max_mood: float = 100.0
@export var desired_expression: GameManager.ExpressionType = GameManager.ExpressionType.NEUTRAL

var game_manager: Node
var is_preparing: bool = false
var prepare_timer: float = 0.0
var prepare_time: float = 2.0

func _ready():
	game_manager = get_node("/root/GameManager")
	if not game_manager:
		game_manager = get_node("/root/Main/GameManager")
	if not game_manager:
		game_manager = get_tree().get_first_node_in_group("game_manager")
	
	# 根據 staff_id 設置可用食物
	if staff_id == 1:
		available_foods = [
			GameManager.FoodType.BEEF_NOODLE,
			GameManager.FoodType.STINKY_TOFU,
			GameManager.FoodType.PEARL_MILK_TEA
		]
		desired_expression = GameManager.ExpressionType.HAPPY
	else:
		available_foods = [
			GameManager.FoodType.OYSTER_OMELETTE,
			GameManager.FoodType.BRAISED_PORK
		]
		desired_expression = GameManager.ExpressionType.NEUTRAL

func can_prepare_food(food_type: GameManager.FoodType) -> bool:
	return food_type in available_foods

func start_preparing(food_type: GameManager.FoodType):
	if not can_prepare_food(food_type):
		return false
	
	is_preparing = true
	prepare_timer = 0.0
	prepare_time = 2.0  # 準備時間
	return true

func _process(delta):
	if is_preparing:
		prepare_timer += delta
		if prepare_timer >= prepare_time:
			is_preparing = false
			prepare_timer = 0.0

func is_ready() -> bool:
	return not is_preparing

func receive_expression(expression: GameManager.ExpressionType):
	if expression == desired_expression:
		mood = min(max_mood, mood + 10)
	else:
		mood = max(0, mood - 5)
