extends Node2D


var tree_obj = preload("res://scenes/objects/static_tree_medium.tscn")

@onready var female_farmer_1: CharacterBody2D = $World/Objects/female_farmer1
@onready var tool_selector: Control = $UI/HUD/tool_selector
@onready var button_group := ButtonGroup.new()
@onready var hud: Node2D = $UI/HUD
#@onready var tree_debug: Node2D = $World/Objects/Tree_Debug

@onready var tree_positions: Array = [Vector2(478.7, 818.0), Vector2(486.6, 848.8), Vector2(494.5, 879.6), Vector2(455.0, 833.4), Vector2(462.9, 864.2), Vector2(470.8, 895.0), Vector2(421.7, 818.0), Vector2(429.6, 848.8), Vector2(437.5, 879.6), Vector2(398.0, 833.4), Vector2(405.9, 864.2), Vector2(413.8, 895.0), Vector2(364.7, 831.0), Vector2(372.6, 861.8), Vector2(380.5, 892.6), Vector2(341.0, 846.4), Vector2(348.9, 877.2), Vector2(356.8, 908.0), Vector2(313.7, 826.0), Vector2(321.6, 856.8), Vector2(329.5, 887.6), Vector2(290.0, 841.4), Vector2(297.9, 872.2), Vector2(305.8, 903.0), Vector2(222.7, 823.0), Vector2(230.6, 853.8), Vector2(238.5, 884.6), Vector2(199.0, 838.4), Vector2(206.9, 869.2), Vector2(214.8, 900.0), Vector2(165.7, 823.0), Vector2(173.6, 853.8), Vector2(181.5, 884.6), Vector2(142.0, 838.4), Vector2(149.9, 869.2), Vector2(157.8, 900.0), Vector2(108.7, 836.0), Vector2(116.6, 866.8), Vector2(124.5, 897.6), Vector2(85.0, 851.4), Vector2(92.89999, 882.2), Vector2(100.8, 913.0), Vector2(57.70001, 831.0), Vector2(65.60001, 861.8), Vector2(73.5, 892.6), Vector2(34.0, 846.4), Vector2(41.89999, 877.2), Vector2(49.79999, 908.0)]
@onready var trees_and_bushes: Node2D = $World/Objects/TreesAndBushes




func _ready():
	hud.visible = true
	for button in tool_selector.get_children():
		if button is Button:
			button.toggle_mode = true
			button.button_group = button_group

	# Select the first button if desired
	button_group.get_buttons()[1].button_pressed = true
	
	#debug_setup_trees()
	#print(get_global_positions(tree_debug))


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

func debug_setup_crops():
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

func _on_selector_button_pressed(button: Button):
	button.release_focus()

func _on_select_hoe_pressed() -> void:
	pass # Replace with function body.

func debug_setup_trees():
	for tri in tree_positions:
		var new_tree = tree_obj.instantiate()
		trees_and_bushes.add_child(new_tree)
		new_tree.global_position = tri
		new_tree._reset_modulation()




# Bottom



func get_global_positions(folder: Node) -> Array[Vector2]:
	var positions: Array[Vector2] = []

	for child in folder.get_children():
		if child is Node2D:
			positions.append(child.global_position)

	return positions

func print_global_positions(folder: Node) -> void:
	for child in folder.get_children():
		if child is Node2D:
			#print(child.name, " -> ", child.global_position)
			print(child.global_position)



func _on_btn_crops_pressed(button: Button):
	debug_setup_crops()
	button.release_focus()

func _on_btn_trees_pressed(button: Button) -> void:
	debug_setup_trees()
	button.release_focus()
