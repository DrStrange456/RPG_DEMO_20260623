class_name item_ui
extends Node2D

@onready var img: TextureRect = $CenterContainer/TextureRect
@onready var qty: Label = $Label
@onready var progress_bar: ProgressBar = $ProgressBar


func _physics_process(_delta: float) -> void:
	_update_ui()

func _update_ui():
	if int(qty.text) <= 1:
		qty.visible = false
	else:
		qty.visible = true

func _set_texture(val: Texture2D):
	if val == null:
		$CenterContainer/TextureRect.texture = null
		$Label.visible = false
		$ProgressBar.visible = false
		return
	$CenterContainer/TextureRect.texture = val

func _set_quantity(val: int):
	if val == null: return
	$Label.text = str(val)
	$Label.visible = (val > 0)
