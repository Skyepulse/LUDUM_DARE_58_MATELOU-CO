extends Sprite2D

var is_looking_thief: bool = false
var is_talking: bool = false

@onready var timer: Timer = $Timer
@onready var animation_timer: Timer = $AnimationTimer
@onready var speech_timer: Timer = $SpeechTimer
@onready var speech_bubble: NinePatchRect = $SpeechBubble
@onready var speech_label: RichTextLabel = $SpeechBubble/Text

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

@export var speech_speed: float = 15.0 # Characters per second
var guide_welcome: Array[String] = [
	"Welcome to the Worldwide Contributions aisle of the British Consortium's Museum!\
	We are very proud to announce that the citizen from the Dastardly French Alliance, the Greek Front of Unity, and the Independant Ireland are not welcomed in our establishment. If you are from one of these, please turn yourself in at your earliest convenience."
]

var current_walking_sprite_index: int = 0
var current_talking_sprite_index: int = 0
var current_looking_sprite_index: int = 0

@export var walking_sprites: Array[Texture2D] = []
@export var talking_sprites: Array[Texture2D] = []
@export var looking_sprites: Array[Texture2D] = []

var speechString: String = ""
var labeltext: String = ""
const MAX_LABEL_LENGTH: int = 100

var initial_position: Vector2

func _ready() -> void:
	GameManager.Guide = self
	speech_bubble.visible = false

	timer.timeout.connect(_on_timer_timeout)
	animation_timer.timeout.connect(update_sprite)
	speech_timer.timeout.connect(_on_speech_timer_timeout)
	
	Signals.connect("start_level", stop_moving)
	Signals.connect("move_scene", start_moving)
	
	Signals.connect("game_paused", on_game_paused)
	Signals.connect("game_unpaused", on_game_unpaused)

	print("Walking animation duration: %f" % walking_animation_frame_duration)
	print("Talking animation duration: %f" % talking_animation_frame_duration)
	print("Looking animation duration: %f" % looking_animation_frame_duration)

	initial_position = position
	
	Signals.connect("game_started", stop_moving)
	
func _process(delta: float) -> void:
	if Signals.game_state == Signals.INGAME:
		var suspicion_increase_value = does_guide_get_suspicious()
		if suspicion_increase_value > 0.0:
			GameManager.increaseSuspicion(suspicion_increase_value * delta)

func start_moving() -> void:
	if not Signals.is_moving:
		Signals.emit_signal("set_input", false)
		
	timer.stop()

	Signals.is_moving = true
	is_looking_thief = false
	is_talking = false

	set_initial_sprite()

	pause_speaking()

func stop_moving() -> void:
	Signals.is_moving = false
	start_talking()
	
	var text: String
	if GameManager.level_index == 0:
		text = guide_welcome[0]
	else:
		text = GameManager.infoDictionary[GameManager.object_index].description
	
	start_bubble_speak(text)


func start_talking() -> void:
	is_talking = true
	is_looking_thief = false

	var talk_time = randf_range(min_talk_time, max_talk_time)
	start_timer(talk_time)

	set_initial_sprite()

	resume_speaking()

func start_looking_thief() -> void:
	is_looking_thief = true
	is_talking = false

	var look_time = randf_range(min_look_time, max_look_time)
	start_timer(look_time)

	set_initial_sprite()

	pause_speaking()

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
	if GameManager.level_index == 0:
		return false
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
	if Signals.game_state == Signals.INGAME:
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

func start_bubble_speak(text: String) -> void:
	speechString = text
	labeltext = ""
	speech_label.text = ""
	speech_timer.wait_time = 1.0 / speech_speed
	speech_timer.start()
	speech_bubble.visible = true

var timer_stopped: bool = false
var timer_anim_stopped: bool = false
var timer_speech_stopped: bool = false

func on_game_paused() -> void:
	timer_stopped = timer.paused
	timer_anim_stopped = animation_timer.paused
	timer_speech_stopped = speech_timer.paused
	
	timer.paused = true
	animation_timer.paused = true
	speech_timer.paused = true
	
func on_game_unpaused() -> void:
	timer.paused = timer_stopped
	animation_timer.paused = timer_anim_stopped
	speech_timer.paused = timer_speech_stopped

func pause_speaking() -> void:
	print("Pausing speaking")
	speech_timer.stop()
	speech_bubble.visible = false

func resume_speaking() -> void:
	speech_timer.start()
	speech_bubble.visible = true

func _on_speech_timer_timeout() -> void:

	if speech_bubble.custom_minimum_size.y < speech_label.size.y + 50:
		speech_bubble.custom_minimum_size.y = speech_label.size.y + 50

	if speechString.length() > 0:
		var char_to_add = speechString[0]
		labeltext += char_to_add
		if labeltext.length() > MAX_LABEL_LENGTH and char_to_add == " ":
			labeltext = ""
			speech_timer.wait_time = 3.0
			speech_timer.start()
			return

		speech_label.text = labeltext
		speechString = speechString.substr(1, speechString.length() - 1)
		speech_timer.wait_time = 1.0 / speech_speed
		speech_timer.start()

	elif labeltext.length() > 0:
		speech_timer.wait_time = 2.0
		speech_timer.start()
		labeltext = ""

	else:
		speech_bubble.visible = false
		speech_timer.stop()
		labeltext = ""
		
		Signals.emit_signal("guide_finished")
		
		print("guide finished")
