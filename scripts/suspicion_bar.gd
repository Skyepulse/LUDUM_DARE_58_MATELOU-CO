extends CenterContainer

@onready var progress_bar: ProgressBar = $ProgressBar

var minVal: float = 0.0
@export var maxVal: float = 100.0
var currentVal: float = 0.0

func _ready():
	progress_bar.min_value = minVal
	progress_bar.max_value = maxVal
	progress_bar.value = currentVal

func hideSuspicionBar():
	progress_bar.visible = false

func showSuspicionBar():
	progress_bar.visible = true
