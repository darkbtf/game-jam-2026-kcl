extends Control

# QTE UI 腳本
@onready var bubble_label: Label = $Bubble/Label
@onready var bubble: Control = $Bubble

var customer: Node = null
var is_active: bool = false

func _ready():
	add_to_group("qte_ui")
	bubble.visible = false

func _process(delta):
	if is_active and customer:
		# 更新對話泡泡位置（跟隨客人）
		var camera = get_viewport().get_camera_2d()
		if camera:
			var camera_pos = camera.get_screen_center_position()
			var offset = Vector2(0, -80)
			var world_pos = customer.position + offset
			var screen_pos = camera.to_local(world_pos)
			bubble.position = screen_pos
		else:
			# 如果沒有相機，直接使用世界座標
			var offset = Vector2(0, -80)
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
