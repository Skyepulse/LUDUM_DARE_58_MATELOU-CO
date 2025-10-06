extends Control

@onready var scroll: ScrollContainer = $ScrollContainer
@onready var vbox: VBoxContainer = $ScrollContainer/VBoxContainer
# Brother node
@onready var textLabel: RichTextLabel = $"../ExplanationPanel/RichTextLabel"
@export var missingTexture: Texture2D

const DEFAULT_TEXT: String = "Hover an object to check if you have collected it, and read it's description!"
const CELL_WIDTH: int = 200
const CELL_HEIGHT: int = 200

const CELL_BY_ROW: int = 4

var sorted_indices: Array = []
var horizontal_boxes: Array[HBoxContainer] = []

@export var visibility: bool = false

func _ready() -> void:
	if scroll == null or vbox == null:
		push_error("ScrollContainer or VBoxContainer not found in MainUI!")
		return

	textLabel.text = DEFAULT_TEXT
	self.get_parent().visible = false

func show_collection():
	initialize_collection_ui()
	self.get_parent().visible = true
	visibility = true
	print("WATCHING COLLECTION")

func hide_collection():
	self.get_parent().visible = false
	visibility = false

func initialize_collection_ui() -> void:

	textLabel.text = DEFAULT_TEXT

	for hbox in horizontal_boxes:
		for cell in hbox.get_children():
			cell.disconnect("mouse_entered", Callable(self, "update_explanation"))
			cell.disconnect("mouse_exited", Callable(self, "update_explanation"))
			cell.queue_free()
		hbox.queue_free()
	horizontal_boxes.clear()

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

		if info.count <= 0:
			texture_panel.texture = missingTexture
		else:
			if info.texture == null:
				push_error("GameManager: Object with index %d has no texture!" % index)
				texture_panel.texture = missingTexture
			else:
				texture_panel.texture = info.texture

		cell.add_child(texture_panel)
		row.add_child(cell)

		# Cell on hover call update explanation on index
		cell.mouse_entered.connect(Callable(self, "update_explanation").bind(index, cell))
		cell.mouse_exited.connect(Callable(self, "update_explanation").bind(-1, cell))

		if row.get_child_count() >= CELL_BY_ROW - 1:
			row = make_row()

func make_row() -> HBoxContainer:
	var row := HBoxContainer.new()
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.custom_minimum_size = Vector2(0, CELL_HEIGHT)
	row.add_theme_constant_override("separation", 55)
	vbox.add_child(row)
	horizontal_boxes.append(row)
	return row

func update_explanation(index: int, cell: Control) -> void:
	if index == -1:
		cell.modulate = Color(1, 1, 1, 1)
		return

	cell.modulate = Color(1, 1, 1, 0.7)
	var info = GameManager.get_object_info(index)
	if info == null:
		push_error("GameManager: No object info found for index %d" % index)
		return

	var string: String = "[b]%s[/b]\n\n[color=green]Collected: %d[/color]\n\n%s" % [info.name, info.count, info.description]
	textLabel.bbcode_enabled = true

	if info.count <= 0:
		string = "\n\n[color=red]You have not collected this item yet! You should consider stealing it... ;)![/color]"
	textLabel.text = string
	


func _on_show_collection_button_pressed() -> void:
	if visibility:
		hide_collection()
	else:
		show_collection()
