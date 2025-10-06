extends Control

@onready var collection_panel: Panel = $Collection/Collection/CollectionPanel
@onready var collection_root: Control = $Collection
@onready var suspicion_bar: CenterContainer = $SuspicionBar
@onready var progress_bar: ProgressBar = $SuspicionBar/ProgressBar
@onready var effects: Control = $Effects
@onready var vignette: TextureRect = $Effects/Vignette
@onready var timer: Timer = $Timer
@onready var gameOverScreen: Control = $GameOverScreen
@onready var main_menu: Control = $MainMenu
@onready var next_level_text = $NextLevelInfo/RichTextLabel
@onready var next_level_root = $NextLevelInfo
@onready var credits = $Credits

@export var vignette_animation_time: float = 1.0
@export var vignette_max_radius: float = 1.0
@export var vignette_min_radius: float = 0.6

var state_entered_from_collection = Signals.PAUSED

var screenSize:Vector2

var currentVal: float = 0.0

func setSuspicion(value: float):
	currentVal = clamp(value, suspicion_bar.minVal, suspicion_bar.maxVal)
	progress_bar.value = currentVal

func _ready() -> void:
	screenSize = get_viewport().get_visible_rect().size
	
	collection_panel.hide_collection()
	suspicion_bar.hideSuspicionBar()

	timer.timeout.connect(_on_Timer_timeout)
	vignette.visible = false
	vignette.material.set_shader_parameter("inner_radius", vignette_max_radius)

	Signals.connect("activate_vignette_effect", play_vignette_animation)

	gameOverScreen.visible = false
	Signals.connect("game_over", show_game_over_screen)
	Signals.connect("restart_game", hide_game_over_screen)

	main_menu.visible = true
	next_level_root.visible = false
	credits.visible = false
	
func collection_button_is_pressed() -> void:
	collection_root.visible = true
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

func show_game_over_screen() -> void:
	gameOverScreen.visible = true
	suspicion_bar.hideSuspicionBar()
	collection_panel.hide_collection()
	Signals.game_state = Signals.PAUSED

func hide_game_over_screen() -> void:
	gameOverScreen.visible = false

func _on_restart_button_pressed() -> void:
	GameManager.startGame()

func _on_see_collection_button_pressed() -> void:
	collection_button_is_pressed()

func _on_start_game_button_pressed() -> void:
	main_menu.visible = false
	GameManager.startGame()

func _on_quit_pressed() -> void:
	get_tree().quit()

func show_main_menu() -> void:
	main_menu.visible = true
	Signals.game_state = Signals.START

	Signals.emit_signal("set_input", false)
	Signals.emit_signal("main_menu")

	collection_panel.hide_collection()
	collection_root.visible = false
	
	suspicion_bar.hideSuspicionBar()
	gameOverScreen.visible = false

func _on_menu_button_pressed() -> void:
	show_main_menu()

func _on_hide_collection_pressed() -> void:
	collection_root.visible = false
	collection_panel.hide_collection()

func set_next_level_text(text: String) -> void:
	next_level_text.bbcode_text = text
	next_level_root.visible = true

func hide_next_level_text() -> void:
	next_level_root.visible = false


func _on_return_to_menu_from_credits_pressed() -> void:
	credits.visible = false
	main_menu.visible = true

func _on_credits_pressed() -> void:
	credits.visible = true
	main_menu.visible = false
