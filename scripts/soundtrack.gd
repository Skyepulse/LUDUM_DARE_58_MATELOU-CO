extends Node

@onready var vol: AudioStreamPlayer = $vol
@onready var fuite: AudioStreamPlayer = $fuite
@onready var speech: AudioStreamPlayer = $speech

func _ready() -> void:
	Signals.connect("game_started", start_main_music)
	Signals.connect("game_paused", paused_main_music)
	Signals.connect("game_unpaused", unpaused_main_music)

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed():
		if event.keycode == KEY_S:
			speech.playing = true
		elif event.keycode == KEY_D:
			speech.playing = false

func start_main_music() -> void:
	speech.playing = true

func paused_main_music() -> void:
	speech.stream_paused = true
	
func unpaused_main_music() -> void:
	speech.stream_paused = false
