class_name storage_data_core
extends DataCore

## CORE STORAGE
#var tmpDATA = {
		#0: [null, 0, true],
		#1: [null, 0, true],
		##1: ["res://resources/seeds_strawberry.tres", 3, true],
		#2: [null, 0, true],
		#3: [null, 0, true],
		#4: [null, 0, true],
		#5: [null, 0, true],
		#6: [null, 0, true],
		#7: [null, 0, true],
		#8: [null, 0, true],
		#9: [null, 0, true],
		#10: [null, 0, true],
		#11: [null, 0, true],
#}

## - Testing data
var tmpDATA = {
		0: ["res://resources/seeds_turnip.tres", 50, true],
		1: ["res://resources/seeds_strawberry.tres", 3, true],
		2: ["res://resources/weapon_sword_fire.tres", 1, true],
		3: [null, 0, true],
		4: ["res://resources/seeds_tomato.tres", 65, true],
		5: ["res://resources/seeds_carrot.tres", 10, true],
		6: ["res://resources/seeds_strawberry.tres", 60, true],
		7: [null, 0, true],
		8: [null, 0, true],
		9: ["res://resources/seeds_strawberry.tres", 35, true],
		10: ["res://resources/seeds_strawberry.tres", 85, true],
		11: [null, 0, true],
}


func _ready() -> void:
	set_data_values(tmpDATA)

func _init() -> void:
	set_data_values(tmpDATA)


func _save_core_inventory_to(glINVENTORY: Dictionary):
	glINVENTORY.clear()
	for i in DATA:
		glINVENTORY[i] = DATA[i].duplicate()

func _putItem_intoSlot(idx: int, res: String, qty: int):
	DATA[idx][0] = res
	DATA[idx][1] = qty

func _updateItem_MinusOne(idx: int):
	DATA[idx][1] -= 1

func _updateItem_Quantity(idx: int, qty: int):
	DATA[idx][1] = qty

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

func _remove_item_at(indx: int):
	if DATA.has(indx):
		DATA[indx] = [null, 0, true]



# BOTTOM
