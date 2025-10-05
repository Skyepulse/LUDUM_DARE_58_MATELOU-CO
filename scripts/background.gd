extends Node2D

var speed:float = 300.0

var guide_offset:Vector2
var player_offset:Vector2

var screenSize:Vector2

@onready var parallax_2d: Parallax2D = $Parallax2D


func _ready() -> void:
	get_viewport().size_changed.connect(resize)
	resize()
	Signals.connect("move_scene", setIsMoving)
	
func init() -> void:
	guide_offset = MainCamera2D.position - GameManager.Guide.position
	player_offset = MainCamera2D.position - GameManager.Player.get_parent().position

func resize() -> void:
	screenSize = get_viewport().get_visible_rect().size
	parallax_2d.repeat_size.x = screenSize.x
	
func move(delta: float) -> void:
	MainCamera2D.position.x += speed*delta
	GameManager.Guide.position.x = MainCamera2D.position.x - guide_offset.x
	GameManager.Player.get_parent().position.x = MainCamera2D.position.x - player_offset.x
	
	if MainCamera2D.position.x >= (1+GameManager.level_index)*screenSize.x:
		Signals.is_moving = false
		GameManager.level_index += 1
		print(GameManager.level_index)
		Signals.emit_signal("start_level")
		Signals.emit_signal("set_input", true)
		
func setIsMoving() -> void:
	Signals.is_moving = true
	
func _process(delta: float) -> void:
	if Signals.is_moving:
		move(delta)
