extends Node2D

# Demo_Inventory.gd


@onready var inventory_core_demo: Control = $InventoryCore_Demo
@onready var core_inventory_controller: GridContainer = $InventoryCore_Demo/Panel/CoreInventoryController

var new_slot = preload("res://Inventory/inventory_slot_ui.tscn")

# PLACEHOLDER FOR SAVED INVENTORY
#var INVENTORY: Dictionary = {
#		0: ["res://resources/seeds_turnip.tres", 98, true],
#		1: ["res://resources/seeds_strawberry.tres", 99, true],
#		2: ["res://resources/weapon_sword_fire.tres", 1, true],
#		3: [null, 0, true],
#		4: ["res://resources/seeds_tomato.tres", 65, true],
#		5: ["res://resources/seeds_carrot.tres", 10, true],
#		6: ["res://resources/tool_axe.tres", 1, true],
#		7: ["res://resources/tool_pick.tres", 1, true],
#		8: ["res://resources/weapon_sword1.tres", 1, true],
#		9: [null, 0, true],
#		10: [null, 0, true],
#		11: [null, 0, true],
#}



func _on_btn_save_inventory_pressed() -> void:
	_save_inventory()

func _on_btn_extend_inventory_pressed() -> void:
	_extend_inventory()

func _on_btn_reset_pressed() -> void:
	_reset_inventory()



func _save_inventory():
	InvCore._save_core_inventory(InvCore.INVENTORY)

func _extend_inventory():
	set_inventory_size_data(20)
	set_inventory_size_ui(20)

func _reset_inventory():
	_reset_dictionary_core_data()
	_reset_inventory_ui(12)



## Extend Inventory
func set_inventory_size_data(amount: int) -> void:
	#var current_size := INVENTORY.size()
    var current_size := InvCore.INVENTORY.size()

	for i in range(current_size, amount):
		#INVENTORY[i] = [null, 0, true]
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


## Reset Inventory
func _reset_dictionary_core_data():
	const INVENTORY_ORIGINAL: Dictionary = {
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
	
	var pINV = InvCore.INVENTORY
	# * Local
	#INVENTORY.clear()
	#for i in INVENTORY_ORIGINAL:
	#	INVENTORY[i] = INVENTORY_ORIGINAL[i].duplicate()
	# * Global
	pINV.clear()
	for i in INVENTORY_ORIGINAL:
		pINV[i] = INVENTORY_ORIGINAL[i].duplicate()
	
	# * UI
	for i in range(INVENTORY_ORIGINAL.size()):
		core_inventory_controller.get_child(i).update_ui()

func _reset_inventory_size(amount: int) -> void:
	# Data
	#for i in range(INVENTORY.size() - 1, amount - 1, -1):
	#	INVENTORY.erase(i)
	for i in range(InvCore.INVENTORY.size() - 1, amount - 1, -1):
		InvCore.INVENTORY.erase(i)
	# UI
	for i in range(core_inventory_controller.get_child_count() - 1, amount - 1, -1):
		core_inventory_controller.get_child(i).free()

func _reset_inventory_ui(amount: int) -> void:
	# Remove slots above the desired size
	for i in range(core_inventory_controller.get_child_count() - 1, amount - 1, -1):
		core_inventory_controller.get_child(i).free()

	# Reset existing slots
	var current_size := core_inventory_controller.get_child_count()

	for i in range(current_size):
		var ui_slot = core_inventory_controller.get_child(i)
		ui_slot.indx = i
		ui_slot._reset_slot()
		ui_slot.slot = OptiInventorySlot.new()

	# Add missing slots
	for i in range(current_size, amount):
		var new_slot_instance = new_slot.instantiate()
		new_slot_instance.indx = i
		new_slot_instance.custom_minimum_size = Vector2(40, 40)
		new_slot_instance._reset_slot()
		new_slot_instance.slot = OptiInventorySlot.new()

		core_inventory_controller.add_child(new_slot_instance)

	# Rebuild/refresh the inventory UI
	inventory_core_demo.initialize()


## Save Inventory
func _save_core_inventory(gcSLOTS: Dictionary,glINVENTORY: Dictionary):
	glINVENTORY.clear()
	for i in gcSLOTS:
		glINVENTORY[i] = gcSLOTS[i].duplicate()




# BOTTOM
