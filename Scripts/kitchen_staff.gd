extends CharacterBody2D

# 內場人員腳本
@export var staff_id: int = 1
@export var available_foods: Array[GameManager.FoodType] = []

@export var mood: float = 50.0
@export var max_mood: float = 100.0
@export var desired_mask: GameManager.MaskType = GameManager.MaskType.NEUTRAL
var desired_food: GameManager.FoodType

var personalities: Array[GameManager.CustomerPersonality] = []
var personality: GameManager.CustomerPersonality

var game_manager: Node
var order_manager: Node
var prepare_time: float = 3.0


signal order_status_change(number, status)
var take_order_number
var cooking_status = false
var cook_food_name

@export var food: Sprite2D

func _ready():
	game_manager = GameManager

	order_manager = get_tree().get_first_node_in_group("orderManager")
	personalities = [
		GameManager.CustomerPersonality.FRIENDLY,
		GameManager.CustomerPersonality.NEUTRAL,
		GameManager.CustomerPersonality.GRUMPY
	]

func start_preparing():
	$CookTimer.wait_time = prepare_time
	$CookTimer.start()
	cooking_status = true
	emit_signal("order_status_change", take_order_number, "prepare")
	print(prepare_time)

func receive_expression(expression: GameManager.MaskType):
	# 確認有無餐點
	if !order_manager.check_empty_meal():
		print("沒有餐點")
		return
	
	# 情緒判斷
	if expression == desired_mask:
		prepare_time = max(2, prepare_time -1)
	else:
		prepare_time = prepare_time +1
		
	# 取得訂單編號
	take_order_number = order_manager.check_order_cook_status()
	if take_order_number == -1:
		print("沒有尚未製作的餐點")
		return
	else:
		cook_food_name = order_manager.order_text_array[take_order_number][0]
	start_preparing()

func random_personality():
	personality = personalities[randi() % personalities.size()]
	match personality:
		GameManager.CustomerPersonality.FRIENDLY:
			desired_mask = GameManager.MaskType.HAPPY
			$Bubble/emoji.texture = load("res://Assets/Emoji/crazy_sign.PNG")
		GameManager.CustomerPersonality.NEUTRAL:
			desired_mask = GameManager.MaskType.NEUTRAL
			$Bubble/emoji.texture = load("res://Assets/Emoji/normal_sign.PNG")
		GameManager.CustomerPersonality.GRUMPY:
			desired_mask = GameManager.MaskType.SAD
			$Bubble/emoji.texture = load("res://Assets/Emoji/shy_sign.PNG")
	mood = max(0, mood - 5)
			
func cook_finish():
	$CookTimer.stop()
	emit_signal("order_status_change", take_order_number, "finish")
	cooking_status = false
	print("煮好了", cook_food_name)

	food.texture = load("res://Assets/Foods/" + cook_food_name + ".png")
	food.food_name = cook_food_name
	food.order_number = take_order_number
	
	# 播放備餐完成音效
	if SFXManager:
		SFXManager.play_meal_ready_sfx()

func player_nearby_staff(body: Node2D) -> void:
	if body.is_in_group("player") and !cooking_status:
		receive_expression(body.current_expression)
