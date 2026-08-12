extends Node2D

# Demo_Inventory.gd


@onready var inv_grid_slots: GridContainer = $InventoryUI_Demo/Panel2/MainInventoryController
@onready var inventory_core_demo: Control = $InventoryCore_Demo
@onready var core_inventory_controller: GridContainer = $InventoryCore_Demo/Panel/CoreInventoryController

var new_slot = preload("res://Inventory/inventory_slot_ui.tscn")

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



func _on_btn_save_inventory_pressed() -> void:
	InvCore._save_core_inventory(grid_to_dictionary(core_inventory_controller),INVENTORY)
	#_save_core_inventory(grid_to_dictionary(inv_grid_slots),INVENTORY)


func _on_btn_extend_inventory_pressed() -> void:
	expand_data(8)
	expand_inventory_ui(8)


func _on_btn_reset_pressed() -> void:
	pass # Replace with function body.







func expand_data(amount: int) -> void:
	var current_size := INVENTORY.size()

	for i in amount:
		var new_index := current_size + i
		INVENTORY[new_index] = [null, 0, true]


func expand_inventory_ui(amount: int) -> void:
	for i in amount:
		var new_slot = new_slot.instantiate()
		new_slot.custom_minimum_size = Vector2(40, 40)
		# FIXME: remove default texture
		core_inventory_controller.add_child(new_slot)





## SECOND TRY




## FIRST TRY
func _save_core_inventory(gcSLOTS: Dictionary,glINVENTORY: Dictionary):
	glINVENTORY.clear()
	for i in gcSLOTS:
		glINVENTORY[i] = gcSLOTS[i].duplicate()

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
