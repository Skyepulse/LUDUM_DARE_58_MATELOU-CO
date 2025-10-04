extends Node

class_name GrabbableObject

# Const layer mask
@onready var sprite: Sprite2D = $Sprite2D
@onready var hitbox: Area2D = $ObjectHitbox

@export var objectName: String = "No Name"
@export var objectDescription: String = "No Description"

@onready var object_root: GrabbableObject = $"."


var grabPoints: Array[Node2D] = []
var numGrabPoints: int = 0

var handOnObject: bool = false

func getDistanceToHand(handPos: Vector2) -> float:
	var minDist = INF
	for grabPoint in grabPoints:
		var dist = grabPoint.global_position.distance_to(handPos)
		if dist < minDist:
			minDist = dist
	return minDist

func getName() -> String:
	return objectName

func getDescription() -> String:
	return objectDescription

func set_position(pos: Vector2) -> void:
	object_root.position = pos

func _ready():
	var grabPointsRoot = $GrabPoints
	for child in grabPointsRoot.get_children():
		if child is Node2D:
			grabPoints.append(child)
			numGrabPoints += 1
		else:
			push_error("Child of GrabPoints is not a Node2D: %s" % child.name)
