extends CharacterBody2D

# 客人腳本
var personality
@export var satisfaction: float = 50.0
@export var max_satisfaction: float = 100.0

var customer_id: int
# 客人想要的食物（在生成時隨機決定，之後不會改變）
var desired_food: GameManager.FoodType
var desired_expression: GameManager.MaskType
var desired_food_name
var is_ordering: bool = false
var order_timer: float = 0.0
var order_time_limit: float = 3.0  # 點單時間限制
var game_manager: Node
var qte_active: bool = false
var qte_food_index: int = 0
@export var qte_emojis_texture : Array[String]
var qte_items: Array
var qte_current_item: String = ""
var qte_timer: float = 0.0
var qte_switch_interval: float = 0.5  # 每0.5秒切換一次

var order_status = false # 確認是否點餐完畢

signal order_started(customer_id)
signal order_completed(customer_id, success: bool)
signal qte_item_changed(item: String)

func _ready():
	game_manager = GameManager
	
	# 設置客戶圖片
	set_customer_texture()
	
	# 確保所有視覺元素可見並設置正確的 z_index
	
	if has_node("Bubble"):
		var bubble = $Bubble
		bubble.visible = true
		bubble.z_index = 10
		bubble.z_as_relative = false
	
	# 確保 customer 本身可見
	visible = true
	z_index = 0
	z_as_relative = false
	
	# 根據個性決定喜歡的表情
	match personality:
		GameManager.CustomerPersonality.RUSHED_OFFICE:
			desired_expression = GameManager.MaskType.HAPPY
			$Bubble/emoji.texture = load("res://Assets/Emoji/crazy_sign.png")
		GameManager.CustomerPersonality.LOCAL_AUNTIE:
			desired_expression = GameManager.MaskType.NEUTRAL
			$Bubble/emoji.texture = load("res://Assets/Emoji/normal_sign.png")
		GameManager.CustomerPersonality.SHY_STUDENT:
			desired_expression = GameManager.MaskType.SAD
			$Bubble/emoji.texture = load("res://Assets/Emoji/shy_sign.png")
	
	# 隨機選擇想要的食物（每個客人只會想要一種食物，在生成時決定）
	var all_foods = [
		GameManager.FoodType.BEEF_NOODLE,
		GameManager.FoodType.RedTea,
		GameManager.FoodType.FriedRice,
		GameManager.FoodType.BraisedRice,
		GameManager.FoodType.BubbleMilkTea
	]
	
	desired_food = all_foods[randi() % all_foods.size()]
	
	# 準備 QTE 物品列表（混合 emoji 和食物）
	prepare_qte_items()

func prepare_qte_items():
	if not game_manager:
		return
	
	# QTE 只包含客人想要的食物 + 隨機 emoji
	desired_food_name = game_manager.get_food_name(desired_food)
	
	qte_items = qte_emojis_texture.duplicate()
	qte_items.append("res://Assets/Foods/" + desired_food_name + ".png")

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
	return qte_current_item.split("/")[-1] == game_manager.get_food_name(desired_food) + ".png"

func complete_order(player_expression: GameManager.MaskType) -> bool:
	is_ordering = false
	qte_active = false
	order_status = true
	
	var success = false
	if player_expression == desired_expression:
		success = true
		satisfaction = min(max_satisfaction, satisfaction + 10)
	else:
		satisfaction = max(0, satisfaction - 10)
	
	return success

func get_desired_food() -> GameManager.FoodType:
	return desired_food

func get_desired_expression() -> GameManager.MaskType:
	return desired_expression

func get_personality() -> GameManager.CustomerPersonality:
	return personality
	
func show_customer_bubble():
	$Bubble.visible = true

func hide_customer_bubble():
	$Bubble.visible = false

func get_customer_name() -> String:
	# 根據 personality 返回對應的名稱
	match personality:
		GameManager.CustomerPersonality.FRIENDLY:
			return "友善"
		GameManager.CustomerPersonality.NEUTRAL:
			return "中性"
		GameManager.CustomerPersonality.GRUMPY:
			return "暴躁"
		GameManager.CustomerPersonality.LOCAL_AUNTIE:
			return "地方阿姨"
		GameManager.CustomerPersonality.SHY_STUDENT:
			return "害羞學生"
		GameManager.CustomerPersonality.RUSHED_OFFICE:
			return "趕時間上班族"
		GameManager.CustomerPersonality.VLOGGER:
			return "奇怪的 vlogger"
		GameManager.CustomerPersonality.RUSHED_DELIVERY:
			return "飆車外送員"
		_:
			return "客人"

func set_customer_texture():
	# 根據 personality 設置對應的圖片
	var sprite = $AnimatedCustomer
	
	match personality:
		GameManager.CustomerPersonality.LOCAL_AUNTIE:
			sprite.sprite_frames = load("res://Assets/SpriteFrames/一般.tres")
			sprite.play("Right")
		GameManager.CustomerPersonality.SHY_STUDENT:
			sprite.sprite_frames = load("res://Assets/SpriteFrames/害羞.tres")
			sprite.play("Right")
		GameManager.CustomerPersonality.RUSHED_OFFICE:
			sprite.sprite_frames = load("res://Assets/SpriteFrames/奧客.tres")
			sprite.play("Right")
		_:
			# 其他 personality 類型保持默認（不設置圖片或使用默認圖片）
			sprite.sprite_frames = load("res://Assets/SpriteFrames/一般.tres")
			sprite.play("Right")
			print("personality")


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if body.take_status and order_status:
			print("玩家有餐")
			body.to_customer()
			
			if body.take_food[0] == desired_food_name:
				order_completed.emit(customer_id, true)
			else:
				order_completed.emit(customer_id, false)
