class_name CustomerData
extends Resource

# 客人資料資源類
@export var description: String = ""  # 描述
@export var preferred_mask: Variant = null  # 喜歡的表情（null 表示無，類型為 MaskType）
@export var loathed_mask: Variant = null  # 討厭的表情（null 表示無，類型為 MaskType）
@export var talk_speed: float = 0.5  # 說話速度
@export var patience_time: float = 120.0  # 耐心時間（秒）
@export var satisfaction_delta_prefer: float = 10.0  # 使用喜歡表情的滿意度變化
@export var satisfaction_delta_loath: float = -10.0  # 使用討厭表情的滿意度變化
@export var satisfaction_delta_fail: float = -20.0  # QTE 失敗的滿意度變化
@export var preferred_dishes: Array[GameManager.FoodType] = []  # 喜歡的食物列表

func _init(
	p_description: String = "",
	p_preferred_mask: Variant = null,
	p_loathed_mask: Variant = null,
	p_talk_speed: float = 0.5,
	p_patience_time: float = 120.0,
	p_satisfaction_delta_prefer: float = 10.0,
	p_satisfaction_delta_loath: float = -10.0,
	p_satisfaction_delta_fail: float = -20.0,
	p_preferred_dishes: Array[GameManager.FoodType] = []
):
	description = p_description
	preferred_mask = p_preferred_mask
	loathed_mask = p_loathed_mask
	talk_speed = p_talk_speed
	patience_time = p_patience_time
	satisfaction_delta_prefer = p_satisfaction_delta_prefer
	satisfaction_delta_loath = p_satisfaction_delta_loath
	satisfaction_delta_fail = p_satisfaction_delta_fail
	preferred_dishes = p_preferred_dishes
