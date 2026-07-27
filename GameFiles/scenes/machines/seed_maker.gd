extends StaticBody2D

@export var ui_scene: PackedScene

var ui_instance

func interact():
	if ui_instance == null:
		ui_instance = ui_scene.instantiate()
		get_tree().current_scene.add_child(ui_instance)

	ui_instance.open(self)
