extends Node2D

#@onready var pause_screen: Control = $UI/PauseScreen
#@onready var general_store: Control = $UI/general_store
#@onready var time_of_day_ui: Control = $UI/TimeOfDayUI
#@onready var btn_weapon: Button = $UI/btnWEAPON
#@onready var btn_tool: Button = $UI/btnTOOL
#@onready var btn_item: Button = $UI/btnITEM

@onready var female_farmer_1: CharacterBody2D = $World/Objects/female_farmer1




#func _ready() -> void:
	#Events.connect("hide_buttons_and_tod", Callable(_hide_ui))
	#Events.connect("show_buttons_and_tod", Callable(_show_ui))

#
#### UI
#func _hide_ui():
	#time_of_day_ui.visible = false
	#btn_weapon.visible = false
	#btn_tool.visible = false
	#btn_item.visible = false
#
#func _show_ui():
	#time_of_day_ui.visible = true
	#btn_weapon.visible = true
	#btn_tool.visible = true
	#btn_item.visible = true



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
	#dev_chest.visible = true
	#dev_chest._reset_inventory()

func _on_chest_large_activate_clicked() -> void:
	pass # Replace with function body.

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		get_tree().change_scene_to_packed(GameManager.house_scene)






# Bottom
