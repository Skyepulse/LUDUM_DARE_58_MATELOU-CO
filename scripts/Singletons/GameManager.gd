extends Node

class CollectedObjectInfo:
	var index: int
	var name: String
	var description: String
	var count: int
	var scene: PackedScene
	var texture: Texture2D

# Suspicion meter
@export var maxSuspicion: float = 100.0
@export var suspicionDecayRate: float = 0.5 # Per Second
@export var decreaseTimer: float = 1.5 # Seconds without increase before decay starts

@export var all_possible_objects: Array[PackedScene] = []

@onready var suspicionDecayTimer: Timer = $DecreaseSuspicionTimer

var Player: Path2D = null # Player
var Guide: Node2D = null # Guide NPC

var currentSuspicion: float = 0.0
var canDecrease: bool = true

var CollectedDictionary: Dictionary = {}
var infoDictionary: Dictionary = {}
var all_indices: Array = []

var level_index:int = 0

func _ready():

	CollectedDictionary.clear()
	for obj in all_possible_objects:
		if obj == null:
			push_error("GameManager: One of the all_possible_objects is null!")
			continue
		var inst := obj.instantiate()
		if inst == null:
			push_error("GameManager: Failed to instantiate one of the all_possible_objects!")
			continue
		
		var index = inst.get("INDEX")
		if typeof(index) == TYPE_NIL:
			push_error("GameManager: One of the all_possible_objects does not have an INDEX property!")
			continue
		else:
			if CollectedDictionary.has(index):
				push_error("GameManager: Duplicate INDEX value in all_possible_objects: %s" % str(index))
			else:
				all_indices.append(index)
				CollectedDictionary[index] = 0
				infoDictionary[index] = CollectedObjectInfo.new()
				infoDictionary[index].name = inst.get("objectName")
				infoDictionary[index].description = inst.get("objectDescription")
				infoDictionary[index].index = index
				infoDictionary[index].count = 0
				infoDictionary[index].scene = obj
				infoDictionary[index].texture = inst.get("texture")

		inst.queue_free()      

	suspicionDecayTimer.wait_time = decreaseTimer
	suspicionDecayTimer.stop()

	suspicionDecayTimer.timeout.connect(_on_decrease_suspicion_timer_timeout)

	if maxSuspicion <= 0:
		maxSuspicion = 100.0

func isHandRetracting() -> bool:
	if Player:
		return Player.retracting
	else:
		print("[ERROR] GameManager: Player reference is null!")
	return false

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

func get_collected_count() -> int:
	var count = 0
	for key in CollectedDictionary.keys():
		if CollectedDictionary[key] > 0:
			count += 1
	return count

func collect_object(index: int) -> void:
	if CollectedDictionary.has(index):
		CollectedDictionary[index] += 1
		if infoDictionary.has(index):
			infoDictionary[index].count += 1
		else:
			push_error("GameManager: Collected object with index %d has no info entry!" % index)
	else:
		push_error("GameManager: Attempted to collect object with invalid index: %s" % str(index))

func is_object_collected(index: int) -> bool:
	if CollectedDictionary.has(index):
		return CollectedDictionary[index] > 0
	else:
		push_error("GameManager: Attempted to check collected status of object with invalid index: %s" % str(index))
		return false

func get_object_info(index: int) -> CollectedObjectInfo:
	if infoDictionary.has(index):
		return infoDictionary[index]
	else:
		push_error("GameManager: Attempted to get info of object with invalid index: %s" % str(index))
		return null
