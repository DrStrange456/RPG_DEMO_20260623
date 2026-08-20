extends Control

# ==============================================================================
# InventoryCore_Demo.gd
# ==============================================================================
# Controls the player's inventory UI and inventory data.
# ==============================================================================


# ==============================================================================
# CONTROLLER REFERENCES
# ==============================================================================

@export var inventory_controller: GridContainer
@export var number_of_slots: int = 12

@onready var core_inventory_controller: GridContainer = $Panel/Storage_CoreInventoryController
@onready var core_storage_controller: gridcontainer_base = $"../Storage_StorageControl/Panel/Storage_CoreStorageController"
@onready var storage_container_core_demo: Control = $"../Storage_StorageControl"
@onready var pInv: Dictionary = InvCore.DATA


# ==============================================================================
# INVENTORY
# ==============================================================================

var new_slot = preload("res://Inventory/inventory_slot_ui.tscn")

var inventory: Array[OptiInventorySlot] = []
var holding_item


# ==============================================================================
# INITIALIZATION
# ==============================================================================

func _ready() -> void:
	initialize()


func initialize() -> void:
	_load_slots_from_save(core_inventory_controller)


func _load_slots_from_save(slots: GridContainer) -> void:
	inventory.resize(pInv.size())

	for i in inventory.size():
		inventory[i] = OptiInventorySlot.new()

	bind_inventory(inventory, slots)

	for j in pInv:
		for i in slots.get_child_count():
			slots._set_slot(i)

		if pInv[j][0] != null and int(pInv[j][1]) > 0:
			inventory[j].indx = j
			inventory[j].set_item(load(pInv[j][0]))
			inventory[j].set_quantity(pInv[j][1])


func bind_inventory(inv, gc: GridContainer) -> void:
	var ui_slots = gc.get_children()

	for i in ui_slots.size():
		ui_slots[i].bind_slot(inv[i])


# ==============================================================================
# INVENTORY SIZE
# ==============================================================================

func _extend_inventory() -> void:
	set_inventory_size_data(20)
	set_inventory_size_ui(20)


func _reset_inventory() -> void:
	_reset_dictionary_core_data()
	_reset_inventory_ui(12)


func set_inventory_size_data(amount: int) -> void:
	var current_size := pInv.size()

	for i in range(current_size, amount):
		pInv[i] = [null, 0, true]


func set_inventory_size_ui(amount: int) -> void:
	var current_size := core_inventory_controller.get_child_count()

	for i in range(current_size, amount):
		var new_slot_instance = new_slot.instantiate()

		new_slot_instance.indx = i
		new_slot_instance.custom_minimum_size = Vector2(40, 40)
		new_slot_instance._reset_slot()
		new_slot_instance.slot = OptiInventorySlot.new()

		core_inventory_controller.add_child(new_slot_instance)

	initialize()


# ==============================================================================
# RESET INVENTORY
# ==============================================================================

func _reset_dictionary_core_data() -> void:

	const INVENTORY_ORIGINAL: Dictionary = {
		0: ["res://resources/seeds_turnip.tres", 98, true],
		1: ["res://resources/seeds_strawberry.tres", 3, true],
		2: ["res://resources/weapon_sword_fire.tres", 1, true],
		3: [null, 0, true],
		4: ["res://resources/seeds_tomato.tres", 65, true],
		5: ["res://resources/seeds_carrot.tres", 10, true],
		6: ["res://resources/seeds_strawberry.tres", 60, true],
		7: [null, 0, true],
		8: [null, 0, true],
		9: ["res://resources/seeds_strawberry.tres", 35, true],
		10: ["res://resources/seeds_strawberry.tres", 85, true],
		11: [null, 0, true]
	}

	var pINV = InvCore.DATA

	pINV.clear()

	for i in INVENTORY_ORIGINAL:
		pINV[i] = INVENTORY_ORIGINAL[i].duplicate()

	for i in range(INVENTORY_ORIGINAL.size()):
		core_inventory_controller.get_child(i).update_ui()


func _reset_inventory_size(amount: int) -> void:

	# DATA
	for i in range(InvCore.INVENTORY.size() - 1, amount - 1, -1):
		InvCore.INVENTORY.erase(i)

	# UI
	for i in range(
		core_inventory_controller.get_child_count() - 1,
		amount - 1,
		-1
	):
		core_inventory_controller.get_child(i).free()


func _reset_inventory_ui(amount: int) -> void:

	# Remove slots above the desired size.
	for i in range(
		core_inventory_controller.get_child_count() - 1,
		amount - 1,
		-1
	):
		core_inventory_controller.get_child(i).free()

	# Reset existing slots.
	var current_size := core_inventory_controller.get_child_count()

	for i in range(current_size):
		var ui_slot = core_inventory_controller.get_child(i)

		ui_slot.indx = i
		ui_slot._reset_slot()
		ui_slot.slot = OptiInventorySlot.new()

	# Add missing slots.
	for i in range(current_size, amount):
		var new_slot_instance = new_slot.instantiate()

		new_slot_instance.indx = i
		new_slot_instance.custom_minimum_size = Vector2(40, 40)
		new_slot_instance._reset_slot()
		new_slot_instance.slot = OptiInventorySlot.new()

		core_inventory_controller.add_child(new_slot_instance)

	initialize()


# ==============================================================================
# SAVE INVENTORY
# ==============================================================================

func _save_inventory() -> void:
	print("To be replaced with save to JSON")


func _save_core_inventory(
	gcSLOTS: Dictionary,
	glINVENTORY: Dictionary
) -> void:

	glINVENTORY.clear()

	for i in gcSLOTS:
		glINVENTORY[i] = gcSLOTS[i].duplicate()


# ==============================================================================
# SORT AND COMBINE
# ==============================================================================

func sort_and_combine_inventory_Inv() -> void:

	var item_totals := {}

	# Collect totals.
	for slot_index in pInv.keys():

		var slot = pInv[slot_index]
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

	# Clear all slots.
	for slot_index in pInv.keys():
		pInv[slot_index] = [null, 0, true]

	# Rebuild stacks.
	var slot_keys = pInv.keys()
	slot_keys.sort()

	var slot_pointer := 0

	for item in item_totals.keys():

		var remaining: int = item_totals[item]

		while remaining > 0 and slot_pointer < slot_keys.size():

			var stack_size: int = min(
				item.max_stack,
				remaining
			)

			var slot_index = slot_keys[slot_pointer]

			pInv[slot_index] = [
				item.resource_path,
				stack_size,
				true
			]

			remaining -= stack_size
			slot_pointer += 1

	initialize()


# ==============================================================================
# TRANSFER ALL ITEMS TO STORAGE
# ==============================================================================

func moveAll_toStorage() -> void:

	for M in core_inventory_controller.get_children():
		core_inventory_controller.left_click_not_holding(M)


# ==============================================================================
# TRANSFER SIMILAR ITEMS TO STORAGE
# ==============================================================================

func collect_similar_to_chest(
	storage_slots: Array,
	inventory_val: Dictionary,
	storage: Dictionary
) -> void:

	# Determine which items already exist in storage.
	var storage_item_types: Array[String] = []

	for key in storage.keys():

		if storage[key][0] == null:
			continue

		var item_path: String = storage[key][0]

		if not storage_item_types.has(item_path):
			storage_item_types.append(item_path)

	# Process each item type.
	for item_path in storage_item_types:

		var item_res = load(item_path)
		var max_stack: int = item_res.max_stack

		# ----------------------------------------------------------------------
		# PASS 1
		# Fill existing storage stacks.
		# ----------------------------------------------------------------------

		for storage_key in storage.keys():

			if storage[storage_key][0] != item_path:
				continue

			var space: int = max_stack - int(storage[storage_key][1])

			if space <= 0:
				continue

			for inventory_key in inventory_val.keys():

				if inventory_val[inventory_key][0] != item_path:
					continue

				var inv_quantity: int = int(
					inventory_val[inventory_key][1]
				)

				if inv_quantity <= 0:
					continue

				var transfer: int = min(
					space,
					inv_quantity
				)

				# DATA
				storage[storage_key][1] += transfer
				inventory_val[inventory_key][1] -= transfer

				# UI
				var ui_slot = storage_slots[storage_key]
				ui_slot.slot.set_quantity(
					storage[storage_key][1]
				)

				# Empty source inventory slot.
				if inventory_val[inventory_key][1] <= 0:
					inventory_val[inventory_key] = [
						null,
						0,
						true
					]

				space -= transfer

				if space <= 0:
					break

		# ----------------------------------------------------------------------
		# PASS 2
		# Fill empty storage slots.
		# ----------------------------------------------------------------------

		for storage_key in storage.keys():

			if storage[storage_key][0] != null:
				continue

			for inventory_key in inventory_val.keys():

				if inventory_val[inventory_key][0] != item_path:
					continue

				var inv_quantity: int = int(
					inventory_val[inventory_key][1]
				)

				if inv_quantity <= 0:
					continue

				var transfer: int = min(
					max_stack,
					inv_quantity
				)

				# DATA
				storage[storage_key] = [
					item_path,
					transfer,
					true
				]

				inventory_val[inventory_key][1] -= transfer

				# UI
				var ui_slot = storage_slots[storage_key]

				ui_slot.slot.set_item(item_res)
				ui_slot.slot.set_quantity(transfer)

				# Empty source inventory slot.
				if inventory_val[inventory_key][1] <= 0:
					inventory_val[inventory_key] = [
						null,
						0,
						true
					]

				break


# ==============================================================================
# BUTTON HANDLERS
# ==============================================================================


func _on_btn_extend_inventory_pressed() -> void:
	_extend_inventory()


func _on_btn_reset_inventory_pressed() -> void:
	_reset_inventory()





func _on_btn_sort_inv_pressed() -> void:
	sort_and_combine_inventory_Inv()

func _on_btn_transfer_like_to_strg_pressed() -> void:
	collect_similar_to_chest(
		core_storage_controller.get_children(),
		InvCore.DATA,
		storage_container_core_demo.storage_core_data.DATA
	)

	initialize()

func _on_btn_transfer_all_to_strg_pressed() -> void:
	moveAll_toStorage()
	initialize()


# Bottom
