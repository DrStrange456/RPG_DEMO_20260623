@icon("res://assets/icons/inv_Icons/InventorySlot.svg")
class_name InvSlotUI extends Panel

@export var indx: int  # for inventory slots this will be the place in the array
var slot : OptiInventorySlot

@onready var icon = $CenterContainer/TextureRect
@onready var qty_label = $Label


func bind_slot(s: OptiInventorySlot):

	slot = s
	slot.changed.connect(update_ui)

	update_ui()

func update_ui():
	icon = $CenterContainer/TextureRect
	qty_label = $Label
	
	if slot.item == null:
		icon.texture = null
		qty_label.text = ""
	else:
		icon.texture = slot.item.icon
		qty_label.text = str(slot.quantity)
