extends Control

# InventoryCore_Demo.gd


@onready var core_inventory_controller: GridContainer = $Panel/CoreInventoryController
var inventory : Array[OptiInventorySlot] = []

var pInv: Dictionary = InvCore.INVENTORY
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
	for i in ui_slots.size():
		ui_slots[i].bind_slot(inv[i])






# BOTTOM
