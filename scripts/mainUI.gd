extends Node

@onready var suspicionBar: ProgressBar = $Suspicion/ProgressBar
@export var maxVal: float = 100.0

@onready var collection_ui: Control = $Collection/CollectionPanel

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

func initialize_collection_ui() -> void:
	if collection_ui == null:
		push_error("MainUI: Collection UI not found!")
		return
	collection_ui.call_deferred("initialize_collection_ui")