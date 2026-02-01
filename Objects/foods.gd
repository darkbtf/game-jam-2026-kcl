extends Sprite2D

var food_name = ""
var order_number

func take_food(body: Node2D):
	if body.is_in_group("player"):
		if !body.take_status:
			# 之後換成空盤子
			texture = null
			body.take_it(food_name, order_number)
