extends popup_ui


@onready var main_inventory_container_ui: GridContainer
var inventory : Array[OptiInventorySlot] = []




func initialize():
	main_inventory_container_ui = find_anywhere("MainInventoryController")
	Events.connect("refresh_market_inv_ui", Callable(_refresh_inventory_items_signal))
	_load_slots_from_save(main_inventory_container_ui)


func bind_inventory(inv,gc: GridContainer):
	#var ui_slots = main_inventory_container_ui.get_children()
	var ui_slots = gc.get_children()
	for i in ui_slots.size():
		ui_slots[i].bind_slot(inv[i])

func _load_slots_from_save(grid_container: GridContainer):
	inventory.resize(GameManager.PLAYER_INVENTORY_TEST.size())
	for i in inventory.size():
		inventory[i] = OptiInventorySlot.new()
	
	bind_inventory(inventory,grid_container)
	
	for j in GameManager.PLAYER_INVENTORY_TEST:
		for i in grid_container.get_child_count():
			grid_container._set_slot(i)
		if GameManager.PLAYER_INVENTORY_TEST[j][0] != null:
			if int(GameManager.PLAYER_INVENTORY_TEST[j][1]) > 0:
				inventory[j].indx = j
				inventory[j].set_item(load(GameManager.PLAYER_INVENTORY_TEST[j][0]))
				inventory[j].set_quantity(GameManager.PLAYER_INVENTORY_TEST[j][1])

func _refresh_inventory_items(grid_container: GridContainer):
	_load_slots_from_save(grid_container)

func _refresh_inventory_items_signal():
	_load_slots_from_save(main_inventory_container_ui)




func _on_btn_sort_inv_pressed() -> void:
	StorageManager.sort_and_combine_inventory_Inv(GameManager.PLAYER_INVENTORY_TEST)
	AudioController.play_sound("sfx_slots_reorder")
	_refresh_inventory_items(main_inventory_container_ui)




func find_anywhere(name1: String) -> Node:
	var tree := get_tree()
	
	# 1. Try to get autoloads
	var autoloads = ProjectSettings.get_setting("application/config/autoloads")
	if autoloads != null:
		for autoload_name in autoloads.keys():
			var singleton = tree.get_first_node_in_group(autoload_name)
			if singleton:
				if singleton.name == name1:
					return singleton
				var found = singleton.find_child(name1, true)
				if found:
					return found

	# 2. Try current scene
	if tree:
		if tree.current_scene:
			var found = tree.current_scene.find_child(name1, true)
			if found:
				return found

	# 3. Try the root (includes autoloads + main viewport)
	return tree.root.find_child(name1, true, false)


# Bottom
