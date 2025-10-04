extends Node

@onready var suspicionBar: ProgressBar = $Suspicion/ProgressBar
@export var maxVal: float = 100.0
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
