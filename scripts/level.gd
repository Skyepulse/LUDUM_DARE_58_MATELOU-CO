extends Node2D

@export var possible_objects: Array[Node2D] = []

func _ready():
    return

func startup_scene(no_index: int):
    var pool = possible_objects.duplicate()

    var random_object: Node2D = pool[randi() % pool.size()]
    
    if random_object.get("INDEX") == no_index:
        pool.erase(random_object)
        random_object = pool[randi() % pool.size()]

    for obj in possible_objects:
        if obj == null or obj.get("INDEX") != random_object.get("INDEX"):
            obj.visible = false
            obj.queue_free()
            print("Freed an unselected object")

    return random_object.get("INDEX")