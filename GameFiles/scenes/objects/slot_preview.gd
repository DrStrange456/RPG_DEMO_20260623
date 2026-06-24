extends Control

@onready var texture_rect: TextureRect = $CenterContainer/TextureRect
@onready var label: Label = $Label


func _set_texture(val):
	texture_rect = $CenterContainer/TextureRect
	texture_rect.texture = val

func _set_quantity(val):
	label = $Label
	label.text = val
