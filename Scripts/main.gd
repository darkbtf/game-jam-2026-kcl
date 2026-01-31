extends Node2D

# 主場景腳本
# 從 LevelManager 獲取關卡配置並應用到遊戲系統

var game_manager: GameManager
var queue_manager: Node

func _ready():
	# 獲取 GameManager 和 QueueManager
	game_manager = get_tree().get_first_node_in_group("game_manager")
	queue_manager = get_node("QueueManager")
	
	# 連接 LevelManager 的信號
	if LevelManager:
		LevelManager.level_changed.connect(_on_level_changed)
	
	# 如果 LevelManager 已經有當前關卡配置，直接應用
	if LevelManager and LevelManager.current_level_config:
		apply_level_config(LevelManager.current_level_config)

# 當關卡改變時的回調
func _on_level_changed(level_index: int, level_config: LevelConfig):
	apply_level_config(level_config)

# 應用關卡配置到遊戲系統
func apply_level_config(config: LevelConfig):
	if not config:
		print("警告: 嘗試應用無效的關卡配置")
		return
	
	# 將關卡配置應用到 QueueManager
	if queue_manager:
		queue_manager.level_config = config
		queue_manager.apply_level_config()  # 確保參數被應用
		print("已應用關卡配置到 QueueManager: ", config.level_name)
	
	# 將關卡配置存儲到 GameManager
	if game_manager:
		game_manager.current_level_config = config
