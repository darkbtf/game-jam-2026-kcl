class_name LevelConfig
extends Resource

# 關卡配置資源類
# 定義關卡的各種參數，包括關卡名稱和客人生成配置
@export var level_name: String = ""  # 關卡名稱
@export var customer_spawn_configs: Array[CustomerSpawnConfig] = []  # 客人生成配置列表
@export var spawn_interval: float = 5.0  # 客人生成間隔（秒）
@export var max_customers: int = 3  # 最大客人數量
@export var duration: float = 120.0  # 關卡持續時間（秒）

func _init(
	p_level_name: String = "",
	p_customer_spawn_configs: Array[CustomerSpawnConfig] = [],
	p_spawn_interval: float = 5.0,
	p_max_customers: int = 3,
	p_duration: float = 120.0
):
	level_name = p_level_name
	customer_spawn_configs = p_customer_spawn_configs
	spawn_interval = p_spawn_interval
	max_customers = p_max_customers
	duration = p_duration

# 根據權重隨機選擇一個客人類型
func get_random_customer_personality() -> GameManager.CustomerPersonality:
	if customer_spawn_configs.is_empty():
		# 如果沒有配置，返回默認值
		return GameManager.CustomerPersonality.FRIENDLY
	
	# 計算總權重
	var total_weight: float = 0.0
	for config in customer_spawn_configs:
		total_weight += config.spawn_weight
	
	if total_weight <= 0.0:
		# 如果總權重為0或負數，返回第一個配置的類型
		return customer_spawn_configs[0].personality
	
	# 隨機選擇
	var random_value = randf() * total_weight
	var current_weight: float = 0.0
	
	for config in customer_spawn_configs:
		current_weight += config.spawn_weight
		if random_value <= current_weight:
			return config.personality
	
	# 如果沒有匹配到（理論上不應該發生），返回最後一個
	return customer_spawn_configs[-1].personality
