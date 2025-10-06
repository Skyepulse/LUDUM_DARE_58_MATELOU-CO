extends Node

@onready var vol: AudioStreamPlayer = $vol
@onready var fuite: AudioStreamPlayer = $fuite
@onready var speech: AudioStreamPlayer = $speech

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed():
		if event.keycode == KEY_S:
			speech.playing = true
		elif event.keycode == KEY_D:
			speech.playing = false
