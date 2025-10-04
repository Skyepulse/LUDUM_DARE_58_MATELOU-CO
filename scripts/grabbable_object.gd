extends Node

class_name GrabbableObject

# Const layer mask
@onready var sprite: Sprite2D = $Sprite
@onready var hitbox: Area2D = $ObjectHitbox

@export var objectName: String = "No Name"
@export var objectDescription: String = "No Description"

var grabPoints: Array[Node2D] = []
var numGrabPoints: int = 0

func getName() -> String:
	return objectName

func getDescription() -> String:
	return objectDescription

func _ready():

	var grabPointsRoot = $GrabPoints
	for child in grabPointsRoot.get_children():
		if child is Node2D:
			grabPoints.append(child)
			numGrabPoints += 1
		else:
			push_error("Child of GrabPoints is not a Node2D: %s" % child.name)
