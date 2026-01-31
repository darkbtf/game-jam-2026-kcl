class_name Food
extends Resource

# 食物資源類
@export var description: String = ""  # 描述
@export var cook_time: float = 0.0  # 製作時間（秒）
@export var sanity_recover: float = 0.0  # 吃掉回 san
@export var throw_distance: float = 0.0  # 可以丟的距離（像素）

func _init(p_description: String = "", p_cook_time: float = 0.0, p_sanity_recover: float = 0.0, p_throw_distance: float = 0.0):
	description = p_description
	cook_time = p_cook_time
	sanity_recover = p_sanity_recover
	throw_distance = p_throw_distance
