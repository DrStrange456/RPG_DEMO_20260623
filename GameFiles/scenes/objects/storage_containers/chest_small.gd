extends StaticBody2D


@export var id: int
@onready var interact_icon: Sprite2D = $imgIcon
var player_within_range: bool = false
var plyr

func _ready():
	interact_icon.visible = false

func _input(_event: InputEvent) -> void:
	if plyr and player_within_range:
		if Input.is_action_just_pressed("activate"):
			UiManager.active_ui = self
			Events.emit_signal("try_interact_sm_chest")
			get_viewport().set_input_as_handled()  # Mark event as handled

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		interact_icon.visible = true
		player_within_range = true
		plyr = body

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		interact_icon.visible = false
		player_within_range = false
		plyr = body
