@icon("res://assets/icons/inv_Icons/InventoryContainer.svg")
extends GridContainer


# ==============================================================================
# CoreInventoryController.gd
# ==============================================================================
#
# Handles interaction between:
#
#   INVENTORY  ---->  STORAGE
#
# Left click:
#   - Move the entire stack.
#
# Right click:
#   - Move exactly one item.
#
# This controller is responsible primarily for:
#   1. Detecting mouse input on inventory slots.
#   2. Requesting item transfers to storage.
#   3. Updating the appropriate UI.
#
# The actual inventory/storage data remains managed by their respective
# data controllers.
# ==============================================================================


# ==============================================================================
# REFERENCES
# ==============================================================================

## Inventory controller.
## Normally this is this GridContainer, but kept as an exported reference
## for compatibility with the existing inventory setup.
@export var source_controller: GridContainer

## Storage controller that receives transferred items.
@export var destination_controller: GridContainer


## Core storage controller.
##
## This is the UI GridContainer that contains the storage slots.
@onready var storage_controller: GridContainer = (
	$"../../../StorageContainerCore_Demo/Panel/CoreStorageController"
)

## Parent Control containing the storage data controller.
@onready var storage_parent_control: Control = (
	$"../../../StorageContainerCore_Demo"
)


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

## Connects an inventory slot's gui_input signal to this controller.
func _set_slot(slot_index: int) -> void:

	var inventory_slots := get_children()
	var inventory_slot: InvSlotUI = inventory_slots[slot_index]

	if not inventory_slot.is_connected(
		"gui_input",
		_slot_gui_input.bind(inventory_slot)
	):
		inventory_slot.connect(
			"gui_input",
			_slot_gui_input.bind(inventory_slot)
		)


# ==============================================================================
# SLOT INPUT
# ==============================================================================

## Handles mouse input for an individual inventory slot.
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

## Handles a left click on an inventory slot.
##
## Left clicking transfers the entire stack from inventory to storage.
func _handle_left_click(slot: InvSlotUI) -> void:

	if holding_item != null:
		return

	_move_entire_stack_to_storage(slot)


## Moves the complete stack from inventory to storage.
func _move_entire_stack_to_storage(
	inventory_slot: InvSlotUI
) -> void:

	var transfer_successful := transfer_inventory_stack_to_storage(
		InvCore.DATA,
		storage_parent_control.storage_core_data.DATA,
		storage_controller.get_children(),
		inventory_slot.indx
	)

	if not transfer_successful:

		# Some of the stack could not fit.
		_return_leftover_to_inventory(
			inventory_slot.indx
		)

	else:

		# The entire stack was transferred.
		InvCore._remove_item_at(
			inventory_slot.indx
		)

	# Refresh storage UI after the transfer.
	storage_controller.update_UI()

	leftover_quantity = 0


# ==============================================================================
# RIGHT CLICK
# ==============================================================================

## Handles a right click on an inventory slot.
##
## Right clicking transfers exactly one item.
func _handle_right_click(slot: InvSlotUI) -> void:

	# Do nothing if the slot is empty.
	if InvCore._isSlot_Empty(slot):
		return

	# Do nothing if we are already holding another item.
	if holding_item != null:
		return

	# If the slot only contains one item, transfer the entire stack.
	if slot.slot.quantity == 1:

		_move_entire_stack_to_storage(slot)
		return

	# Otherwise transfer exactly one item.
	_move_single_item_to_storage(slot)

	# Refresh storage UI after the transfer.
	storage_controller.update_UI()

	debug_out()


## Moves exactly one item from inventory to storage.
func _move_single_item_to_storage(
	inventory_slot: InvSlotUI
) -> void:

	transfer_single_inventory_item_to_storage(
		InvCore.DATA,
		storage_parent_control.storage_core_data.DATA,
		storage_controller.get_children(),
		inventory_slot.indx,
		self
	)

	leftover_quantity = 0


# ==============================================================================
# INVENTORY -> STORAGE
# ==============================================================================

## Attempts to transfer an entire inventory stack into storage.
##
## The function attempts to:
##
##   1. Add the item to existing storage stacks.
##   2. Use empty storage slots for anything remaining.
##   3. Return true if everything fit.
##   4. Return false if some items could not fit.
##
## The inventory itself is not removed here. The caller decides what to do
## after the transfer result is known.
func transfer_inventory_stack_to_storage(
	inventory: Dictionary,
	storage: Dictionary,
	storage_slots: Array,
	inventory_slot_index: int
) -> bool:

	var inventory_slot_data = inventory.get(
		inventory_slot_index
	)

	if inventory_slot_data == null:
		return false

	var item_path = inventory_slot_data[0]
	var quantity: int = int(inventory_slot_data[1])

	# Nothing to transfer.
	if item_path == null or quantity <= 0:
		return false

	var item = load(item_path)

	if item == null:
		return false

	var max_stack: int = item.max_stack
	var remaining_quantity := quantity


	# --------------------------------------------------------------------------
	# STEP 1: Fill existing storage stacks.
	# --------------------------------------------------------------------------

	for storage_slot in storage_slots:

		if remaining_quantity <= 0:
			break

		# This storage slot contains a different item.
		if storage_slot.slot.item != item:
			continue

		var current_quantity: int = (
			storage_slot.slot.quantity
		)

		var available_space := (
			max_stack - current_quantity
		)

		# This stack is already full.
		if available_space <= 0:
			continue

		var amount_to_add: int = min(
			available_space,
			remaining_quantity
		)

		var new_quantity := (
			current_quantity + amount_to_add
		)


		# ----------------------------------------------------------------------
		# Update storage DATA.
		# ----------------------------------------------------------------------

		storage[storage_slot.indx][1] = new_quantity


		# ----------------------------------------------------------------------
		# Update storage UI.
		# ----------------------------------------------------------------------

		storage_slot.slot.set_quantity(
			new_quantity
		)


		remaining_quantity -= amount_to_add


	# --------------------------------------------------------------------------
	# STEP 2: Fill empty storage slots.
	# --------------------------------------------------------------------------

	for storage_slot in storage_slots:

		if remaining_quantity <= 0:
			break

		# Skip occupied slots.
		if storage_slot.slot.item != null:
			continue

		var stack_quantity: int = min(
			max_stack,
			remaining_quantity
		)


		# ----------------------------------------------------------------------
		# Update storage DATA.
		# ----------------------------------------------------------------------

		storage[storage_slot.indx][0] = (
			item.resource_path
		)

		storage[storage_slot.indx][1] = (
			stack_quantity
		)


		# ----------------------------------------------------------------------
		# Update storage UI.
		# ----------------------------------------------------------------------

		storage_slot.slot.set_item(item)
		storage_slot.slot.set_quantity(stack_quantity)


		remaining_quantity -= stack_quantity


	# --------------------------------------------------------------------------
	# STEP 3: Determine whether the entire stack fit.
	# --------------------------------------------------------------------------

	if remaining_quantity <= 0:

		return true


	# --------------------------------------------------------------------------
	# STEP 4: Some items could not fit.
	# --------------------------------------------------------------------------

	leftover_quantity = remaining_quantity

	return false


# ==============================================================================
# TRANSFER SINGLE ITEM
# ==============================================================================

## Transfers exactly ONE item from inventory to storage.
##
## The function first searches for an existing compatible storage stack.
## If no compatible stack is available, it searches for an empty storage slot.
##
## Returns:
##   true  - One item was transferred.
##   false - No room was available.
func transfer_single_inventory_item_to_storage(
	inventory: Dictionary,
	storage: Dictionary,
	storage_slots: Array,
	inventory_slot_index: int,
	inventory_controller: GridContainer
) -> bool:

	var inventory_slot_data = inventory.get(
		inventory_slot_index
	)

	if inventory_slot_data == null:
		return false

	var item_path = inventory_slot_data[0]
	var inventory_quantity: int = (
		int(inventory_slot_data[1])
	)

	# Nothing to transfer.
	if item_path == null or inventory_quantity <= 0:
		return false

	var item = load(item_path)

	if item == null:
		return false

	var max_stack: int = item.max_stack


	# ==========================================================================
	# STEP 1: Find an existing storage stack.
	# ==========================================================================

	for storage_slot in storage_slots:

		# This is a different item.
		if storage_slot.slot.item != item:
			continue

		var current_quantity: int = (
			int(storage_slot.slot.quantity)
		)

		# This stack is full.
		if current_quantity >= max_stack:
			continue


		# ----------------------------------------------------------------------
		# Add exactly ONE item.
		# ----------------------------------------------------------------------

		var new_quantity := current_quantity + 1


		# ----------------------------------------------------------------------
		# Update storage DATA.
		# ----------------------------------------------------------------------

		storage[storage_slot.indx][1] = (
			new_quantity
		)


		# ----------------------------------------------------------------------
		# Update storage UI.
		# ----------------------------------------------------------------------

		storage_slot.slot.set_quantity(
			new_quantity
		)


		# ----------------------------------------------------------------------
		# Remove ONE item from inventory DATA.
		# ----------------------------------------------------------------------

		inventory_quantity -= 1

		inventory[inventory_slot_index][1] = (
			inventory_quantity
		)


		# ----------------------------------------------------------------------
		# Update inventory UI.
		# ----------------------------------------------------------------------

		var inventory_slot: InvSlotUI = (
			inventory_controller.get_child(
				inventory_slot_index
			)
		)

		if inventory_quantity <= 0:

			inventory_slot.slot.clear()

		else:

			inventory_slot.slot.set_quantity(
				inventory_quantity
			)


		return true


	# ==========================================================================
	# STEP 2: Find an empty storage slot.
	# ==========================================================================

	for storage_slot in storage_slots:

		# Skip occupied slots.
		if storage_slot.slot.item != null:
			continue


		# ----------------------------------------------------------------------
		# Update storage DATA.
		# ----------------------------------------------------------------------

		storage[storage_slot.indx][0] = (
			item.resource_path
		)

		storage[storage_slot.indx][1] = 1


		# ----------------------------------------------------------------------
		# Update storage UI.
		# ----------------------------------------------------------------------

		storage_slot.slot.set_item(item)
		storage_slot.slot.set_quantity(1)


		# ----------------------------------------------------------------------
		# Remove ONE item from inventory DATA.
		# ----------------------------------------------------------------------

		inventory_quantity -= 1

		inventory[inventory_slot_index][1] = (
			inventory_quantity
		)


		# ----------------------------------------------------------------------
		# Update inventory UI.
		# ----------------------------------------------------------------------

		var inventory_slot: InvSlotUI = (
			inventory_controller.get_child(
				inventory_slot_index
			)
		)

		if inventory_quantity <= 0:

			inventory_slot.slot.clear()

		else:

			inventory_slot.slot.set_quantity(
				inventory_quantity
			)


		return true


	# ==========================================================================
	# STEP 3: Storage is full.
	# ==========================================================================

	return false


# ==============================================================================
# RETURN LEFTOVER ITEMS
# ==============================================================================

## Restores any items that could not fit into storage.
##
## This is used when an entire inventory stack was moved but storage did not
## have enough available space.
func _return_leftover_to_inventory(
	inventory_slot_index: int
) -> void:

	# --------------------------------------------------------------------------
	# Update inventory DATA.
	# --------------------------------------------------------------------------

	InvCore._updateItem_At(
		inventory_slot_index,
		leftover_quantity
	)


	# --------------------------------------------------------------------------
	# Update inventory UI.
	# --------------------------------------------------------------------------

	var inventory_slot: InvSlotUI = (
		get_child(inventory_slot_index)
	)

	if leftover_quantity <= 0:

		inventory_slot.slot.clear()

	else:

		inventory_slot.slot.set_quantity(
			leftover_quantity
		)


# ==============================================================================
# HOLDING STACK
# ==============================================================================

## Returns true when the item currently being held has reached max stack size.
func _is_holding_stack_full() -> bool:

	if holding_item == null:
		return false

	var current_quantity: int = (
		int(holding_item.label.text)
	)

	var max_stack: int = (
		int(holding_item_resource.max_stack)
	)

	return current_quantity >= max_stack


# ==============================================================================
# UI
# ==============================================================================

## Refreshes every inventory slot's visual state.
func update_UI() -> void:

	for inventory_slot in get_children():
		inventory_slot.update_ui()


# ==============================================================================
# DEBUGGING
# ==============================================================================

## Prints both inventory and storage data to the output panel.
func debug_out() -> void:

	print_inventory_debug(
		InvCore.DATA
	)

	print_inventory_debug(
		storage_parent_control.storage_core_data.DATA
	)


## Prints the contents of an inventory/storage dictionary.
func print_inventory_debug(
	inventory: Dictionary
) -> void:

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
