extends Control

# UI 管理器
@onready var san_bar: TextureProgressBar = $SanBar
@onready var time_bar: TextureProgressBar = $timeBar
@onready var game_over_panel: Control = $GameOverPanel
@onready var player_face_panel: Control = $PlayerFacePanel
@onready var player_face: Sprite2D = $PlayerFacePanel/Face

var show_viewport_border: bool = true

var game_manager: Node
var player: Node

func _ready():
	# 設置 UI 在暫停時仍能處理輸入
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# 設置所有Label的字體大小為2.5倍
	call_deferred("scale_all_labels")
	
	# 延遲獲取 game_manager，確保場景已載入
	call_deferred("find_game_manager")

func find_game_manager():
	game_manager = get_tree().get_first_node_in_group("game_manager")
	
	if game_manager:
		# 連接信號（如果還沒連接）
		if not game_manager.san_changed.is_connected(_on_san_changed):
			game_manager.san_changed.connect(_on_san_changed)
		if not game_manager.game_over.is_connected(_on_game_over):
			game_manager.game_over.connect(_on_game_over)
		if not game_manager.time_changed.is_connected(_on_time_changed):
			game_manager.time_changed.connect(_on_time_changed)
		
		# 初始化顯示
		_on_san_changed(100)
		_on_time_changed(100)
	
	# 延遲獲取 player，因為可能還沒創建
	call_deferred("find_player")

func find_player():
	# UI 在 CanvasLayer 下，Player 在 Main 下
	# 所以路径应该是 ../../Player
	player = get_node("../../Player")
	if not player:
		player = get_node("../Player")
	if not player:
		player = get_tree().get_first_node_in_group("player")
	if player and game_manager:
		# 初始化玩家表情顯示
		var expr = player.get_current_expression()
		var is_expressing = player.is_expressing()
		update_player_face_texture(expr, is_expressing)


func _process(delta):
	# 更新當前時間（秒數）
	
	# 如果需要顯示 viewport 邊界，每幀重繪
	if show_viewport_border:
		queue_redraw()
	
	if player and game_manager:
		var expr = player.get_current_expression()
		var expr_name = game_manager.get_expression_name(expr)
		var is_expressing = player.is_expressing()
		
		# 更新玩家表情顯示（使用圖片）
		update_player_face_texture(expr, is_expressing)
	elif not game_manager:
		# 如果 game_manager 還沒找到，嘗試重新獲取
		call_deferred("find_game_manager")

func _on_san_changed(new_value: float):
	if san_bar:
		san_bar.value = new_value

func _on_time_changed(new_value: float):
	if time_bar:
		time_bar.value = new_value

func set_player(player_node: Node):
	player = player_node

func _on_game_over():
	if game_over_panel:
		game_over_panel.visible = true
	# 暫停遊戲
	get_tree().paused = true

func _input(event):
	# 遊戲結束後按 R 鍵重新開始
	if game_over_panel and game_over_panel.visible:
		if event.is_action_pressed("ui_accept") or (event is InputEventKey and event.pressed and event.keycode == KEY_R):
			restart_game()

func restart_game():
	# 取消暫停
	get_tree().paused = false
	# 重新載入場景
	get_tree().reload_current_scene()

func scale_all_labels():
	# 遞歸設置所有Label的字體大小
	_set_label_font_size(self)

func _set_label_font_size(node: Node):
	if node is Label:
		var label = node as Label
		# 獲取當前字體大小，如果沒有設置則使用默認值16
		var current_size = label.get_theme_font_size("font_size")
		if current_size == 0:
			current_size = 16
		
		# 檢查是否在 ControlsPanel 下，如果是則使用一半大小（1.25倍），否則使用2.5倍
		var is_in_controls_panel = false
		var parent = node.get_parent()
		while parent:
			if parent.name == "ControlsPanel":
				is_in_controls_panel = true
				break
			parent = parent.get_parent()
		
		if is_in_controls_panel:
			# ControlsPanel 中的 Label 使用 1.25 倍（2.5 * 0.5）
			label.add_theme_font_size_override("font_size", int(current_size * 1.25))
		else:
			# 其他 Label 使用 2.5 倍
			label.add_theme_font_size_override("font_size", int(current_size * 2.5))
	
	# 遞歸處理所有子節點
	for child in node.get_children():
		_set_label_font_size(child)

func get_expression_emoji(expr: GameManager.MaskType) -> String:
	match expr:
		GameManager.MaskType.HAPPY:
			return "😊"
		GameManager.MaskType.NEUTRAL:
			return "😐"
		GameManager.MaskType.SAD:
			return "😢"
		_:
			return "😐"

func update_player_face_texture(expr: GameManager.MaskType, is_expressing: bool):
	var texture_path: String = ""
	
	# 如果沒做表情，顯示 idle
	if not is_expressing:
		texture_path = "res://Assets/face_normal.png"
	else:
		# 根據表情顯示對應的圖片
		match expr:
			GameManager.MaskType.HAPPY:
				texture_path = "res://Assets/face_happy.png"
			GameManager.MaskType.NEUTRAL:
				texture_path = "res://Assets/face_normal.png"
			GameManager.MaskType.SAD:
				texture_path = "res://Assets/face_sad.png"
			_:
				texture_path = "res://Assets/face_normal.png"
	
	if texture_path != "":
		var texture = load(texture_path)
		if texture:
			player_face.texture = texture
		else:
			print("無法載入玩家表情圖片: ", texture_path)

func find_nearby_target() -> Node:
	if not player:
		return null
	
	var interaction_range = 100.0
	var closest_target = null
	var min_distance = interaction_range
	
	# 檢查客人（UI 在 CanvasLayer 下，所以需要 ../../QueueManager）
	var queue_manager = get_node_or_null("../../QueueManager")
	if queue_manager and "customers" in queue_manager:
		for customer in queue_manager.customers:
			if customer:
				var distance = player.position.distance_to(customer.position)
				if distance < min_distance:
					min_distance = distance
					closest_target = customer
	
	# 檢查內場人員
	var kitchen_staff_1 = get_node_or_null("../../KitchenStaff1")
	var kitchen_staff_2 = get_node_or_null("../../KitchenStaff2")
	
	for staff in [kitchen_staff_1, kitchen_staff_2]:
		if staff:
			var distance = player.position.distance_to(staff.position)
			if distance < min_distance:
				min_distance = distance
				closest_target = staff
	
	return closest_target
