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
enum MaskType {
	HAPPY,    # 開心
	NEUTRAL,  # 中性
	SAD       # 難過
}

# 客人個性類型
enum CustomerPersonality {
	FRIENDLY,        # 友善 - 喜歡開心表情（舊版，保留兼容）
	NEUTRAL,         # 中性 - 喜歡中性表情（舊版，保留兼容）
	GRUMPY,          # 暴躁 - 喜歡難過表情（舊版，保留兼容）
	LOCAL_AUNTIE,    # 地方阿姨
	SHY_STUDENT,     # 害羞學生
	RUSHED_OFFICE,   # 趕時間上班族
	VLOGGER,         # 奇怪的 vlogger
	RUSHED_DELIVERY  # 飆車外送員
}

# 內場人員類型
enum KitchenStaffType {
	AQIANG,   # 阿強
	KASUMI    # KASUMI
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
	MaskType.HAPPY: "開心",
	MaskType.NEUTRAL: "中性",
	MaskType.SAD: "難過"
}

# 食物資料字典（FoodType -> Food 資源）
var foods: Dictionary = {}

# 表情資料字典（MaskType -> Mask 資源）
var masks: Dictionary = {}

# 客人資料字典（CustomerPersonality -> CustomerData 資源）
var customer_data: Dictionary = {}

# 內場人員資料字典（KitchenStaffType -> KitchenStaffData 資源）
var kitchen_staff_data: Dictionary = {}

# 當前關卡配置
var current_level_config: LevelConfig = null

func _ready():
	add_to_group("game_manager")
	# 初始化五種食物
	initialize_foods()
	# 初始化三種表情
	initialize_masks()
	# 初始化三種客人
	initialize_customers()
	# 初始化內場人員
	initialize_kitchen_staffs()

func initialize_foods():
	# 牛肉麵
	foods[FoodType.BEEF_NOODLE] = Food.new(
		"香濃的牛肉湯配上Q彈的麵條，是台灣經典美食",  # description
		5.0,  # cook_time (秒)
		15.0,  # sanity_recover
		200.0  # throw_distance (像素)
	)
	
	# 臭豆腐
	foods[FoodType.STINKY_TOFU] = Food.new(
		"外酥內嫩的臭豆腐，搭配泡菜和醬汁，風味獨特",  # description
		3.0,  # cook_time (秒)
		10.0,  # sanity_recover
		150.0  # throw_distance (像素)
	)
	
	# 珍珠奶茶
	foods[FoodType.PEARL_MILK_TEA] = Food.new(
		"濃郁的奶茶配上Q彈的珍珠，是台灣最具代表性的飲品",  # description
		2.0,  # cook_time (秒)
		8.0,  # sanity_recover
		300.0  # throw_distance (像素)
	)
	
	# 蚵仔煎
	foods[FoodType.OYSTER_OMELETTE] = Food.new(
		"新鮮的蚵仔配上蛋液和地瓜粉，煎至金黃酥脆",  # description
		4.0,  # cook_time (秒)
		12.0,  # sanity_recover
		180.0  # throw_distance (像素)
	)
	
	# 滷肉飯
	foods[FoodType.BRAISED_PORK] = Food.new(
		"肥瘦相間的滷肉配上白飯，是台灣最受歡迎的平民美食",  # description
		3.5,  # cook_time (秒)
		13.0,  # sanity_recover
		170.0  # throw_distance (像素)
	)

func get_food(food_type: FoodType) -> Food:
	return foods.get(food_type, null)

func initialize_masks():
	# 冷靜專業 (NEUTRAL)
	masks[MaskType.NEUTRAL] = Mask.new(
		"說不上友善，但還在禮貌的範圍內，某些客人反而愛這一味，精神負擔小",  # description
		0.5,  # sanity_drain (每秒)
		"K"   # key
	)
	
	# 營業微笑 (HAPPY)
	masks[MaskType.HAPPY] = Mask.new(
		"服務業的標準答案，絕對的安全牌，除非你遇上了找碴的客人… 精神負擔中",  # description
		1.0,  # sanity_drain (每秒)
		"J"   # key
	)
	
	# 委屈尷尬 (SAD)
	masks[MaskType.SAD] = Mask.new(
		"一般來說是道歉用的表情，躲過憤怒客人客訴的唯一解，但一般的客人可能會跟你一起尷尬。精神負擔大",  # description
		1.5,  # sanity_drain (每秒)
		"L"   # key
	)

func get_mask(mask_type: MaskType) -> Mask:
	return masks.get(mask_type, null)

func _parse_mask_string(mask_str: String) -> Variant:
	match mask_str:
		"營業微笑":
			return MaskType.HAPPY
		"冷靜專業":
			return MaskType.NEUTRAL
		"委屈尷尬":
			return MaskType.SAD
		"無":
			return null
		_:
			return null

func _parse_food_string(food_str: String) -> FoodType:
	match food_str:
		"魯肉飯", "滷肉飯":
			return FoodType.BRAISED_PORK
		"蚵仔煎":
			return FoodType.OYSTER_OMELETTE
		"珍珠奶茶":
			return FoodType.PEARL_MILK_TEA
		"臭豆腐":
			return FoodType.STINKY_TOFU
		"牛肉麵":
			return FoodType.BEEF_NOODLE
		_:
			return FoodType.BEEF_NOODLE  # 默認值

func _parse_dishes_string(dishes_str: String) -> Array[FoodType]:
	var dishes: Array[FoodType] = []
	var dish_list = dishes_str.split("、")
	for dish in dish_list:
		var dish_trimmed = dish.strip_edges()
		if dish_trimmed != "":
			dishes.append(_parse_food_string(dish_trimmed))
	return dishes

func initialize_customers():
	# 友善 (FRIENDLY) - 保留舊版兼容
	customer_data[CustomerPersonality.FRIENDLY] = CustomerData.new(
		"友善的客人，喜歡看到開心的表情，容易滿足",  # description
		MaskType.HAPPY,  # preferred_mask
		null,  # loathed_mask
		0.5,  # talk_speed
		100.0,  # patience_time
		20.0,  # satisfaction_delta_prefer
		-15.0,  # satisfaction_delta_loath
		-10.0,  # satisfaction_delta_fail
		[]  # preferred_dishes
	)
	
	# 中性 (NEUTRAL) - 保留舊版兼容
	customer_data[CustomerPersonality.NEUTRAL] = CustomerData.new(
		"中性的客人，偏好專業冷靜的態度，不喜歡過度熱情",  # description
		MaskType.NEUTRAL,  # preferred_mask
		null,  # loathed_mask
		0.5,  # talk_speed
		100.0,  # patience_time
		20.0,  # satisfaction_delta_prefer
		-15.0,  # satisfaction_delta_loath
		-10.0,  # satisfaction_delta_fail
		[]  # preferred_dishes
	)
	
	# 暴躁 (GRUMPY) - 保留舊版兼容
	customer_data[CustomerPersonality.GRUMPY] = CustomerData.new(
		"暴躁的客人，需要看到委屈尷尬的表情來獲得同情，否則容易不滿",  # description
		MaskType.SAD,  # preferred_mask
		null,  # loathed_mask
		0.5,  # talk_speed
		100.0,  # patience_time
		20.0,  # satisfaction_delta_prefer
		-15.0,  # satisfaction_delta_loath
		-10.0,  # satisfaction_delta_fail
		[]  # preferred_dishes
	)
	
	# 地方阿姨 (LOCAL_AUNTIE)
	customer_data[CustomerPersonality.LOCAL_AUNTIE] = CustomerData.new(
		"友善的中年阿姨，跟主角在路上遇到會打招呼，天使客人，教學關卡只會有他。",  # description
		_parse_mask_string("營業微笑"),  # preferred_mask
		_parse_mask_string("無"),  # loathed_mask
		0.5,  # talk_speed
		120.0,  # patience_time
		10.0,  # satisfaction_delta_prefer
		-10.0,  # satisfaction_delta_loath
		-20.0,  # satisfaction_delta_fail
		_parse_dishes_string("魯肉飯、蚵仔煎")  # preferred_dishes
	)
	
	# 害羞學生 (SHY_STUDENT)
	customer_data[CustomerPersonality.SHY_STUDENT] = CustomerData.new(
		"平常都去點餐機點餐的學生，常常會覺得服務人員很兇",  # description
		_parse_mask_string("營業微笑"),  # preferred_mask
		_parse_mask_string("冷靜專業"),  # loathed_mask
		0.5,  # talk_speed
		60.0,  # patience_time
		10.0,  # satisfaction_delta_prefer
		10.0,  # satisfaction_delta_loath
		-20.0,  # satisfaction_delta_fail
		_parse_dishes_string("珍珠奶茶、臭豆腐、蚵仔煎")  # preferred_dishes
	)
	
	# 趕時間上班族 (RUSHED_OFFICE)
	customer_data[CustomerPersonality.RUSHED_OFFICE] = CustomerData.new(
		"就是趕時間，一直低頭看手機也不會看你的臉，講話很快，只在乎儘快拿到餐點。",  # description
		_parse_mask_string("無"),  # preferred_mask
		_parse_mask_string("無"),  # loathed_mask
		0.35,  # talk_speed
		40.0,  # patience_time
		5.0,  # satisfaction_delta_prefer
		-20.0,  # satisfaction_delta_loath
		-30.0,  # satisfaction_delta_fail
		_parse_dishes_string("魯肉飯、珍珠奶茶")  # preferred_dishes
	)
	
	# 奇怪的 vlogger (VLOGGER)
	customer_data[CustomerPersonality.VLOGGER] = CustomerData.new(
		"拿著自拍棒直播，自我中心喜歡被捧，心血來潮可能會找碴，拿你做效果。",  # description
		_parse_mask_string("委屈尷尬"),  # preferred_mask
		_parse_mask_string("冷靜專業"),  # loathed_mask
		0.4,  # talk_speed
		45.0,  # patience_time
		20.0,  # satisfaction_delta_prefer
		-20.0,  # satisfaction_delta_loath
		-30.0,  # satisfaction_delta_fail
		_parse_dishes_string("牛肉麵、臭豆腐")  # preferred_dishes
	)
	
	# 飆車外送員 (RUSHED_DELIVERY)
	customer_data[CustomerPersonality.RUSHED_DELIVERY] = CustomerData.new(
		"超級趕時間！！！",  # description
		_parse_mask_string("無"),  # preferred_mask
		_parse_mask_string("無"),  # loathed_mask
		0.25,  # talk_speed
		30.0,  # patience_time
		20.0,  # satisfaction_delta_prefer
		-20.0,  # satisfaction_delta_loath
		-30.0,  # satisfaction_delta_fail
		_parse_dishes_string("魯肉飯、珍珠奶茶")  # preferred_dishes
	)

func get_customer_data(personality: CustomerPersonality) -> CustomerData:
	return customer_data.get(personality, null)

func initialize_kitchen_staffs():
	# 阿強 (AQIANG)
	kitchen_staff_data[KitchenStaffType.AQIANG] = KitchenStaffData.new(
		"阿強",  # name
		"有包手的冷靜低敏感廚師，不會介意你催他，但態度友善一點也不壞",  # description
		_parse_dishes_string("魯肉飯、蚵仔煎、牛肉麵"),  # dishes
		_parse_mask_string("營業微笑"),  # preferred_mask
		_parse_mask_string("無")  # loathed_mask
	)
	
	# KASUMI
	kitchen_staff_data[KitchenStaffType.KASUMI] = KitchenStaffData.new(
		"KASUMI",  # name
		"傳說中會使用美味魔法的女僕廚師，要對她溫柔一點喔",  # description
		_parse_dishes_string("珍珠奶茶、臭豆腐"),  # dishes
		_parse_mask_string("委屈尷尬"),  # preferred_mask
		_parse_mask_string("冷靜專業")  # loathed_mask
	)

func get_kitchen_staff_data(staff_type: KitchenStaffType) -> KitchenStaffData:
	return kitchen_staff_data.get(staff_type, null)

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

func get_expression_name(mask_type: MaskType) -> String:
	return expression_names.get(mask_type, "未知表情")

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
