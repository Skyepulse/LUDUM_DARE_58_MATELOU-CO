extends Node2D

var speed:float = 100.0
var isMoving:bool = true
@onready var guide: Sprite2D = $"../Guide"

var screenSize:Vector2
@onready var mur: Parallax2D = $mur
@onready var sol: Parallax2D = $sol
@onready var colonne: Parallax2D = $colonne

func resize() -> void:
	screenSize = get_viewport().get_visible_rect().size
	mur.repeat_size.x = screenSize.x
	sol.repeat_size.x = screenSize.x
	colonne.repeat_size.x = screenSize.x
	
func move(delta: float) -> void:
	MainCamera2D.position.x += speed*delta
	if MainCamera2D.position.x >= screenSize.x:
		isMoving = false
		MainCamera2D.position.x -= screenSize.x
		
func setIsMoving() -> void:
	isMoving = true
	
func _ready() -> void:
	get_viewport().size_changed.connect(resize)
	resize()
	guide.move.connect(setIsMoving)
	
func _process(delta: float) -> void:
	if isMoving:
		move(delta)
