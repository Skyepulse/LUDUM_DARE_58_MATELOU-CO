extends Camera2D

var screenSize:Vector2
@onready var GameUI: Control = $GameUI

func resize() -> void:
	screenSize = get_viewport().get_visible_rect().size
	offset = screenSize/2
	GameUI.size = screenSize
	
func _ready() -> void:
	get_viewport().size_changed.connect(resize)
	resize()
