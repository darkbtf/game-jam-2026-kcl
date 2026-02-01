extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# 播放 Resting BGM
	if LevelManager:
		LevelManager.play_resting_bgm()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
