extends Control

@export var Orders_Array : Array[Control]

var order_number = 0
var order_text_array: Array[String]
@export var max_order = 3

var make_number = 0

func _ready():
	var interactionManager = get_tree().get_first_node_in_group("interactionManager")
	interactionManager.create_order.connect(add_meal)

func add_meal(meal_name):
	order_text_array.append(meal_name)
	
	for i in range(len(order_text_array)):
		if i >= max_order:
			break
		Orders_Array[i].get_node("MealLabel").text = order_text_array[i]

func del_meal():
	return
	
func update_prepare_status(number, status):
	return
