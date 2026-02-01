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
		var offset = Vector2(-120, -100)  # 上方 10px
		bubble.position = customer.position + offset

func show_qte(target_customer: Node):
	customer = target_customer
	is_active = true
	bubble.visible = true
	
	if customer and !customer.order_status:
		customer.hide_customer_bubble()
		customer.qte_item_changed.connect(_on_qte_item_changed)
		_on_qte_item_changed(customer.qte_current_item)

func hide_qte():
	is_active = false
	bubble.visible = false
	if customer and !customer.order_status:
		customer.show_customer_bubble()
		customer.qte_item_changed.disconnect(_on_qte_item_changed)
	customer = null

func _on_qte_item_changed(item: String):
	if bubble_label:
		bubble_label.text = item
