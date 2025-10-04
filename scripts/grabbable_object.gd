extends Node

# Const layer mask
@onready var sprite: Sprite2D = $Sprite
@onready var hitbox: Area2D = $ObjectHitbox

var grabPoints: Array[Node2D] = []
var numGrabPoints: int = 0

func _ready():

	var grabPointsRoot = $GrabPoints
	for child in grabPointsRoot.get_children():
		if child is Node2D:
			grabPoints.append(child)
			numGrabPoints += 1
		else:
			push_error("Child of GrabPoints is not a Node2D: %s" % child.name)
