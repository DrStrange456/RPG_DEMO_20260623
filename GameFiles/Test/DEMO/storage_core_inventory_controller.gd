@icon("res://assets/icons/inv_Icons/InventoryContainer.svg")
extends GridContainer

# CoreInventoryController.gd
# inventory links verified


@onready var core_inventory_controller: GridContainer = $"../../../StorageContainer/Panel/CoreInventoryController"



var slotPreview = GmMgr.glSlotPrev
var holding_item

# - these are for tracking while holding the item
var holding_item_resource
var holding_item_qty




func _process(_delta: float) -> void:
	if holding_item != null:  # Set item holding to mouse pos
		_update_mouse_holding_item_position()

func _update_mouse_holding_item_position():
	holding_item.position = get_local_mouse_position() - Vector2(20,20)




func _set_slot(indx):
	var ic_children = get_children()
	var slot_for_update: InvSlotUI = ic_children[indx]
	if !slot_for_update.is_connected("gui_input", _slot_gui_input.bind(slot_for_update)):
		print("added gui input")
		slot_for_update.connect("gui_input", _slot_gui_input.bind(slot_for_update))

func _slot_gui_input(event: InputEvent, slot: InvSlotUI):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT && event.pressed:
			pick_all_from_slot(event,slot)  # HANDLE LEFT CLICKS
		if event.button_index == MOUSE_BUTTON_RIGHT && event.pressed:
			pick_just_one_from_slot(event,slot)  # HANDLE RIGHT CLICKS



## LEFT CLICK
func pick_all_from_slot(_event: InputEvent, slot: InvSlotUI):
	if holding_item != null:  # Holding Item with Mouse
		if InvCore._isSlot_Empty(slot):
			Left_Click_Empty_Slot(slot)
		else:  # Putting item into occupied slot
			if InvCore._isSlotItem_diff(slot, holding_item):
				Left_Click_Different_Item(slot)
			else:
				Left_Click_Same_Item(slot)
	else:  
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
				"container": core_inventory_controller,
				"slot_index": slot.indx
			}
			# FIXME: the old procedure pointing to wrong inventory.
	#StorageManager.move_item_to_storage(context)
	core_inventory_controller.update_UI()


func Left_Click_Empty_Slot(slot: InvSlotUI):
	#mouse_drop_in_EmptySlot(slot)
	pass

func Left_Click_Different_Item(slot: InvSlotUI):
	#mouse_and_slot_swap(slot)
	pass

func Left_Click_Same_Item(slot: InvSlotUI):
	#mouse_attempt_combine_like_items(slot)
	pass





## - Handle Right Clicks

func Right_Click_Not_Holding(slot: InvSlotUI):
	#if slot.slot.quantity == 1:
		#Left_Click_Not_Holding(slot)
	#else:  # slot qty > 1
		#mouse_pick_single_item_fromSlot(slot)
	pass

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

















### INV to STRG
func move_item_to_storage(ctx):
	var gcGRID_INV = ctx.source
	var gcGRID_STRG = ctx.container
	var intSlotIndex = ctx.slot_index
	#if ptrINVENTORY[intSlotIndex][0] != null:
		#if transfer_inventory_slot_to_container(ptrINVENTORY,gcGRID_STRG.get_children(),intSlotIndex):
			#_remove_from_inventory(gcGRID_INV,intSlotIndex)  # All items successfully transferred
		#else:
			#_return_what_didnt_fit(gcGRID_INV,intSlotIndex)
		#leftover_delta = 0




## - Functions

func mouse_drop_in_EmptySlot(slot: InvSlotUI):
	InvCore._putItem_intoSlot(
		slot.indx,
		holding_item_resource.resource_path,
		int(holding_item_qty))
	
	## * Update UI
	move_item_from_mouse_to_slot(slot)

func move_item_from_mouse_to_slot(obj_Slot):
	# 1) Unparent holding item and reparent to slot
	# 2) Set slot variables accordingly
	# - - - (1)
	remove_child(holding_item)
	obj_Slot.slot.item = holding_item_resource
	obj_Slot.qty_label = holding_item_qty
	obj_Slot.slot.quantity = holding_item_qty
	obj_Slot.update_ui()
	# - - - (2)
	holding_item = null

func _pin_single_item_to_mouse(slot):
	if slot:
		if !InvCore._isSlot_Empty(slot):
			# unparent item obj and attach to mouse, 
			# must add back to scene tree so added to current (InvController) node
			var itm_preview = slotPreview.instantiate()
			itm_preview._set_texture(slot.slot.item.icon)
			itm_preview._set_quantity(str(1))
			add_child(itm_preview)
			return itm_preview

#func isSlot_Empty(slot: InvSlotUI)->bool:
	#return InvCore._isSlot_Empty(slot)

func mouse_pick_from_slot(slot: InvSlotUI):
	pin_to_mouse(slot)

func pin_to_mouse(slot: InvSlotUI):
	store_key_data(slot)
	move_item_to_mouse_holding(slot)
	remove_from_inventory(slot.indx)

func move_item_to_mouse_holding(slot: InvSlotUI):
	holding_item = pin_item_to_mouse(slot)

func pin_item_to_mouse(slot: InvSlotUI):
	if slot.slot.item:
		# unparent item obj and attach to mouse, 
		# must add back to scene tree so added to current (InvController) node
		var itm_preview = slotPreview.instantiate()
		itm_preview._set_texture(slot.slot.item.icon)
		itm_preview._set_quantity(slot.qty_label.text)
		add_child(itm_preview)
		return itm_preview

func remove_from_inventory(intSlotIndex: int):
	InvCore._remove_item_at(intSlotIndex)
	
	# * Update UI
	var slots = get_children()
	slots[intSlotIndex].slot.item = null
	slots[intSlotIndex].slot.quantity = ""
	slots[intSlotIndex].update_ui()

func store_key_data(slot: InvSlotUI):
	holding_item_resource = slot.slot.item
	holding_item_qty = int(slot.qty_label.text)

func mouse_and_slot_swap(obj_Slot: InvSlotUI):
	var slot_idx = obj_Slot.indx
	var itm_resource = obj_Slot.slot.item
	var slot_qty = obj_Slot.slot.quantity
	
	# Copy slot item data to temp variables
	var holding_item_resource_tmp = itm_resource
	var holding_item_qty_tmp = slot_qty
	
	# * Update Data
	var tmp_resource = holding_item_resource.resource_path
	InvCore._putItem_intoSlot(slot_idx,tmp_resource,int(holding_item_qty))
	
	# * Update UI
	move_item_from_mouse_to_slot(obj_Slot)
	
	holding_item_resource = holding_item_resource_tmp
	holding_item_qty = holding_item_qty_tmp
	
	var itm_preview = slotPreview.instantiate()
	itm_preview._set_texture(holding_item_resource.icon)
	itm_preview._set_quantity(str(holding_item_qty))
	add_child(itm_preview)
	holding_item = itm_preview

func mouse_attempt_combine_like_items(obj_Slot: InvSlotUI):
	var itm_resource = obj_Slot.slot.item
	var itm_max_stack = itm_resource.max_stack
	
	var qty1 = int(obj_Slot.slot.quantity)    # Qty from Slot
	var qty2 = int(holding_item.label.text)  # Qty holding
	var room_to_add = itm_max_stack - qty1
	#
	if qty1 == itm_max_stack: return  # slot full, cannot add
	if room_to_add >= qty2:
		# Set slot qty to combined amount
		mouse_add_all_holding_to_slot(obj_Slot, qty1+qty2)
	else:
		# Add what will fit and update mouse holding
		mouse_add_what_will_fit_to_slot(obj_Slot, qty2-room_to_add)

func mouse_add_all_holding_to_slot(obj_Slot: InvSlotUI, amt: int)->void:
	var slot_idx = obj_Slot.indx
	
	# * Update Data
	var tmp_resource = holding_item_resource.resource_path
	InvCore._putItem_intoSlot(slot_idx,tmp_resource,int(amt))
	
	# * Update UI
	remove_child(holding_item)
	holding_item.free()
	obj_Slot.qty_label.text = str(amt)
	obj_Slot.slot.quantity = amt

func mouse_add_what_will_fit_to_slot(obj_Slot: InvSlotUI, leftover: int)->void:
	var slot_idx = obj_Slot.indx
	var itm_resource = obj_Slot.slot.item
	var itm_max_stack = itm_resource.max_stack
	
	# * Update Data
	var tmp_resource = holding_item_resource.resource_path
	InvCore._putItem_intoSlot(slot_idx,tmp_resource,int(itm_max_stack))
	
	# * Update UI
	obj_Slot.qty_label.text = str(itm_max_stack)
	obj_Slot.slot.quantity = itm_max_stack
	holding_item.label.text = str(leftover)
	holding_item_qty = str(leftover)

func _is_holding_stack_full()->bool:
	var itm_stack = int(holding_item.label.text)
	var itm_max_stack = int(holding_item_resource.max_stack)
	return itm_stack == itm_max_stack

func mouse_take_item_fromSlot_holding(obj_slot):
	var slot_idx = obj_slot.indx
	
	# * Update Data
	InvCore._remove_item_at(slot_idx)
	
	# * Update UI
	obj_slot.slot.item = null
	obj_slot.slot.quantity = ""
	obj_slot.update_ui()
	
	holding_item_qty = int(holding_item.label.text) + 1
	holding_item.label.text = str(holding_item_qty)

func mouse_pick_item_fromSlot_holding(obj_slot):
	var slot_idx = obj_slot.indx
	
	# * Update Data
	InvCore._updateItem_MinusOne(slot_idx)
	
	# * Update UI (SLOT/MOUSE)
	obj_slot.qty_label.text = str(int(obj_slot.qty_label.text) - 1)
	obj_slot.slot.quantity -= 1
	holding_item_qty = int(holding_item.label.text) + 1
	holding_item.label.text = str(holding_item_qty)

func mouse_pick_single_item_fromSlot(slot: InvSlotUI):
	var slot_idx = slot.indx
	var itm_resource = slot.slot.item
	
	holding_item_resource = itm_resource
	holding_item_qty = 1
	
	# * Update Data
	InvCore._updateItem_MinusOne(slot_idx)
	
	## * Update UI
	slot.qty_label.text = str(int(slot.qty_label.text) - 1)
	slot.slot.quantity -= 1
	holding_item = _pin_single_item_to_mouse(slot)






# BOTTOM
