extends AnimatedSprite2D


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		play("open")


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		play("close") # Replace with function body.
