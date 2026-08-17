extends Control


# ==============================================================================
# STORAGE DATA CONTROLLER
# ==============================================================================

@export var storage_controller: GridContainer
@export var number_of_slots: int

@onready var storage_core_data = storage_data_core.new()
@onready var core_inventory: Dictionary = storage_core_data.DATA
@onready var core_storage_controller: gridcontainer_base = $Panel/CoreStorageController
@onready var core_inventory_controller_strg: GridContainer = $"../StorageInventoryCore_Demo/Panel/CoreInventoryController_Strg"


var new_slot = preload("res://Inventory/inventory_slot_ui.tscn")

# ==============================================================================
# INVENTORY
# ==============================================================================

#const INVENTORY_SIZE := 12

var inventory: Array[OptiInventorySlot] = []


# ==============================================================================
# INITIALIZATION
# ==============================================================================

func _ready() -> void:
	initialize()


func initialize() -> void:
	_load_slots_from_save(storage_controller)


# ==============================================================================
# LOAD INVENTORY
# ==============================================================================

func _load_slots_from_save(slots: GridContainer) -> void:
	_create_inventory_slots()
	_bind_inventory_to_ui(slots)
	_connect_ui_slots(slots)
	_load_saved_items()


# ==============================================================================
# CREATE INVENTORY
# ==============================================================================

func _create_inventory_slots() -> void:
	inventory.resize(core_inventory.size())

	for index in inventory.size():
		inventory[index] = OptiInventorySlot.new()


# ==============================================================================
# CONNECT UI SLOTS
# ==============================================================================

func _connect_ui_slots(slots: GridContainer) -> void:
	for index in slots.get_child_count():
		slots._set_slot(index)


# ==============================================================================
# LOAD SAVED ITEMS
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
# BIND INVENTORY DATA TO UI
# ==============================================================================

func _bind_inventory_to_ui(slots: GridContainer) -> void:
	var ui_slots = slots.get_children()

	for index in ui_slots.size():
		ui_slots[index].bind_slot(
			inventory[index]
	)






func _extend_inventory():
	set_storage_size_data(20)
	set_storage_size_ui(20)

func _reset_inventory():
	_reset_dictionary_core_data()
	_reset_inventory_ui(12)




## Reset Inventory
func _reset_dictionary_core_data():
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
	}
	
	var pINV = core_inventory
	# * Local
	#INVENTORY.clear()
	#for i in INVENTORY_ORIGINAL:
	#	INVENTORY[i] = INVENTORY_ORIGINAL[i].duplicate()
	# * Global
	pINV.clear()
	for i in INVENTORY_ORIGINAL:
		pINV[i] = INVENTORY_ORIGINAL[i].duplicate()
	
	# * UI
	for i in range(INVENTORY_ORIGINAL.size()):
		storage_controller.get_child(i).update_ui()

func _reset_inventory_size(amount: int) -> void:
	# Data
	#for i in range(INVENTORY.size() - 1, amount - 1, -1):
	#	INVENTORY.erase(i)
	for i in range(InvCore.INVENTORY.size() - 1, amount - 1, -1):
		InvCore.INVENTORY.erase(i)
	# UI
	for i in range(storage_controller.get_child_count() - 1, amount - 1, -1):
		storage_controller.get_child(i).free()

func _reset_inventory_ui(amount: int) -> void:
	# Remove slots above the desired size
	for i in range(storage_controller.get_child_count() - 1, amount - 1, -1):
		storage_controller.get_child(i).free()

	# Reset existing slots
	var current_size := storage_controller.get_child_count()

	for i in range(current_size):
		var ui_slot = storage_controller.get_child(i)
		ui_slot.indx = i
		ui_slot._reset_slot()
		ui_slot.slot = OptiInventorySlot.new()

	# Add missing slots
	for i in range(current_size, amount):
		var new_slot_instance = new_slot.instantiate()
		new_slot_instance.indx = i
		new_slot_instance.custom_minimum_size = Vector2(40, 40)
		new_slot_instance._reset_slot()
		new_slot_instance.slot = OptiInventorySlot.new()

		storage_controller.add_child(new_slot_instance)

	# Rebuild/refresh the inventory UI
	initialize()


## Extend Inventory
func set_storage_size_data(amount: int) -> void:
	#var current_size := INVENTORY.size()
	var current_size := core_inventory.size()

	for i in range(current_size, amount):
		#INVENTORY[i] = [null, 0, true]
		core_inventory[i] = [null, 0, true]

func set_storage_size_ui(amount: int) -> void:
	var current_size := storage_controller.get_child_count()

	for i in range(current_size, amount):
		var new_slot_instance = new_slot.instantiate()
		new_slot_instance.indx = i
		new_slot_instance.custom_minimum_size = Vector2(40, 40)
		new_slot_instance._reset_slot()
		new_slot_instance.slot = OptiInventorySlot.new()
		
		storage_controller.add_child(new_slot_instance)

	initialize()


## Sort and Combine
func sort_and_combine_inventory_Inv():
	var item_totals := {}

	# --- Collect totals ---
	for slot_index in core_inventory.keys():

		var slot = core_inventory[slot_index]
		var path = slot[0]
		var qty = slot[1]

		if path == null:
			continue

		var item
		if path is String:
			item = load(path)
		else:
			item = load(path.resource_path)

		if item_totals.has(item):
			item_totals[item] += int(qty)
		else:
			item_totals[item] = int(qty)

	# --- Clear all slots ---
	for slot_index in core_inventory.keys():
		core_inventory[slot_index] = [null, 0, true]

	# --- Rebuild stacks ---
	var slot_keys = core_inventory.keys()
	slot_keys.sort()

	var slot_pointer := 0

	for item in item_totals.keys():

		var remaining: int = item_totals[item]

		while remaining > 0 and slot_pointer < slot_keys.size():

			var stack_size: int = min(item.max_stack, remaining)
			var slot_index = slot_keys[slot_pointer]

			core_inventory[slot_index] = [
				item.resource_path,
				stack_size,
				true
			]

			remaining -= stack_size
			slot_pointer += 1
	
	initialize()



## - Transfer All Items to Inventory
func moveAll_toInventory():
	for M in core_storage_controller.get_children():
		core_storage_controller.left_click_not_holding(M)


## - Transfer similar items to inv
func collect_similar_to_chest(
	inventory_slots: Array,
	inv_val: Dictionary,
	inv: Dictionary
) -> void:

	# ---------------------------------------------------------
	# Determine which items already exist in inv
	# ---------------------------------------------------------
	var inv_item_types: Array[String] = []

	for key in inv.keys():

		if inv[key][0] == null:
			continue

		var item_path: String = inv[key][0]

		if not inv_item_types.has(item_path):
			inv_item_types.append(item_path)


	# ---------------------------------------------------------
	# Process each item type
	# ---------------------------------------------------------
	for item_path in inv_item_types:

		var item_res = load(item_path)
		var max_stack: int = item_res.max_stack


		# =====================================================
		# PASS 1
		# Fill existing inv stacks
		# =====================================================
		for inv_key in inv.keys():

			if inv[inv_key][0] != item_path:
				continue

			var space: int = (
				max_stack -
				int(inv[inv_key][1])
			)

			if space <= 0:
				continue


			for inventory_key in inv_val.keys():

				if inv_val[inventory_key][0] != item_path:
					continue

				var inv_quantity: int = int(
					inv_val[inventory_key][1]
				)

				if inv_quantity <= 0:
					continue


				var transfer: int = min(
					space,
					inv_quantity
				)


				# ================================
				# DATA
				# ================================
				inv[inv_key][1] += transfer

				inv_val[inventory_key][1] -= transfer


				# ================================
				# UI
				# ================================
				var ui_slot = inventory_slots[inv_key]

				ui_slot.slot.set_quantity(
					inv[inv_key][1]
				)


				# Empty inventory slot
				if inv_val[inventory_key][1] <= 0:
					inv_val[inventory_key] = [
						null,
						0,
						true
					]


				space -= transfer

				if space <= 0:
					break


		# =====================================================
		# PASS 2
		# Fill empty inv slots
		# =====================================================
		for inv_key in inv.keys():

			if inv[inv_key][0] != null:
				continue


			for inventory_key in inv_val.keys():

				if inv_val[inventory_key][0] != item_path:
					continue

				var inv_quantity: int = int(
					inv_val[inventory_key][1]
				)

				if inv_quantity <= 0:
					continue


				var transfer: int = min(
					max_stack,
					inv_quantity
				)


				# ================================
				# DATA
				# ================================
				inv[inv_key] = [
					item_path,
					transfer,
					true
				]

				inv_val[inventory_key][1] -= transfer


				# ================================
				# UI
				# ================================
				var ui_slot = inventory_slots[inv_key]

				ui_slot.slot.set_item(item_res)
				ui_slot.slot.set_quantity(transfer)


				# Empty inventory slot
				if inv_val[inventory_key][1] <= 0:
					inv_val[inventory_key] = [
						null,
						0,
						true
					]

				break






func _on_btn_sort_storage_pressed() -> void:
	sort_and_combine_inventory_Inv()


func _on_btn_extend_storage_pressed() -> void:
	_extend_inventory()


func _on_btn_reset_storage_pressed() -> void:
	_reset_inventory()


func _on_btn_move_all_to_inventory_pressed() -> void:
	moveAll_toInventory()
	initialize()


func _on_btn_move_like_to_inventory_pressed() -> void:
	collect_similar_to_chest(
		core_inventory_controller_strg.get_children(),
		storage_core_data.DATA,
		InvCore.DATA)
	initialize()
