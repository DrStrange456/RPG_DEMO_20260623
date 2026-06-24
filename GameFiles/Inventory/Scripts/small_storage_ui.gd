extends popup_ui

@onready var inventory_container_ui: GridContainer = $PopupRoot/InventorySlotContainer
@onready var small_container: TestContainer = $PopupRoot/SmallContainer
@onready var test_container: TestContainer = $PopupRoot/SmallContainer
#@onready var large_container: TestContainerLarge = $LargeContainer


var inventory : Array[OptiInventorySlot] = []




func initialize():
	_load_slots_from_save()

func bind_inventory(inv):
	var ui_slots = $PopupRoot/InventorySlotContainer.get_children()
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
