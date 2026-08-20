extends Control


# ==============================================================================
# STORAGE DATA
# ==============================================================================

@export var storage_controller: GridContainer
@export var number_of_slots: int

@onready var storage_core_data = storage_data_core.new()
@onready var core_inventory: Dictionary = storage_core_data.DATA

@onready var core_inventory_controller_strg: GridContainer = (
	$"../Storage_InventoryControl/Panel/Storage_CoreInventoryController"
)

var new_slot = preload("res://Inventory/inventory_slot_ui.tscn")


# ==============================================================================
# STORAGE SLOTS
# ==============================================================================

var inventory: Array[OptiInventorySlot] = []


# ==============================================================================
# INITIALIZATION
# ==============================================================================

func _ready() -> void:
	initialize()


func initialize() -> void:
	_load_slots_from_save(storage_controller)


func _load_slots_from_save(slots: GridContainer) -> void:
	_create_inventory_slots()
	_bind_inventory_to_ui(slots)
	_connect_ui_slots(slots)
	_load_saved_items()


# ==============================================================================
# CREATE STORAGE SLOTS
# ==============================================================================

func _create_inventory_slots() -> void:
	inventory.resize(core_inventory.size())

	for index in inventory.size():
		inventory[index] = OptiInventorySlot.new()


# ==============================================================================
# CONNECT STORAGE UI SLOTS
# ==============================================================================

func _connect_ui_slots(slots: GridContainer) -> void:
	for index in slots.get_child_count():
		slots._set_slot(index)


# ==============================================================================
# LOAD SAVED STORAGE ITEMS
# ==============================================================================

func _load_saved_items() -> void:

	if core_inventory.is_empty():
		return

	for index in inventory.size():

		if core_inventory[index][0] == null:
			continue

		if int(core_inventory[index][1]) <= 0:
			continue

		inventory[index].indx = index
		inventory[index].set_item(
			load(core_inventory[index][0])
		)
		inventory[index].set_quantity(
			core_inventory[index][1]
		)


# ==============================================================================
# BIND STORAGE DATA TO UI
# ==============================================================================

func _bind_inventory_to_ui(slots: GridContainer) -> void:

	var ui_slots = slots.get_children()

	for index in ui_slots.size():
		ui_slots[index].bind_slot(
			inventory[index]
	)


# ==============================================================================
# STORAGE SIZE
# ==============================================================================

func _extend_inventory() -> void:
	set_storage_size_data(20)
	set_storage_size_ui(20)


func set_storage_size_data(amount: int) -> void:

	var current_size := core_inventory.size()

	for index in range(current_size, amount):
		core_inventory[index] = [null, 0, true]


func set_storage_size_ui(amount: int) -> void:

	var current_size := storage_controller.get_child_count()

	for index in range(current_size, amount):

		var new_slot_instance = new_slot.instantiate()

		new_slot_instance.indx = index
		new_slot_instance.custom_minimum_size = Vector2(40, 40)
		new_slot_instance._reset_slot()
		new_slot_instance.slot = OptiInventorySlot.new()

		storage_controller.add_child(new_slot_instance)

	initialize()


# ==============================================================================
# RESET STORAGE
# ==============================================================================

func _reset_inventory() -> void:
	_reset_dictionary_core_data()
	_reset_inventory_ui(20)


func _reset_dictionary_core_data() -> void:

	const INVENTORY_ORIGINAL: Dictionary = {
		0: [null, 0, true],
		1: [null, 0, true],
		2: [null, 0, true],
		3: [null, 0, true],
		4: [null, 0, true],
		5: [null, 0, true],
		6: [null, 0, true],
		7: [null, 0, true],
		8: [null, 0, true],
		9: [null, 0, true],
		10: [null, 0, true],
		11: [null, 0, true],
		12: [null, 0, true],
		13: [null, 0, true],
		14: [null, 0, true],
		15: [null, 0, true],
		16: [null, 0, true],
		17: [null, 0, true],
		18: [null, 0, true],
		19: [null, 0, true],
	}

	var storage_inventory = core_inventory

	# Reset storage data.
	storage_inventory.clear()

	for index in INVENTORY_ORIGINAL:
		storage_inventory[index] = INVENTORY_ORIGINAL[index].duplicate()

	# Refresh storage UI.
	for index in range(INVENTORY_ORIGINAL.size()):
		storage_controller.get_child(index).update_ui()


func _reset_inventory_size(amount: int) -> void:

	# Remove data slots above the requested size.
	for index in range(
		InvCore.INVENTORY.size() - 1,
		amount - 1,
		-1
	):
		InvCore.INVENTORY.erase(index)

	# Remove UI slots above the requested size.
	for index in range(
		storage_controller.get_child_count() - 1,
		amount - 1,
		-1
	):
		storage_controller.get_child(index).free()


func _reset_inventory_ui(amount: int) -> void:

	# Remove slots above the requested size.
	for index in range(
		storage_controller.get_child_count() - 1,
		amount - 1,
		-1
	):
		storage_controller.get_child(index).free()


	# Reset existing slots.
	var current_size := storage_controller.get_child_count()

	for index in range(current_size):

		var ui_slot = storage_controller.get_child(index)

		ui_slot.indx = index
		ui_slot._reset_slot()
		ui_slot.slot = OptiInventorySlot.new()


	# Add missing slots.
	for index in range(current_size, amount):

		var new_slot_instance = new_slot.instantiate()

		new_slot_instance.indx = index
		new_slot_instance.custom_minimum_size = Vector2(40, 40)
		new_slot_instance._reset_slot()
		new_slot_instance.slot = OptiInventorySlot.new()

		storage_controller.add_child(new_slot_instance)


	# Rebuild and refresh storage UI.
	initialize()


# ==============================================================================
# SORT AND COMBINE
# ==============================================================================

func sort_and_combine_inventory_Inv() -> void:

	var item_totals := {}


	# ------------------------------------------------------------------------------
	# Collect the total quantity for each item type.
	# ------------------------------------------------------------------------------

	for slot_index in core_inventory.keys():

		var slot = core_inventory[slot_index]
		var item_path = slot[0]
		var quantity = slot[1]

		if item_path == null:
			continue

		var item

		if item_path is String:
			item = load(item_path)
		else:
			item = load(item_path.resource_path)

		if item_totals.has(item):
			item_totals[item] += int(quantity)
		else:
			item_totals[item] = int(quantity)


	# ------------------------------------------------------------------------------
	# Clear all storage slots.
	# ------------------------------------------------------------------------------

	for slot_index in core_inventory.keys():
		core_inventory[slot_index] = [null, 0, true]


	# ------------------------------------------------------------------------------
	# Rebuild storage using the item's maximum stack size.
	# ------------------------------------------------------------------------------

	var slot_keys = core_inventory.keys()
	slot_keys.sort()

	var slot_pointer := 0

	for item in item_totals.keys():

		var remaining_quantity: int = item_totals[item]

		while remaining_quantity > 0 and slot_pointer < slot_keys.size():

			var stack_quantity: int = min(
				item.max_stack,
				remaining_quantity
			)

			var slot_index = slot_keys[slot_pointer]

			core_inventory[slot_index] = [
				item.resource_path,
				stack_quantity,
				true
			]

			remaining_quantity -= stack_quantity
			slot_pointer += 1

	initialize()


# ==============================================================================
# TRANSFER ALL ITEMS TO INVENTORY
# ==============================================================================

func moveAll_toInventory() -> void:

	for slot in storage_controller.get_children():
		storage_controller.left_click_not_holding(slot)


# ==============================================================================
# COLLECT SIMILAR ITEMS
# ==============================================================================

func collect_similar_to_chest(
	inventory_slots: Array,
	inv_val: Dictionary,
	inv: Dictionary
) -> void:

	# ------------------------------------------------------------------------------
	# Determine which item types already exist in the inventory.
	# ------------------------------------------------------------------------------

	var inventory_item_types: Array[String] = []

	for key in inv.keys():

		if inv[key][0] == null:
			continue

		var item_path: String = inv[key][0]

		if not inventory_item_types.has(item_path):
			inventory_item_types.append(item_path)


	# ------------------------------------------------------------------------------
	# Process each item type.
	# ------------------------------------------------------------------------------

	for item_path in inventory_item_types:

		var item_resource = load(item_path)
		var max_stack: int = item_resource.max_stack


		# ==========================================================================
		# PASS 1
		# Fill existing inventory stacks.
		# ==========================================================================

		for inventory_key in inv.keys():

			if inv[inventory_key][0] != item_path:
				continue

			var available_space: int = (
				max_stack -
				int(inv[inventory_key][1])
			)

			if available_space <= 0:
				continue


			for source_key in inv_val.keys():

				if inv_val[source_key][0] != item_path:
					continue

				var source_quantity: int = int(
					inv_val[source_key][1]
				)

				if source_quantity <= 0:
					continue


				var transfer_quantity: int = min(
					available_space,
					source_quantity
				)


				# DATA
				inv[inventory_key][1] += transfer_quantity
				inv_val[source_key][1] -= transfer_quantity


				# UI
				var ui_slot = inventory_slots[inventory_key]

				ui_slot.slot.set_quantity(
					inv[inventory_key][1]
				)


				# Clear the source slot when empty.
				if inv_val[source_key][1] <= 0:
					inv_val[source_key] = [
						null,
						0,
						true
					]


				available_space -= transfer_quantity

				if available_space <= 0:
					break


		# ==========================================================================
		# PASS 2
		# Fill empty inventory slots.
		# ==========================================================================

		for inventory_key in inv.keys():

			if inv[inventory_key][0] != null:
				continue


			for source_key in inv_val.keys():

				if inv_val[source_key][0] != item_path:
					continue

				var source_quantity: int = int(
					inv_val[source_key][1]
				)

				if source_quantity <= 0:
					continue


				var transfer_quantity: int = min(
					max_stack,
					source_quantity
				)


				# DATA
				inv[inventory_key] = [
					item_path,
					transfer_quantity,
					true
				]

				inv_val[source_key][1] -= transfer_quantity


				# UI
				var ui_slot = inventory_slots[inventory_key]

				ui_slot.slot.set_item(item_resource)
				ui_slot.slot.set_quantity(
					transfer_quantity
				)


				# Clear the source slot when empty.
				if inv_val[source_key][1] <= 0:
					inv_val[source_key] = [
						null,
						0,
						true
					]

				break


# ==============================================================================
# BUTTON HANDLERS
# ==============================================================================


func _on_btn_extend_storage_pressed() -> void:
	_extend_inventory()


func _on_btn_reset_storage_pressed() -> void:
	_reset_inventory()



func _on_btn_sort_chest_pressed() -> void:
	sort_and_combine_inventory_Inv()

func _on_btn_transfer_like_pressed() -> void:
	collect_similar_to_chest(
		core_inventory_controller_strg.get_children(),
		storage_core_data.DATA,
		InvCore.DATA
	)

	initialize()

func _on_btn_transfer_all_pressed() -> void:
	moveAll_toInventory()
	initialize()





# Bottom
