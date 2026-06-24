@icon("res://assets/icons/inv_Icons/InventoryContainer.svg")
extends GridContainer

func _set_slot(indx):
	var ic_children = get_children()
	var slot_for_update: InvSlotUI = ic_children[indx]
	if !slot_for_update.is_connected("gui_input", _slot_gui_input.bind(slot_for_update)):
		slot_for_update.connect("gui_input", _slot_gui_input.bind(slot_for_update))

func _slot_gui_input(event: InputEvent, slot: InvSlotUI):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT && event.pressed:
			var context = {
				"source": self,
				"container": get_parent().get_parent().test_container,
				"slot_index": slot.indx
			}
			StorageManager.move_item_to_storage(context)
			AudioController.play_sound("sfx_slot_pick")
		if event.button_index == MOUSE_BUTTON_RIGHT && event.pressed:
			var context = {
				"source": self,
				"container": get_parent().test_container,
				"slot_index": slot.indx
			}
			StorageManager.move_single_item_to_storage(context)
			AudioController.play_sound("sfx_slot_right_click")
