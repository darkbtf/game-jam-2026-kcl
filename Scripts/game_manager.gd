class_name GameManager
extends Node

# 遊戲管理器
signal san_changed(new_value)
signal customer_satisfaction_changed(customer_id, new_value)
signal order_completed(customer_id, success: bool)
signal game_over()
signal overall_satisfaction_changed(new_value)

# 遊戲狀態
var player_san: float = 100.0
var max_san: float = 100.0
var san_drain_rate: float = 2.0  # 每秒掉多少 san
var is_game_over: bool = false

# 全局滿意度
var overall_satisfaction: float = 50.0
var max_satisfaction: float = 100.0

# 食物類型（台灣在地風格）
enum FoodType {
	BEEF_NOODLE,      # 牛肉麵
	STINKY_TOFU,      # 臭豆腐
	PEARL_MILK_TEA,   # 珍珠奶茶
	OYSTER_OMELETTE,  # 蚵仔煎
	BRAISED_PORK      # 滷肉飯
}

# 表情類型
enum ExpressionType {
	HAPPY,    # 開心
	NEUTRAL,  # 中性
	SAD       # 難過
}

# 客人個性類型
enum CustomerPersonality {
	FRIENDLY,   # 友善 - 喜歡開心表情
	NEUTRAL,    # 中性 - 喜歡中性表情
	GRUMPY      # 暴躁 - 喜歡難過表情（需要同情）
}

# 內場人員
var kitchen_staff_1_food: Array[FoodType] = [FoodType.BEEF_NOODLE, FoodType.STINKY_TOFU, FoodType.PEARL_MILK_TEA]
var kitchen_staff_2_food: Array[FoodType] = [FoodType.OYSTER_OMELETTE, FoodType.BRAISED_PORK]

# 食物名稱
var food_names = {
	FoodType.BEEF_NOODLE: "牛肉麵",
	FoodType.STINKY_TOFU: "臭豆腐",
	FoodType.PEARL_MILK_TEA: "珍珠奶茶",
	FoodType.OYSTER_OMELETTE: "蚵仔煎",
	FoodType.BRAISED_PORK: "滷肉飯"
}

# 表情名稱
var expression_names = {
	ExpressionType.HAPPY: "開心",
	ExpressionType.NEUTRAL: "中性",
	ExpressionType.SAD: "難過"
}

func _ready():
	add_to_group("game_manager")

func drain_san(amount: float):
	if is_game_over:
		return
	
	player_san = max(0, player_san - amount)
	san_changed.emit(player_san)
	
	# 檢查遊戲結束
	if player_san <= 0 and not is_game_over:
		is_game_over = true
		game_over.emit()

func restore_san(amount: float):
	player_san = min(max_san, player_san + amount)
	san_changed.emit(player_san)

func get_food_name(food_type: FoodType) -> String:
	return food_names.get(food_type, "未知食物")

func get_expression_name(expr_type: ExpressionType) -> String:
	return expression_names.get(expr_type, "未知表情")

func update_overall_satisfaction(customers: Array):
	# 計算所有客人的平均滿意度
	if customers.is_empty():
		# 如果沒有客人，滿意度緩慢下降
		overall_satisfaction = max(0, overall_satisfaction - 0.1)
	else:
		var total_satisfaction = 0.0
		var valid_customers = 0
		for customer in customers:
			if customer and "satisfaction" in customer:
				total_satisfaction += customer.satisfaction
				valid_customers += 1
		
		if valid_customers > 0:
			overall_satisfaction = total_satisfaction / valid_customers
		else:
			overall_satisfaction = max(0, overall_satisfaction - 0.1)
		
		overall_satisfaction = clamp(overall_satisfaction, 0, max_satisfaction)
	
	overall_satisfaction_changed.emit(overall_satisfaction)
