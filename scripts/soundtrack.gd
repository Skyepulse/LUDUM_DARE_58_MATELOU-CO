extends Node

@onready var vol: AudioStreamPlayer = $vol
@onready var fuite: AudioStreamPlayer = $fuite
@onready var speech: AudioStreamPlayer = $speech

func _ready() -> void:
	Signals.connect("restart_game", start_main_music)
	Signals.connect("game_over", play_game_over_music)
	Signals.connect("main_menu", play_menu_music)

	play_menu_music()

func start_main_music() -> void:
	if fuite.playing:
		return

	if speech.playing:
		speech.playing = false
		speech.stop()
	if vol.playing:
		vol.playing = false
		vol.stop()
	fuite.playing = true
	fuite.play()

	print("Playing main game music")

func play_menu_music() -> void:
	if speech.playing:
		return

	if vol.playing:
		vol.playing = false
		vol.stop()
	if fuite.playing:
		fuite.playing = false
		fuite.stop()
	speech.playing = true
	speech.play()

	print("Playing menu music")

func play_game_over_music() -> void:
	if vol.playing:
		return

	if fuite.playing:
		fuite.playing = false
		fuite.stop()
	if speech.playing:
		speech.playing = false
		speech.stop()
	vol.playing = true
	vol.play()

	print("Playing game over music")