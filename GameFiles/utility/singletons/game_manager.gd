extends Node

#func _ready():
	#print("Game Manager ready at: ", Time.get_ticks_msec())

const FACING_RIGHT = "RIGHT"
const FACING_LEFT = "LEFT"
const FACING_UP = "UP"
const FACING_DOWN = "DOWN"

@onready var glPlayerRef = get_tree().get_first_node_in_group("player")
@onready var glDebugSpawnLocation
@onready var inventory_main: popup_ui

var world_scene = preload("res://scenes/levels/dev_starter_world.tscn")
var house_scene = preload("res://scenes/levels/dev_house.tscn")

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
		18: ["res://resources/crop_strawberry.tres", 3, true],
		19: ["res://resources/crop_carrot.tres", 2, true],
		20: ["res://resources/crop_tomato.tres", 1, true],
		21: ["res://resources/crop_turnip.tres", 2, true],
		22: [null, 0, true],
		23: ["res://resources/crop_strawberry.tres", 50, true],
		24: [null, 0, true],
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
		18: [null, 0, true],
		19: [null, 0, true],
		20: [null, 0, true],
		21: [null, 0, true],
		22: [null, 0, true],
		23: [null, 0, true],
		24: [null, 0, true],
}



func _save_inventory(slots: Dictionary):
	#inventory_main = find_anywhere("Inventory_Main")
	#inventory_main._save_slots_to_dictionary(slots)
	PLAYER_INVENTORY_TEST_LARGE.clear()

	for i in slots:
		PLAYER_INVENTORY_TEST_LARGE[i] = slots[i].duplicate()


func _save_large_container(slots: Dictionary):
	STORAGE_TEST_LARGE.clear()

	for i in slots:
		STORAGE_TEST_LARGE[i] = slots[i].duplicate()





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

func convDir_from_Vector(dir):
	match dir:
		Vector2(1,0): return FACING_RIGHT
		Vector2(-1,0): return FACING_LEFT
		Vector2(0,-1): return FACING_UP
		Vector2(0,1): return FACING_DOWN

func find_anywhere(name1: String) -> Node:
	var tree := get_tree()
	
	# 1. Try to get autoloads
	var autoloads = ProjectSettings.get_setting("application/config/autoloads")
	if autoloads != null:
		for autoload_name in autoloads.keys():
			var singleton = tree.get_first_node_in_group(autoload_name)
			if singleton:
				if singleton.name == name1:
					return singleton
				var found = singleton.find_child(name1, true)
				if found:
					return found

	# 2. Try current scene
	if tree:
		if tree.current_scene:
			var found = tree.current_scene.find_child(name1, true)
			if found:
				return found

	# 3. Try the root (includes autoloads + main viewport)
	return tree.root.find_child(name1, true, false)



# BOTTOM
