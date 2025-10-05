extends Camera2D

@onready var MainUI: Control = $MainUI
var screenSize:Vector2

func resize() -> void:
	screenSize = get_viewport().get_visible_rect().size
	offset = screenSize/2
	MainUI.size = screenSize
	
func _ready() -> void:
	get_viewport().size_changed.connect(resize)
	resize()