extends Node

signal move_scene
signal start_level
signal set_input(state: bool)

var is_moving: bool = false

# Signals.connect("signal_name", function)
# Signals.emit_signal("signal_name")
