@icon("res://assets/icons/inv_Icons/InventoryContainer.svg")
extends GridContainer

#
#NOTE: NOT FOR ACTUAL USE.  DEMO ONLY
#

# ==============================================================================
# CoreStorageController.gd
# ==============================================================================
#
# Handles interaction between:
#
#   STORAGE  <---->  INVENTORY
#
# Left click:
#   - Move the entire stack.
#
# Right click:
#   - Move exactly one item.
#
# This controller is responsible primarily for:
#   1. Detecting mouse input on storage slots.
#   2. Requesting item transfers.
#   3. Updating the appropriate UI.
#
# The actual inventory/storage data remains managed by the respective
# data controllers.
# ==============================================================================


# ==============================================================================
# REFERENCES
# ==============================================================================

## Grid containing the source slots.
@export var source_controller: GridContainer

## Parent Control containing the source data controller.
@export var source_parent_control: Control

## Grid containing the destination slots.
@export var destination_controller: GridContainer

## Parent Control containing the destination data controller.
@export var destination_parent_control: Control


## Reference to the storage data controller.
@onready var storage_data = source_parent_control.storage_core_data


# ==============================================================================
# ITEM HOLDING
# ==============================================================================

## UI element currently attached to the mouse cursor.
var holding_item = null

## Resource associated with the item currently being held.
var holding_item_resource = null

## Quantity of the item currently being held.
var holding_item_quantity: int = 0


## Used when only part of a stack could be transferred.
var leftover_quantity: int = 0


# ==============================================================================
# PROCESS
# ==============================================================================

func _process(_delta: float) -> void:
	if holding_item != null:
		_update_holding_item_position()


# ==============================================================================
# MOUSE / HOLDING ITEM
# ==============================================================================

## Keeps the item being held underneath the mouse cursor.
func _update_holding_item_position() -> void:
	holding_item.position = get_local_mouse_position() - Vector2(20, 20)


# ==============================================================================
# SLOT SETUP
# ==============================================================================

## Connects a storage slot's gui_input signal to this controller.
func _set_slot(slot_index: int) -> void:
	var storage_slots := get_children()
	var storage_slot: InvSlotUI = storage_slots[slot_index]

	if not storage_slot.is_connected(
		"gui_input",
		_slot_gui_input.bind(storage_slot)
	):
		storage_slot.connect(
			"gui_input",
			_slot_gui_input.bind(storage_slot)
	)


# ==============================================================================
# SLOT INPUT
# ==============================================================================

## Handles mouse input for an individual storage slot.
func _slot_gui_input(event: InputEvent, slot: InvSlotUI) -> void:
	if not event is InputEventMouseButton:
		return

	if not event.pressed:
		return

	match event.button_index:
		MOUSE_BUTTON_LEFT:
			_handle_left_click(slot)

		MOUSE_BUTTON_RIGHT:
			_handle_right_click(slot)


# ==============================================================================
# LEFT CLICK
# ==============================================================================

## Handles a left click on a storage slot.
##
## Left clicking transfers the entire stack from storage to inventory.
func _handle_left_click(slot: InvSlotUI) -> void:
	if holding_item != null:
		return

	_move_entire_stack_to_inventory(slot)


## Moves the complete stack from storage to inventory.
func _move_entire_stack_to_inventory(storage_slot: InvSlotUI) -> void:

	var transfer_context := {
		"source_controller": self,
		"destination_controller": destination_controller,
		"slot_index": storage_slot.indx
	}

	_move_item_to_inventory(transfer_context)

	destination_controller.update_UI()


# ==============================================================================
# RIGHT CLICK
# ==============================================================================

## Handles a right click on a storage slot.
##
## Right clicking transfers exactly one item.
func _handle_right_click(slot: InvSlotUI) -> void:

	# Refresh the storage data reference.
	storage_data = source_parent_control.storage_core_data

	# Do nothing if the slot is empty.
	if storage_data._isSlot_Empty(slot):
		return

	# We are not currently holding another item.
	if holding_item != null:
		return

	# If the slot only contains one item, move the entire stack.
	if slot.slot.quantity == 1:
		_move_entire_stack_to_inventory(slot)
		return

	# Otherwise move exactly one item.
	_move_single_item_to_inventory(slot)

	destination_controller.update_UI()


## Moves exactly one item from storage to inventory.
func _move_single_item_to_inventory(storage_slot: InvSlotUI) -> void:

	var transfer_context := {
		"source_controller": self,
		"destination_controller": destination_controller,
		"slot_index": storage_slot.indx
	}

	_transfer_single_storage_item_to_inventory(transfer_context)


# ==============================================================================
# STORAGE -> INVENTORY
# ==============================================================================

## Transfers an entire storage slot into the inventory.
##
## The function attempts to:
##
##   1. Add the item to existing inventory stacks.
##   2. Use empty inventory slots for anything remaining.
##   3. Remove the item from storage if everything fits.
##   4. Return any leftover quantity to storage if the inventory is full.
func _move_item_to_inventory(context: Dictionary) -> void:

	var storage_controller: GridContainer = context.source_controller
	var inventory_controller: GridContainer = context.destination_controller
	var storage_slot_index: int = context.slot_index

	storage_data = source_parent_control.storage_core_data

	# Make sure the storage slot actually contains an item.
	if storage_data._isSlot_Empty_At(storage_slot_index):
		return

	var transfer_successful := transfer_storage_stack_to_inventory(
		storage_data.DATA,
		InvCore.DATA,
		inventory_controller.get_children(),
		storage_slot_index
	)

	if transfer_successful:
		# Everything fit into the inventory.
		storage_data._remove_item_at(storage_slot_index)
	else:
		# Only part of the stack could be transferred.
		_return_leftover_to_storage(
			storage_controller,
			storage_slot_index
		)

	leftover_quantity = 0


# ==============================================================================
# TRANSFER ENTIRE STACK
# ==============================================================================

## Attempts to transfer an entire storage stack into the inventory.
##
## Returns:
##   true  - Everything was transferred.
##   false - Some items could not fit.
func transfer_storage_stack_to_inventory(
	storage: Dictionary,
	inventory: Dictionary,
	inventory_slots: Array,
	storage_slot_index: int
) -> bool:

	var storage_slot_data = storage.get(storage_slot_index)

	if storage_slot_data == null:
		return false

	var item_path = storage_slot_data[0]
	var quantity: int = int(storage_slot_data[1])

	# Nothing to transfer.
	if item_path == null or quantity <= 0:
		return false

	var item = load(item_path)

	if item == null:
		return false

	var max_stack: int = item.max_stack
	var remaining_quantity := quantity


	# --------------------------------------------------------------------------
	# STEP 1: Fill existing inventory stacks.
	# --------------------------------------------------------------------------

	for inventory_slot in inventory_slots:

		if remaining_quantity <= 0:
			break

		# This slot contains a different item.
		if inventory_slot.slot.item != item:
			continue

		var current_quantity: int = inventory_slot.slot.quantity
		var available_space := max_stack - current_quantity

		# Stack is already full.
		if available_space <= 0:
			continue

		var amount_to_add: int = min(
			available_space,
			remaining_quantity
		)

		var new_quantity := current_quantity + amount_to_add

		# Update inventory data.
		inventory[inventory_slot.indx][1] = new_quantity

		# Update inventory UI.
		inventory_slot.slot.set_quantity(new_quantity)

		remaining_quantity -= amount_to_add


	# --------------------------------------------------------------------------
	# STEP 2: Fill empty inventory slots.
	# --------------------------------------------------------------------------

	for inventory_slot in inventory_slots:

		if remaining_quantity <= 0:
			break

		# Skip occupied slots.
		if inventory_slot.slot.item != null:
			continue

		var stack_quantity: int = min(
			max_stack,
			remaining_quantity
		)

		# Update inventory UI.
		inventory_slot.slot.set_item(item)
		inventory_slot.slot.set_quantity(stack_quantity)

		# Update inventory data.
		inventory[inventory_slot.indx][0] = item.resource_path
		inventory[inventory_slot.indx][1] = stack_quantity

		remaining_quantity -= stack_quantity


	# --------------------------------------------------------------------------
	# STEP 3: Determine whether everything transferred.
	# --------------------------------------------------------------------------

	if remaining_quantity <= 0:
		storage[storage_slot_index] = [null, 0, true]
		return true

	# Some of the stack could not fit.
	leftover_quantity = remaining_quantity

	return false


# ==============================================================================
# RETURN LEFTOVER ITEMS
# ==============================================================================

## Updates the storage slot with any items that could not fit in inventory.
func _return_leftover_to_storage(
	storage_controller: GridContainer,
	storage_slot_index: int
) -> void:

	# --------------------------------------------------------------------------
	# Update storage DATA.
	# --------------------------------------------------------------------------

	storage_data._updateItem_At(
		storage_slot_index,
		leftover_quantity
	)


	# --------------------------------------------------------------------------
	# Update storage UI.
	# --------------------------------------------------------------------------

	var storage_slot: InvSlotUI = (
		storage_controller.get_child(storage_slot_index)
	)

	if leftover_quantity <= 0:
		storage_slot.slot.clear()
	else:
		storage_slot.slot.set_quantity(leftover_quantity)


# ==============================================================================
# TRANSFER SINGLE ITEM
# ==============================================================================

## Transfers exactly ONE item from storage to inventory.
##
## The function first searches for an existing compatible stack.
## If no stack is available, it searches for an empty inventory slot.
##
## Returns:
##   true  - One item was transferred.
##   false - No room was available.
func _transfer_single_storage_item_to_inventory(
	context: Dictionary
) -> bool:

	var storage_slot_index: int = context.slot_index
	var inventory_controller: GridContainer = context.destination_controller

	var storage_inventory: Dictionary = storage_data.DATA
	var inventory_data: Dictionary = InvCore.DATA

	var storage_slot_data = storage_inventory.get(storage_slot_index)

	if storage_slot_data == null:
		return false

	var item_path = storage_slot_data[0]
	var storage_quantity: int = int(storage_slot_data[1])

	# Nothing to transfer.
	if item_path == null or storage_quantity <= 0:
		return false

	var item = load(item_path)

	if item == null:
		return false

	var max_stack: int = item.max_stack


	# --------------------------------------------------------------------------
	# STEP 1: Find an existing inventory stack.
	# --------------------------------------------------------------------------

	for inventory_slot in inventory_controller.get_children():

		if inventory_slot.slot.item != item:
			continue

		var current_quantity: int = inventory_slot.slot.quantity

		# This stack is full.
		if current_quantity >= max_stack:
			continue

		# Add exactly ONE item.
		var new_quantity := current_quantity + 1

		# Update inventory DATA.
		inventory_data[inventory_slot.indx][1] = new_quantity

		# Update inventory UI.
		inventory_slot.slot.set_quantity(new_quantity)

		# Remove ONE item from storage DATA.
		storage_quantity -= 1
		storage_inventory[storage_slot_index][1] = storage_quantity

		# Update storage UI.
		var storage_slot: InvSlotUI = (
			source_controller.get_child(storage_slot_index)
		)

		if storage_quantity <= 0:
			storage_slot.slot.clear()
		else:
			storage_slot.slot.set_quantity(storage_quantity)

		return true


	# --------------------------------------------------------------------------
	# STEP 2: Find an empty inventory slot.
	# --------------------------------------------------------------------------

	for inventory_slot in inventory_controller.get_children():

		if inventory_slot.slot.item != null:
			continue

		# Update inventory DATA.
		inventory_data[inventory_slot.indx][0] = item.resource_path
		inventory_data[inventory_slot.indx][1] = 1

		# Update inventory UI.
		inventory_slot.slot.set_item(item)
		inventory_slot.slot.set_quantity(1)

		# Remove ONE item from storage DATA.
		storage_quantity -= 1
		storage_inventory[storage_slot_index][1] = storage_quantity

		# Update storage UI.
		var storage_slot: InvSlotUI = (
			source_controller.get_child(storage_slot_index)
		)

		if storage_quantity <= 0:
			storage_slot.slot.clear()
		else:
			storage_slot.slot.set_quantity(storage_quantity)

		return true


	# --------------------------------------------------------------------------
	# STEP 3: Inventory is full.
	# --------------------------------------------------------------------------

	return false


# ==============================================================================
# HOLDING STACK
# ==============================================================================

## Returns true when the item currently being held has reached max stack size.
func _is_holding_stack_full() -> bool:

	if holding_item == null:
		return false

	var current_quantity: int = int(holding_item.label.text)
	var max_stack: int = int(holding_item_resource.max_stack)

	return current_quantity >= max_stack


# ==============================================================================
# UI
# ==============================================================================

## Refreshes every storage slot's visual state.
func update_UI() -> void:

	for storage_slot in get_children():
		storage_slot.update_ui()


# ==============================================================================
# DEBUGGING
# ==============================================================================

## Prints both inventory and storage data to the output panel.
func debug_out() -> void:

	print_inventory_debug(InvCore.DATA)
	print_inventory_debug(
		source_parent_control.storage_core_data.DATA
	)


## Prints the contents of an inventory/storage dictionary.
func print_inventory_debug(inventory: Dictionary) -> void:

	print("\n========== INVENTORY ==========")

	for slot_index in inventory:

		var slot_data = inventory[slot_index]

		print(
			"Slot %02d | Item: %-45s | Amount: %3d | Enabled: %s"
			% [
				slot_index,
				str(slot_data[0]),
				slot_data[1],
				slot_data[2]
			]
		)

	print("================================\n")
