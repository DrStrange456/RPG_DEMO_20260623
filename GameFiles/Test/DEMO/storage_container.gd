extends Control

# InventoryCore_Demo.gd
# inventory links verified

# DATA: This script loads the data into the UI
# Also sets up GUI Input captures

var new_slot = preload("res://Inventory/inventory_slot_ui.tscn")

@onready var core_inventory_controller: GridContainer = $Panel/CoreInventoryController
var inventory : Array[OptiInventorySlot] = []

var pInv: Dictionary = {
	0: [null, 0, true],
	1: [null, 0, true],
	2: [null, 0, true],
	3: [null, 0, true],
	4: [null, 0, true],
	5: [null, 0, true],
	6: [null, 0, true],
	7: [null, 0, true],
	8: [null, 0, true],
	9: [null, 0, true],
	10: [null, 0, true],
	11: [null, 0, true],
}
var holding_item



func _ready() -> void:
	initialize()




func initialize():
	_load_slots_from_save(core_inventory_controller)

func _load_slots_from_save(slots: GridContainer):
	inventory.resize(pInv.size())
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
	if inv.size() > 0:
		for i in ui_slots.size():
			ui_slots[i].bind_slot(inv[i])



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
