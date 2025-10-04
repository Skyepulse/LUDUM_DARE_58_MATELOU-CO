extends Node2D

@onready var rayBox: Area2D = $RayBox
@onready var rayVisual: Polygon2D = $RayBox/Visual

@export var rayLength: float = 100.0
@export var rayWidth: float = 60.0
@export var initRotation: float = 0.0
@export var suspicionIncreaseRate: float = 5.0 # Per Second

var enteredTimes: int = 0
var flag: bool = false

func _ready():
    setPoints(rayLength, rayWidth)
    rotateCamera(initRotation)

func _process(delta: float) -> void:
    if flag:
        GameManager.increaseSuspicion(suspicionIncreaseRate * delta)

func setPoints(length: float, width: float):
    var shape := ConvexPolygonShape2D.new()
    shape.points = [
        Vector2(0, 10),
        Vector2(length, width / 2),
        Vector2(length, -width / 2),
        Vector2(0, -10),
    ]

    var collisionShape := rayBox.get_node("CollisionShape2D") as CollisionShape2D
    if collisionShape:
        collisionShape.shape = shape
        rayVisual.polygon = shape.points

func changeRay(length: float, width: float):
    rayLength = length
    rayWidth = width
    setPoints(rayLength, rayWidth)

func rotateCamera(degrees_val: float):
    rotation_degrees = wrapf(degrees_val, 0.0, 360.0)

func _on_ray_box_area_entered(area: Area2D) -> void:
    if GameManager.isHandRetracting():
        return

    if area.is_in_group("Player"):

        enteredTimes += 1
        print("Player detected! Entered times: %d" % enteredTimes)

        flag = true

func _on_ray_box_area_exited(area: Area2D) -> void:
    if not flag:
        return

    if area.is_in_group("Player"):
        if GameManager.isHandRetracting():
            enteredTimes -= 1

            print("Player exited! Entered times: %d" % enteredTimes)
            if enteredTimes <= 0:
                enteredTimes = 0
            else:
                return

            flag = false
            print("Player lost!")

        