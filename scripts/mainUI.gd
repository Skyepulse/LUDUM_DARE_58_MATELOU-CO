extends Node

@onready var suspicionBar: ProgressBar = $Suspicion/ProgressBar
@export var maxVal: float = 100.0

const SHOW_TEXT: String = "SHOW COLLECTION"
const HIDE_TEXT: String = "HIDE COLLECTION"

@onready var collection_ui: Control = $Collection/CollectionPanel
@onready var showCollectionButton: Button = $"Show Collection Button"

var minVal: float = 0.0
var currentVal: float = 0.0

func _ready():
	suspicionBar.min_value = minVal
	suspicionBar.max_value = maxVal
	suspicionBar.value = currentVal

func setSuspicion(value: float):
	currentVal = clamp(value, minVal, maxVal)
	suspicionBar.value = currentVal

func hideSuspicionBar():
	suspicionBar.visible = false

func showSuspicionBar():
	suspicionBar.visible = true

func _on_show_collection_button_pressed() -> void:
	var visibility = collection_ui.get("visibility")
	if visibility:
		showCollectionButton.text = SHOW_TEXT
	else:
		showCollectionButton.text = HIDE_TEXT