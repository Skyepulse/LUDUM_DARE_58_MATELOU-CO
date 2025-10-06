extends Node2D

@onready var background: Node2D = $Background
const OBJECT_BUTTON = preload("uid://bdfxsfkj33qq8")

@export var possible_levels: Array[PackedScene] = []
var rng = RandomNumberGenerator.new()

var last_object_index: int = -1

func instantiate_objects():
	var screen_size = get_viewport().get_visible_rect().size
	var offset = Vector2(GameManager.level_index + 1.5, 0.35) * screen_size;
	var level = possible_levels[rng.randi() % possible_levels.size()].instantiate()
	add_child(level)

	level.set_position(offset)
	last_object_index = level.startup_scene(last_object_index)
	GameManager.object_index = last_object_index
	print("Current object index: %d" % GameManager.object_index)

func instantiate_begin_button() -> void:
	var screen_size = get_viewport().get_visible_rect().size
	var offset = Vector2(0.5, 0.4) * screen_size;
	var obj = OBJECT_BUTTON.instantiate()
	add_child(obj)
	
	obj.set_position(offset)

func _ready() -> void:
	background.init()
	instantiate_begin_button()
	Signals.connect("move_scene", instantiate_objects)
	# Signals.emit_signal("move_scene")
	# Signals.emit_signal("set_input", false)
