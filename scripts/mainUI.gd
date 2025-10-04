extends Node

@onready var suspicionBar: ProgressBar = $Suspicion/ProgressBar
@export var maxVal: int = 100
var minVal: int = 0
var currentVal: int = 0

func _ready():
    suspicionBar.min_value = minVal
    suspicionBar.max_value = maxVal
    suspicionBar.value = currentVal

func setSuspicion(value: int):
    currentVal = clamp(value, minVal, maxVal)
    suspicionBar.value = currentVal

func hideSuspicionBar():
    suspicionBar.visible = false

func showSuspicionBar():
    suspicionBar.visible = true


