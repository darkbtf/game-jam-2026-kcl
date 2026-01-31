extends Control

# UI 管理器
@onready var san_bar: ProgressBar = $SanBar
@onready var satisfaction_bar: ProgressBar = $SatisfactionBar
@onready var game_over_panel: Control = $GameOverPanel
@onready var player_face_label: Label = $PlayerFacePanel/Label
@onready var player_face_panel: Control = $PlayerFacePanel

var show_viewport_border: bool = true

var game_manager: Node
var player: Node

func _ready():
	# 設置 UI 在暫停時仍能處理輸入
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# 設置所有Label的字體大小為2.5倍
	call_deferred("scale_all_labels")
	
	# 設置 ProgressBar 的顏色
	call_deferred("setup_bar_colors")
	
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
		if not game_manager.overall_satisfaction_changed.is_connected(_on_satisfaction_changed):
			game_manager.overall_satisfaction_changed.connect(_on_satisfaction_changed)
		
		# 初始化顯示
		_on_san_changed(game_manager.player_san)
		_on_satisfaction_changed(game_manager.overall_satisfaction)
	
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
	if player:
		# 確保 player 有 get_current_expression 方法
		pass


func _process(delta):
	# 更新當前時間（秒數）
	
	# 如果需要顯示 viewport 邊界，每幀重繪
	if show_viewport_border:
		queue_redraw()
	
	if player and game_manager:
		var expr = player.get_current_expression()
		var expr_name = game_manager.get_expression_name(expr)
		
		# 更新玩家表情顯示（左下）
		if player_face_label:
			var emoji = get_expression_emoji(expr)
			player_face_label.text = emoji
	elif not game_manager:
		# 如果 game_manager 還沒找到，嘗試重新獲取
		call_deferred("find_game_manager")

func _on_san_changed(new_value: float):
	if san_bar:
		san_bar.value = new_value

func _on_satisfaction_changed(new_value: float):
	if satisfaction_bar:
		satisfaction_bar.value = new_value

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

func setup_bar_colors():
	# 設置 ProgressBar 的填充顏色
	if san_bar:
		san_bar.add_theme_color_override("fill", Color(0.2, 0.8, 0.2))  # 綠色
	if satisfaction_bar:
		satisfaction_bar.add_theme_color_override("fill", Color(0.8, 0.2, 0.2))  # 紅色

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

func get_expression_emoji(expr: GameManager.ExpressionType) -> String:
	match expr:
		GameManager.ExpressionType.HAPPY:
			return "😊"
		GameManager.ExpressionType.NEUTRAL:
			return "😐"
		GameManager.ExpressionType.SAD:
			return "😢"
		_:
			return "😐"

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

func _draw():
	# 繪製 viewport 邊界框線
	if show_viewport_border:
		var viewport_size = get_viewport_rect().size
		var border_color = Color.YELLOW
		var border_width = 2.0
		
		# 繪製四條邊
		# 上邊
		draw_line(Vector2(0, 0), Vector2(viewport_size.x, 0), border_color, border_width)
		# 下邊
		draw_line(Vector2(0, viewport_size.y), Vector2(viewport_size.x, viewport_size.y), border_color, border_width)
		# 左邊
		draw_line(Vector2(0, 0), Vector2(0, viewport_size.y), border_color, border_width)
		# 右邊
		draw_line(Vector2(viewport_size.x, 0), Vector2(viewport_size.x, viewport_size.y), border_color, border_width)
		
		# 繪製中心線（可選，幫助定位）
		var center_color = Color.YELLOW.lerp(Color.TRANSPARENT, 0.5)
		# 垂直中心線
		draw_line(Vector2(viewport_size.x / 2, 0), Vector2(viewport_size.x / 2, viewport_size.y), center_color, 1.0)
		# 水平中心線
		draw_line(Vector2(0, viewport_size.y / 2), Vector2(viewport_size.x, viewport_size.y / 2), center_color, 1.0)
