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







@onready var control: Control = $UI/HUD/debug_selector/toggle_buttons/Control
@onready var toggle_buttons: Button = $UI/HUD/debug_selector/toggle_buttons



func _on_toggle_buttons_pressed() -> void:
	var tmp_chk = control.visible
	if tmp_chk:
		control.visible = false
		toggle_buttons.text = ">"
	else:
		control.visible = true
		toggle_buttons.text = "<"


func _on_btn_crops_pressed() -> void:
	debug_hoe_land()
	debug_plant_crops()




func debug_hoe_land():
	var spawn_point_pairs = []
	spawn_point_pairs.append([Vector2(32,2),Vector2(523.9481, 43.94793)])
	spawn_point_pairs.append([Vector2(31,2),Vector2(496.3224, 36.32233)])
	spawn_point_pairs.append([Vector2(30,2),Vector2(483.8224, 36.32233)])
	spawn_point_pairs.append([Vector2(29,2),Vector2(466.3224, 36.32233)])
	spawn_point_pairs.append([Vector2(28,2),Vector2(451.3224, 36.32233)])
	spawn_point_pairs.append([Vector2(27,2),Vector2(433.8224, 36.32233)])
	spawn_point_pairs.append([Vector2(32,3),Vector2(518.8224, 58.82233)])
	spawn_point_pairs.append([Vector2(31,3),Vector2(503.8224, 58.82233)])
	spawn_point_pairs.append([Vector2(30,3),Vector2(491.3224, 58.82233)])
	spawn_point_pairs.append([Vector2(29,3),Vector2(473.8224, 58.82233)])
	spawn_point_pairs.append([Vector2(28,3),Vector2(458.8224, 58.82233)])
	spawn_point_pairs.append([Vector2(27,3),Vector2(443.8224, 58.82233)])
	spawn_point_pairs.append([Vector2(32,4),Vector2(523.8224, 73.82233)])
	spawn_point_pairs.append([Vector2(31,4),Vector2(508.8224, 73.82233)])
	spawn_point_pairs.append([Vector2(30,4),Vector2(488.8224, 73.82233)])
	spawn_point_pairs.append([Vector2(29,4),Vector2(478.8224, 73.82233)])
	spawn_point_pairs.append([Vector2(28,4),Vector2(458.8224, 73.82233)])
	spawn_point_pairs.append([Vector2(27,4),Vector2(443.8224, 73.82233)])
	spawn_point_pairs.append([Vector2(32,5),Vector2(527.7513, 89.03805)])
	spawn_point_pairs.append([Vector2(31,5),Vector2(504.2513, 90.53805)])
	spawn_point_pairs.append([Vector2(30,5),Vector2(489.2513, 90.53805)])
	spawn_point_pairs.append([Vector2(29,5),Vector2(474.2513, 90.53805)])
	spawn_point_pairs.append([Vector2(28,5),Vector2(456.7513, 90.53805)])
	spawn_point_pairs.append([Vector2(27,5),Vector2(439.2513, 90.53805)])
	spawn_point_pairs.append([Vector2(32,6),Vector2(524.2513, 110.538)])
	spawn_point_pairs.append([Vector2(31,6),Vector2(509.2513, 110.538)])
	spawn_point_pairs.append([Vector2(30,6),Vector2(494.2513, 110.538)])
	spawn_point_pairs.append([Vector2(29,6),Vector2(479.2513, 110.538)])
	spawn_point_pairs.append([Vector2(28,6),Vector2(461.7513, 110.538)])
	spawn_point_pairs.append([Vector2(27,6),Vector2(446.7513, 110.538)])
	spawn_point_pairs.append([Vector2(32,7),Vector2(524.2513, 125.538)])
	spawn_point_pairs.append([Vector2(31,7),Vector2(506.7513, 125.538)])
	spawn_point_pairs.append([Vector2(30,7),Vector2(481.7513, 125.538)])
	spawn_point_pairs.append([Vector2(29,7),Vector2(469.2513, 125.538)])
	spawn_point_pairs.append([Vector2(28,7),Vector2(449.2513, 125.538)])
	spawn_point_pairs.append([Vector2(27,7),Vector2(434.2513, 125.538)])
	
	for pair in spawn_point_pairs:
		var first: Vector2 = pair[0]
		var second: Vector2 = pair[1]
		female_farmer_1._manual_hoe_action(first,second)

	for pair in spawn_point_pairs:
		var first: Vector2 = pair[0]
		var second: Vector2 = pair[1]
		female_farmer_1._manual_seeding_action(first,second)


func debug_plant_crops():
	pass






# Bottom
