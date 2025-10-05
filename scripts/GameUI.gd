extends Control

@onready var menu: Control = $Menu
@onready var play_button: Button = $Menu/PlayButton
@onready var collection_button: Button = $Menu/CollectionButton
@onready var credit_button: Button = $Menu/CreditButton
@onready var quit_button: Button = $Menu/QuitButton

@onready var collection_panel: Panel = $Collection/CollectionPanel

var screenSize:Vector2

const PLAY_TEXT: String = "PLAY"
const COLLECTION_TEXT: String = "COLLECTION"
const CREDIT_TEXT: String = "CREDIT"
const QUIT_TEXT: String = "QUIT"

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
	
func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed():
		if event.keycode == KEY_ESCAPE:
			escape_is_pressed()

func escape_is_pressed() -> void:
	if Signals.game_state == Signals.INGAME:
		Signals.game_state = Signals.PAUSED
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
	
func collection_button_is_pressed() -> void:
	Signals.game_state = Signals.COLLECTION
	menu.visible = false
	collection_panel.show_collection()
	
