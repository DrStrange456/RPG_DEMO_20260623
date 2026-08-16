@icon("res://assets/icons/inv_Icons/InventoryContainer.svg")
class_name gridcontainer_base
extends GridContainer


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
