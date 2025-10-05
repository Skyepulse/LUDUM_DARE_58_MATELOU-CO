extends Sprite2D

var is_looking_thief: bool = false
var is_talking: bool = false

@onready var timer: Timer = $Timer
@onready var animation_timer: Timer = $AnimationTimer

@export var suspicion_increase_on_object_interaction: float = 10.0
@export var suspicion_min_increase_on_hand_movement: float = 2.0
@export var suspicion_max_increase_on_hand_movement: float = 10.0
@export var min_hand_movement_speed_cutoff: float = 50.0 # Below 50, we get no suspicion increase
@export var max_hand_movement_speed_cutoff: float = 300.0 # Above 300, we get max suspicion increase

@export var max_talk_time: float = 8.0
@export var min_talk_time: float = 2.0

@export var max_look_time: float = 4.0
@export var min_look_time: float = 1.0

@export var walking_animation_frame_duration: float = 0.8
@export var talking_animation_frame_duration: float = 1.0
@export var looking_animation_frame_duration: float = 2.0

var current_walking_sprite_index: int = 0
var current_talking_sprite_index: int = 0
var current_looking_sprite_index: int = 0

@export var walking_sprites: Array[Texture2D] = []
@export var talking_sprites: Array[Texture2D] = []
@export var looking_sprites: Array[Texture2D] = []

func _ready() -> void:
	GameManager.Guide = self

	timer.timeout.connect(_on_timer_timeout)
	animation_timer.timeout.connect(update_sprite)
	
	Signals.connect("start_level", stop_moving)

	print("Walking animation duration: %f" % walking_animation_frame_duration)
	print("Talking animation duration: %f" % talking_animation_frame_duration)
	print("Looking animation duration: %f" % looking_animation_frame_duration)
	
func _process(delta: float) -> void:
	var suspicion_increase_value = does_guide_get_suspicious()
	if suspicion_increase_value > 0.0:
		GameManager.increaseSuspicion(suspicion_increase_value * delta)
	
func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed():
		if event.keycode == KEY_SPACE:
			start_moving()

func start_moving() -> void:
	Signals.emit_signal("move_scene")
	Signals.emit_signal("set_input", false)
	timer.stop()

	Signals.is_moving = true
	is_looking_thief = false
	is_talking = false

	set_initial_sprite()

func stop_moving() -> void:
	Signals.is_moving = false
	start_talking()

func start_talking() -> void:
	is_talking = true
	is_looking_thief = false

	var talk_time = randf_range(min_talk_time, max_talk_time)
	start_timer(talk_time)

	set_initial_sprite()

func start_looking_thief() -> void:
	is_looking_thief = true
	is_talking = false

	var look_time = randf_range(min_look_time, max_look_time)
	start_timer(look_time)

	set_initial_sprite()

func start_timer(time: float) -> void:
	timer.wait_time = time
	timer.start()

func _on_timer_timeout() -> void:
	if Signals.is_moving:
		return

	animation_timer.stop()

	if is_looking_thief:
		# Start Talking Again
		start_talking()
	else:
		start_looking_thief()

func does_guide_get_suspicious() -> float:
	if Signals.is_moving or is_talking:
		return false

	var susp: float = 0.0

	if GameManager.Player.is_on_object():
		susp += suspicion_increase_on_object_interaction

	if GameManager.Player.get_average_speed() > min_hand_movement_speed_cutoff:
		var speed_ratio = clamp((GameManager.Player.get_average_speed() - min_hand_movement_speed_cutoff) / (max_hand_movement_speed_cutoff - min_hand_movement_speed_cutoff), 0.0, 1.0)
		var speed_based_suspicion = lerp(suspicion_min_increase_on_hand_movement, suspicion_max_increase_on_hand_movement, speed_ratio)
		susp += speed_based_suspicion
	
	return susp

func set_initial_sprite() -> void:
	if Signals.is_moving:
		if walking_sprites.size() > 0:
			self.texture = walking_sprites[0]
			animation_timer.wait_time = walking_animation_frame_duration
		else:
			print_rich("[color=red]Warning: No walking sprites assigned to Guide![/color]")
	elif is_talking:
		if talking_sprites.size() > 0:
			self.texture = talking_sprites[0]
			animation_timer.wait_time = talking_animation_frame_duration
		else:
			print_rich("[color=red]Warning: No talking sprites assigned to Guide![/color]")
	elif is_looking_thief:
		if looking_sprites.size() > 0:
			self.texture = looking_sprites[0]
			animation_timer.wait_time = looking_animation_frame_duration
		else:
			print_rich("[color=red]Warning: No looking sprites assigned to Guide![/color]")

	animation_timer.start()

func update_sprite() -> void:
	if Signals.is_moving:
		if walking_sprites.size() == 0:
			return
		current_walking_sprite_index = (current_walking_sprite_index + 1) % walking_sprites.size()
		self.texture = walking_sprites[current_walking_sprite_index]
		animation_timer.wait_time = walking_animation_frame_duration
	elif is_talking:
		if talking_sprites.size() == 0:
			return
		current_talking_sprite_index = (current_talking_sprite_index + 1) % talking_sprites.size()
		self.texture = talking_sprites[current_talking_sprite_index]
		animation_timer.wait_time = talking_animation_frame_duration
	elif is_looking_thief:
		if looking_sprites.size() == 0:
			return
		current_looking_sprite_index = (current_looking_sprite_index + 1) % looking_sprites.size()
		self.texture = looking_sprites[current_looking_sprite_index]
		animation_timer.wait_time = looking_animation_frame_duration

	animation_timer.start()
