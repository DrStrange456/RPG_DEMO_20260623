extends gridcontainer_base


# ==============================================================================
# CoreStorageController.gd
# ==============================================================================
#
# Controls item transfers from the storage container to the inventory.
#
# Left Click:
#   - Transfers the entire stack.
#
# Right Click:
#   - Transfers one item from a stack.
#
# ==============================================================================


# ==============================================================================
# CONTROLLER REFERENCES
# ==============================================================================

@export var source_controller: GridContainer
@export var source_parent_control: Control

@export var destination_controller: GridContainer
@export var destination_parent_control: Control


# ==============================================================================
# DATA REFERENCES
# ==============================================================================

# Storage data controller associated with the source container.
@onready var storage_inventory = source_parent_control.storage_core_data


# ==============================================================================
# ITEM HOLDING
# ==============================================================================

var slot_preview = GmMgr.glSlotPrev
var holding_item

# These variables track the item currently being held.
var holding_item_resource
var holding_item_quantity

# Tracks the number of items that could not be transferred.
var leftover_quantity: int = 0


# ==============================================================================
# PROCESS
# ==============================================================================

func _process(_delta: float) -> void:
	if holding_item != null:
		# Keep the held item positioned underneath the mouse.
		_update_holding_item_position()


func _update_holding_item_position() -> void:
	holding_item.position = get_local_mouse_position() - Vector2(20, 20)


# ==============================================================================
# SLOT SETUP
# ==============================================================================

func _set_slot(slot_index):
	var storage_slots = get_children()
	var slot_to_update: InvSlotUI = storage_slots[slot_index]

	if not slot_to_update.is_connected(
		"gui_input",
		_slot_gui_input.bind(slot_to_update)
	):
		slot_to_update.connect(
			"gui_input",
			_slot_gui_input.bind(slot_to_update)
		)


# ==============================================================================
# SLOT INPUT
# ==============================================================================

func _slot_gui_input(event: InputEvent, slot: InvSlotUI):
	if event is InputEventMouseButton:

		# Left mouse button.
		if event.button_index == MOUSE_BUTTON_LEFT && event.pressed:
			pick_all_from_slot(event, slot)

		# Right mouse button.
		if event.button_index == MOUSE_BUTTON_RIGHT && event.pressed:
			pick_just_one_from_slot(event, slot)


# ==============================================================================
# LEFT CLICK
# ==============================================================================

func pick_all_from_slot(_event: InputEvent, slot: InvSlotUI):
	# Only pick up an item if we are not already holding one.
	if holding_item == null:
		left_click_not_holding(slot)


# ==============================================================================
# RIGHT CLICK
# ==============================================================================

func pick_just_one_from_slot(_event: InputEvent, slot: InvSlotUI):
	storage_inventory = source_parent_control.storage_core_data

	if !storage_inventory._isSlot_Empty(slot):

		# Only pick up an item if we are not already holding one.
		if holding_item == null:
			right_click_not_holding(slot)


# ==============================================================================
# LEFT CLICK HANDLING
# ==============================================================================

func left_click_not_holding(slot: InvSlotUI):
	var context = {
		"source": self,
		"container": destination_controller,
		"slot_index": slot.indx
	}

	move_item_to_inventory(context)
	destination_controller.update_UI()


# ==============================================================================
# RIGHT CLICK HANDLING
# ==============================================================================

func right_click_not_holding(slot: InvSlotUI):
	# If there is only one item in the slot,
	# transfer the entire slot.
	if slot.slot.quantity == 1:
		left_click_not_holding(slot)

	else:
		# If there are multiple items,
		# transfer only one item.
		var context = {
			"source": self,
			"container": destination_controller,
			"slot_index": slot.indx
		}

		move_just_one_item_to_storage(context)

	destination_controller.update_UI()


# ==============================================================================
# STORAGE -> INVENTORY
# ==============================================================================

func move_item_to_inventory(context):
	# Move the entire storage slot.
	var inventory_grid = context.source
	var storage_grid = context.container
	var storage_slot_index = context.slot_index

	storage_inventory = source_parent_control.storage_core_data

	if !storage_inventory._isSlot_Empty_At(storage_slot_index):

		if transfer_storage_slot_to_inventory(
			storage_inventory.DATA,
			InvCore.DATA,
			storage_grid.get_children(),
			storage_slot_index
		):
			storage_inventory._remove_item_at(
				storage_slot_index
			)

		else:
			_return_what_didnt_fit(
				inventory_grid,
				storage_slot_index
			)

		leftover_quantity = 0


# ==============================================================================
# TRANSFER ENTIRE STORAGE STACK
# ==============================================================================

func transfer_storage_slot_to_inventory(
	inventory: Dictionary,
	inventory_storage,
	container: Array,
	slot_index: int
):
	var slot_data = inventory[slot_index]

	var item_path = slot_data[0]
	var quantity = slot_data[1]

	if item_path == null:
		return

	var item = load(item_path)
	var max_stack = item.max_stack
	var remaining_quantity = int(quantity)


	# --------------------------------------------------------------------------
	# FILL EXISTING STACKS
	# --------------------------------------------------------------------------

	for slot in container:
		if remaining_quantity <= 0:
			break

		if slot.slot.item == item:
			var available_space = max_stack - slot.slot.quantity

			if available_space <= 0:
				continue

			var amount_to_add = min(
				available_space,
				remaining_quantity
			)

			inventory_storage[slot.indx][1] = (
				slot.slot.quantity + amount_to_add
			)

			slot.slot.set_quantity(
				slot.slot.quantity + amount_to_add
			)

			remaining_quantity -= amount_to_add


	# --------------------------------------------------------------------------
	# FILL EMPTY SLOTS
	# --------------------------------------------------------------------------

	for slot in container:
		if remaining_quantity <= 0:
			break

		if slot.slot.item == null:
			var stack_quantity = min(
				max_stack,
				remaining_quantity
			)

			slot.slot.set_item(item)
			slot.slot.set_quantity(stack_quantity)

			inventory_storage[slot.indx][0] = item.resource_path
			inventory_storage[slot.indx][1] = stack_quantity

			remaining_quantity -= stack_quantity


	# --------------------------------------------------------------------------
	# UPDATE SOURCE STORAGE DATA
	# --------------------------------------------------------------------------

	if remaining_quantity == 0:
		inventory[slot_index] = [null, 0, true]

	if remaining_quantity > 0:
		leftover_quantity = remaining_quantity


# ==============================================================================
# RETURN ITEMS THAT DID NOT FIT
# ==============================================================================

func _return_what_didnt_fit(
	inventory_grid: GridContainer,
	inventory_slot_index: int
):
	# Update data.
	storage_inventory._updateItem_At(
		inventory_slot_index,
		leftover_quantity
	)

	# Update UI.
	var source_slot = inventory_grid.get_child(
		inventory_slot_index
	)

	if leftover_quantity <= 0:
		source_slot.slot.clear()
	else:
		source_slot.slot.set_quantity(
			leftover_quantity
		)


# ==============================================================================
# TRANSFER SINGLE ITEM
# ==============================================================================

func move_just_one_item_to_storage(context):
	var storage_slot_index = context.slot_index

	if !storage_inventory._isSlot_Empty_At(storage_slot_index):

		if transfer_single_storage_item_to_container(
			storage_inventory.DATA,
			source_parent_control.storage_core_data.DATA,
			destination_controller.get_children(),
			storage_slot_index,
			self
		):
			storage_inventory._updateItem_MinusOne(
				storage_slot_index
			)

		leftover_quantity = 0


# ==============================================================================
# TRANSFER ONE STORAGE ITEM
# ==============================================================================

func transfer_single_storage_item_to_container(
	inventory: Dictionary,
	storage,
	container: Array,
	slot_index: int,
	inventory_grid: GridContainer
):
	var source_slot_data = inventory.get(slot_index)

	if source_slot_data == null:
		return

	var item_path = source_slot_data[0]
	var quantity := int(source_slot_data[1])

	# Nothing to transfer.
	if item_path == null or quantity <= 0:
		return

	var item = load(item_path)

	if item == null:
		return

	var max_stack: int = item.max_stack


	# ==========================================================================
	# FIND EXISTING STACK
	# ==========================================================================

	for destination_slot in container:
		if destination_slot.slot.item != item:
			continue

		var current_quantity := int(
			destination_slot.slot.quantity
		)

		if current_quantity >= max_stack:
			continue

		# Add exactly ONE item.
		current_quantity += 1


		# ----------------------------------------------------------------------
		# STORAGE DATA
		# ----------------------------------------------------------------------

		# The original code uses InvCore.DATA here.
		InvCore.DATA[destination_slot.indx][1] = current_quantity


		# ----------------------------------------------------------------------
		# STORAGE UI
		# ----------------------------------------------------------------------

		destination_slot.slot.set_quantity(
			current_quantity
		)


		# ----------------------------------------------------------------------
		# INVENTORY DATA
		# ----------------------------------------------------------------------

		quantity -= 1
		inventory[slot_index][1] = quantity


		# ----------------------------------------------------------------------
		# INVENTORY UI
		# ----------------------------------------------------------------------

		var source_slot = inventory_grid.get_child(
			slot_index
		)

		if quantity <= 0:
			source_slot.slot.clear()
		else:
			source_slot.slot.set_quantity(quantity)

		return


	# ==========================================================================
	# FIND EMPTY INVENTORY SLOT
	# ==========================================================================

	for destination_slot in container:
		if destination_slot.slot.item != null:
			continue


		# ----------------------------------------------------------------------
		# STORAGE DATA
		# ----------------------------------------------------------------------

		# The original code uses InvCore.DATA here.
		InvCore.DATA[destination_slot.indx][0] = item.resource_path
		InvCore.DATA[destination_slot.indx][1] = 1


		# ----------------------------------------------------------------------
		# STORAGE UI
		# ----------------------------------------------------------------------

		destination_slot.slot.set_item(item)
		destination_slot.slot.set_quantity(1)


		# ----------------------------------------------------------------------
		# INVENTORY DATA
		# ----------------------------------------------------------------------

		quantity -= 1
		inventory[slot_index][1] = quantity


		# ----------------------------------------------------------------------
		# INVENTORY UI
		# ----------------------------------------------------------------------

		var source_slot = inventory_grid.get_child(
			slot_index
		)

		if quantity <= 0:
			source_slot.slot.clear()
		else:
			source_slot.slot.set_quantity(quantity)

		return


	# ==========================================================================
	# NO ROOM
	# ==========================================================================

	return


# ==============================================================================
# SUPPORT FUNCTIONS
# ==============================================================================

## Returns true if the currently held stack is full.
func _is_holding_stack_full() -> bool:
	var item_stack = int(holding_item.label.text)
	var item_max_stack = int(holding_item_resource.max_stack)

	return item_stack == item_max_stack


## Refreshes the UI for every storage slot.
func update_UI() -> void:
	var slots = get_children()

	for slot in slots:
		slot.update_ui()
