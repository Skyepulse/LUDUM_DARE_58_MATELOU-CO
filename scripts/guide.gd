extends Sprite2D

var cam_offset:Vector2

func _ready() -> void:
	cam_offset = MainCamera2D.position - position
	
func _process(delta: float) -> void:
	MainCamera2D.position.x += 100*delta
	position.x = MainCamera2D.position.x - cam_offset.x
