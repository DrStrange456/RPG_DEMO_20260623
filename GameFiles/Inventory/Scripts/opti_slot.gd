@icon("res://assets/icons/inv_Icons/InventorySlot.svg")
class_name OptiInventorySlot
extends RefCounted

signal changed

@export var indx: int  # for inventory slots this will be the place in the array

var item: Resource = null
var quantity: int = 0
var enabled: bool = true

func set_item(new_item):
	item = new_item
	changed.emit()

func set_quantity(q):
	quantity = int(q)
	changed.emit()

func clear():
	item = null
	quantity = 0
	changed.emit()
