class_name Hoe_Ability extends Node

func set_AnimState(animTree: AnimationTree):
	var animState = animTree.get("parameters/playback")
	animState.travel("Hoe")
 
func hoe_tile(pos,soil_hoed,rc) -> void:
	pos = soil_hoed.local_to_map(rc.getHitLocation())
	print(pos,rc.getHitLocation())
	soil_hoed.set_cell(pos,0,Vector2(0,0))
	var cells = soil_hoed.get_used_cells()
	soil_hoed.set_cells_terrain_connect(cells, 0, 0, true)

func hoe_tile_no_reticle(pos,soil_hoed,rc_hit_loc) -> void:
	pos = soil_hoed.local_to_map(rc_hit_loc)
	soil_hoed.set_cell(pos,0,Vector2(0,0))
	var cells = soil_hoed.get_used_cells()
	soil_hoed.set_cells_terrain_connect(cells, 0, 0, true)
