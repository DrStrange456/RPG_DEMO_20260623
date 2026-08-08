extends popup_ui


@onready var inventory_container_ui: GridContainer = $PopupRoot/InventorySlotContainer
@onready var large_container: TestContainerLarge = $PopupRoot/LargeContainer
@onready var test_container: TestContainerLarge = $PopupRoot/LargeContainer

var inventory : Array[OptiInventorySlot] = []


var slot_contents: Dictionary = {
		0: ["res://resources/crop_carrot.tres", 90, true],
		1: ["res://resources/crop_tomato.tres", 90, true],
		2: ["res://resources/crop_strawberry.tres", 90, true],
		3: ["res://resources/crop_turnip.tres", 90, true],
		4: [null, 0, true],
		5: [null, 0, true],
		6: [null, 0, true],
		7: [null, 0, true],
		8: [null, 0, true],
		9: [null, 0, true],
		10: [null, 0, true],
		11: [null, 0, true],
		12: [null, 0, true],
		13: [null, 0, true],
		14: [null, 0, true],
		15: [null, 0, true],
		16: [null, 0, true],
		17: [null, 0, true],
		18: [null, 0, true],
		19: [null, 0, true],
		20: [null, 0, true],
		21: [null, 0, true],
		22: [null, 0, true],
		23: [null, 0, true],
		24: [null, 0, true],
}




func initialize():
	#_load_slots_from_save()
	large_container.load_storage_from_dictionary(slot_contents)



func bind_inventory(inv):
	var ui_slots = $PopupRoot/InventorySlotContainer.get_children()
	for i in ui_slots.size():
		ui_slots[i].bind_slot(inv[i])

func _reset_inventory():
	_load_slots_from_save()

func _load_slots_from_save():
	# build out inventory data structure
	inventory.resize(GmMgr.PLAYER_INVENTORY_TEST_LARGE.size())
	for i in inventory.size():
		inventory[i] = OptiInventorySlot.new()
	
	# bind the data structure to the ui
	bind_inventory(inventory)
	
	# load data and ui
	for j in GmMgr.PLAYER_INVENTORY_TEST_LARGE:
		# - DATA
		if GmMgr.PLAYER_INVENTORY_TEST_LARGE[j][0] != null:
			if int(GmMgr.PLAYER_INVENTORY_TEST_LARGE[j][1]) > 0:
				inventory[j].indx = j
				inventory[j].set_item(load(GmMgr.PLAYER_INVENTORY_TEST_LARGE[j][0]))
				inventory[j].set_quantity(GmMgr.PLAYER_INVENTORY_TEST_LARGE[j][1])
		# - UI
		var ui = $PopupRoot/InventorySlotContainer
		ui._set_slot(j)

func _refresh_inventory_items():
	_load_slots_from_save()

#func _input(_event: InputEvent) -> void:
	#if visible:
		#if Input.is_action_pressed("ui_cancel"):
			#self.visible = false
			#UiManager.active_ui = null
			#UiManager.open_large_chest()
			#get_viewport().set_input_as_handled()  # Mark event as handled

func open_ui():
	_load_slots_from_save()


func _on_btn_sort_chest_pressed() -> void:
	StorageManager.sort_and_combine_inventory_Strg(test_container)

func _on_btn_sort_inv_pressed() -> void:
	StorageManager.sort_and_combine_inventory_Inv(GmMgr.PLAYER_INVENTORY_TEST_LARGE)
	_refresh_inventory_items()



func _on_btn_transfer_all_pressed() -> void:
	StorageManager.move_all_to_inventory(
		test_container.get_children(),
		GmMgr.PLAYER_INVENTORY_TEST_LARGE)
	_refresh_inventory_items()

func _on_btn_transfer_like_pressed() -> void:
	StorageManager.collect_similar_from_chest(
		test_container.get_children(),
		GmMgr.PLAYER_INVENTORY_TEST_LARGE)
	_refresh_inventory_items()

func _on_btn_transfer_like_to_strg_pressed() -> void:
	StorageManager.collect_similar_to_chest(
		test_container.get_children(),
		GmMgr.PLAYER_INVENTORY_TEST_LARGE)
	_refresh_inventory_items()

func _on_btn_transfer_all_to_strg_pressed() -> void:
	StorageManager.move_all_to_container(
		GmMgr.PLAYER_INVENTORY_TEST_LARGE,
		test_container.get_children())
	# FIXME: Not saving resulting inventory
	#GmMgr._save_inventory(GmMgr.PLAYER_INVENTORY_TEST_LARGE)
	_refresh_inventory_items()



#
#func _on_btn_sort_chest_pressed() -> void:
	#StorageManager.sort_and_combine_inventory_Strg(test_container)
#
#func _on_btn_sort_inv_pressed() -> void:
	#StorageManager.sort_and_combine_inventory_Inv(GmMgr.PLAYER_INVENTORY_TEST_LARGE)
	#_refresh_inventory_items()
#
#func _on_btn_transfer_all_pressed() -> void:
	#StorageManager.move_all_to_inventory(test_container.get_children(),GmMgr.PLAYER_INVENTORY_TEST_LARGE)
	#_refresh_inventory_items()
#
#func _on_btn_transfer_like_pressed() -> void:
	#StorageManager.collect_similar_from_chest(test_container.get_children(),GmMgr.PLAYER_INVENTORY_TEST_LARGE)
	#_refresh_inventory_items()
#

#func _save_slots_to_dictionary():
	#for i in inventory.size():
		#var slot = inventory[i]
#
		#if slot.item == null or slot.quantity <= 0:
			#GmMgr.PLAYER_INVENTORY_TEST[i] = [null, 0, true]
		#else:
			#GmMgr.PLAYER_INVENTORY_TEST[i] = [
				#slot.item.resource_path,
				#slot.quantity,
				#slot.enabled
			#]
#
#func _save_slots_to_dictionary_lrg():
	#for i in inventory.size():
		#var slot = inventory[i]
#
		#if slot.item == null or slot.quantity <= 0:
			#GmMgr.PLAYER_INVENTORY_TEST_LARGE[i] = [null, 0, true]
		#else:
			#GmMgr.PLAYER_INVENTORY_TEST_LARGE[i] = [
				#slot.item.resource_path,
				#slot.quantity,
				#slot.enabled
			#]

### - Context Menu Options
func _on_btn_move_pressed() -> void:
	StorageManager._handle_move_action()




# Bottom
