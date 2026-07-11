extends Node2D

@onready var female_farmer_1: CharacterBody2D = $World/Objects/female_farmer1
@onready var tool_selector: Control = $UI/HUD/tool_selector
@onready var button_group := ButtonGroup.new()
@onready var hud: Node2D = $UI/HUD




func _ready():
	hud.visible = true
	for button in tool_selector.get_children():
		if button is Button:
			button.toggle_mode = true
			button.button_group = button_group

	# Select the first button if desired
	button_group.get_buttons()[1].button_pressed = true

func _get_selected_button() -> BaseButton:
	return button_group.get_pressed_button()


func _on_btn_weapon_pressed() -> void:
	female_farmer_1._attempt_sword()
	#btn_weapon.release_focus()

func _on_btn_tool_pressed() -> void:
	female_farmer_1._attempt_hoe()
	#btn_tool.release_focus()

func _on_btn_item_pressed() -> void:
	female_farmer_1._attempt_seed()
	#btn_item.release_focus()





func _on_chest_small_activate_clicked() -> void:
	GameManager._on_pause_opened()

func _on_chest_large_activate_clicked() -> void:
	pass # Replace with function body.

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		get_tree().change_scene_to_packed(GameManager.house_scene)






# Bottom
