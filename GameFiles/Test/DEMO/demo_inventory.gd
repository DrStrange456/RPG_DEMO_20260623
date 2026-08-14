extends Node2D

# Demo_Inventory.gd

@onready var inventory_core_demo: Control = $INV/InventoryCore_Demo
@onready var inv: Node2D = $INV
@onready var inv_and_strg: Node2D = $INV_AND_STRG




func _on_btn_save_inventory_pressed() -> void:
	inventory_core_demo._save_inventory()

func _on_btn_extend_inventory_pressed() -> void:
	inventory_core_demo._extend_inventory()

func _on_btn_reset_pressed() -> void:
	inventory_core_demo._reset_inventory()

func _on_btn_sort_and_combine_pressed() -> void:
	inventory_core_demo.sort_and_combine_inventory_Inv()

func _on_btn_inventory_only_pressed() -> void:
	$INV.visible = true
	$INV_AND_STRG.visible = false

func _on_btn_inventory_and_storage_pressed() -> void:
	$INV.visible = false
	$INV_AND_STRG.visible = true




# BOTTOM
