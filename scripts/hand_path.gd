extends Path2D

@onready var path_2d: Path2D = $"."
@onready var line_2d: Line2D = $"../Line2D"
@onready var hand: Sprite2D = $"../Hand"
@onready var thief: Node2D = $".."

@onready var arm_curve = path_2d.curve

@export var retracting: bool = true;

var cur_length = 0
var max_length = 20
var min_length = 2

var retract_speed = 50

func update_line():
	var points = []
	for i in range(arm_curve.point_count):
		points.append(arm_curve.get_point_position(i))
	line_2d.points = points	

func mouse_input(delta: float) -> void:
	var count = arm_curve.point_count
	var mouse_pos = get_viewport().get_mouse_position()
	mouse_pos = (mouse_pos + MainCamera2D.position - thief.position) / thief.scale
	
	var last_point = arm_curve.get_point_position(count - 1)
	var direction = mouse_pos - last_point
	last_point += direction * delta * 2.0
	
	arm_curve.set_point_position(count - 1, last_point)
	
	cur_length = (last_point - arm_curve.get_point_position(count - 2)).length()
	
	if cur_length > max_length:
		arm_curve.add_point(last_point)
		
	hand.position = last_point
	
	#var hand_dir = last_point - arm_curve.get_point_position(count - 2)
	
	hand.look_at(get_viewport().get_mouse_position())	


func retract(delta: float) -> void:
	var count = arm_curve.point_count
	
	if count <= 2:
		return
	
	var last_point = arm_curve.get_point_position(count - 1)
	var last_last_point = arm_curve.get_point_position(count - 2)
	
	var dir = last_last_point - last_point
	var length = dir.length()
	
	if length < min_length:
		arm_curve.remove_point(count - 1)
		return
	dir /= length
	last_point += dir * retract_speed * delta
	
	arm_curve.set_point_position(count - 1, last_point)
	
	hand.position = last_point
	var hand_look = (last_point - dir * 100) * thief.scale + thief.position
	hand.look_at(hand_look)
	
	
func _ready() -> void:
	var count = arm_curve.point_count
	var point_0 = arm_curve.get_point_position(0)
	var point_1 = arm_curve.get_point_position(1)
	hand.position = point_1
	hand.look_at(point_1 + (point_1 - point_0)*10)

func _process(delta: float) -> void:
	retracting = !Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
	if retracting:
		retract(delta)
	else:
		mouse_input(delta)
		
	
	update_line()
	
	
