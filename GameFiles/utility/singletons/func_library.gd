extends Node

#func _ready():
	#print("Func Library ready at: ", Time.get_ticks_msec())

# TILEMAPLAYER
func is_hit_location_valid_tml(tm: TileMapLayer, hitLoc: Vector2)->bool:
	# INPUT
	# 1) Tilemap to check hit location against
	# 2) Hit Location
	# 
	# If Hit location matches with a valid tilemap tile, return true.
	# Else return false
	
	var tmp_pos_id
	if tm:
		tmp_pos_id = tm.get_cell_atlas_coords(tm.local_to_map(hitLoc))
		return (tmp_pos_id[1] > -1)
	return false

# TILEMAP
func is_hit_location_valid(tm: TileMap, hitLoc: Vector2)->bool:
	# INPUT
	# 1) Tilemap to check hit location against
	# 2) Hit Location
	# 
	# If Hit location matches with a valid tilemap tile, return true.
	# Else return false
	
	var tmp_pos_id
	if tm:
		tmp_pos_id = tm.get_cell_atlas_coords(0,tm.local_to_map(hitLoc)) 
		return (tmp_pos_id[1] > -1)
	return false


func write_log(isEnabled: bool, strTEXT: String, strTYPE: String)->void:
	if isEnabled:
		match strTYPE:
			"info":
				print(strTEXT)
			"warn":
				push_warning(strTEXT)
			"err":
				push_error(strTEXT)

func get_key_from_value(dict: Dictionary, value: Variant)->Variant:
	for key in dict.keys():
		if dict[key] == value:
			return key
	return null

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



# Bottom
