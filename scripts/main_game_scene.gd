extends Node2D

@onready var background: Node2D = $Background

const OBJ_JOCONDE = preload("uid://cpt378r0tx734")

var rng = RandomNumberGenerator.new()

func instantiate_objects():
	var count = GameManager.all_indices.size()
	var index = GameManager.all_indices[rng.randi() % count]
	
	GameManager.object_index = index
	
	print(count, ", ", index)
	
	var screen_size = get_viewport().get_visible_rect().size
	var offset = Vector2(GameManager.level_index + 1.5, 0.4) * screen_size;
	var obj = GameManager.infoDictionary[index].scene.instantiate()
	add_child(obj)
	
	obj.scale = Vector2(0.2, 0.2)
	obj.set_position(offset)

func _ready() -> void:
	background.init()
	Signals.connect("move_scene", instantiate_objects)
	Signals.emit_signal("move_scene")
	Signals.emit_signal("set_input", false)
