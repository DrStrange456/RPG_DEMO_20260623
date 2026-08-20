extends DataCore

## CORE INVENTORY
var tmpDATA = {
		0: ["res://resources/seeds_turnip.tres", 98, true],
		1: ["res://resources/seeds_strawberry.tres", 3, true],
		2: ["res://resources/weapon_sword_fire.tres", 1, true],
		3: [null, 0, true],
		4: [null, 0, true],
		#4: ["res://resources/seeds_tomato.tres", 65, true],
		5: ["res://resources/seeds_carrot.tres", 10, true],
		6: ["res://resources/seeds_strawberry.tres", 60, true],
		7: [null, 0, true],
		8: ["res://resources/crop_strawberry.tres", 3, true],
		9: ["res://resources/crop_carrot.tres", 2, true],
		10: ["res://resources/crop_tomato.tres", 1, true],
		11: ["res://resources/crop_turnip.tres", 2, true],
}

func _ready() -> void:
	set_data_values(tmpDATA)




func _add_item_to_inventory(
	resource_path: String,
	quantity: int,
	enabled: bool = true
) -> int:

	var item = load(resource_path)

	if item == null:
		return quantity

	var remaining := quantity
	var max_stack: int = item.max_stack


	# ----------------------------------------------------------
	# PASS 1: FILL EXISTING STACKS
	# ----------------------------------------------------------

	for index in DATA:

		if remaining <= 0:
			return 0

		var slot = DATA[index]

		if slot[0] != resource_path:
			continue

		var current_quantity: int = int(slot[1])
		var available_space: int = max_stack - current_quantity

		if available_space <= 0:
			continue

		var amount_to_add: int = min(
			available_space,
			remaining
		)

		DATA[index][1] += amount_to_add
		remaining -= amount_to_add


	# ----------------------------------------------------------
	# PASS 2: USE EMPTY SLOTS
	# ----------------------------------------------------------

	for index in DATA:

		if remaining <= 0:
			return 0

		if DATA[index][0] != null:
			continue

		var amount_to_add: int = min(
			max_stack,
			remaining
		)

		DATA[index] = [
			resource_path,
			amount_to_add,
			enabled
		]

		remaining -= amount_to_add


	# ----------------------------------------------------------
	# RETURN WHAT DID NOT FIT
	# ----------------------------------------------------------

	return remaining





func _save_core_inventory_to(glINVENTORY: Dictionary):
	glINVENTORY.clear()
	for i in DATA:
		glINVENTORY[i] = DATA[i].duplicate()

func _putItem_intoSlot(idx: int, res: String, qty: int):
	DATA[idx][0] = res
	DATA[idx][1] = qty

func _updateItem_MinusOne(idx: int):
	DATA[idx][1] -= 1

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
