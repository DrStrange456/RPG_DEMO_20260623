@icon("res://assets/icons/inv_Icons/InventoryContainer.svg")
extends GridContainer

# CoreStorageController.gd
# inventory links verified


@export var SRC_Controller: GridContainer
@export var DST_Controller: GridContainer


@onready var core_inventory_controller_strg: GridContainer = $"../../../StorageInventoryCore_Demo/Panel/CoreInventoryController_Strg"
@onready var storage_container_core_demo: Control = $"../.."
@onready var strgInv = storage_container_core_demo.storage_core_data



var slotPreview = GmMgr.glSlotPrev
var holding_item

# - these are for tracking while holding the item
var holding_item_resource
var holding_item_qty

var leftover_delta: int = 0


func _process(_delta: float) -> void:
	if holding_item != null:  # Set item holding to mouse pos
		_update_mouse_holding_item_position()

func _update_mouse_holding_item_position():
	holding_item.position = get_local_mouse_position() - Vector2(20,20)




func _set_slot(indx):
	var ic_children = get_children()
	var slot_for_update: InvSlotUI = ic_children[indx]
	if !slot_for_update.is_connected("gui_input", _slot_gui_input.bind(slot_for_update)):
		slot_for_update.connect("gui_input", _slot_gui_input.bind(slot_for_update))

func _slot_gui_input(event: InputEvent, slot: InvSlotUI):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT && event.pressed:
			pick_all_from_slot(event,slot)  # HANDLE LEFT CLICKS
		if event.button_index == MOUSE_BUTTON_RIGHT && event.pressed:
			pick_just_one_from_slot(event,slot)  # HANDLE RIGHT CLICKS



## LEFT CLICK
func pick_all_from_slot(_event: InputEvent, slot: InvSlotUI):
	if holding_item == null:  # Holding Item with Mouse
		Left_Click_Not_Holding(slot)


## RIGHT CLICK
func pick_just_one_from_slot(_event: InputEvent, slot: InvSlotUI):
	strgInv = storage_container_core_demo.storage_core_data
	if !strgInv._isSlot_Empty(slot):
		if holding_item == null:  # Holding Item with Mouse
			Right_Click_Not_Holding(slot)


## - Handle Left Clicks

func Left_Click_Not_Holding(slot: InvSlotUI):
	var context = {
				"source": self,
				"container": core_inventory_controller_strg,
				"slot_index": slot.indx
			}
	move_item_to_inventory(context)
	core_inventory_controller_strg.update_UI()
	debug_out()


## - Handle Right Clicks

func Right_Click_Not_Holding(slot: InvSlotUI):
	if slot.slot.quantity == 1:
		Left_Click_Not_Holding(slot)
	else:  # slot qty > 1
		var context = {
				"source": self,
				"container": core_inventory_controller_strg,
				"slot_index": slot.indx
			}
		move_just_one_item_to_storage(context)
	core_inventory_controller_strg.update_UI()
	debug_out()


### STRG to INV
func move_item_to_inventory(ctx):
	# Move whole slot
	var gcGRID_INV = ctx.source
	var gcGRID_STRG = ctx.container
	var intSlotIndex = ctx.slot_index
	strgInv = storage_container_core_demo.storage_core_data
	if !strgInv._isSlot_Empty_At(intSlotIndex):
		if transfer_storage_slot_to_inventory(
			strgInv.DATA,
			InvCore.DATA,
			gcGRID_STRG.get_children(),
			intSlotIndex):
				
			strgInv._remove_item_at(intSlotIndex)
		else:
			_return_what_didnt_fit(gcGRID_INV,intSlotIndex)
		leftover_delta = 0


func transfer_storage_slot_to_inventory(
	inventory: Dictionary, 
	invStorage,
	container: Array, 
	slot_index: int):
	var slot_data = inventory[slot_index]
	var item_path = slot_data[0]
	var quantity = slot_data[1]

	if item_path == null:
		return

	var item = load(item_path)
	var max_stack = item.max_stack
	var remaining = int(quantity)

	# --- fill existing stacks ---
	for slot in container:

		if remaining <= 0:
			break

		if slot.slot.item == item:

			var space = max_stack - slot.slot.quantity
			if space <= 0:
				continue

			var add = min(space, remaining)

			invStorage[slot.indx][1] = slot.slot.quantity + add
			slot.slot.set_quantity(slot.slot.quantity + add)
			remaining -= add

	# --- fill empty slots ---
	for slot in container:

		if remaining <= 0:
			break

		if slot.slot.item == null:

			var stack = min(max_stack, remaining)

			slot.slot.set_item(item)
			slot.slot.set_quantity(stack)
			
			invStorage[slot.indx][0] = item.resource_path
			invStorage[slot.indx][1] = stack

			remaining -= stack

	# --- update inventory dictionary ---
	if remaining == 0:
		inventory[slot_index] = [ null, 0, true ]
	if remaining > 0:
		leftover_delta = remaining


func _return_what_didnt_fit(gcGRID_INV: GridContainer,intSlotIndex: int):
	# - - Update Data then UI
	# DATA
	strgInv._updateItem_At(intSlotIndex,leftover_delta)
	# UI
	var handle_to_source_slot = gcGRID_INV.get_child(intSlotIndex)
	if leftover_delta <= 0:
		handle_to_source_slot.slot.clear()
	else:
		handle_to_source_slot.slot.set_quantity(leftover_delta)





## STRG to INV
func move_just_one_item_to_storage(ctx):
	var gcGRID_STRG = ctx.container
	var intSlotIndex = ctx.slot_index
	if !strgInv._isSlot_Empty_At(intSlotIndex):
		if transfer_single_storage_item_to_container(
			strgInv.DATA,
			storage_container_core_demo.storage_core_data.DATA,
			DST_Controller.get_children(),
			intSlotIndex,
			self):
			
			strgInv._updateItem_MinusOne(intSlotIndex)
		leftover_delta = 0


func transfer_single_storage_item_to_container(
	inventory: Dictionary,
	storage,
	container: Array,
	slot_index: int,
	inventory_grid: GridContainer):

	var src_slot_data = inventory.get(slot_index)

	if src_slot_data == null:
		return

	var item_path = src_slot_data[0]
	var quantity := int(src_slot_data[1])

	# Nothing to transfer
	if item_path == null or quantity <= 0:
		return

	var item = load(item_path)

	if item == null:
		return

	var max_stack: int = item.max_stack


	# ============================================================
	# FIND EXISTING STACK
	# ============================================================

	for dest_slot in container:

		if dest_slot.slot.item != item:
			continue

		var current_quantity := int(dest_slot.slot.quantity)

		if current_quantity >= max_stack:
			continue

		# Add exactly ONE
		current_quantity += 1

		# STORAGE DATA
		#storage[dest_slot.indx][1] = current_quantity
		InvCore.DATA[dest_slot.indx][1] = current_quantity

		# STORAGE UI
		dest_slot.slot.set_quantity(current_quantity)

		# INVENTORY DATA
		quantity -= 1
		inventory[slot_index][1] = quantity

		# INVENTORY UI
		var source_slot = inventory_grid.get_child(slot_index)

		if quantity <= 0:
			source_slot.slot.clear()
		else:
			source_slot.slot.set_quantity(quantity)

		return


	# ============================================================
	# FIND EMPTY STORAGE SLOT
	# ============================================================

	for dest_slot in container:

		if dest_slot.slot.item != null:
			continue

		# STORAGE DATA
		#storage[dest_slot.indx][0] = item.resource_path
		#storage[dest_slot.indx][1] = 1
		
		InvCore.DATA[dest_slot.indx][0] = item.resource_path
		InvCore.DATA[dest_slot.indx][1] = 1

		# STORAGE UI
		dest_slot.slot.set_item(item)
		dest_slot.slot.set_quantity(1)

		# INVENTORY DATA
		quantity -= 1
		inventory[slot_index][1] = quantity

		# INVENTORY UI
		var source_slot = inventory_grid.get_child(slot_index)

		if quantity <= 0:
			source_slot.slot.clear()
		else:
			source_slot.slot.set_quantity(quantity)

		return


	# ============================================================
	# NO ROOM
	# ============================================================

	return










## - Functions
func _is_holding_stack_full()->bool:
	var itm_stack = int(holding_item.label.text)
	var itm_max_stack = int(holding_item_resource.max_stack)
	return itm_stack == itm_max_stack

func update_UI():
	var slots = get_children()
	for m in slots:
		m.update_ui()








func debug_out():
	print_inventory_debug(InvCore.DATA)
	print_inventory_debug(storage_container_core_demo.storage_core_data.DATA)


func print_inventory_debug(inventory: Dictionary) -> void:
	print("\n========== INVENTORY ==========")

	for index in inventory:
		var item = inventory[index]

		print(
			"Slot %02d | Item: %-45s | Amount: %3d | Enabled: %s"
			% [
				index,
				str(item[0]),
				item[1],
				item[2]
			]
		)

	print("================================\n")






# BOTTOM
