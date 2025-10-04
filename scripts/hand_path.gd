extends Path2D

@onready var path_2d: Path2D = $"."
@onready var line_2d: Line2D = $"../Line2D"
@onready var hand: Sprite2D = $"../Hand"
@onready var thief: Node2D = $".."

var cur_length = 0
var max_length = 20
var min_length = 2

func update_line():
	var points = []
	for i in range(path_2d.curve.point_count):
		points.append(path_2d.curve.get_point_position(i))
	line_2d.points = points	

func mouse_input(delta: float) -> void:
	var count = path_2d.curve.point_count
	var mouse_pos = get_viewport().get_mouse_position()
	mouse_pos = mouse_pos + MainCamera2D.position - thief.position
	
	var last_point = path_2d.curve.get_point_position(count - 1)
	var direction = mouse_pos - last_point
	last_point += direction * delta * 2.0
	
	path_2d.curve.set_point_position(count - 1, last_point)
	
	cur_length = (last_point - path_2d.curve.get_point_position(count - 2)).length()
	
	if cur_length > max_length:
		path_2d.curve.add_point(last_point)
		
	hand.position = last_point
	
	#var hand_dir = last_point - path_2d.curve.get_point_position(count - 2)
	
	hand.look_at(get_viewport().get_mouse_position())	


func _process(delta: float) -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		mouse_input(delta)
	
	update_line()
	
	
