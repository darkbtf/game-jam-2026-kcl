extends Sprite2D

func take_food(body: Node2D):
	if body.is_in_group("player"):
		# 之後換成空盤子
		texture = null
