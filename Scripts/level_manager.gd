extends Node

# 關卡管理器 (Autoload)
# 負責管理所有關卡配置、狀態和切換邏輯

# 關卡狀態
enum LevelState {
	NOT_STARTED,  # 未開始
	LOADING,      # 載入中
	PLAYING,      # 進行中
	PAUSED,       # 暫停
	COMPLETED,    # 完成
	FAILED        # 失敗
}

signal level_changed(level_index: int, level_config: LevelConfig)
signal level_state_changed(state: LevelState)
signal level_time_updated(remaining_time: float)  # 關卡剩餘時間更新
signal level_time_up()  # 關卡時間到
signal game_over()  # 遊戲結束（san 值歸零時觸發）

# 所有關卡配置列表（在初始化時載入）
var levels: Array[LevelConfig] = []

# 當前關卡索引
var current_level_index: int = -1

# 當前關卡配置
var current_level_config: LevelConfig = null

# 當前關卡狀態
var current_state: LevelState = LevelState.NOT_STARTED

# 關卡計時器
var level_timer: float = 0.0
var level_duration: float = 0.0

# 關卡統計
var customers_served_successfully: int = 0  # 成功服務的客人數量
var customers_unserved: int = 0  # 未服務的客人數量

# BGM 播放器
var bgm_player: AudioStreamPlayer
var active_bgm_path = "res://Assets/BGM/GGJ2026_Snack Bar Active 10.ogg"
var resting_bgm_path = "res://Assets/BGM/GGJ2026_Snack Bar Resting2.ogg"

# BGM 音量設置（0.0 到 1.0）
var bgm_volume: float = 1.0

func _ready():
	# 初始化 BGM 播放器
	bgm_player = AudioStreamPlayer.new()
	add_child(bgm_player)
	
	# 載入保存的音量設置
	load_volume_settings()
	
	# 應用音量設置
	apply_bgm_volume()
	
	# 初始化時載入所有關卡配置
	initialize_levels()
	
	# 等待一幀，確保場景樹完全載入
	await get_tree().process_frame
	
	# 連接 game_manager 的 san_changed 信號
	call_deferred("connect_game_manager_signals")
	
	# 如果直接進入 MainScene，自動載入 level 0
	# 如果之後有 MenuScene，可以在 MenuScene 中手動調用 start_level(0)
	var current_scene = get_tree().current_scene
	if current_scene and current_scene.scene_file_path == "res://Scenes/main.tscn":
		start_level(0)

# 初始化所有關卡配置
func initialize_levels():
	# 創建所有關卡配置
	# 可以在這裡定義所有關卡，或者之後擴展為從其他地方載入
	
	# Level 0: 教學關卡（只有地方阿姨）- 90秒
	var level0 = LevelConfig.new()
	level0.level_name = "教學關卡"
	level0.spawn_interval = 8.0
	level0.max_customers = 2
	level0.duration = 60.0
	
	var auntie_config = CustomerSpawnConfig.new(
		GameManager.CustomerPersonality.LOCAL_AUNTIE,
		1.0
	)
	level0.customer_spawn_configs.append(auntie_config)
	levels.append(level0)
	
	# Level 1: 基礎關卡（三種基本客人）- 120秒
	var level1 = LevelConfig.new()
	level1.level_name = "基礎關卡"
	level1.spawn_interval = 5.0
	level1.max_customers = 3
	level1.duration = 120.0
	
	var shy_student_config = CustomerSpawnConfig.new(
		GameManager.CustomerPersonality.SHY_STUDENT,
		1.0
	)
	var friendly_config = CustomerSpawnConfig.new(
		GameManager.CustomerPersonality.FRIENDLY,
		1.0
	)
	var neutral_config = CustomerSpawnConfig.new(
		GameManager.CustomerPersonality.NEUTRAL,
		1.0
	)
	var grumpy_config = CustomerSpawnConfig.new(
		GameManager.CustomerPersonality.GRUMPY,
		1.0
	)
	level1.customer_spawn_configs.append(auntie_config)
	level1.customer_spawn_configs.append(shy_student_config)
	levels.append(level1)
	
	# Level 2: 進階關卡（包含所有客人類型，不同頻率）- 120秒
	var level2 = LevelConfig.new()
	level2.level_name = "進階關卡"
	level2.spawn_interval = 4.0
	level2.max_customers = 4
	level2.duration = 120.0
	
	level2.customer_spawn_configs.append(CustomerSpawnConfig.new(GameManager.CustomerPersonality.LOCAL_AUNTIE, 2.0))
	level2.customer_spawn_configs.append(CustomerSpawnConfig.new(GameManager.CustomerPersonality.SHY_STUDENT, 1.5))
	level2.customer_spawn_configs.append(CustomerSpawnConfig.new(GameManager.CustomerPersonality.RUSHED_OFFICE, 1.0))
	level2.customer_spawn_configs.append(CustomerSpawnConfig.new(GameManager.CustomerPersonality.VLOGGER, 0.8))
	level2.customer_spawn_configs.append(CustomerSpawnConfig.new(GameManager.CustomerPersonality.RUSHED_DELIVERY, 0.5))
	levels.append(level2)
	
	# Level 3: 高級關卡 - 120秒
	var level3 = LevelConfig.new()
	level3.level_name = "高級關卡"
	level3.spawn_interval = 3.5
	level3.max_customers = 5
	level3.duration = 120.0
	
	level3.customer_spawn_configs.append(CustomerSpawnConfig.new(GameManager.CustomerPersonality.SHY_STUDENT, 2.0))
	level3.customer_spawn_configs.append(CustomerSpawnConfig.new(GameManager.CustomerPersonality.RUSHED_OFFICE, 1.5))
	level3.customer_spawn_configs.append(CustomerSpawnConfig.new(GameManager.CustomerPersonality.VLOGGER, 1.2))
	level3.customer_spawn_configs.append(CustomerSpawnConfig.new(GameManager.CustomerPersonality.RUSHED_DELIVERY, 1.0))
	levels.append(level3)
	
	# Level 4: 專家關卡 - 180秒（Level 4 以後都是 180秒）
	var level4 = LevelConfig.new()
	level4.level_name = "專家關卡"
	level4.spawn_interval = 3.0
	level4.max_customers = 6
	level4.duration = 180.0
	
	level4.customer_spawn_configs.append(CustomerSpawnConfig.new(GameManager.CustomerPersonality.RUSHED_OFFICE, 2.0))
	level4.customer_spawn_configs.append(CustomerSpawnConfig.new(GameManager.CustomerPersonality.VLOGGER, 1.5))
	level4.customer_spawn_configs.append(CustomerSpawnConfig.new(GameManager.CustomerPersonality.RUSHED_DELIVERY, 1.2))
	level4.customer_spawn_configs.append(CustomerSpawnConfig.new(GameManager.CustomerPersonality.SHY_STUDENT, 1.0))
	levels.append(level4)
	
	# Level 5 以後的關卡可以在這裡繼續添加
	# 使用 create_level_with_duration 輔助函數可以自動設置 180 秒的 duration
	
	# Level 4 以後的關卡可以在這裡添加
	# 它們會自動使用 180 秒的 duration（通過 create_level_with_duration 函數）
	# 例如：
	# var level4 = create_level_with_duration(4, "關卡4", ...)
	# levels.append(level4)
	
	print("已初始化 ", levels.size(), " 個關卡配置")

# 連接 game_manager 的信號
func connect_game_manager_signals():
	var game_manager = GameManager
	if game_manager:
		if not game_manager.san_changed.is_connected(_on_san_changed):
			game_manager.san_changed.connect(_on_san_changed)
		print("已連接 game_manager 的 san_changed 信號")
	else:
		print("警告: 無法找到 game_manager，san_changed 信號未連接")

# 處理 san 值變更
func _on_san_changed(new_value: float):
	# 當 san 值歸零時，觸發關卡失敗
	if new_value <= 0 and current_state == LevelState.PLAYING:
		fail_level()
		game_over.emit()

# 輔助函數：根據關卡索引自動設置 duration
func create_level_with_duration(level_index: int, level_name: String, spawn_interval: float, max_customers: int, customer_configs: Array[CustomerSpawnConfig]) -> LevelConfig:
	var level = LevelConfig.new()
	level.level_name = level_name
	level.spawn_interval = spawn_interval
	level.max_customers = max_customers
	level.customer_spawn_configs = customer_configs
	
	# 根據關卡索引設置 duration
	if level_index == 0:
		level.duration = 90.0  # 教學關卡 90秒
	elif level_index >= 1 and level_index <= 3:
		level.duration = 120.0  # Level 1-3 是 120秒
	else:
		level.duration = 180.0  # Level 4 以後都是 180秒
	
	return level

# 開始指定關卡
func start_level(level_index: int):
	if level_index < 0 or level_index >= levels.size():
		print("錯誤: 無效的關卡索引: ", level_index)
		return false
	
	# 重設關卡狀態
	current_state = LevelState.LOADING
	
	# 清空隊列和訂單
	reset_game_state()
	
	# 重置統計數據
	customers_served_successfully = 0
	customers_unserved = 0
	
	current_level_index = level_index
	current_level_config = levels[level_index]
	
	# 設置關卡計時器
	level_duration = current_level_config.duration
	level_timer = 0.0
	
	print("開始載入關卡 ", level_index, ": ", current_level_config.level_name, " (持續時間: ", level_duration, "秒)")
	
	# 發送信號（MainScene 會監聽這個信號並應用配置）
	level_changed.emit(level_index, current_level_config)
	level_state_changed.emit(current_state)
	
	# 設置為進行中狀態（實際應用會在 MainScene 的 _on_level_changed 中完成）
	current_state = LevelState.PLAYING
	level_state_changed.emit(current_state)
	
	# 播放 Active BGM
	play_active_bgm()
	
	return true

# 重設遊戲狀態（清空隊列和訂單）
func reset_game_state():
	var main_scene = get_tree().current_scene
	if not main_scene:
		return
	
	# 獲取 QueueManager 並清空隊列
	var queue_manager = main_scene.get_node_or_null("QueueManager")
	if queue_manager and queue_manager.has_method("clear_queue"):
		queue_manager.clear_queue()
		print("已清空隊列")
	
	# 獲取 OrderManager 並清空訂單
	var order_manager = main_scene.get_node_or_null("CanvasLayer/Order")
	if order_manager and order_manager.has_method("clear_orders"):
		order_manager.clear_orders()
		print("已清空訂單")
	
	# 重置玩家位置到初始位置
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.position = Vector2(640, 500)  # 初始位置
		player.velocity = Vector2.ZERO  # 重置速度
		# 清空玩家手上的食物
		player.take_status = false
		player.take_food = ["", 0]
		if player.has_node("Tray_left"):
			player.get_node("Tray_left").visible = false
		if player.has_node("Tray_right"):
			player.get_node("Tray_right").visible = false
		print("已重置玩家位置和手上的食物")
	
	# 清空出餐台上的所有食物
	var foods_node = main_scene.get_node_or_null("Foods")
	if foods_node:
		for child in foods_node.get_children():
			if child.has_method("init_food"):
				child.init_food()
		print("已清空出餐台上的食物")
	
	# 重置玩家 sanity
	var game_manager = GameManager
	if game_manager:
		game_manager.player_san = game_manager.max_san
		game_manager.san_changed.emit(game_manager.player_san)
		print("已重置玩家 sanity")

# 切換到下一個關卡
func next_level():
	if current_level_index < 0:
		# 如果沒有當前關卡，從 level 0 開始
		# return start_level(0)
		# 測試版從 level 1 開始
		return start_level(1)
	
	var next_index = current_level_index + 1
	if next_index >= levels.size():
		print("已到達最後一個關卡")
		return false
	
	return start_level(next_index)

# 重新開始當前關卡
func restart_current_level():
	if current_level_index >= 0:
		return start_level(current_level_index)
	return false

# 設置關卡狀態
func set_level_state(new_state: LevelState):
	if current_state != new_state:
		current_state = new_state
		level_state_changed.emit(current_state)

# 完成當前關卡
func complete_level():
	set_level_state(LevelState.COMPLETED)
	print("關卡完成: ", current_level_config.level_name if current_level_config else "未知")
	# 計算未服務的客人（關卡結束時還在隊列中的客人）
	calculate_unserved_customers()
	# 播放關卡完成音效
	if SFXManager:
		SFXManager.play_level_cleared_sfx()
	# 播放 Resting BGM
	play_resting_bgm()

# 失敗當前關卡
func fail_level():
	if current_state == LevelState.FAILED:
		return  # 已經失敗了，避免重複觸發
	set_level_state(LevelState.FAILED)
	print("關卡失敗: ", current_level_config.level_name if current_level_config else "未知")
	# 播放關卡失敗音效
	if SFXManager:
		SFXManager.play_level_failed_sfx()
	# 播放 Resting BGM
	play_resting_bgm()

# 獲取當前關卡配置
func get_current_level_config() -> LevelConfig:
	return current_level_config

# 獲取指定索引的關卡配置s
func get_level_config(level_index: int) -> LevelConfig:
	if level_index >= 0 and level_index < levels.size():
		return levels[level_index]
	return null

# 獲取關卡總數
func get_level_count() -> int:
	return levels.size()

# 檢查是否有下一個關卡
func has_next_level() -> bool:
	return current_level_index >= 0 and current_level_index + 1 < levels.size()

# 更新關卡計時器（應該在 _process 中調用）
func _process(delta):
	if current_state == LevelState.PLAYING and level_duration > 0:
		level_timer += delta
		var remaining_time = max(0.0, level_duration - level_timer)
		print('fire ', remaining_time)
		level_time_updated.emit(remaining_time)
		
		# 檢查時間是否到了
		if level_timer >= level_duration:
			level_timer = level_duration
			level_time_up.emit()
			# 可以選擇自動完成關卡或失敗
			complete_level()  # 或者 fail_level()
	

# 獲取關卡剩餘時間
func get_remaining_time() -> float:
	if level_duration > 0:
		return max(0.0, level_duration - level_timer)
	return 0.0

# 獲取關卡已進行時間
func get_elapsed_time() -> float:
	return level_timer

# 獲取關卡總時長
func get_level_duration() -> float:
	return level_duration if current_level_config else 0.0

# 記錄成功服務的客人
func record_customer_served_successfully():
	customers_served_successfully += 1

# 記錄未服務的客人
func record_customer_unserved():
	customers_unserved += 1

# 計算未服務的客人（關卡結束時還在隊列中的客人）
func calculate_unserved_customers():
	var main_scene = get_tree().current_scene
	if not main_scene:
		return
	
	var queue_manager = main_scene.get_node_or_null("QueueManager")
	if queue_manager and queue_manager.has_method("get_customer_count"):
		var remaining_customers = queue_manager.get_customer_count()
		customers_unserved += remaining_customers

# 處理關卡完成/失敗後的按鍵輸入
func _input(event: InputEvent):
	if event is InputEventKey and event.pressed:
		if current_state == LevelState.COMPLETED and event.keycode == KEY_N:
				next_level()
				get_viewport().set_input_as_handled()
		elif current_state == LevelState.FAILED and event.keycode == KEY_R:
			restart_current_level()
			get_viewport().set_input_as_handled()

func is_ended():
	return current_state in [LevelState.COMPLETED, LevelState.FAILED]

# 播放 Active BGM
func play_active_bgm():
	if bgm_player:
		var stream = load(active_bgm_path)
		if stream:
			# 設置循環播放
			if stream is AudioStreamOggVorbis:
				stream.loop = true
			bgm_player.stream = stream
			bgm_player.play()
			print("播放 Active BGM: ", active_bgm_path)

# 播放 Resting BGM
func play_resting_bgm():
	if bgm_player:
		var stream = load(resting_bgm_path)
		if stream:
			# 設置循環播放
			if stream is AudioStreamOggVorbis:
				stream.loop = true
			bgm_player.stream = stream
			bgm_player.play()
			print("播放 Resting BGM: ", resting_bgm_path)

# 設置 BGM 音量（0.0 到 1.0）
func set_bgm_volume(volume: float):
	bgm_volume = clamp(volume, 0.0, 1.0)
	apply_bgm_volume()
	save_volume_settings()

# 應用 BGM 音量
func apply_bgm_volume():
	if bgm_player:
		bgm_player.volume_db = linear_to_db(bgm_volume)

# 保存音量設置
func save_volume_settings():
	var config = ConfigFile.new()
	config.set_value("audio", "bgm_volume", bgm_volume)
	config.save("user://settings.cfg")

# 載入音量設置
func load_volume_settings():
	var config = ConfigFile.new()
	var err = config.load("user://settings.cfg")
	if err == OK:
		if config.has_section_key("audio", "bgm_volume"):
			bgm_volume = config.get_value("audio", "bgm_volume", 1.0)
