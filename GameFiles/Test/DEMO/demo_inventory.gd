extends Node2D


@onready var inv_grid_slots: GridContainer = $InventoryUI_Demo/Panel/MainInventoryController



var INVENTORY: Dictionary = {
		0: ["res://resources/seeds_turnip.tres", 98, true],
		1: ["res://resources/seeds_strawberry.tres", 99, true],
		2: ["res://resources/weapon_sword_fire.tres", 1, true],
		3: [null, 0, true],
		4: ["res://resources/seeds_tomato.tres", 65, true],
		5: ["res://resources/seeds_carrot.tres", 10, true],
		6: ["res://resources/tool_axe.tres", 1, true],
		7: ["res://resources/tool_pick.tres", 1, true],
		8: ["res://resources/weapon_sword1.tres", 1, true],
		9: [null, 0, true],
		10: [null, 0, true],
		11: [null, 0, true],
}



func _save_core_inventory(gcSLOTS: Dictionary,glINVENTORY: Dictionary):
	glINVENTORY.clear()
	for i in gcSLOTS:
		glINVENTORY[i] = gcSLOTS[i].duplicate()


func _on_btn_save_inventory_pressed() -> void:
	_save_core_inventory(grid_to_dictionary(inv_grid_slots),INVENTORY)


func grid_to_dictionary(container: GridContainer) -> Dictionary:
	var result: Dictionary = {}
	var ui_slots = container.get_children()

	for i in ui_slots.size():
		var ui_slot: InvSlotUI = ui_slots[i]
		var slot: OptiInventorySlot = ui_slot.slot

		if slot.item == null or slot.quantity <= 0:
			result[i] = [null, 0, slot.enabled]
		else:
			result[i] = [
				slot.item.resource_path,
				slot.quantity,
				slot.enabled
			]

	return result



# BOTTOM
