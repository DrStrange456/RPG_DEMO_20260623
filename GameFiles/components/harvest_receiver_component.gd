extends Node

@export var popup_scene: PackedScene

var inventory_component

func _ready():
	pass


func receive_crop(crop):
	# Store data before crop is removed
	var tmp = crop.res.name
	var tmp_name = tmp.to_lower()
	var crop_texture_icon = crop
	var crop_texture = crop_texture_icon.res.icon_texture

	# Remove crop from world
	crop.queue_free()

	# Show popup
	await show_crop_popup(crop_texture)

	# Add to inventory AFTER animation
	#var tmp = crop.res
	#StorageManager.get_resource_by_name(crop)
	StorageManager.try_add_item_to_inventory(GameManager.PLAYER_INVENTORY_TEST,tmp_name,1)
	#inventory_component.add_item(crop_item_data, 1)
	#print("debug")

func show_crop_popup(texture: Texture2D) -> void:
	var popup = popup_scene.instantiate()
	GameManager.glPlayerRef.add_child(popup)
	popup.global_position = GameManager.glPlayerRef.global_position + Vector2(0, -32)
	popup.setup(texture)
	await popup.play_popup()
