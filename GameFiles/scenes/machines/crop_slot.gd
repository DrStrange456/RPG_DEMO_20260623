class_name CropSlot
extends Button

signal selected(slot)

@onready var icon_rect: TextureRect = $Panel/TextureRect
@onready var count_label: Label = $Panel/Label

var crop_resource
var crop_count: int = 0
var inventory_slot_num


func setup(crop, amount, indx):
	icon_rect = $Panel/TextureRect
	count_label = $Panel/Label
	
	crop_resource = crop
	crop_count = int(amount)
	inventory_slot_num = indx
	
	icon_rect.texture = crop.icon
	count_label.text = str(amount)


func _pressed():

	selected.emit(self)


func set_selected(value: bool):

	if value:
		modulate = Color(1, 1, 0.6)
	else:
		modulate = Color.WHITE


# Bottom
