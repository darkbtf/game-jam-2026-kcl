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

func add_meal(meal_name):
	order_text_array.append([meal_name, "not ready"])
	for i in range(len(order_text_array)):
		if i >= max_order:
			break
		Orders_Array[i].get_node("MealLabel").text = order_text_array[i][0]

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
