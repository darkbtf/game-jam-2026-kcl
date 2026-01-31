extends CharacterBody2D

# 內場人員腳本
@export var staff_id: int = 1
@export var available_foods: Array[GameManager.FoodType] = []

@export var mood: float = 50.0
@export var max_mood: float = 100.0
@export var desired_mask: GameManager.MaskType = GameManager.MaskType.NEUTRAL

var personalities: Array[GameManager.CustomerPersonality] = []
var personality: GameManager.CustomerPersonality

var game_manager: Node
var order_manager: Node
var prepare_time: float = 3.0


signal order_status_change(number, status)
var take_order_number
var cooking_status = false

func _ready():
	game_manager = get_tree().get_first_node_in_group("game_manager")

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
	if len(order_manager.order_text_array) == 0:
		print("沒有餐點")
		return
	
	# 情緒判斷
	if expression == desired_mask:
		prepare_time = max(2, prepare_time -1)
	else:
		prepare_time = min(10, prepare_time +1)
		
	# 取得訂單編號
	take_order_number = order_manager.make_number
	if !order_manager.check_order__cook_status(take_order_number):
		print("沒有尚未製作的餐點")
		return
	
	start_preparing()

func random_personality():
	personality = personalities[randi() % personalities.size()]
	match personality:
		GameManager.CustomerPersonality.FRIENDLY:
			desired_mask = GameManager.MaskType.HAPPY
			$Bubble/Label.text = "😊"
		GameManager.CustomerPersonality.NEUTRAL:
			desired_mask = GameManager.MaskType.NEUTRAL
			$Bubble/Label.text = "😐"
		GameManager.CustomerPersonality.GRUMPY:
			desired_mask = GameManager.MaskType.SAD
			$Bubble/Label.text = "😢"
	mood = max(0, mood - 5)
			
func cook_finish():
	$CookTimer.stop()
	emit_signal("order_status_change", take_order_number, "finish")
	cooking_status = false
	print("煮好了")
	return


func player_nearby_staff(body: Node2D) -> void:
	if body.is_in_group("player") and !cooking_status:
		receive_expression(body.current_expression)
