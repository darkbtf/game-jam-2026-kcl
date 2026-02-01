extends Control

@export var Orders_Array : Array[Control]

var order_number = 0
var order_text_array: Array[Array]
@export var max_order = 3

var make_number = 0

func _ready():
	var interactionManager = get_tree().get_first_node_in_group("interactionManager")
	interactionManager.create_order.connect(add_meal)
	
	var kitchenStaffs = get_tree().get_nodes_in_group("staff")
	for k in kitchenStaffs:
		k.order_status_change.connect(update_prepare_status)
	
	clear_orders()
	
func check_empty_meal():
	# 都是空的
	if order_text_array.count([null, "not meal"]) >= max_order:
		return false
	else:
		return true

func add_meal(meal_name):
	for i in range(len(order_text_array)):
		if order_text_array[i][0] == null:
			order_text_array[i] = [meal_name, "not ready"]
			Orders_Array[i].get_node("Meal").texture = load("res://Assets/Foods/" + order_text_array[i][0] + ".png")
			return true
	print("餐點已滿")
	return false
	
func del_meal():
	return

func check_order_cook_status(number):
	if number >= len(order_text_array):
		return "no order"
	return order_text_array[number][1]

	
func update_prepare_status(number, status):
	if make_number >= max_order -1:
		make_number = max_order - 1
	elif make_number < 0:
		make_number = 0
	
	match status:
		"prepare":
			Orders_Array[number].get_node("AnimatedSprite2D").play("cooking")
			order_text_array[number][1] = "cooking"
			make_number +=1
		"finish":
			Orders_Array[number].get_node("AnimatedSprite2D").play("finish")
			order_text_array[number][1] = "finish"
		"del":
			Orders_Array[number].get_node("AnimatedSprite2D").play("stay")
			make_number -= 1

# 清空所有訂單
func clear_orders():
	order_text_array.clear()
	for i in range(max_order):
		order_text_array.append([null, "not meal"])
		
	order_number = 0
	make_number = 0
	# 重置所有訂單顯示
	for order_control in Orders_Array:
		if order_control and order_control.has_node("Meal"):
			order_control.get_node("Meal").texture = null
		if order_control and order_control.has_node("AnimatedSprite2D"):
			order_control.get_node("AnimatedSprite2D").play("stay")
	print("已清空訂單")
