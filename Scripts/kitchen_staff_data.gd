class_name KitchenStaffData
extends Resource

# 內場人員資料資源類
@export var name: String = ""  # 名稱
@export var description: String = ""  # 描述
@export var dishes: Array[GameManager.FoodType] = []  # 可製作的食物列表
@export var preferred_mask: Variant = null  # 喜歡的表情（null 表示無，類型為 MaskType）
@export var loathed_mask: Variant = null  # 討厭的表情（null 表示無，類型為 MaskType）

func _init(
	p_name: String = "",
	p_description: String = "",
	p_dishes: Array[GameManager.FoodType] = [],
	p_preferred_mask: Variant = null,
	p_loathed_mask: Variant = null
):
	name = p_name
	description = p_description
	dishes = p_dishes
	preferred_mask = p_preferred_mask
	loathed_mask = p_loathed_mask
