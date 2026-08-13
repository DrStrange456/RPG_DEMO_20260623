extends Node2D

# Demo_Inventory.gd


@onready var inv_grid_slots: GridContainer = $InventoryUI_Demo/Panel2/MainInventoryController
@onready var inventory_core_demo: Control = $InventoryCore_Demo
@onready var core_inventory_controller: GridContainer = $InventoryCore_Demo/Panel/CoreInventoryController

var new_slot = preload("res://Inventory/inventory_slot_ui.tscn")

# PLACEHOLDER FOR SAVED INVENTORY
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
	InvCore._save_core_inventory(INVENTORY)


func _on_btn_extend_inventory_pressed() -> void:
	set_inventory_size_data(20)
	set_inventory_size_ui(20)


func _on_btn_reset_pressed() -> void:
	_reset_dictionary()
	_reset_inventory_size(12)
	_reset_inventory_ui(12)



func _reset_dictionary():
	var INVENTORY_ORIGINAL: Dictionary = {
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
	
	INVENTORY.clear()
	for i in INVENTORY_ORIGINAL:
		INVENTORY[i] = INVENTORY_ORIGINAL[i].duplicate()

func _reset_inventory_size(amount: int) -> void:
	for i in range(INVENTORY.size() - 1, amount - 1, -1):
		INVENTORY.erase(i)
	for i in range(InvCore.INVENTORY.size() - 1, amount - 1, -1):
		InvCore.INVENTORY.erase(i)

func _reset_inventory_ui(amount: int) -> void:
	var current_size := core_inventory_controller.get_child_count()

	# Reset existing slots
	for child in core_inventory_controller.get_children():
		if child.has_method("_reset_slot"):
			child._reset_slot()
			child.slot = OptiInventorySlot.new()

	# Add any slots that don't currently exist
	for i in range(current_size, amount):
		var new_slot_instance = new_slot.instantiate()
		new_slot_instance.indx = i
		new_slot_instance.custom_minimum_size = Vector2(40, 40)
		new_slot_instance._reset_slot()
		new_slot_instance.slot = OptiInventorySlot.new()

		core_inventory_controller.add_child(new_slot_instance)

	inventory_core_demo.initialize()



#func set_inventory_size_data(amount: int) -> void:
	#var current_size := INVENTORY.size()
	#var pINV_size := InvCore.INVENTORY.size()
	#for i in amount:
		#var new_index := current_size + i
		#INVENTORY[new_index] = [null, 0, true]
		#InvCore.INVENTORY[new_index] = [null, 0, true]

func set_inventory_size_data(amount: int) -> void:
	var current_size := INVENTORY.size()

	for i in range(current_size, amount):
		INVENTORY[i] = [null, 0, true]
		InvCore.INVENTORY[i] = [null, 0, true]

#func set_inventory_size_ui(amount: int) -> void:
	#for i in amount:
		#var new_slot = new_slot.instantiate()
		#new_slot.indx = 12 + i
		#new_slot.custom_minimum_size = Vector2(40, 40)
		#new_slot._reset_slot()
		#new_slot.slot = OptiInventorySlot.new()
		#core_inventory_controller.add_child(new_slot)
	#inventory_core_demo.initialize()

func set_inventory_size_ui(amount: int) -> void:
	var current_size := core_inventory_controller.get_child_count()

	for i in range(current_size, amount):
		var new_slot_instance = new_slot.instantiate()
		new_slot_instance.indx = i
		new_slot_instance.custom_minimum_size = Vector2(40, 40)
		new_slot_instance._reset_slot()
		new_slot_instance.slot = OptiInventorySlot.new()
		
		core_inventory_controller.add_child(new_slot_instance)

	inventory_core_demo.initialize()

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

#func bind_inventory(inv,gc: GridContainer):
	#var ui_slots = gc.get_children()
	#for i in ui_slots.size():
		#ui_slots[i].bind_slot(inv[i])


# BOTTOM
