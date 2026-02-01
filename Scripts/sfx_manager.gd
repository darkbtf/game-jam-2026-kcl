extends Node

# 音效管理器
# 負責管理所有遊戲音效的播放

# 音效播放器池（用於同時播放多個音效）
var sfx_players: Array[AudioStreamPlayer] = []
var max_players: int = 10  # 最多同時播放的音效數量

# QTE 音效播放器（專用於循環播放並可停止）
var qte_sfx_player: AudioStreamPlayer

# 音量設置（0.0 到 1.0）
var sfx_volume: float = 1.0

# 音效路徑
var sold_sfx_path = "res://Assets/SFX/GGJ2026SFX_Sold.ogg"
var level_cleared_sfx_path = "res://Assets/SFX/GGJ2026_LevelCleared.ogg"
var level_failed_sfx_path = "res://Assets/SFX/GGJ2026_LevelFailed.ogg"
var meal_ready_sfx_path = "res://Assets/SFX/GGJ2026SFX_MealReady.ogg"
var qte_gibberish_sfx_path = "res://Assets/SFX/GGJ2026SFX_GibberishXD.ogg"

func _ready():
	# 預先創建音效播放器池
	for i in range(max_players):
		var player = AudioStreamPlayer.new()
		add_child(player)
		sfx_players.append(player)
	
	# 創建 QTE 音效播放器
	qte_sfx_player = AudioStreamPlayer.new()
	add_child(qte_sfx_player)
	
	# 載入保存的音量設置
	load_volume_settings()
	
	# 應用音量設置
	apply_sfx_volume()

# 播放送餐完成音效
func play_sold_sfx():
	play_sfx(sold_sfx_path)

# 播放關卡完成音效
func play_level_cleared_sfx():
	play_sfx(level_cleared_sfx_path)

# 播放關卡失敗音效
func play_level_failed_sfx():
	play_sfx(level_failed_sfx_path)

# 播放備餐完成音效
func play_meal_ready_sfx():
	play_sfx(meal_ready_sfx_path)

# 播放 QTE 音效（循環播放）
func play_qte_gibberish_sfx():
	if not qte_sfx_player:
		return
	
	var stream = load(qte_gibberish_sfx_path)
	if not stream:
		print("無法載入 QTE 音效: ", qte_gibberish_sfx_path)
		return
	
	# 設置循環播放
	if stream is AudioStreamOggVorbis:
		stream.loop = true
	
	qte_sfx_player.stream = stream
	qte_sfx_player.play()

# 停止 QTE 音效
func stop_qte_gibberish_sfx():
	if qte_sfx_player and qte_sfx_player.playing:
		qte_sfx_player.stop()

# 通用音效播放函數
func play_sfx(sfx_path: String):
	if sfx_path.is_empty():
		return
	
	var stream = load(sfx_path)
	if not stream:
		print("無法載入音效: ", sfx_path)
		return
	
	# 找一個可用的播放器
	for player in sfx_players:
		if not player.playing:
			player.stream = stream
			player.play()
			return
	
	# 如果所有播放器都在使用，使用第一個（會中斷當前播放）
	if sfx_players.size() > 0:
		sfx_players[0].stream = stream
		sfx_players[0].play()

# 設置 SFX 音量（0.0 到 1.0）
func set_sfx_volume(volume: float):
	sfx_volume = clamp(volume, 0.0, 1.0)
	apply_sfx_volume()
	save_volume_settings()

# 應用 SFX 音量到所有播放器
func apply_sfx_volume():
	for player in sfx_players:
		player.volume_db = linear_to_db(sfx_volume)
	if qte_sfx_player:
		qte_sfx_player.volume_db = linear_to_db(sfx_volume)

# 保存音量設置
func save_volume_settings():
	var config = ConfigFile.new()
	config.set_value("audio", "sfx_volume", sfx_volume)
	config.save("user://settings.cfg")

# 載入音量設置
func load_volume_settings():
	var config = ConfigFile.new()
	var err = config.load("user://settings.cfg")
	if err == OK:
		if config.has_section_key("audio", "sfx_volume"):
			sfx_volume = config.get_value("audio", "sfx_volume", 1.0)
