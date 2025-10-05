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
var retract_speed_fast = 500

var average_speed: float = 0.0
var last_hand_pos: Vector2 = Vector2.ZERO

var grabbed_object: GrabbableObject = null

var input_enabled: bool = true

func set_input_enabled(en: bool) -> void:
	input_enabled = en

func reset_arm() -> void:
	while arm_curve.point_count > 2:
		arm_curve.remove_point(arm_curve.point_count - 1)
	
	orient_hand()
	

func update_line():
	var points = []
	for i in range(arm_curve.point_count):
		points.append(arm_curve.get_point_position(i))
	line_2d.points = points

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed:
		if event.keycode == KEY_SPACE:
			reset_arm()

func orient_hand() -> void:
	var count = arm_curve.point_count
	if count < 2:
		return
		
	var last_point = arm_curve.get_point_position(count-1)
	var last_last_point = arm_curve.get_point_position(count-2)
	
	var dir = last_point - last_last_point
	var length = dir.length()
	
	if length > 0:
		dir /= length
	
	var hand_look = (last_point + dir * 100) * thief.scale + thief.position
	
	hand.position = last_point
	hand.look_at(hand_look)

func mouse_input(delta: float) -> void:
	var count = arm_curve.point_count
	if count <= 2:
		arm_curve.add_point(arm_curve.get_point_position(count - 1))
		count += 1
	var mouse_pos = get_viewport().get_mouse_position()
	mouse_pos = (mouse_pos + MainCamera2D.position - thief.position) / thief.scale
	
	var last_point = arm_curve.get_point_position(count - 1)
	var direction = mouse_pos - last_point
	last_point += direction * delta * 2.0
	
	arm_curve.set_point_position(count - 1, last_point)
	
	var last_last_point: Vector2 = arm_curve.get_point_position(count - 2)
	
	cur_length = (last_point - last_last_point).length()
	
	if cur_length > max_length:
		arm_curve.add_point(last_point)
		last_last_point = last_last_point + (last_point - last_last_point) / cur_length * max_length
		arm_curve.set_point_position(count - 1, last_last_point)
	
	orient_hand()


func retract(delta: float) -> void:
	var holding_object: bool = grabbed_object != null
	
	var count = arm_curve.point_count
	
	if count <= 2:
		return
	
	var speed = retract_speed
	if holding_object:
		speed = retract_speed_fast
	
	var cut_length = speed * delta
	
	var index_last = count - 1
	var last_point: Vector2
	var last_dir: Vector2
	while index_last > 2:
		var p1 = arm_curve.get_point_position(index_last)
		var p2 = arm_curve.get_point_position(index_last - 1)
		
		last_point = p1
		
		var dir = p1 - p2
		var length = dir.length()
		
		last_dir = dir / length
		
		if length >= cut_length:
			arm_curve.set_point_position(index_last, p1 - dir * (cut_length / length))
			break
		else:
			arm_curve.remove_point(index_last)
			cut_length -= length
			index_last -= 1
	
	orient_hand()
	
	if holding_object:
		grabbed_object.set_position(last_point * thief.scale + thief.position)
		if index_last <= 2:
			collect_object()

func set_grabbed_object(object: GrabbableObject) -> void:
	grabbed_object = object
	print(" grabbed player ")

func unset_grabbed_object(object: GrabbableObject) -> void:
	if object == grabbed_object && !retracting:
		grabbed_object = null
		print(" ungrabbed player ")
	
func _ready() -> void:
	GameManager.Player = self
	
	var count = arm_curve.point_count
	var point_0 = arm_curve.get_point_position(0)
	var point_1 = arm_curve.get_point_position(1)
	hand.position = point_1
	last_hand_pos = hand.global_position
	hand.look_at(point_1 + (point_1 - point_0) * 10)
	
func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("Grabbable"):
		print("Hand on object: %s" % area.get_parent().name)
		set_grabbed_object(area.get_parent())

func _on_area_2d_area_exited(area: Area2D) -> void:
	if area.is_in_group("Grabbable"):
		print("Hand off object: %s" % area.get_parent().name)
		unset_grabbed_object(area.get_parent())

func collect_object():
	if grabbed_object != null:
		GameManager.collect_object(grabbed_object.INDEX)
		grabbed_object.queue_free()

func is_on_object() -> bool:
	return grabbed_object != null

func get_grabbed_object() -> GrabbableObject:
	return grabbed_object

func update_average_speed(delta: float) -> void:
	var hand_pos = hand.global_position
	var speed = (hand_pos - last_hand_pos).length() / delta
	average_speed = lerp(average_speed, speed, 0.1)
	last_hand_pos = hand_pos
	
func get_average_speed() -> float:
	return average_speed

func _process(delta: float) -> void:
	retracting = !Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
	
	if input_enabled:
		if retracting:
			retract(delta)
		else:
			mouse_input(delta)
		update_average_speed(delta)
	
	update_line()
