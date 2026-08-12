extends Node

var INVENTORY: Dictionary = {
		0: ["res://resources/seeds_turnip.tres", 98, true],
		1: ["res://resources/seeds_strawberry.tres", 1, true],
		2: ["res://resources/weapon_sword_fire.tres", 1, true],
		3: ["res://resources/weapon_sword1.tres", 1, true],
		4: ["res://resources/seeds_tomato.tres", 65, true],
		5: ["res://resources/seeds_carrot.tres", 10, true],
		6: ["res://resources/seeds_strawberry.tres", 60, true],
		7: ["res://resources/seeds_strawberry.tres", 85, true],
		8: [null, 0, true],
		9: [null, 0, true],
		10: [null, 0, true],
		11: [null, 0, true],
}




func _save_core_inventory(gcSLOTS: Dictionary,glINVENTORY: Dictionary):
	glINVENTORY.clear()
	for i in INVENTORY:
		glINVENTORY[i] = INVENTORY[i].duplicate()

func _putItem_intoSlot(idx: int, res: String, qty: int):
	INVENTORY[idx][0] = res
	INVENTORY[idx][1] = qty

func _isSlotItem_diff(slot: InvSlotUI, holding)->bool:
	# TODO: Needs testing
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
	var itm = INVENTORY[idx][0]
	if !INVENTORY.has(idx):
		return true
	if itm == null: 
		return true
	return false

func _remove_item_at(indx: int):
	if INVENTORY.has(indx):
		INVENTORY[indx] = [null, 0, true]
