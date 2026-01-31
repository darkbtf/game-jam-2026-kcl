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

# 分配個性
var personalities
var personality = ""

func _ready():
	game_manager = get_tree().get_first_node_in_group("game_manager")
	personalities = [
		GameManager.CustomerPersonality.FRIENDLY,
		GameManager.CustomerPersonality.NEUTRAL,
		GameManager.CustomerPersonality.GRUMPY
	]
	
	random_personality()
	

func start_preparing(food_type: GameManager.FoodType):
	$CookTimer.wait_time = prepare_time
	$CookTimer.start()
	return true

func receive_expression(expression: GameManager.ExpressionType):
	if expression == desired_expression:
		mood = min(max_mood, mood + 10)
	else:
		mood = max(0, mood - 5)

func random_personality():
	personality = personalities[randi() % personalities.size()]
	match personality:
		GameManager.CustomerPersonality.FRIENDLY:
			desired_expression = GameManager.ExpressionType.HAPPY
			$Bubble/Label.text = "😊"
		GameManager.CustomerPersonality.NEUTRAL:
			desired_expression = GameManager.ExpressionType.NEUTRAL
			$Bubble/Label.text = "😐"
		GameManager.CustomerPersonality.GRUMPY:
			desired_expression = GameManager.ExpressionType.SAD
			$Bubble/Label.text = "😢"
			
func cook_finish():
	print("煮好了")
	return


func player_nearby_staff(area: Area2D) -> void:
	print("接觸")
	pass # Replace with function body.
