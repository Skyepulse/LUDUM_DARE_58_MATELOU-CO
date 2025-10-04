extends Sprite2D

var cam_offset:Vector2

var is_looking_thief: bool = false
var is_talking: bool = false
var is_moving: bool = false

@onready var timer: Timer = $Timer

@export var max_talk_time: float = 8.0
@export var min_talk_time: float = 2.0

@export var max_look_time: float = 4.0
@export var min_look_time: float = 1.0

signal move 

func _ready() -> void:
	cam_offset = MainCamera2D.position - position
	GameManager.Guide = self

	timer.timeout.connect(_on_timer_timeout)
	
func _process(delta: float) -> void:
	position.x = MainCamera2D.position.x - cam_offset.x
	var suspicion_increase_value = does_guide_get_suspicious()
	if suspicion_increase_value > 0.0:
		GameManager.increaseSuspicion(suspicion_increase_value)
	
func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed():
		if event.keycode == KEY_SPACE:
			start_moving()

func start_moving() -> void:
	move.emit()
	timer.stop()

	rotation_degrees = 90

	is_moving = true
	is_looking_thief = false
	is_talking = false

func stop_moving() -> void:
	is_moving = false
	start_talking()

func start_talking() -> void:
	is_talking = true
	is_looking_thief = false

	rotation_degrees = 0.0

	var talk_time = randf_range(min_talk_time, max_talk_time)
	start_timer(talk_time)

func start_looking_thief() -> void:
	is_looking_thief = true
	is_talking = false

	rotation_degrees = -90.0

	var look_time = randf_range(min_look_time, max_look_time)
	start_timer(look_time)

func start_timer(time: float) -> void:
	timer.wait_time = time
	timer.start()

func _on_timer_timeout() -> void:
	if is_moving:
		return

	if is_looking_thief:
		# Start Talking Again
		start_talking()
	else:
		start_looking_thief()

func does_guide_get_suspicious() -> float:
	if is_moving or is_talking:
		return false

	var susp: float = 0.0

	# If is hand on object:
		# susp += 10

	# If is hand moving:
		# susp += 5
	
	return susp