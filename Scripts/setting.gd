extends Control

# Setting 場景
# 顯示設定視窗，覆蓋整個屏幕
# 注意：按鈕行為和輸入處理在 ui_manager.gd 中

@onready var level_digit1_label: Label = $LevelDigit1Label
@onready var level_digit2_label: Label = $LevelDigit2Label
@onready var sound_icon: TextureButton = $SoundIcon
@onready var x_button: TextureButton = $XButton
@onready var volume_control_panel: Control = $VolumeControlPanel
@onready var bgm_slider: HSlider = $VolumeControlPanel/VBoxContainer/BGMSection/BGMSlider
@onready var bgm_value_label: Label = $VolumeControlPanel/VBoxContainer/BGMSection/BGMValueLabel
@onready var sfx_slider: HSlider = $VolumeControlPanel/VBoxContainer/SFXSection/SFXSlider
@onready var sfx_value_label: Label = $VolumeControlPanel/VBoxContainer/SFXSection/SFXValueLabel

func _ready():
	# 設置 UI 在暫停時仍能處理輸入
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# 連接 LevelManager 的信號
	if LevelManager:
		if not LevelManager.level_changed.is_connected(_on_level_changed):
			LevelManager.level_changed.connect(_on_level_changed)
	
	# 初始化顯示當前關卡
	update_level_display()
	
	# 連接 X 按鈕的點擊信號
	if x_button:
		if not x_button.pressed.is_connected(_on_x_button_pressed):
			x_button.pressed.connect(_on_x_button_pressed)
	
	# 連接 SoundIcon 的點擊信號
	if sound_icon:
		if not sound_icon.pressed.is_connected(_on_sound_icon_pressed):
			sound_icon.pressed.connect(_on_sound_icon_pressed)
	
	# 連接音量滑桿的信號
	if bgm_slider:
		if not bgm_slider.value_changed.is_connected(_on_bgm_slider_changed):
			bgm_slider.value_changed.connect(_on_bgm_slider_changed)
	
	if sfx_slider:
		if not sfx_slider.value_changed.is_connected(_on_sfx_slider_changed):
			sfx_slider.value_changed.connect(_on_sfx_slider_changed)
	
	# 初始化音量顯示
	update_volume_display()

func _input(event: InputEvent):
	# 處理點擊背景關閉設定視窗
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if not visible:
			return
		
		var mouse_pos = get_global_mouse_position()
		
		# 檢查是否點擊在任何可交互的 UI 元素上
		var clicked_on_ui = false
		
		# 檢查是否點擊在 X 按鈕上
		if x_button and x_button.visible:
			var x_rect = Rect2(x_button.global_position, x_button.size)
			if x_rect.has_point(mouse_pos):
				clicked_on_ui = true
		
		# 檢查是否點擊在 SoundIcon 上
		if not clicked_on_ui and sound_icon and sound_icon.visible:
			var sound_rect = Rect2(sound_icon.global_position, sound_icon.size)
			if sound_rect.has_point(mouse_pos):
				clicked_on_ui = true
		
		# 檢查是否點擊在 VolumeControlPanel 上
		if not clicked_on_ui and volume_control_panel and volume_control_panel.visible:
			var panel_rect = Rect2(volume_control_panel.global_position, volume_control_panel.size)
			if panel_rect.has_point(mouse_pos):
				clicked_on_ui = true
		
		# 檢查是否點擊在 LevelDigit 標籤上
		if not clicked_on_ui and level_digit1_label and level_digit1_label.visible:
			var level1_rect = Rect2(level_digit1_label.global_position, level_digit1_label.size)
			if level1_rect.has_point(mouse_pos):
				clicked_on_ui = true
		
		if not clicked_on_ui and level_digit2_label and level_digit2_label.visible:
			var level2_rect = Rect2(level_digit2_label.global_position, level_digit2_label.size)
			if level2_rect.has_point(mouse_pos):
				clicked_on_ui = true
		
		# 如果沒有點擊在任何 UI 元素上，且點擊在背景上，則關閉設定視窗
		if not clicked_on_ui:
			var background = get_node_or_null("Background")
			if background:
				var bg_local_pos = background.get_local_mouse_position()
				var bg_rect = Rect2(Vector2.ZERO, background.size)
				if bg_rect.has_point(bg_local_pos):
					hide_setting()
					get_viewport().set_input_as_handled()

func show_setting():
	visible = true
	# 可以選擇暫停遊戲
	# get_tree().paused = true

func hide_setting():
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

func _on_x_button_pressed():
	# 關閉設定視窗
	hide_setting()

func _on_sound_icon_pressed():
	# 切換音量控制面板的顯示
	if volume_control_panel:
		volume_control_panel.visible = not volume_control_panel.visible

func _on_bgm_slider_changed(value: float):
	# 更新 BGM 音量（將 0-100 轉換為 0.0-1.0）
	var volume = value / 100.0
	if LevelManager:
		LevelManager.set_bgm_volume(volume)
	update_volume_display()

func _on_sfx_slider_changed(value: float):
	# 更新 SFX 音量（將 0-100 轉換為 0.0-1.0）
	var volume = value / 100.0
	if SFXManager:
		SFXManager.set_sfx_volume(volume)
	update_volume_display()

func update_volume_display():
	# 更新 BGM 音量顯示
	if LevelManager and bgm_slider and bgm_value_label:
		var bgm_volume_percent = int(LevelManager.bgm_volume * 100)
		bgm_slider.value = bgm_volume_percent
		bgm_value_label.text = str(bgm_volume_percent) + "%"
	
	# 更新 SFX 音量顯示
	if SFXManager and sfx_slider and sfx_value_label:
		var sfx_volume_percent = int(SFXManager.sfx_volume * 100)
		sfx_slider.value = sfx_volume_percent
		sfx_value_label.text = str(sfx_volume_percent) + "%"
