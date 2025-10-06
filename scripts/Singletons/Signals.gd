extends Node

signal move_scene
signal activate_vignette_effect
signal start_level
signal set_input(state: bool)
signal game_over
signal restart_game
signal main_menu

enum {INGAME, PAUSED, COLLECTION, CREDIT}

var is_moving: bool = false
var game_state = PAUSED

# Signals.connect("signal_name", function)
# Signals.emit_signal("signal_name")
