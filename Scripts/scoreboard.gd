extends Control

# Scoreboard 場景
# 在關卡結束時顯示，覆蓋整個屏幕

@onready var win_content: Control = $WinContent
@onready var lose_content: Control = $LoseContent
@onready var level_digit1_label: Label = $LevelDigit1Label
@onready var level_digit2_label: Label = $LevelDigit2Label
@onready var good_count_label: Label = $WinContent/GoodCountLabel
@onready var bad_count_label: Label = $WinContent/BadCountLabel

func _ready():
	# 設置 UI 在暫停時仍能處理輸入
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# 連接 LevelManager 的信號
	if LevelManager:
		if not LevelManager.level_state_changed.is_connected(_on_level_state_changed):
			LevelManager.level_state_changed.connect(_on_level_state_changed)
		if not LevelManager.level_changed.is_connected(_on_level_changed):
			LevelManager.level_changed.connect(_on_level_changed)
	
	# 初始化顯示當前關卡
	update_level_display()
	
	# 初始化 Content 的顯示狀態
	if LevelManager:
		update_content_visibility()

func _on_level_state_changed(state):
	# 當關卡狀態變為完成或失敗時顯示 scoreboard
	if state == LevelManager.LevelState.COMPLETED or state == LevelManager.LevelState.FAILED:
		show_scoreboard()
	else:
		hide_scoreboard()

func show_scoreboard():
	visible = true
	# 根據是否成功過關來顯示對應的 Content
	if LevelManager:
		update_content_visibility()
		update_customer_counts()
	# 可以選擇暫停遊戲
	# get_tree().paused = true

func hide_scoreboard():
	visible = false
	# 如果暫停了遊戲，記得取消暫停
	# get_tree().paused = false

func _on_level_changed(level_index: int, level_config: LevelConfig):
	update_level_display()

func update_level_display():
	if LevelManager:
		var current_level = LevelManager.current_level_index
		if current_level >= 0:
			# 使用零填充格式（例如 "01", "02"）
			var level_str = "%02d" % (current_level + 1)
			if level_digit1_label:
				level_digit1_label.text = level_str[0]
			if level_digit2_label:
				level_digit2_label.text = level_str[1]
		else:
			if level_digit1_label:
				level_digit1_label.text = "0"
			if level_digit2_label:
				level_digit2_label.text = "0"

func update_content_visibility():
	if LevelManager:
		var is_success = LevelManager.current_state == LevelManager.LevelState.COMPLETED
		if win_content:
			win_content.visible = is_success
		if lose_content:
			lose_content.visible = not is_success

func update_customer_counts():
	if LevelManager:
		if good_count_label:
			good_count_label.text = str(LevelManager.customers_served_successfully)
		if bad_count_label:
			bad_count_label.text = str(LevelManager.customers_unserved)
