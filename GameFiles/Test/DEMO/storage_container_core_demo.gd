extends Control


# ==============================================================================
# STORAGE DATA CONTROLLER
# ==============================================================================

@export var storage_controller: GridContainer
@export var number_of_slots: int

@onready var storage_core_data = storage_data_core.new()
@onready var core_inventory: Dictionary = storage_core_data.DATA


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
	inventory.resize(number_of_slots)

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
