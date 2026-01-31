extends CharacterBody2D

# 客人腳本
var personality
@export var satisfaction: float = 50.0
@export var max_satisfaction: float = 100.0

var customer_id: int
# 客人想要的食物（在生成時隨機決定，之後不會改變）
var desired_food: GameManager.FoodType
var desired_expression: GameManager.ExpressionType
var desired_food_name
var is_ordering: bool = false
var order_timer: float = 0.0
var order_time_limit: float = 3.0  # 點單時間限制
var game_manager: Node
var qte_active: bool = false
var qte_food_index: int = 0
var qte_emojis: Array[String] = ["😊", "😐", "😢", "🍜", "🍢", "🧋", "🦪", "🍚"]
var qte_items: Array = []
var qte_current_item: String = ""
var qte_timer: float = 0.0
var qte_switch_interval: float = 0.5  # 每0.5秒切換一次

signal order_started(customer_id)
signal order_completed(customer_id, success: bool)
signal qte_item_changed(item: String)

func _ready():
	game_manager = get_tree().get_first_node_in_group("GameManager")
	
	# 根據個性決定喜歡的表情
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
	
	# 隨機選擇想要的食物（每個客人只會想要一種食物，在生成時決定）
	var all_foods = [
		GameManager.FoodType.BEEF_NOODLE,
		GameManager.FoodType.STINKY_TOFU,
		GameManager.FoodType.PEARL_MILK_TEA,
		GameManager.FoodType.OYSTER_OMELETTE,
		GameManager.FoodType.BRAISED_PORK
	]
	desired_food = all_foods[randi() % all_foods.size()]
	
	# 準備 QTE 物品列表（混合 emoji 和食物）
	prepare_qte_items()

func prepare_qte_items():
	if not game_manager:
		return
	
	# QTE 只包含客人想要的食物 + 隨機 emoji
	var random_emojis = ["🔥", "❤️", "👀", "💀", "🚗", "🐂", "🔫", "⭐", "💎", "🎯", "🎲", "🎪"]
	desired_food_name = game_manager.get_food_name(desired_food)
	
	qte_items = random_emojis.duplicate()
	qte_items.append(desired_food_name)

func _process(delta):
	if qte_active:
		qte_timer += delta
		if qte_timer >= qte_switch_interval:
			qte_timer = 0.0
			# 切換到下一個物品，但確保最終會顯示正確的食物
			qte_food_index = (qte_food_index + 1) % qte_items.size()
			qte_current_item = qte_items[qte_food_index]
			qte_item_changed.emit(qte_current_item)

func start_order():
	if is_ordering:
		return
	
	is_ordering = true
	qte_active = false
	order_timer = 0.0
	order_started.emit(customer_id)

func start_qte():
	# 開始 QTE，隨機選擇起始位置
	qte_active = true
	qte_timer = 0.0
	qte_food_index = randi() % qte_items.size()
	qte_current_item = qte_items[qte_food_index]
	qte_item_changed.emit(qte_current_item)

func check_qte_success() -> bool:
	# 檢查是否在正確的食物上鬆開
	return qte_current_item == game_manager.get_food_name(desired_food)

func complete_order(player_expression: GameManager.ExpressionType) -> bool:
	is_ordering = false
	qte_active = false
	
	var success = false
	if player_expression == desired_expression:
		success = true
		satisfaction = min(max_satisfaction, satisfaction + 20)
	else:
		satisfaction = max(0, satisfaction - 15)
	
	order_completed.emit(customer_id, success)
	return success

func get_desired_food() -> GameManager.FoodType:
	return desired_food

func get_desired_expression() -> GameManager.ExpressionType:
	return desired_expression

func get_personality() -> GameManager.CustomerPersonality:
	return personality
	
func show_customer_bubble():
	$Bubble.visible = true

func hide_customer_bubble():
	$Bubble.visible = false
	
