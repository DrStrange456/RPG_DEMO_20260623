extends popup_ui

@export var machine_obj: StaticBody2D

@onready var slot_in: Panel = $PopupRoot/Panel/panel_left/slot_in
@onready var slot_out: Panel = $PopupRoot/Panel/panel_left/slot_out
@onready var grid_container: GridContainer = $PopupRoot/Panel/panel_right/GridContainer
@onready var progress_bar: ProgressBar = $PopupRoot/Panel/ProgressBar
@onready var btn_collect: Button = $PopupRoot/Panel/btnCOLLECT

# Temporary until inventory integration
var selected_crop = preload("res://resources/crop_carrot.tres")
var selected_amount := 2


func _ready() -> void:

	if machine_obj == null:
		push_error("Seed Maker UI: machine_obj is not assigned.")
		return

	# Connect to machine signals
	machine_obj.processing_started.connect(update_ui)
	machine_obj.seed_produced.connect(update_ui)
	machine_obj.processing_finished.connect(update_ui)
	machine_obj.seeds_collected.connect(update_ui)
	machine_obj.state_changed.connect(update_ui)

	update_ui()


func _process(_delta: float) -> void:

	if machine_obj == null:
		return

	if machine_obj.state == machine_obj.State.PROCESSING:
		progress_bar.visible = true

		progress_bar.value = (
			(machine_obj.timer.wait_time - machine_obj.timer.time_left)
			/ machine_obj.timer.wait_time
		) * 100.0
	else:
		progress_bar.visible = false
		progress_bar.value = 0


func update_ui() -> void:

	btn_collect.visible = machine_obj.seeds_ready > 0

	update_input_slot()
	update_output_slot()

	# Optional labels later
	# lbl_remaining.text = str(machine_obj.crops_remaining)
	# lbl_ready.text = str(machine_obj.seeds_ready)


func _on_button_pressed() -> void:

	machine_obj.start_processing(selected_crop, selected_amount)


func _on_btn_collect_pressed() -> void:

	machine_obj.collect()


func update_input_slot() -> void:

	var texture_rect = slot_in.get_child(0).get_child(0)

	if machine_obj.input_crop:
		texture_rect.texture = machine_obj.input_crop.icon
	else:
		texture_rect.texture = null


func update_output_slot() -> void:

	var texture_rect = slot_out.get_child(0).get_child(0)

	if machine_obj.output_seed:
		texture_rect.texture = machine_obj.output_seed.icon
	else:
		texture_rect.texture = null


func _move_selected_to_in() -> void:

	var gv_items = grid_container.get_children()

	if gv_items.is_empty():
		return

	var item_from_grid = gv_items[0].get_child(0).get_child(0)
	var destination = slot_in.get_child(0).get_child(0)

	destination.texture = item_from_grid.texture


func _on_button_2_pressed() -> void:

	_reset()


func _reset() -> void:

	var input_texture = slot_in.get_child(0).get_child(0)
	input_texture.texture = null

	var output_texture = slot_out.get_child(0).get_child(0)
	output_texture.texture = null



# Bottom
