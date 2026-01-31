class_name CustomerSpawnConfig
extends Resource

# 客人生成配置
# 用於定義在關卡中某種客人類型的出現頻率
@export var personality: GameManager.CustomerPersonality  # 客人個性類型
@export var spawn_weight: float = 1.0  # 生成權重（頻率），數值越大出現機率越高

func _init(p_personality: GameManager.CustomerPersonality = GameManager.CustomerPersonality.FRIENDLY, p_spawn_weight: float = 1.0):
	personality = p_personality
	spawn_weight = p_spawn_weight
