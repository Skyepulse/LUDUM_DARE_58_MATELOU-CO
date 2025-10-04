extends Node

# Suspicion meter
@export var maxSuspicion: float = 100.0
@export var suspicionDecayRate: float = 0.5 # Per Second
@export var decreaseTimer: float = 1.5 # Seconds without increase before decay starts

@onready var suspicionDecayTimer: Timer = $DecreaseSuspicionTimer

var Player: Path2D = null # Player

var currentSuspicion: float = 0.0
var canDecrease: bool = true

func _ready():

    suspicionDecayTimer.wait_time = decreaseTimer
    suspicionDecayTimer.stop()

    suspicionDecayTimer.connect("timeout", Callable(self, "_on_decrease_suspicion_timer_timeout"))

    if maxSuspicion <= 0:
        maxSuspicion = 100.0

func _process(delta: float):
    if canDecrease:
        decreaseSuspicion(suspicionDecayRate * delta)

func increaseSuspicion(amount: float):
    currentSuspicion = clamp(currentSuspicion + amount, 0, maxSuspicion)
    MainCamera2D.MainUI.setSuspicion(currentSuspicion)

    suspicionDecayTimer.stop()
    suspicionDecayTimer.wait_time = decreaseTimer
    suspicionDecayTimer.start()
    canDecrease = false

func decreaseSuspicion(amount: float):
    currentSuspicion = clamp(currentSuspicion - amount, 0, maxSuspicion)
    MainCamera2D.MainUI.setSuspicion(currentSuspicion)

func _on_decrease_suspicion_timer_timeout():
    canDecrease = true