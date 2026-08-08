extends popup_ui

@export var machine_obj: StaticBody2D

@onready var slot_in: Panel = $PopupRoot/Panel/panel_left/slot_in
@onready var slot_out: Panel = $PopupRoot/Panel/panel_left/slot_out
@onready var grid_container: GridContainer = $PopupRoot/Panel/panel_right/Panel/ScrollContainer/GridContainer
@onready var progress_bar: ProgressBar = $PopupRoot/Panel/ProgressBar
@onready var btn_collect: Button = $PopupRoot/Panel/btnCOLLECT
@onready var crop_in_icon: TextureRect = $PopupRoot/Panel/panel_left/slot_in/CenterContainer/crop_in_rect
@onready var seed_out_icon: TextureRect = $PopupRoot/Panel/panel_left/slot_out/CenterContainer/seed_out_rect
@onready var crop_in_amt: Label = $PopupRoot/Panel/panel_left/slot_in/Label
@onready var seed_out_amt: Label = $PopupRoot/Panel/panel_left/slot_out/Label




var crop_slot_scene = preload("res://scenes/machines/crop_slot.tscn")

# Temporary until inventory integration
var selected_crop = preload("res://resources/crop_carrot.tres")
var selected_crop2 = preload("res://resources/crop_strawberry.tres")
var selected_amount := 2
var selected_inv_indx_ptr

var selected_slot: CropSlot = null



func _ready() -> void:
	crop_in_icon.texture = null
	seed_out_icon.texture = null
	crop_in_amt.text = ""
	seed_out_amt.text = ""

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
	populate_crop_grid()
	#populate_grid(crops_array)


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
	
	crop_in_amt.visible = false if crop_in_amt.text == "0" else true
	seed_out_amt.visible = false if seed_out_amt.text == "0" else true
	

func update_ui() -> void:

	btn_collect.visible = machine_obj.seeds_ready > 0

	update_input_slot()
	update_output_slot()

	# Optional labels later
	# lbl_remaining.text = str(machine_obj.crops_remaining)
	# lbl_ready.text = str(machine_obj.seeds_ready)

func open_ui():
	populate_crop_grid()
	update_ui()

## Add button
func _on_button_pressed() -> void:
	var ptr_to_inventory_slot = selected_inv_indx_ptr
	var tmp_selected_crop = selected_crop
	var tmp_selected_amount = selected_amount
	
	crop_in_icon.texture = selected_crop.icon
	crop_in_amt.text = str(selected_amount)
	
	# Remove crop from inventory
	StorageManager._remove_from_inventory_NoUI(ptr_to_inventory_slot)
	populate_crop_grid()
	machine_obj.start_processing(tmp_selected_crop, tmp_selected_amount)

## Collect button
func _on_btn_collect_pressed() -> void:

	machine_obj.collect()


func update_input_slot() -> void:

	var texture_rect = slot_in.get_child(0).get_child(0)
	var crop_num = crop_in_amt

	if machine_obj.input_crop:
		texture_rect.texture = machine_obj.input_crop.icon
		crop_num.text = str(machine_obj.crops_remaining)
	else:
		texture_rect.texture = null
		crop_num.text = ""


func update_output_slot() -> void:

	var texture_rect = slot_out.get_child(0).get_child(0)
	var seed_num = seed_out_amt

	if machine_obj.output_seed:
		texture_rect.texture = machine_obj.output_seed.icon
		seed_num.text = str(machine_obj.seeds_ready)
	else:
		texture_rect.texture = null
		seed_num.text = ""



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






func _on_crop_slot_selected(slot):

	if selected_slot:
		selected_slot.set_selected(false)

	selected_slot = slot
	selected_slot.set_selected(true)

	selected_crop = slot.crop_resource
	selected_amount = slot.crop_count
	selected_inv_indx_ptr = slot.inventory_slot_num




func populate_crop_grid():

	# Clear existing slots
	for child in grid_container.get_children():
		child.queue_free()

	selected_slot = null
	selected_crop = null


	for slot_index in GmMgr.PLAYER_INVENTORY_TEST_LARGE.keys():

		var slot = GmMgr.PLAYER_INVENTORY_TEST_LARGE[slot_index]

		var resource_path = slot[0]
		var quantity = slot[1]
		var enabled = slot[2]

		if resource_path == null:
			continue

		if int(quantity) <= 0:
			continue

		if !enabled:
			continue

		var item = load(resource_path)

		if item == null:
			continue

	# Only allow crops to appear
		if item.item_type != Enum.ItemType.keys()[Enum.ItemType.crop]:
			continue

		var crop_slot = crop_slot_scene.instantiate()

		crop_slot.setup(item, quantity, slot_index)
		crop_slot.selected.connect(_on_crop_slot_selected)

		grid_container.add_child(crop_slot)


func find_anywhere(name1: String) -> Node:
	var tree := get_tree()
	
	# 1. Try to get autoloads
	var autoloads = ProjectSettings.get_setting("application/config/autoloads")
	if autoloads != null:
		for autoload_name in autoloads.keys():
			var singleton = tree.get_first_node_in_group(autoload_name)
			if singleton:
				if singleton.name == name1:
					return singleton
				var found = singleton.find_child(name1, true)
				if found:
					return found

	# 2. Try current scene
	if tree:
		if tree.current_scene:
			var found = tree.current_scene.find_child(name1, true)
			if found:
				return found

	# 3. Try the root (includes autoloads + main viewport)
	return tree.root.find_child(name1, true, false)



# Bottom
