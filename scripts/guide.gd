extends Sprite2D

var cam_offset:Vector2

signal move 

func _ready() -> void:
	cam_offset = MainCamera2D.position - position
	
func _process(delta: float) -> void:
	position.x = MainCamera2D.position.x - cam_offset.x
	
func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed():
		if event.keycode == KEY_SPACE:
			move.emit()
