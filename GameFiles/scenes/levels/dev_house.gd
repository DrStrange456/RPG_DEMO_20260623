extends Node2D


@onready var storage_objects: Node2D = $UI/Storage_Bin
var dev_chest_lrg

func _ready() -> void:
	#setup large chest UI
	dev_chest_lrg = GameManager.glChest_lrg.instantiate()
	storage_objects.add_child(dev_chest_lrg)
	dev_chest_lrg.visible = false

func _on_chest_large_activate_clicked() -> void:
	GameManager._on_pause_opened()
	dev_chest_lrg.visible = true
	dev_chest_lrg._reset_inventory()

func _on_transition_point_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		get_tree().change_scene_to_packed(GameManager.world_scene)



# Bottom
