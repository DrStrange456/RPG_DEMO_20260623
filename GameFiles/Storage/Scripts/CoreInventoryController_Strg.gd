extends gridcontainer_base


# ==============================================================================
# CoreInventoryController.gd
# ==============================================================================
#
# Handles transferring items from the inventory to the storage container.
#
# LEFT CLICK
#   Transfers the entire stack.
#
# RIGHT CLICK
#   Transfers one item from the stack.
#
# ==============================================================================


# ==============================================================================
# CONTROLLER REFERENCES
# ==============================================================================

@export var source_controller: GridContainer
@export var destination_controller: GridContainer


# ==============================================================================
# STORAGE REFERENCES
# ==============================================================================

@onready var storage_controller: GridContainer = (
	$"../../../Storage_StorageControl/Panel/Storage_CoreStorageController"
)

@onready var storage_parent_control: Control = (
	$"../../../Storage_StorageControl"
)


# ==============================================================================
# ITEM HOLDING
# ==============================================================================

var slot_preview = GmMgr.glSlotPrev

# Tracks the item currently being held by the mouse.
var holding_item_resource
var holding_item_quantity

# Tracks how many items could not be transferred.
var leftover_quantity: int = 0


# ==============================================================================
# PROCESS
# ==============================================================================

func _process(_delta: float) -> void:
	if holding_item != null:
		_update_holding_item_position()


func _update_holding_item_position() -> void:
	holding_item.position = get_local_mouse_position() - Vector2(20, 20)


# ==============================================================================
# SLOT SETUP
# ==============================================================================

func _set_slot(slot_index):

	var inventory_slots = get_children()
	var slot_to_update: InvSlotUI = inventory_slots[slot_index]

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

	# Only transfer if we are not already holding an item.
	if holding_item == null:
		left_click_not_holding(slot)


# ==============================================================================
# RIGHT CLICK
# ==============================================================================

func pick_just_one_from_slot(_event: InputEvent, slot: InvSlotUI):

	if !InvCore._isSlot_Empty(slot):

		# Only transfer if we are not already holding an item.
		if holding_item == null:
			right_click_not_holding(slot)


# ==============================================================================
# LEFT CLICK HANDLING
# ==============================================================================

func left_click_not_holding(slot: InvSlotUI):

	var context = {
		"source": self,
		"container": storage_controller,
		"slot_index": slot.indx
	}

	move_item_to_storage(context)

	storage_controller.update_UI()


# ==============================================================================
# RIGHT CLICK HANDLING
# ==============================================================================

func right_click_not_holding(slot: InvSlotUI):

	# A single item uses the normal full-stack transfer.
	if slot.slot.quantity == 1:

		left_click_not_holding(slot)

	else:

		# Multiple items: transfer only one.
		var context = {
			"source": self,
			"container": storage_controller,
			"slot_index": slot.indx
		}

		move_just_one_item_to_storage(context)

	storage_controller.update_UI()


# ==============================================================================
# INVENTORY -> STORAGE
# ==============================================================================

func move_item_to_storage(context):

	var inventory_grid = context.source
	var storage_grid = context.container
	var inventory_slot_index = context.slot_index

	if !InvCore._isSlot_Empty_At(inventory_slot_index):

		if transfer_inventory_slot_to_container(
			InvCore.DATA,
			storage_parent_control.storage_core_data.DATA,
			storage_grid.get_children(),
			inventory_slot_index
		):

			InvCore._remove_item_at(inventory_slot_index)

		else:

			_return_what_didnt_fit(
				inventory_grid,
				inventory_slot_index
			)

		leftover_quantity = 0


# ==============================================================================
# TRANSFER ENTIRE INVENTORY STACK
# ==============================================================================

func transfer_inventory_slot_to_container(
	inventory: Dictionary,
	storage,
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


	# ------------------------------------------------------------------------------
	# FILL EXISTING STACKS
	# ------------------------------------------------------------------------------

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

			var new_slot_quantity: int = int(
				slot.slot.quantity + amount_to_add
			)

			# Update storage data.
			storage[slot.indx][1] = new_slot_quantity

			# Update storage UI.
			slot.slot.set_quantity(new_slot_quantity)

			remaining_quantity -= amount_to_add


	# ------------------------------------------------------------------------------
	# FILL EMPTY SLOTS
	# ------------------------------------------------------------------------------

	for slot in container:

		if remaining_quantity <= 0:
			break

		if slot.slot.item == null:

			var stack_quantity = min(
				max_stack,
				remaining_quantity
			)

			# Update storage UI.
			slot.slot.set_item(item)
			slot.slot.set_quantity(stack_quantity)

			# Update storage data.
			storage[slot.indx][0] = item.resource_path
			storage[slot.indx][1] = stack_quantity

			remaining_quantity -= stack_quantity


	# ------------------------------------------------------------------------------
	# UPDATE INVENTORY DATA
	# ------------------------------------------------------------------------------

	if remaining_quantity == 0:
		InvCore._remove_item_at(slot_index)

	if remaining_quantity > 0:
		leftover_quantity = remaining_quantity


# ==============================================================================
# TRANSFER SINGLE ITEM
# ==============================================================================

func move_just_one_item_to_storage(context):

	var storage_grid = context.container
	var inventory_slot_index = context.slot_index

	if !InvCore._isSlot_Empty_At(inventory_slot_index):

		if transfer_single_inventory_item_to_container(
			InvCore.DATA,
			storage_parent_control.storage_core_data.DATA,
			storage_grid.get_children(),
			inventory_slot_index,
			self
		):

			InvCore._updateItem_MinusOne(inventory_slot_index)

		leftover_quantity = 0


# ==============================================================================
# TRANSFER ONE INVENTORY ITEM
# ==============================================================================

func transfer_single_inventory_item_to_container(
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


	# ------------------------------------------------------------------------------
	# FIND EXISTING STACK
	# ------------------------------------------------------------------------------

	for destination_slot in container:

		if destination_slot.slot.item != item:
			continue

		var current_quantity := int(
			destination_slot.slot.quantity
		)

		if current_quantity >= max_stack:
			continue

		# Add exactly one item.
		current_quantity += 1

		# Update storage data.
		storage[destination_slot.indx][1] = current_quantity

		# Update storage UI.
		destination_slot.slot.set_quantity(current_quantity)

		# Update inventory data.
		quantity -= 1
		inventory[slot_index][1] = quantity

		# Update inventory UI.
		var source_slot = inventory_grid.get_child(slot_index)

		if quantity <= 0:
			source_slot.slot.clear()
		else:
			source_slot.slot.set_quantity(quantity)

		return


	# ------------------------------------------------------------------------------
	# FIND EMPTY STORAGE SLOT
	# ------------------------------------------------------------------------------

	for destination_slot in container:

		if destination_slot.slot.item != null:
			continue

		# Update storage data.
		storage[destination_slot.indx][0] = item.resource_path
		storage[destination_slot.indx][1] = 1

		# Update storage UI.
		destination_slot.slot.set_item(item)
		destination_slot.slot.set_quantity(1)

		# Update inventory data.
		quantity -= 1
		inventory[slot_index][1] = quantity

		# Update inventory UI.
		var source_slot = inventory_grid.get_child(slot_index)

		if quantity <= 0:
			source_slot.slot.clear()
		else:
			source_slot.slot.set_quantity(quantity)

		return


	# ------------------------------------------------------------------------------
	# NO ROOM
	# ------------------------------------------------------------------------------

	return


# ==============================================================================
# RETURN ITEMS THAT DID NOT FIT
# ==============================================================================

func _return_what_didnt_fit(
	inventory_grid: GridContainer,
	inventory_slot_index: int
):

	# Update inventory data.
	InvCore._updateItem_At(
		inventory_slot_index,
		leftover_quantity
	)

	# Update inventory UI.
	var source_slot = inventory_grid.get_child(
		inventory_slot_index
	)

	if leftover_quantity <= 0:
		source_slot.slot.clear()
	else:
		source_slot.slot.set_quantity(leftover_quantity)


# ==============================================================================
# SUPPORT FUNCTIONS
# ==============================================================================

## Returns true if the currently held stack is full.
func _is_holding_stack_full() -> bool:

	var item_stack = int(holding_item.label.text)
	var item_max_stack = int(holding_item_resource.max_stack)

	return item_stack == item_max_stack


## Refreshes the UI for every inventory slot.
func update_UI() -> void:

	var slots = get_children()

	for slot in slots:
		slot.update_ui()




# Bottom
