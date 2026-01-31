extends Node2D

# 排隊管理器
@export var customer_scene: PackedScene
@export var spawn_interval: float = 5.0
@export var max_customers: int = 3
@export var level_config: LevelConfig  # 關卡配置

var spawn_timer: float = 3.5
var customers: Array[Node] = []
var customer_counter: int = 0
var queue_positions: Array[Vector2] = []
var satisfaction_update_timer: float = 0.0
var satisfaction_update_interval: float = 0.5  # 每0.5秒更新一次滿意度
var game_manager: Node

func _ready():
	# 獲取遊戲管理器
	game_manager = get_tree().get_first_node_in_group("game_manager")
	
	# 應用關卡配置（如果有的話）
	apply_level_config()
	
	# 設置排隊位置（左側1/4，從上到下）
	# 窗口大小1280x720，右邊1/4是960-1280
	# 使用x=1120（右邊1/4的中間位置）
	for i in range(max_customers):
		queue_positions.append(Vector2(270, 270 + i * 120))

# 應用關卡配置（可以在運行時調用來動態切換關卡）
func apply_level_config():
	if level_config:
		spawn_interval = level_config.spawn_interval
		max_customers = level_config.max_customers
		# 重新計算排隊位置（如果 max_customers 改變了）
		queue_positions.clear()
		for i in range(max_customers):
			queue_positions.append(Vector2(270, 270 + i * 120))

func _process(delta):
	spawn_timer += delta
	satisfaction_update_timer += delta
	
	# 定期生成新客人
	if spawn_timer >= spawn_interval and customers.size() < max_customers:
		spawn_customer()
		spawn_timer = 0.0
	
	# 定期更新全局滿意度
	if satisfaction_update_timer >= satisfaction_update_interval:
		if game_manager:
			game_manager.update_overall_satisfaction(customers)
		satisfaction_update_timer = 0.0

func spawn_customer():
	if not customer_scene:
		return
		
	var customer = customer_scene.instantiate()
	customer_counter += 1
	customer.customer_id = customer_counter
	
	# 根據關卡配置分配個性
	if level_config and not level_config.customer_spawn_configs.is_empty():
		# 使用關卡配置中的權重系統來選擇客人類型
		customer.personality = level_config.get_random_customer_personality()
	else:
		# 如果沒有關卡配置，使用默認的隨機分配
		if not game_manager:
			# 如果 game_manager 還沒初始化，延遲獲取
			game_manager = get_tree().get_first_node_in_group("game_manager")
		
		if game_manager:
			var personalities = [
				GameManager.CustomerPersonality.FRIENDLY,
				GameManager.CustomerPersonality.NEUTRAL,
				GameManager.CustomerPersonality.GRUMPY
			]
			customer.personality = personalities[randi() % personalities.size()]
		else:
			# 如果還是找不到 game_manager，使用默認值
			customer.personality = GameManager.CustomerPersonality.NEUTRAL
	
	# 設置位置
	var queue_index = customers.size()
	if queue_index < queue_positions.size():
		customer.position = queue_positions[queue_index]
	else:
		customer.position = Vector2(270, 270)
	
	# 確保 customer 可見
	customer.visible = true
	
	add_child(customer)
	customers.append(customer)
	
	# 連接信號
	customer.order_completed.connect(_on_customer_order_completed)

func _on_customer_order_completed(customer_id: int, success: bool):
	# 移除完成的客人
	for i in range(customers.size()):
		if customers[i].customer_id == customer_id:
			customers[i].queue_free()
			customers.remove_at(i)
			# 重新排列剩餘客人
			rearrange_customers()
			break

func rearrange_customers():
	for i in range(customers.size()):
		if i < queue_positions.size():
			customers[i].position = queue_positions[i]

# 清空隊列（移除所有客人）
func clear_queue():
	for customer in customers:
		if is_instance_valid(customer):
			customer.queue_free()
	customers.clear()
	spawn_timer = 0.0
	satisfaction_update_timer = 0.0
