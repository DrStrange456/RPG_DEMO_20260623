@icon("res://assets/icons/inv_Icons/InventoryContainer.svg")
extends GridContainer

# CoreInventoryController.gd

@onready var core_inventory_controller: GridContainer = $"."


var slotPreview = GmMgr.glSlotPrev
var holding_item
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
		if check_isSlot_Empty(slot):
			Left_Click_Empty_Slot(slot)
		else:  # Putting item into occupied slot
			if is_SlotItem_diff(slot, holding_item):
				Left_Click_Different_Item(slot)
			else:
				Left_Click_Same_Item(slot)
	else:  
		Left_Click_Not_Holding(slot)

## RIGHT CLICK
func pick_just_one_from_slot(_event: InputEvent, slot: InvSlotUI):
	if !check_isSlot_Empty(slot):
		if holding_item != null:  # Holding Item with Mouse
			if !is_SlotItem_diff(slot, holding_item):
				if _is_holding_stack_full(): 
					return  # slot full, cannot add
				Right_Click_Holding_Same_Item(slot)
		else:
			Right_Click_Not_Holding(slot)



## - Handle Left Clicks

func check_isSlot_Empty(slot: InvSlotUI)->bool:
	return InvCore._isSlot_Empty(slot)

func is_SlotItem_diff(itm_Slot: InvSlotUI, holding)->bool:
	return false

func Left_Click_Not_Holding(slot: InvSlotUI):
	if check_isSlot_Empty(slot): return
	mouse_pick_from_slot(slot)

func Left_Click_Empty_Slot(slot: InvSlotUI):
	pass

func Left_Click_Different_Item(slot: InvSlotUI):
	pass

func Left_Click_Same_Item(slot: InvSlotUI):
	pass





## - Handle Right Clicks

func _is_holding_stack_full()->bool:
	return false


func Right_Click_Not_Holding(slot: InvSlotUI):
	pass

func Right_Click_Holding_Same_Item(slot: InvSlotUI):
	pass







## - Functions

func mouse_pick_from_slot(slot: InvSlotUI):
	_pin_to_mouse(slot)

func _pin_to_mouse(slot: InvSlotUI):
	_store_key_data(slot)
	_move_item_to_mouse_holding(slot)
	_remove_from_inventory(slot.indx)

func _move_item_to_mouse_holding(slot: InvSlotUI):
	holding_item = _pin_item_to_mouse(slot)

func _pin_item_to_mouse(slot: InvSlotUI):
	if slot.slot.item:
		# unparent item obj and attach to mouse, 
		# must add back to scene tree so added to current (InvController) node
		var itm_preview = slotPreview.instantiate()
		itm_preview._set_texture(slot.slot.item.icon)
		itm_preview._set_quantity(slot.qty_label.text)
		add_child(itm_preview)
		return itm_preview

func _remove_from_inventory(intSlotIndex: int):
	InvCore._remove_item_at(intSlotIndex)
	
	# * Update UI
	var slots = core_inventory_controller.get_children()
	slots[intSlotIndex].slot.item = null
	slots[intSlotIndex].slot.quantity = ""
	slots[intSlotIndex].update_ui()

func _store_key_data(slot: InvSlotUI):
	holding_item_resource = slot.slot.item
	holding_item_qty = int(slot.qty_label.text)




# BOTTOM
