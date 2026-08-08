extends Node2D


var tree_obj = preload("res://scenes/objects/static_tree_medium.tscn")
var rock_obj = preload("res://scenes/objects/rock.tscn")

@onready var female_farmer_1: CharacterBody2D = $World/Objects/female_farmer1
@onready var tool_selector: Control = $UI/HUD/tool_selector
@onready var button_group := ButtonGroup.new()
@onready var hud: Node2D = $UI/HUD

@onready var rocks: Node2D = $World/Objects/_Rocks
@onready var trees_and_bushes: Node2D = $World/Objects/_TreesAndBushes

var tree_positions: Array = [Vector2(478.7, 818.0), Vector2(486.6, 848.8), Vector2(494.5, 879.6), Vector2(455.0, 833.4), Vector2(462.9, 864.2), Vector2(470.8, 895.0), Vector2(421.7, 818.0), Vector2(429.6, 848.8), Vector2(437.5, 879.6), Vector2(398.0, 833.4), Vector2(405.9, 864.2), Vector2(413.8, 895.0), Vector2(364.7, 831.0), Vector2(372.6, 861.8), Vector2(380.5, 892.6), Vector2(341.0, 846.4), Vector2(348.9, 877.2), Vector2(356.8, 908.0), Vector2(313.7, 826.0), Vector2(321.6, 856.8), Vector2(329.5, 887.6), Vector2(290.0, 841.4), Vector2(297.9, 872.2), Vector2(305.8, 903.0), Vector2(222.7, 823.0), Vector2(230.6, 853.8), Vector2(238.5, 884.6), Vector2(199.0, 838.4), Vector2(206.9, 869.2), Vector2(214.8, 900.0), Vector2(165.7, 823.0), Vector2(173.6, 853.8), Vector2(181.5, 884.6), Vector2(142.0, 838.4), Vector2(149.9, 869.2), Vector2(157.8, 900.0), Vector2(108.7, 836.0), Vector2(116.6, 866.8), Vector2(124.5, 897.6), Vector2(85.0, 851.4), Vector2(92.89999, 882.2), Vector2(100.8, 913.0), Vector2(57.70001, 831.0), Vector2(65.60001, 861.8), Vector2(73.5, 892.6), Vector2(34.0, 846.4), Vector2(41.89999, 877.2), Vector2(49.79999, 908.0)]
var rock_positions: Array = [Vector2(2099.5, 719.0), Vector2(2099.5, 753.0), Vector2(2099.5, 736.0), Vector2(2079.0, 719.0), Vector2(2079.0, 753.0), Vector2(2079.0, 736.0), Vector2(2140.5, 709.0), Vector2(2140.5, 743.0), Vector2(2140.5, 726.0), Vector2(2120.0, 709.0), Vector2(2120.0, 743.0), Vector2(2120.0, 726.0), Vector2(2113.5, 772.0), Vector2(2113.5, 806.0), Vector2(2113.5, 789.0), Vector2(2093.0, 772.0), Vector2(2093.0, 806.0), Vector2(2093.0, 789.0), Vector2(2151.5, 761.0), Vector2(2151.5, 795.0), Vector2(2151.5, 778.0), Vector2(2131.0, 761.0), Vector2(2131.0, 795.0), Vector2(2131.0, 778.0), Vector2(2235.5, 714.0), Vector2(2235.5, 748.0), Vector2(2235.5, 731.0), Vector2(2215.0, 714.0), Vector2(2215.0, 748.0), Vector2(2215.0, 731.0), Vector2(2276.5, 704.0), Vector2(2276.5, 738.0), Vector2(2276.5, 721.0), Vector2(2256.0, 704.0), Vector2(2256.0, 738.0), Vector2(2256.0, 721.0), Vector2(2249.5, 767.0), Vector2(2249.5, 801.0), Vector2(2249.5, 784.0), Vector2(2229.0, 767.0), Vector2(2229.0, 801.0), Vector2(2229.0, 784.0), Vector2(2287.5, 756.0), Vector2(2287.5, 790.0), Vector2(2287.5, 773.0), Vector2(2267.0, 756.0), Vector2(2267.0, 790.0), Vector2(2267.0, 773.0), Vector2(2157.5, 861.0), Vector2(2157.5, 895.0), Vector2(2157.5, 878.0), Vector2(2137.0, 861.0), Vector2(2137.0, 895.0), Vector2(2137.0, 878.0), Vector2(2198.5, 851.0), Vector2(2198.5, 885.0), Vector2(2198.5, 868.0), Vector2(2178.0, 851.0), Vector2(2178.0, 885.0), Vector2(2178.0, 868.0), Vector2(2171.5, 914.0), Vector2(2171.5, 948.0), Vector2(2171.5, 931.0), Vector2(2151.0, 914.0), Vector2(2151.0, 948.0), Vector2(2151.0, 931.0), Vector2(2209.5, 903.0), Vector2(2209.5, 937.0), Vector2(2209.5, 920.0), Vector2(2189.0, 903.0), Vector2(2189.0, 937.0), Vector2(2189.0, 920.0)]


#@onready var tree_debug: Node2D = $World/Objects/Tree_Debug



func _ready():
	hud.visible = true
	for button in tool_selector.get_children():
		if button is Button:
			button.toggle_mode = true
			button.button_group = button_group

	# Select the first button if desired
	button_group.get_buttons()[0].button_pressed = true
	
	debug_setup_trees()
	#print(get_global_positions(rocks))


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
	GmMgr._on_pause_opened()

func _on_chest_large_activate_clicked() -> void:
	pass # Replace with function body.

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		get_tree().change_scene_to_packed(GmMgr.house_scene)







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

func _on_selector_button_pressed(button: Button):
	button.release_focus()

func _on_select_hoe_pressed() -> void:
	pass # Replace with function body.

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


func debug_setup_trees():
	for tri in tree_positions:
		var new_tree = tree_obj.instantiate()
		trees_and_bushes.add_child(new_tree)
		new_tree.global_position = tri
		new_tree._reset_modulation()

func debug_setup_rocks():
	for obj in rock_positions:
		var new_obj = rock_obj.instantiate()
		rocks.add_child(new_obj)
		new_obj.global_position = obj
		#new_obj._reset_modulation()








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

func _on_btn_rocks_pressed(button: Button) -> void:
	debug_setup_rocks()
	button.release_focus()




# Bottom


func _on_inventory_main_visibility_changed(source: CanvasItem) -> void:
	source._refresh_inventory_items_signal()
