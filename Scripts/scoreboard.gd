extends Control

# Scoreboard 場景
# 在關卡結束時顯示，覆蓋整個屏幕

func _ready():
	# 設置 UI 在暫停時仍能處理輸入
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# 連接 LevelManager 的信號
	if LevelManager:
		if not LevelManager.level_state_changed.is_connected(_on_level_state_changed):
			LevelManager.level_state_changed.connect(_on_level_state_changed)
		if not LevelManager.level_time_up.is_connected(_on_level_time_up):
			LevelManager.level_time_up.connect(_on_level_time_up)

func _on_level_state_changed(state):
	# 當關卡狀態變為完成時顯示 scoreboard
	if state == LevelManager.LevelState.COMPLETED:
		show_scoreboard()

func _on_level_time_up():
	# 當關卡時間到時顯示 scoreboard
	show_scoreboard()

func show_scoreboard():
	visible = true
	# 可以選擇暫停遊戲
	# get_tree().paused = true

func hide_scoreboard():
	visible = false
	# 如果暫停了遊戲，記得取消暫停
	# get_tree().paused = false
