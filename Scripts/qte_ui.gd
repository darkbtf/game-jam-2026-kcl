extends Control

# QTE UI 腳本
@onready var bubble_emoji = $Bubble/emoji
@onready var bubble: Control = $Bubble

var customer: Node = null
var is_active: bool = false

func _ready():
	add_to_group("qte_ui")
	bubble.visible = false

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
	bubble_emoji.texture = load(item)
