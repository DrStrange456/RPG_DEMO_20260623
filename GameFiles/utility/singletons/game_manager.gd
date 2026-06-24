extends Node

#func _ready():
	#print("Game Manager ready at: ", Time.get_ticks_msec())


var world_scene = preload("res://scenes/levels/dev_starter_world.tscn")
var house_scene = preload("res://scenes/levels/dev_house.tscn")


@onready var glPlayerRef = get_tree().get_first_node_in_group("player")

var glPlantScene = preload("res://utility/misc/plant.tscn")
var glSlotPrev = preload("res://scenes/objects/slot_preview.tscn")
var glSlotUI = preload("res://Inventory/inventory_slot_ui.tscn")
var glSlot = preload("res://Inventory/Scripts/inventory_slot_ui.gd")

var glChest = preload("res://Inventory/StorageUI/StorageUI_Sm.tscn")
var glChest_lrg = preload("res://Inventory/StorageUI/StorageUI_Lrg.tscn")

# TIME/DATE TRACKING
var gl_TIME: String
var gl_DATE: String


var PLAYER_MONEY = 85

var ACTIVE_MENU

var selected_weapon
var selected_tool
var selected_item = preload("res://resources/seeds_strawberry.tres")


var current_state = Enum.UIState.NONE


var PLAYER_INVENTORY_TEST: Dictionary = {
		0: ["res://resources/seeds_turnip.tres", 98, true],
		1: ["res://resources/seeds_strawberry.tres", 99, true],
		2: ["res://resources/weapon_sword_fire.tres", 1, true],
		3: [null, 0, true],
		#3: ["res://resources/weapon_sword2.tres", 1, true],
		4: ["res://resources/seeds_tomato.tres", 65, true],
		5: ["res://resources/seeds_carrot.tres", 10, true],
		6: ["res://resources/tool_axe.tres", 1, true],
		7: ["res://resources/tool_pick.tres", 1, true],
		8: ["res://resources/weapon_sword1.tres", 1, true],
		#9: ["res://resources/tool_hoe.tres", 1, true],
		9: [null, 0, true],
		#10: [null, 0, true],
		#11: [null, 0, true],
		#12: [null, 0, true],
		#13: [null, 0, true],
		#14: [null, 0, true],
		#15: [null, 0, true],
}

var PLAYER_INVENTORY_TEST_LARGE: Dictionary = {
		0: ["res://resources/seeds_turnip.tres", 98, true],
		1: ["res://resources/seeds_strawberry.tres", 99, true],
		2: ["res://resources/weapon_sword_fire.tres", 1, true],
		3: [null, 0, true],
		4: ["res://resources/seeds_tomato.tres", 65, true],
		5: ["res://resources/seeds_carrot.tres", 10, true],
		6: ["res://resources/tool_axe.tres", 1, true],
		7: ["res://resources/tool_pick.tres", 1, true],
		8: ["res://resources/weapon_sword1.tres", 1, true],
		9: [null, 0, true],
		10: [null, 0, true],
		11: [null, 0, true],
		12: ["res://resources/seeds_tomato.tres", 90, true],
		13: [null, 0, true],
		14: ["res://resources/seeds_strawberry.tres", 35, true],
		15: [null, 0, true],
		16: [null, 0, true],
		17: [null, 0, true],
}

var STORAGE_TEST: Dictionary = {
		0: ["res://resources/crop_carrot.tres", 98, true],
		1: ["res://resources/crop_tomato.tres", 97, true],
		2: ["res://resources/seeds_tomato.tres", 90, true],
		3: ["res://resources/seeds_strawberry.tres", 90, true],
		4: ["res://resources/seeds_turnip.tres", 90, true],
		5: [null, 0, true],
		#6: [null, 0, true],
		#7: [null, 0, true],
		#8: ["res://resources/seeds_strawberry.tres", 90, true],
		#9: [null, 0, true],
		#10: [null, 0, true],
		#11: [null, 0, true],
		#12: [null, 0, true],
		#13: [null, 0, true],
		#14: [null, 0, true],
		#15: [null, 0, true],
		#16: ["res://resources/crop_carrot.tres", 98, true],
		#17: [null, 0, true],
}

var STORAGE_TEST_LARGE: Dictionary = {
		0: ["res://resources/crop_carrot.tres", 98, true],
		1: ["res://resources/crop_tomato.tres", 97, true],
		2: ["res://resources/seeds_tomato.tres", 90, true],
		3: ["res://resources/seeds_strawberry.tres", 90, true],
		4: ["res://resources/seeds_turnip.tres", 90, true],
		5: [null, 0, true],
		6: [null, 0, true],
		7: [null, 0, true],
		8: ["res://resources/seeds_strawberry.tres", 90, true],
		9: [null, 0, true],
		10: [null, 0, true],
		11: [null, 0, true],
		12: [null, 0, true],
		13: [null, 0, true],
		14: [null, 0, true],
		15: [null, 0, true],
		16: ["res://resources/crop_carrot.tres", 98, true],
		17: [null, 0, true],
}



### - FUNCTIONS
func _on_pause_opened():
	get_tree().paused = true

func _on_pause_closed():
	get_tree().paused = false





## - Common call to player node
func _get_player_ref():
	var plyr
	plyr = get_tree().get_first_node_in_group("player")
	return plyr
	

# BOTTOM
