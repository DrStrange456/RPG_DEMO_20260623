class_name Seed_Sowing_Ability extends Node2D

#@onready var plyr = GameManager._get_player_ref()

#var plant_scene = GameManager.glPlantScene

var plant_rate: float = 0.0  # seconds between auto-planting when held
var plant_timer: float = 0.0


func _seed_sowing_actions(delta)->void:
	if Input.is_action_just_pressed("button_square"):
		_player_planting(GameManager.selected_item)
		plant_timer = 0.0
	elif Input.is_action_pressed("button_square"):
		plant_timer += delta
		if plant_timer >= plant_rate:
			_player_planting(GameManager.selected_item)
			plant_timer = 0.0

func _seed_sowing_single()->void:
	_player_planting(GameManager.selected_item)
	plant_timer = 0.0


func _player_planting(itm: Resource):
	if GameManager.glPlayerRef.pos:
		var tmpIsHoed = GameManager.glPlayerRef._isValid_Hoed_Location()
		var tmpIsSpaceAvailable = GameManager.glPlayerRef._is_space_available()
		if tmpIsHoed and tmpIsSpaceAvailable:
			#var tmpName = InventoryAPI._translate_seed_nm_to_plant_nm(seed_name)
			_place_crop(itm,GameManager.glPlayerRef.dirt.map_to_local(GameManager.glPlayerRef.pos))
	
	GameManager.glPlayerRef.set_Mode_to_Default()


func _place_crop(itm: Resource,_loc: Vector2):
	print("Planting")
	var plant_res = PlantResource.new()
	plant_res.setup(itm.enum_seed_value,itm.enum_seed_item_value)
	var plant = GameManager.glPlantScene.instantiate()
	var objects_fldr = find_anywhere("Crops")
	plant.setup(GameManager.glPlayerRef.pos, objects_fldr, plant_res, plant_death)
	GameManager.glPlayerRef.crop_list_array.append(GameManager.glPlayerRef.pos)


func plant_death(coord: Vector2i):
	GameManager.glPlayerRef.crop_list_array.erase(coord)






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
