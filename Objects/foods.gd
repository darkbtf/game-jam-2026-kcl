extends Sprite2D

var food_name

func take_food(body: Node2D):
	if body.is_in_group("player"):
		# 之後換成空盤子
		texture = null
		body.take_food(food_name)
