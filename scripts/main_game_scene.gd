extends Node2D

@onready var background: Node2D = $Background

func _ready() -> void:
	background.init()
	Signals.emit_signal("move_scene")
	Signals.emit_signal("set_input", false)
