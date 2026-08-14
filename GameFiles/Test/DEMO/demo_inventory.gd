extends Node2D

# Demo_Inventory.gd

@onready var inventory_core_demo: Control = $InventoryCore_Demo


func _on_btn_save_inventory_pressed() -> void:
	inventory_core_demo._save_inventory()

func _on_btn_extend_inventory_pressed() -> void:
	inventory_core_demo._extend_inventory()

func _on_btn_reset_pressed() -> void:
	inventory_core_demo._reset_inventory()




# BOTTOM
