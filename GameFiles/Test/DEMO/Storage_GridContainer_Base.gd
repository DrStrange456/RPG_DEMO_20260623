@icon("res://assets/icons/inv_Icons/InventoryContainer.svg")
class_name gridcontainer_base
extends GridContainer

var holding_item

# ==============================================================================
# PROCESS
# ==============================================================================

func _process(_delta: float) -> void:
	if holding_item != null:
		# Keep the held item positioned underneath the mouse.
		_update_holding_item_position()


func _update_holding_item_position() -> void:
	holding_item.position = get_local_mouse_position() - Vector2(20, 20)


# ==============================================================================
# DEBUGGING
# ==============================================================================

func debug_out(val: Dictionary) -> void:

	print_inventory_debug(
		val
	)


func print_inventory_debug(
	inventory: Dictionary
) -> void:

	print("\n========== INVENTORY ==========")

	for slot_index in inventory:

		var slot_data = inventory[slot_index]

		print(
			"Slot %02d | Item: %-45s | Amount: %3d | Enabled: %s"
			% [
				slot_index,
				str(slot_data[0]),
				slot_data[1],
				slot_data[2]
			]
		)

	print("================================\n")
