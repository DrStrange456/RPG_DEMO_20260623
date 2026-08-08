class_name Seed_Sowing_Ability extends Node2D

#@onready var plyr = GmMgr._get_player_ref()

#var plant_scene = GmMgr.glPlantScene

var plant_rate: float = 0.0  # seconds between auto-planting when held
var plant_timer: float = 0.0


func _seed_sowing_actions(delta)->void:
	if Input.is_action_just_pressed("button_square"):
		_player_planting(GmMgr.selected_item)
		plant_timer = 0.0
	elif Input.is_action_pressed("button_square"):
		plant_timer += delta
		if plant_timer >= plant_rate:
			_player_planting(GmMgr.selected_item)
			plant_timer = 0.0

func _seed_sowing_single()->void:
	_player_planting(GmMgr.selected_item)
	plant_timer = 0.0


func _player_planting(itm: Resource):
	if GmMgr.glPlayerRef.pos:
		var tmpIsHoed = GmMgr.glPlayerRef._isValid_Hoed_Location()
		var tmpIsSpaceAvailable = GmMgr.glPlayerRef._is_space_available()
		if tmpIsHoed and tmpIsSpaceAvailable:
			#print(itm)
			#print(GmMgr.glPlayerRef.dirt.map_to_local(GmMgr.glPlayerRef.pos))
			_place_crop(itm,GmMgr.glPlayerRef.dirt.map_to_local(GmMgr.glPlayerRef.pos))
	
	GmMgr.glPlayerRef.set_Mode_to_Default()

func _debug_place_crop(itm,loc,loc_coord):
	#Is location valid
	GmMgr.glDebugSpawnLocation = loc
	var tmpIsHoed = GmMgr.glPlayerRef._isValid_Hoed_Location_byValue(loc_coord)
	var tmpIsSpaceAvailable = GmMgr.glPlayerRef._is_space_available_byValue(loc)
	if tmpIsHoed and tmpIsSpaceAvailable:
		var plant_res = PlantResource.new()
		plant_res.setup(itm.enum_seed_value,itm.enum_seed_item_value)
		var plant = GmMgr.glPlantScene.instantiate()
		var objects_fldr = find_anywhere("Crops")
		plant.setup(loc, objects_fldr, plant_res, plant_death)
		GmMgr.glPlayerRef.crop_list_array.append(Vector2i(loc))


func _place_crop(itm: Resource,loc: Vector2):
	var loc_coord = GmMgr.glPlayerRef._mapGlobal_toLocal(loc)
	var tmpIsHoed = GmMgr.glPlayerRef._isValid_Hoed_Location_byValue(loc)
	#var tmpIsHoed = GmMgr.glPlayerRef._isValid_Hoed_Location_byValue(loc_coord)
	#var tmpIsSpaceAvailable = GmMgr.glPlayerRef._is_space_available_byValue(loc)
	var tmpIsSpaceAvailable = GmMgr.glPlayerRef._is_space_available_byValue(loc_coord)
	if tmpIsHoed and tmpIsSpaceAvailable:
		var plant_res = PlantResource.new()
		plant_res.setup(itm.enum_seed_value,itm.enum_seed_item_value)
		var plant = GmMgr.glPlantScene.instantiate()
		var objects_fldr = find_anywhere("Crops")
		plant.setup(GmMgr.glPlayerRef.pos, objects_fldr, plant_res, plant_death)
		GmMgr.glPlayerRef.crop_list_array.append(GmMgr.glPlayerRef.pos)


func plant_death(coord: Vector2i):
	GmMgr.glPlayerRef.crop_list_array.erase(coord)






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
