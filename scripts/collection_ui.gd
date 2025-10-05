extends Control

@onready var scroll: ScrollContainer = $ScrollContainer
@onready var vbox: VBoxContainer = $ScrollContainer/VBoxContainer

const CELL_WIDTH: int = 100
const CELL_HEIGHT: int = 200

const CELL_BY_ROW: int = 4

func _ready() -> void:
	if scroll == null or vbox == null:
		push_error("ScrollContainer or VBoxContainer not found in MainUI!")
		return

func initialize_collection_ui() -> void:
	return