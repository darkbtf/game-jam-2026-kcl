extends Control

# QTE UI 腳本
@onready var bubble_label: Label = $Bubble/Label
@onready var bubble: Control = $Bubble

var customer: Node = null
var is_active: bool = false

func _ready():
	add_to_group("qte_ui")
	bubble.visible = false
	# 設置字體大小為 1.5 倍（假設默認是 20，所以設為 30）
	if bubble_label:
		bubble_label.add_theme_font_size_override("font_size", 30)

func _process(delta):
	if is_active and customer:
		# 更新對話泡泡位置（跟隨客人，顯示在客人上方 10px）
		var camera = get_viewport().get_camera_2d()
		if camera:
			# 將世界座標轉換為屏幕座標
			var world_pos = customer.global_position
			var offset = Vector2(0, -10)  # 上方 10px
			var world_pos_with_offset = world_pos + offset
			# 計算屏幕座標：世界座標相對於相機的位置 + 視口中心
			var viewport_size = get_viewport().get_visible_rect().size
			var camera_pos = camera.global_position
			var screen_pos = world_pos_with_offset - camera_pos + viewport_size / 2
			bubble.position = screen_pos
		else:
			# 如果沒有相機，直接使用世界座標
			var offset = Vector2(0, -10)  # 上方 10px
			bubble.position = customer.position + offset

func show_qte(target_customer: Node):
	customer = target_customer
	is_active = true
	bubble.visible = true
	
	if customer:
		customer.qte_item_changed.connect(_on_qte_item_changed)
		_on_qte_item_changed(customer.qte_current_item)

func hide_qte():
	is_active = false
	bubble.visible = false
	if customer:
		customer.qte_item_changed.disconnect(_on_qte_item_changed)
	customer = null

func _on_qte_item_changed(item: String):
	if bubble_label:
		bubble_label.text = item
