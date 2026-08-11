extends Node

var INVENTORY: Dictionary = {
		0: ["res://resources/seeds_turnip.tres", 98, true],
		1: ["res://resources/seeds_strawberry.tres", 99, true],
		2: ["res://resources/weapon_sword_fire.tres", 1, true],
		3: ["res://resources/weapon_sword1.tres", 1, true],
		4: ["res://resources/seeds_tomato.tres", 65, true],
		5: ["res://resources/seeds_carrot.tres", 10, true],
		6: ["res://resources/tool_axe.tres", 1, true],
		7: ["res://resources/tool_pick.tres", 1, true],
		8: [null, 0, true],
		9: [null, 0, true],
		10: [null, 0, true],
		11: [null, 0, true],
}



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
