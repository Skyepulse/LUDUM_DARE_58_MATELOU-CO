extends Control

@onready var menu: Control = $Menu
@onready var play_button: Button = $Menu/PlayButton
@onready var collection_button: Button = $Menu/CollectionButton
@onready var credit_button: Button = $Menu/CreditButton
@onready var quit_button: Button = $Menu/QuitButton

@onready var collection_panel: Panel = $Collection/CollectionPanel
@onready var suspicion_bar: CenterContainer = $SuspicionBar
@onready var progress_bar: ProgressBar = $SuspicionBar/ProgressBar
@onready var effects: Control = $Effects
@onready var vignette: TextureRect = $Effects/Vignette
@onready var timer: Timer = $Timer

@export var vignette_animation_time: float = 1.0
@export var vignette_max_radius: float = 1.0
@export var vignette_min_radius: float = 0.6

var screenSize:Vector2

const PLAY_TEXT: String = "PLAY"
const COLLECTION_TEXT: String = "COLLECTION"
const CREDIT_TEXT: String = "CREDIT"
const QUIT_TEXT: String = "QUIT"

var currentVal: float = 0.0

func setSuspicion(value: float):
	currentVal = clamp(value, suspicion_bar.minVal, suspicion_bar.maxVal)
	progress_bar.value = currentVal

func _ready() -> void:
	screenSize = get_viewport().get_visible_rect().size
	menu.position = screenSize/2
	
	play_button.text = PLAY_TEXT
	play_button.position.y = -7.5*play_button.size.y
	
	collection_button.text = COLLECTION_TEXT
	collection_button.position.y = -2.5*collection_button.size.y
	
	credit_button.text = CREDIT_TEXT
	credit_button.position.y = 2.5*credit_button.size.y
	
	quit_button.text = QUIT_TEXT
	quit_button.position.y = 7.5*quit_button.size.y
	
	collection_panel.hide_collection()
	suspicion_bar.hideSuspicionBar()

	timer.timeout.connect(_on_Timer_timeout)
	vignette.visible = false
	vignette.material.set_shader_parameter("inner_radius", vignette_max_radius)

	Signals.connect("activate_vignette_effect", play_vignette_animation)
	
func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed():
		if event.keycode == KEY_ESCAPE:
			escape_is_pressed()

func escape_is_pressed() -> void:
	if Signals.game_state == Signals.INGAME:
		Signals.game_state = Signals.PAUSED
		suspicion_bar.hideSuspicionBar()
		menu.visible = true
	elif Signals.game_state == Signals.COLLECTION:
		Signals.game_state = Signals.PAUSED
		collection_panel.hide_collection()
		menu.visible = true
	elif Signals.game_state == Signals.CREDIT:
		Signals.game_state = Signals.PAUSED
		menu.visible = true
		
func play_button_is_pressed() -> void:
	Signals.game_state = Signals.INGAME
	menu.visible = false
	suspicion_bar.showSuspicionBar()
	
func collection_button_is_pressed() -> void:
	Signals.game_state = Signals.COLLECTION
	menu.visible = false
	collection_panel.show_collection()
	
func play_vignette_animation():
	vignette.visible = true
	timer.wait_time = vignette_animation_time
	timer.start()

func _process(_delta: float) -> void:

	if timer.time_left == 0.0:
		return

	var time_left = timer.time_left
	var half_time = vignette_animation_time / 2.0
	if time_left > half_time:
		var t = (vignette_animation_time - time_left) / half_time
		var radius = lerp(vignette_max_radius, vignette_min_radius, t)
		vignette.material.set_shader_parameter("inner_radius", radius)
	else:
		var t = (half_time - time_left) / half_time
		var radius = lerp(vignette_min_radius, vignette_max_radius, t)
		vignette.material.set_shader_parameter("inner_radius", radius)

func _on_Timer_timeout() -> void:
	vignette.visible = false
	timer.stop()
