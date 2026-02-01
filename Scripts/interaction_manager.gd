extends Node

# 交互管理器 - 處理玩家與客人的交互
var player: Node
var qte_ui: Node
var current_customer: Node = null
var is_interacting: bool = false

signal create_order(meal_name)


func _ready():
	# 延遲獲取節點，確保場景已載入
	call_deferred("setup_nodes")

func setup_nodes():
	player = get_tree().get_first_node_in_group("player")
	qte_ui = get_tree().get_first_node_in_group("qte_ui")

func _process(delta):
	if not player:
		return
	
	# 檢查玩家是否靠近客人
	var nearby_customer = find_nearby_customer()
	
	if nearby_customer and (Input.is_action_just_pressed("expression_happy") or \
	   Input.is_action_just_pressed("expression_neutral") or \
	   Input.is_action_just_pressed("expression_sad")):
		# 開始與客人交互
		start_interaction(nearby_customer)
	
	# 處理 QTE
	if is_interacting and current_customer:
		# 檢查是否鬆開表情鍵
		if Input.is_action_just_released("expression_happy") or \
		   Input.is_action_just_released("expression_neutral") or \
		   Input.is_action_just_released("expression_sad"):
			complete_interaction()

func find_nearby_customer() -> Node:
	var queue_manager = get_node("../QueueManager")
	if not queue_manager:
		return null
	
	var min_distance = 100.0
	var closest_customer = null
	
	for customer in queue_manager.customers:
		var distance = player.position.distance_to(customer.position)
		if distance < min_distance and !customer.order_status:
			min_distance = distance
			closest_customer = customer
	
	return closest_customer

func start_interaction(customer: Node):
	if is_interacting:
		return
	
	current_customer = customer
	is_interacting = true
	
	# 開始客人的點單流程
	if not customer.is_ordering:
		customer.start_order()
	
	# 開始 QTE
	customer.start_qte()
	if qte_ui:
		qte_ui.show_qte(customer)

func complete_interaction():
	if not is_interacting or not current_customer:
		return
	
	var player_expression = player.get_current_expression()
	var success = current_customer.check_qte_success()
	
	
	if success:
		# QTE 成功，完成訂單
		current_customer.complete_order(player_expression)
		emit_signal("create_order", current_customer.desired_food_name)
	else:
		# QTE 失敗，降低滿意度
		current_customer.satisfaction = max(0, current_customer.satisfaction - 10)
	
	# 結束交互
	is_interacting = false
	current_customer = null
	
	if qte_ui:
		qte_ui.hide_qte()
