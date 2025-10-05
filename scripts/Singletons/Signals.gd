extends Node

signal move_scene
signal start_level
signal set_input(state: bool)

enum {INGAME, PAUSED, COLLECTION, CREDIT}

var is_moving: bool = false
var game_state = PAUSED

# Signals.connect("signal_name", function)
# Signals.emit_signal("signal_name")
