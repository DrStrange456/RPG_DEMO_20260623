extends Control

# InventoryCore_Demo.gd
# inventory links verified


var new_slot = preload("res://Inventory/inventory_slot_ui.tscn")

@onready var core_inventory_controller: GridContainer = $Panel/CoreInventoryController_Strg
@onready var pInv: Dictionary = InvCore.DATA

var inventory : Array[OptiInventorySlot] = []
var holding_item



func _ready() -> void:
	initialize()
	#_extend_inventory()




func initialize():
	_load_slots_from_save(core_inventory_controller)

func _load_slots_from_save(slots: GridContainer):
	inventory.resize(12)
	for i in inventory.size():
		inventory[i] = OptiInventorySlot.new()
	
	bind_inventory(inventory,slots)
	
	for j in pInv:
		for i in slots.get_child_count():
			slots._set_slot(i)
		if pInv[j][0] != null:
			if int(pInv[j][1]) > 0:
				inventory[j].indx = j
				inventory[j].set_item(load(pInv[j][0]))
				inventory[j].set_quantity(pInv[j][1])

func bind_inventory(inv,gc: GridContainer):
	var ui_slots = gc.get_children()
	for i in ui_slots.size():
		ui_slots[i].bind_slot(inv[i])










func _save_inventory():
	#InvCore._save_core_inventory(InvCore.INVENTORY)
	print("To be replaced with save to JSON")

func _extend_inventory():
	set_inventory_size_data(20)
	set_inventory_size_ui(20)

func _reset_inventory():
	_reset_dictionary_core_data()
	_reset_inventory_ui(12)





## Extend Inventory
func set_inventory_size_data(amount: int) -> void:
	#var current_size := INVENTORY.size()
	var current_size := pInv.size()

	for i in range(current_size, amount):
		#INVENTORY[i] = [null, 0, true]
		pInv[i] = [null, 0, true]

func set_inventory_size_ui(amount: int) -> void:
	var current_size := core_inventory_controller.get_child_count()

	for i in range(current_size, amount):
		var new_slot_instance = new_slot.instantiate()
		new_slot_instance.indx = i
		new_slot_instance.custom_minimum_size = Vector2(40, 40)
		new_slot_instance._reset_slot()
		new_slot_instance.slot = OptiInventorySlot.new()
		
		core_inventory_controller.add_child(new_slot_instance)

	initialize()


## Reset Inventory
func _reset_dictionary_core_data():
	const INVENTORY_ORIGINAL: Dictionary = {
		0: ["res://resources/seeds_turnip.tres", 98, true],
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
	initialize()


## Save Inventory
func _save_core_inventory(gcSLOTS: Dictionary,glINVENTORY: Dictionary):
	glINVENTORY.clear()
	for i in gcSLOTS:
		glINVENTORY[i] = gcSLOTS[i].duplicate()


## Sort and Combine
func sort_and_combine_inventory_Inv():
	var item_totals := {}

	# --- Collect totals ---
	for slot_index in pInv.keys():

		var slot = pInv[slot_index]
		var path = slot[0]
		var qty = slot[1]

		if path == null:
			continue

		var item
		if path is String:
			item = load(path)
		else:
			item = load(path.resource_path)

		if item_totals.has(item):
			item_totals[item] += int(qty)
		else:
			item_totals[item] = int(qty)

	# --- Clear all slots ---
	for slot_index in pInv.keys():
		pInv[slot_index] = [null, 0, true]

	# --- Rebuild stacks ---
	var slot_keys = pInv.keys()
	slot_keys.sort()

	var slot_pointer := 0

	for item in item_totals.keys():

		var remaining: int = item_totals[item]

		while remaining > 0 and slot_pointer < slot_keys.size():

			var stack_size: int = min(item.max_stack, remaining)
			var slot_index = slot_keys[slot_pointer]

			pInv[slot_index] = [
				item.resource_path,
				stack_size,
				true
			]

			remaining -= stack_size
			slot_pointer += 1
	
	initialize()





# BOTTOM


func _on_btn_sort_inventory_pressed() -> void:
	sort_and_combine_inventory_Inv()


func _on_btn_extend_inventory_pressed() -> void:
	_extend_inventory()
