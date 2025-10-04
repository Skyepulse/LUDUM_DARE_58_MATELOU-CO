extends Node

# Suspicion meter
@export var maxSuspicion: int = 100
var currentSuspicion: int = 0

func _ready():
    if maxSuspicion <= 0:
        maxSuspicion = 100
        
    currentSuspicion = 0
