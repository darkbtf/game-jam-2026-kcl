class_name Mask
extends Resource

# 表情資源類
@export var description: String = ""  # 描述
@export var sanity_drain: float = 0.0  # 每秒消耗的 san 值
@export var key: String = ""  # 對應的按鍵

func _init(p_description: String = "", p_sanity_drain: float = 0.0, p_key: String = ""):
	description = p_description
	sanity_drain = p_sanity_drain
	key = p_key
