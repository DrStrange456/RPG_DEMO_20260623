class_name DataCore
extends Node


## CORE INVENTORY
var DATA: Dictionary = {}


func set_data_values(val: Dictionary)->void:
	DATA = val




func _save_core_inventory_to(glINVENTORY: Dictionary):
	glINVENTORY.clear()
	for i in DATA:
		glINVENTORY[i] = DATA[i].duplicate()

func _putItem_intoSlot(idx: int, res: String, qty: int):
	DATA[idx][0] = res
	DATA[idx][1] = qty

func _updateItem_MinusOne(idx: int):
	DATA[idx][1] -= 1

func _updateItem_At(idx: int, amt: int):
	DATA[idx][1] = amt

func _isSlotItem_diff(slot: InvSlotUI, holding)->bool:
	if slot and holding:
		var itm_in_slot = slot.slot.item
		var itm_in_mouse = holding
		# Return true if the textures are different
		if itm_in_slot:
			return (itm_in_slot.icon != itm_in_mouse.texture_rect.texture)
		else:
			return false  # return false if item_in_slot is null
	else:
		return true

func _isSlot_Empty(slot: InvSlotUI)->bool:
	var idx = slot.indx
	var itm = DATA[idx][0]
	if !DATA.has(idx):
		return true
	if itm == null: 
		return true
	return false

func _isSlot_Empty_At(idx: int)->bool:
	#var idx = slot.indx
	var itm = DATA[idx][0]
	if !DATA.has(idx):
		return true
	if itm == null: 
		return true
	return false

func _remove_item_at(indx: int):
	if DATA.has(indx):
		DATA[indx] = [null, 0, true]



# BOTTOM
