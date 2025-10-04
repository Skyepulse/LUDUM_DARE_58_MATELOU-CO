extends Node

# Const layer mask
var sprite: Sprite2D = null
var grabPoints: Array[Node2D] = []
var numGrabPoints: int = 0
var hitbox: Area2D = null

func _ready():
	sprite = $Sprite
	hitbox = $ObjectHitbox

	var grabPointsRoot = $GrabPoints
	for child in grabPointsRoot.get_children():
		if child is Node2D:
			grabPoints.append(child)
			numGrabPoints += 1
		else:
			push_error("Child of GrabPoints is not a Node2D: %s" % child.name)
