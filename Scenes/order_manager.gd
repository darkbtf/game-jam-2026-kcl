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
	order_text_array.append([meal_name, false])
	for i in range(len(order_text_array)):
		if i >= max_order:
			break
		Orders_Array[i].get_node("MealLabel").text = order_text_array[i][0]

func del_meal():
	return

func check_order__cook_status(number):
	if order_text_array[number][1]:
		return false
	else:
		order_text_array[number][1] = true
		return true
	
func update_prepare_status(number, status):
	if make_number >= make_number:
		make_number = make_number
	elif make_number < 0:
		make_number = 0
	
	match status:
		"prepare":
			Orders_Array[number].get_node("StatusLabel").text = status
			make_number +=1
		"finish":
			Orders_Array[number].get_node("StatusLabel").text = status
		"del":
			make_number -= 1
