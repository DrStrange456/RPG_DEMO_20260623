@icon("res://assets/icons/inv_Icons/InventoryContainer.svg")
extends GridContainer

# CoreInventoryController.gd



@onready var Core_Storage_Controller: GridContainer = $"../../../StorageContainerCore_Demo/Panel/CoreStorageController"
@onready var storage_container_core_demo: Control = $"../../../StorageContainerCore_Demo"




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
	if !InvCore._isSlot_Empty(slot):
		if holding_item != null:  # Holding Item with Mouse
			if !InvCore._isSlotItem_diff(slot, holding_item):
				if _is_holding_stack_full(): 
					return  # slot full, cannot add
				Right_Click_Holding_Same_Item(slot)
		else:
			Right_Click_Not_Holding(slot)




## - Handle Left Clicks

func Left_Click_Not_Holding(slot: InvSlotUI):
	var context = {
				"source": self,
				"container": Core_Storage_Controller,
				"slot_index": slot.indx
			}
	move_item_to_storage(context)
	Core_Storage_Controller.update_UI()






## - Handle Right Clicks

func Right_Click_Not_Holding(slot: InvSlotUI):
	if slot.slot.quantity == 1:
		Left_Click_Not_Holding(slot)
	else:  # slot qty > 1
		var context = {
				"source": self,
				"container": Core_Storage_Controller,
				"slot_index": slot.indx
			}
		move_just_one_item_to_storage(context)
	Core_Storage_Controller.update_UI()
	debug_out()

func Right_Click_Holding_Same_Item(slot: InvSlotUI):
	#if !InvCore._isSlot_Empty(slot):
		#if slot.slot.quantity == 1:
			## - Mouse pick single item, add to holding -
			#mouse_take_item_fromSlot_holding(slot)
		#else:
			## - Mouse pick from multiples  -
			## decrement slot stack, and increment holding stack
			#mouse_pick_item_fromSlot_holding(slot)
	pass



#func _Right_Click_Not_Holding(slot):
	#move_just_one_item_to_storage(slot)

#func mouse_get_item_from_slot(slot):
	#if InvCore._isSlot_Empty(slot): return
	#mouse_pick_from_slot(slot)
#
#func mouse_pick_from_slot(slot: InvSlotUI):
	#pin_to_mouse(slot)
#
#func pin_to_mouse(slot: InvSlotUI):
	#store_key_data(slot)
	#move_item_to_mouse_holding(slot)
	#remove_from_inventory(slot.indx)
#
#func store_key_data(slot: InvSlotUI):
	#holding_item_resource = slot.slot.item
	#holding_item_qty = int(slot.qty_label.text)
#
#func move_item_to_mouse_holding(slot: InvSlotUI):
	#holding_item = pin_item_to_mouse(slot)
#
#func pin_item_to_mouse(slot: InvSlotUI):
	#if slot.slot.item:
		## unparent item obj and attach to mouse, 
		## must add back to scene tree so added to current (InvController) node
		#var itm_preview = slotPreview.instantiate()
		#itm_preview._set_texture(slot.slot.item.icon)
		#itm_preview._set_quantity(slot.qty_label.text)
		#add_child(itm_preview)
		#return itm_preview
#
#func remove_from_inventory(intSlotIndex: int):
	#InvCore._remove_item_at(intSlotIndex)
	#
	## * Update UI
	#var slots = get_children()
	#slots[intSlotIndex].slot.item = null
	#slots[intSlotIndex].slot.quantity = ""
	#slots[intSlotIndex].update_ui()







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







### INV to STRG
func move_item_to_storage(ctx):
	var gcGRID_INV = ctx.source
	var gcGRID_STRG = ctx.container
	var intSlotIndex = ctx.slot_index
	if !InvCore._isSlot_Empty_At(intSlotIndex):
		if transfer_inventory_slot_to_container(
			InvCore.DATA,
			storage_container_core_demo.storage_core_data.DATA,
			gcGRID_STRG.get_children(),
			intSlotIndex):
				
			InvCore._remove_item_at(intSlotIndex)
		else:
			_return_what_didnt_fit(gcGRID_INV,intSlotIndex)
		leftover_delta = 0

func move_just_one_item_to_storage(ctx):
	var gcGRID_INV = ctx.source
	var gcGRID_STRG = ctx.container
	var intSlotIndex = ctx.slot_index
	if !InvCore._isSlot_Empty_At(intSlotIndex):
		if transfer_single_inventory_item_to_container(
			InvCore.DATA,
			storage_container_core_demo.storage_core_data.DATA,
			gcGRID_STRG.get_children(),
			intSlotIndex):
				
			#InvCore._remove_item_at(intSlotIndex)
			InvCore._updateItem_MinusOne(intSlotIndex)
			# should only be removing a single item
		#else:
			#_return_what_didnt_fit(gcGRID_INV,intSlotIndex)
		leftover_delta = 0








func transfer_inventory_slot_to_container(
	inventory: Dictionary, 
	storage,
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

			var new_slot_qty: int = int(slot.slot.quantity + add)
			storage[slot.indx][1] = new_slot_qty  # DATA
			slot.slot.set_quantity(new_slot_qty)  # UI
			remaining -= add

	# --- fill empty slots ---
	for slot in container:

		if remaining <= 0:
			break

		if slot.slot.item == null:

			var stack = min(max_stack, remaining)

			slot.slot.set_item(item)
			slot.slot.set_quantity(stack)
			
			storage[slot.indx][0] = item.resource_path
			storage[slot.indx][1] = stack

			remaining -= stack

	# --- update inventory dictionary ---
	if remaining == 0:
		InvCore._remove_item_at(slot_index)
	if remaining > 0:
		leftover_delta = remaining


#func transfer_single_inventory_item_to_container(
	#inventory: Dictionary, 
	#storage,
	#container: Array, 
	#slot_index: int):
		#
	#var src_slot_data = inventory[slot_index]
	#var item_path = src_slot_data[0]
	#var quantity = src_slot_data[1]
#
	#if item_path == null:
		#return
#
	#var item = load(item_path)
	#var max_stack = item.max_stack
	#var src_remaining = int(quantity)
#
	## --- fill existing stacks ---
	#for slot in container:
#
		#if src_remaining <= 0:
			#break
#
		#if slot.slot.item == item:
#
			#var space = max_stack - slot.slot.quantity
			#if space <= 0:
				#continue
#
			#var add = min(space, src_remaining)
#
			##var new_slot_qty: int = int(slot.slot.quantity + add)
			#var new_slot_qty: int = int(slot.slot.quantity - 1)
			#var new_strg_slot_qty: int = storage[slot.indx][1] + 1
			#storage[slot.indx][1] = new_strg_slot_qty  # DATA
			#slot.slot.set_quantity(new_slot_qty)  # UI
			#src_remaining -= add
#
	## --- fill empty slots ---
	#for dest_slot in container:
#
		#if src_remaining <= 0:
			#break
#
		#if dest_slot.slot.item == null:
#
			#var src_stack = min(max_stack, src_remaining)
			##var stack = 1
#
			## UI
			#dest_slot.slot.set_item(item)
			#dest_slot.slot.set_quantity(1) # SRC
			#
			## DATA
			#storage[dest_slot.indx][0] = item.resource_path
			#storage[dest_slot.indx][1] = 1 # DEST
#
			##src_remaining -= 1
			#src_remaining -= src_stack
			#return
#
	## --- update inventory dictionary ---
	#if src_remaining == 0:
		#InvCore._remove_item_at(slot_index)
	#if src_remaining > 0:
		#leftover_delta = src_remaining

func transfer_single_inventory_item_to_container(
	inventory: Dictionary,
	storage,
	container: Array,
	slot_index: int
):

	var src_slot_data = inventory[slot_index]
	var item_path = src_slot_data[0]
	var quantity = int(src_slot_data[1])

	# Source slot is empty
	if item_path == null or quantity <= 0:
		return

	var item = load(item_path)

	if item == null:
		return

	var max_stack: int = item.max_stack


	# ============================================================
	# TRANSFER EXACTLY ONE ITEM
	# ============================================================

	# ------------------------------------------------------------
	# 1. Look for an existing matching storage stack
	# ------------------------------------------------------------

	for dest_slot in container:

		if dest_slot.slot.item != item:
			continue

		var current_quantity: int = int(dest_slot.slot.quantity)

		if current_quantity >= max_stack:
			continue

		# Add ONE item to storage
		var new_quantity := current_quantity + 1

		# DATA - storage
		storage[dest_slot.indx][1] = new_quantity

		# UI - storage
		dest_slot.slot.set_quantity(new_quantity)

		# DATA - inventory
		inventory[slot_index][1] = quantity - 1

		# UI - inventory
		var source_slot = get_child(slot_index)

		if source_slot:
			if quantity - 1 <= 0:
				source_slot.slot.clear()
			else:
				source_slot.slot.set_quantity(quantity - 1)

		return


	# ------------------------------------------------------------
	# 2. Look for an empty storage slot
	# ------------------------------------------------------------

	for dest_slot in container:

		if dest_slot.slot.item != null:
			continue

		# DATA - storage
		storage[dest_slot.indx][0] = item.resource_path
		storage[dest_slot.indx][1] = 1

		# UI - storage
		dest_slot.slot.set_item(item)
		dest_slot.slot.set_quantity(1)

		# DATA - inventory
		inventory[slot_index][1] = quantity - 1

		# UI - inventory
		#var source_slot = get_node_or_null("../InventorySlotContainer").get_child(slot_index)
		var source_slot = get_child(slot_index)

		if source_slot:
			if quantity - 1 <= 0:
				source_slot.slot.clear()
			else:
				source_slot.slot.set_quantity(quantity - 1)

		return


	# ------------------------------------------------------------
	# 3. Storage is full / no available space
	# ------------------------------------------------------------

	return




func _return_what_didnt_fit(gcGRID_INV: GridContainer,intSlotIndex: int):
	# - - Update Data then UI
	# DATA
	InvCore._updateItem_At(intSlotIndex,leftover_delta)
	# UI
	var handle_to_source_slot = gcGRID_INV.get_child(intSlotIndex)
	if leftover_delta <= 0:
		handle_to_source_slot.slot.clear()
	else:
		handle_to_source_slot.slot.set_quantity(leftover_delta)










## - Functions
func _is_holding_stack_full()->bool:
	var itm_stack = int(holding_item.label.text)
	var itm_max_stack = int(holding_item_resource.max_stack)
	return itm_stack == itm_max_stack

func update_UI():
	var slots = get_children()
	for m in slots:
		m.update_ui()





# BOTTOM
