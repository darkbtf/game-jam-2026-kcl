extends Control

# 表情面板腳本 - 用於繪製框線
func _draw():
	# 繪製白色框線
	var border_width = 2.0
	var rect = Rect2(Vector2.ZERO, size)
	draw_rect(rect, Color.WHITE, false, border_width)
