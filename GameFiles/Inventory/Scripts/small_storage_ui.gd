extends popup_ui

@onready var inventory_container_ui: GridContainer = $PopupRoot/InventorySlotContainer
@onready var small_container: TestContainer = $PopupRoot/SmallContainer
@onready var test_container: TestContainer = $PopupRoot/SmallContainer


var inventory : Array[OptiInventorySlot] = []

@onready var slot_contents: Dictionary = {
		0: ["res://resources/seeds_carrot.tres", 51, true],
		1: ["res://resources/seeds_tomato.tres", 52, true],
		2: ["res://resources/seeds_strawberry.tres", 53, true],
		3: ["res://resources/seeds_turnip.tres", 54, true],
		4: [null, 0, true],
		5: [null, 0, true],
}


func _load_strg_slots_from_save():
	# load data and ui
	for j in slot_contents:
		# - DATA
		if slot_contents[j][0] != null:
			if int(slot_contents[j][1]) > 0:
				inventory[j].indx = j
				inventory[j].set_item(load(slot_contents[j][0]))
				inventory[j].set_quantity(slot_contents[j][1])
		# - UI
		var ui = $PopupRoot/InventorySlotContainer
		ui._set_slot(j)
	
	#var ui_slots = small_container.get_children()
	##var inv_cont = $PopupRoot/InventorySlotContainer
	#for k in ui_slots.size():
		#ui_slots._set_slot(k)
		#ui_slots[k].set_item(load(slot_contents[k][0]) if slot_contents[k][0] else null)
		#ui_slots[k].set_quantity(slot_contents[k][1])
	#bind_storage(ui_slots)


func initialize():
	#_load_slots_from_save()
	#_load_strg_slots_from_save()
	small_container.load_storage_from_dictionary(slot_contents)

func bind_inventory(inv):
	var ui_slots = $PopupRoot/InventorySlotContainer.get_children()
	for i in ui_slots.size():
		ui_slots[i].bind_slot(inv[i])

func bind_storage(inv):
	var ui_slots = small_container.get_children()
	for i in ui_slots.size():
		ui_slots[i].bind_slot(inv[i])

func _reset_inventory():
	_load_slots_from_save()

func _load_slots_from_save():
	# build out inventory data structure
	inventory.resize(GameManager.PLAYER_INVENTORY_TEST.size())
	for i in inventory.size():
		inventory[i] = OptiInventorySlot.new()
	
	# bind the data structure to the ui
	bind_inventory(inventory)
	
	# load data and ui
	for j in GameManager.PLAYER_INVENTORY_TEST:
		# - DATA
		if GameManager.PLAYER_INVENTORY_TEST[j][0] != null:
			if int(GameManager.PLAYER_INVENTORY_TEST[j][1]) > 0:
				inventory[j].indx = j
				inventory[j].set_item(load(GameManager.PLAYER_INVENTORY_TEST[j][0]))
				inventory[j].set_quantity(GameManager.PLAYER_INVENTORY_TEST[j][1])
		# - UI
		var ui = $PopupRoot/InventorySlotContainer
		ui._set_slot(j)

func _refresh_inventory_items():
	_load_slots_from_save()



func _input(_event: InputEvent) -> void:
	if visible:
		if Input.is_action_pressed("ui_cancel"):
			self.visible = false
			UiManager.active_ui = null
			UiManager.open_small_chest()
			get_viewport().set_input_as_handled()  # Mark event as handled



func _on_btn_sort_chest_pressed() -> void:
	StorageManager.sort_and_combine_inventory_Strg(test_container)

func _on_btn_sort_inv_pressed() -> void:
	StorageManager.sort_and_combine_inventory_Inv(GameManager.PLAYER_INVENTORY_TEST)
	_refresh_inventory_items()



func _on_btn_transfer_all_pressed() -> void:
	StorageManager.move_all_to_inventory(
		test_container.get_children(),
		GameManager.PLAYER_INVENTORY_TEST)
	_refresh_inventory_items()

func _on_btn_transfer_like_pressed() -> void:
	StorageManager.collect_similar_from_chest(
		test_container.get_children(),
		GameManager.PLAYER_INVENTORY_TEST)
	_refresh_inventory_items()

func _on_btn_transfer_like_to_strg_pressed() -> void:
	StorageManager.collect_similar_to_chest(
		test_container.get_children(),
		GameManager.PLAYER_INVENTORY_TEST)
	_refresh_inventory_items()

func _on_btn_transfer_all_to_strg_pressed() -> void:
	StorageManager.move_all_to_container(
		GameManager.PLAYER_INVENTORY_TEST,
		test_container.get_children())
	_refresh_inventory_items()



### - Context Menu Options
func _on_btn_move_pressed() -> void:
	StorageManager._handle_move_action()




# Bottom
