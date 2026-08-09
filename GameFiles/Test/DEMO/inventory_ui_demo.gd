extends Control


@onready var main_inventory_container_ui: GridContainer
var inventory : Array[OptiInventorySlot] = []


func _ready() -> void:
	initialize()




func initialize():
	var pInventory = self.get_parent().PLAYER_INVENTORY_TEST_LARGE
	var inv_ui = self.find_child("MainInventoryController",1)
	_load_slots_from_save(inv_ui, pInventory)

func _load_slots_from_save(slots: GridContainer, inv: Dictionary):
	inventory.resize(inv.size())
	for i in inventory.size():
		inventory[i] = OptiInventorySlot.new()
	
	bind_inventory(inventory,slots)
	
	for j in inv:
		for i in slots.get_child_count():
			slots._set_slot(i)
		if inv[j][0] != null:
			if int(inv[j][1]) > 0:
				inventory[j].indx = j
				inventory[j].set_item(load(inv[j][0]))
				inventory[j].set_quantity(inv[j][1])

func bind_inventory(inv,gc: GridContainer):
	var ui_slots = gc.get_children()
	for i in ui_slots.size():
		ui_slots[i].bind_slot(inv[i])
