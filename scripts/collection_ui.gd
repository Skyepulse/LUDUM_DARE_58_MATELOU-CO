extends Control

@onready var scroll: ScrollContainer = $ScrollContainer
@onready var vbox: VBoxContainer = $ScrollContainer/VBoxContainer

const CELL_WIDTH: int = 200
const CELL_HEIGHT: int = 200

const CELL_BY_ROW: int = 4

var sorted_indices: Array = []
var horizontal_boxes: Array[HBoxContainer] = []

func _ready() -> void:
	if scroll == null or vbox == null:
		push_error("ScrollContainer or VBoxContainer not found in MainUI!")
		return

func initialize_collection_ui() -> void:

	print("Initializing Collection UI...")
	vbox.add_theme_constant_override("separation", 25)
	
	var row := make_row()

	var all_indices = GameManager.all_indices
	all_indices.sort()

	sorted_indices = all_indices

	for index in all_indices:
		var info = GameManager.get_object_info(index)
		if info == null:
			push_error("GameManager: No object info found for index %d" % index)
			continue

		var cell := Panel.new()
		cell.custom_minimum_size = Vector2(CELL_WIDTH, CELL_HEIGHT)

		var sb := StyleBoxFlat.new()
		sb.bg_color = Color(0.1, 0.1, 0.1, 0.5)
		sb.corner_radius_top_left = 8
		sb.corner_radius_top_right = 8
		sb.corner_radius_bottom_left = 8
		sb.corner_radius_bottom_right = 8
		cell.add_theme_stylebox_override("panel", sb)

		var texture_panel: TextureRect = TextureRect.new()
		texture_panel.custom_minimum_size = Vector2(CELL_WIDTH, CELL_HEIGHT)
		
		texture_panel.size_flags_horizontal = 0
		texture_panel.size_flags_vertical   = 0
		texture_panel.expand_mode = TextureRect.EXPAND_IGNORE_SIZE

		texture_panel.texture = info.texture

		cell.add_child(texture_panel)
		row.add_child(cell)

		if row.get_child_count() >= CELL_BY_ROW - 1:
			row = make_row()

	print("Vertical children count: %d" % vbox.get_child_count())
	for hbox in horizontal_boxes:
		print("HBox children count: %d" % hbox.get_child_count())

func make_row() -> HBoxContainer:
	var row := HBoxContainer.new()
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.custom_minimum_size = Vector2(0, CELL_HEIGHT)
	row.add_theme_constant_override("separation", 55)
	vbox.add_child(row)
	horizontal_boxes.append(row)
	return row
