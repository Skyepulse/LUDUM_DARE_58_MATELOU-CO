extends Node2D

var screenSize:Vector2
@onready var mur: Parallax2D = $mur
@onready var sol: Parallax2D = $sol
@onready var colonne: Parallax2D = $colonne

func resize() -> void:
	screenSize = get_viewport().get_visible_rect().size
	mur.repeat_size.x = screenSize.x
	sol.repeat_size.x = screenSize.x
	colonne.repeat_size.x = screenSize.x
	
func _ready() -> void:
	get_viewport().size_changed.connect(resize)
	resize()
