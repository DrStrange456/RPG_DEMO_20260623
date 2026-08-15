extends Control

@onready var storage_core_data = storage_data_core.new()
@onready var pInv: Dictionary = storage_core_data.DATA
@onready var core_storage_controller: GridContainer = $Panel/CoreStorageController

var inventory : Array[OptiInventorySlot] = []




func _ready() -> void:
	initialize()


func initialize():
	_load_slots_from_save(core_storage_controller)

func _load_slots_from_save(slots: GridContainer):
	inventory.resize(12)
	for i in inventory.size():
		inventory[i] = OptiInventorySlot.new()
	
	bind_inventory(inventory,slots)
	
	for j in inventory.size():
		for i in slots.get_child_count():
			slots._set_slot(i)
		if pInv.size() > 0:
			if pInv[j][0] != null:
				if int(pInv[j][1]) > 0:
					inventory[j].indx = j
					inventory[j].set_item(load(pInv[j][0]))
					inventory[j].set_quantity(pInv[j][1])

func bind_inventory(inv,gc: GridContainer):
	var ui_slots = gc.get_children()
	for i in ui_slots.size():
		ui_slots[i].bind_slot(inv[i])
