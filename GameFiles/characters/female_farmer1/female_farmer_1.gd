extends CharacterBody2D



#region Reticle
@onready var reticleComp: Node2D = $Components/Reticle_Component
var isReticleVisible: bool = false
var pos_id
var pos
#endregion

@export_category("Stats")
@export var MAX_HEALTH : int = 100
@export var CURRENT_HEALTH : int = 100
@export_category("General")
@export var SWORD_SPEED_MULTIPLIER = 1.0
@export var knockback_decay := 800.0
@export var invincibility_duration := 2.0
@export var ground_pulse_scene : PackedScene

@onready var weapon_hit_box: Area2D = $Components/Weapon_Hit_Box
@onready var pulse: GroundPulse_Component = $Components/GroundPulse_Component
@onready var damage_component = $Components/Damage_Component
@onready var harvest_receiver: Node = $Components/harvest_receiver
@onready var currentFacingDir = Vector2.DOWN
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var animationState = animation_tree.get("parameters/playback")
@onready var dirt = _get_Handle_Node("Grid_Plantable")
@onready var soil_hoed = _get_Handle_Node("Grid_Hoed")

var hoe =        _loadAbility("hoe") as Hoe_Ability
var seeding =    _loadAbility("seeding") as Seed_Sowing_Ability

var crop_list_array = []
var listPlantedLocations: Array = crop_list_array

var direction: Vector2 = Vector2.DOWN
var knockback_velocity: Vector2
var state = Enum.State.DEFAULT
var last_direction: Vector2
var is_invincible := false
var can_move: bool = true
var current_interactable
var current_crop = null
var speed_bonus := 150
var speed := 150



func _ready() -> void:
	weapon_hit_box.monitoring = false
	weapon_hit_box.monitorable = false
	
	animation_tree.active = true
	animation_player.active = true
	reticleComp.visible = true
	reticleComp.init_detectors_toFalse()
	
	#print("Time to playable: ",
		#Time.get_ticks_msec() - StartupTimer.launch_time,
		#" ms")
	#
	#print("Shooting with:", currentFacingDir)

func _process(_delta: float) -> void:
	update_interaction_target()
	
	isReticleVisible = false  # Default to false
	isReticleVisible = _isLocation_Placeable()
	reticleComp._setToolVisibility(isReticleVisible)
	
	#if we can see it, put it in the right place
	if isReticleVisible:
		_place_reticle_correctly()


func _physics_process(delta: float) -> void:
	match state:
		Enum.State.DEFAULT:
			if can_move:
				get_basic_input(delta)
				move_action(delta)
				animate()
		Enum.State.SHOP:
			get_basic_input(delta)
		Enum.State.HOEING:
			animationState.travel('Idle')
			hoe_state()
		Enum.State.SEEDING:
			animationState.travel('Idle')
			seed_state(delta)
		Enum.State.SWORD:
			animationState.travel('Swing')
			sword_state(delta)
	if direction:
		last_direction = direction

func move_action(delta):
	animation_tree.advance(delta * 0.25)
	
	direction = Input.get_vector(
		"mapped_move_left",
		"mapped_move_right",
		"mapped_move_up",
		"mapped_move_down"
	)

	if direction != Vector2.ZERO:
		currentFacingDir = direction.normalized()
	
	match currentFacingDir:
		Vector2.UP:
			reticleComp.setReticle_FacingDir("up")
		Vector2.RIGHT:
			reticleComp.setReticle_FacingDir("right")
		Vector2.DOWN:
			reticleComp.setReticle_FacingDir("down")
		Vector2.LEFT:
			reticleComp.setReticle_FacingDir("left")
	
	velocity = direction * (speed + speed_bonus)
	
	# Slowly reduce knockback
	knockback_velocity = knockback_velocity.move_toward(
		Vector2.ZERO,
		knockback_decay * delta
	)

	velocity = velocity + knockback_velocity
	move_and_slide()

func get_basic_input(delta):
	animation_tree.advance(delta * 0.25)
	if Input.is_action_just_pressed("button_cross"):
		#_attempt_sword()
		_execute_primary_action()
		#get_viewport().set_input_as_handled()
	if Input.is_action_just_released("button_square"):
		#if state == Enum.State.DEFAULT:
			#if current_crop:
				#harvest_receiver.receive_crop(current_crop)
		_execute_secondary_action()
	
func animate():
	if direction:
		animation_tree.set("parameters/Idle/blend_position", currentFacingDir)
		animation_tree.set("parameters/Walk/blend_position", currentFacingDir)
		animation_tree.set("parameters/Run/blend_position", currentFacingDir)
		animation_tree.set("parameters/Swing/blend_position", currentFacingDir)
		if Input.is_action_pressed("sprinting"):
			animationState.travel("Run")
			speed_bonus = 150
		else:
			animationState.travel("Walk")
			speed_bonus = 0
	else:
		animationState.travel('Idle')


## - - - ACTIONS - - -
func _execute_primary_action():
	var root_scene = get_tree().current_scene
	var current_button = root_scene._get_selected_button()
	match current_button.name:
		"selectATTACK":
			_attempt_sword()
		"selectHOE":
			_attempt_hoe()
		"selectCHOP":
			_attempt_chop()
		"selectPICK":
			_attempt_pick()
		"selectPLANT":
			_attempt_seed()
		"selectHARVEST":
			_execute_secondary_action()
		"selectPICKUP":
			_attempt_handle_object()


func _execute_secondary_action():
	# Harvest Crops
	if state == Enum.State.DEFAULT:
		if current_crop:
			harvest_receiver.receive_crop(current_crop)




func update_interaction_target():
	pass

func _attempt_hoe():
	state = Enum.State.HOEING

func _attempt_seed():
	state = Enum.State.SEEDING

func _attempt_sword():
	state = Enum.State.SWORD

func _attempt_pick():
	performAction_PickAxe()

func _attempt_chop():
	performAction_AxeSwing()

func _attempt_handle_object():
	pass


func _manual_hoe_action(cell_pos,ret_hit_loc):
	hoe.hoe_tile_no_reticle(cell_pos, soil_hoed, ret_hit_loc)

func _manual_seeding_action(loc,vec):
	seeding._debug_place_crop(GmMgr.selected_item,loc,vec)

## - - - HOEING - - -
func hoe_state():
	velocity = Vector2.ZERO
	if _isValid_Floor_Location():
		hoe.hoe_tile(pos, soil_hoed, reticleComp)
		#print(pos, soil_hoed, reticleComp)
	state = Enum.State.DEFAULT


## - - - SEEDING - - -
func seed_state(_delta):
	seeding._seed_sowing_single()
	state = Enum.State.DEFAULT


## - - - SWINGING - - -
func sword_state(delta):
	animation_tree.advance(delta * SWORD_SPEED_MULTIPLIER)
	velocity = Vector2.ZERO
	
	# turn hitbox ON
	weapon_hit_box.monitoring = true
	weapon_hit_box.monitorable = true
	
	#shoot_fireball()
	pulse.cast(currentFacingDir)
	
	_init_attack_anim()   # Currently not used
	await animation_player.animation_finished


func _init_attack_anim()->void:
#	Use this to setup other variables, such as swing speed
	match currentFacingDir:
		Vector2.UP:
			pass
		Vector2.LEFT:
			pass
		Vector2.DOWN:
			pass
		Vector2.RIGHT:
			pass


func _attack_anim_done()->void:
	# when animation frames advanced artificially, the player still waits for duration to end.
	#  this can be used to signal when the frames have completed.  
	#  Usage: has to be added as a method track in player.
	#weapon.texture = null
	state = Enum.State.DEFAULT
	
	weapon_hit_box.monitoring = false
	weapon_hit_box.monitorable = false



## - Rock Crushing
func performAction_PickAxe():
	await get_tree().process_frame
	pickRock_action_initiated(1)  # signal_name, damage_value

func pickRock_action_initiated(dam):
	if reticleComp.is_ROCK_DET_colliding():
		var target = reticleComp.ROCK_DET_Collider()
		var target_parent = target.get_parent()
		if target_parent.has_method("take_damage"):
			if target_parent.is_in_group("rocks"):
				target_parent.take_damage(dam, self.global_position)



## - Axe Swing
func performAction_AxeSwing():
	await get_tree().process_frame
	chopTree_action_initiated(1)  # signal_name, damage_value

func chopTree_action_initiated(dam):
	if reticleComp.is_TREE_DET_colliding():
		var target = reticleComp.TREE_DET_Collider()
		var target_parent = target.get_parent()
		if target_parent.has_method("take_damage"):
			if target_parent.is_in_group("trees"):
				target_parent.take_damage(dam, self.global_position)




func _free_crop_location(posi):
	var tmp = to_float_vector(soil_hoed.local_to_map(posi))
	GmMgr.glPlayerRef.crop_list_array.erase(Vector2i(tmp))
	print(GmMgr.glPlayerRef.crop_list_array)
	
func to_float_vector(v: Vector2) -> Vector2:
	return Vector2(float(v.x), float(v.y))

func to_int_vector(v: Vector2) -> Vector2:
	return Vector2(int(v.x), int(v.y))


### - Reticle
func _mapGlobal_toLocal(loc)->Vector2:
	return to_float_vector(soil_hoed.local_to_map(loc))

func _place_reticle_correctly()->void:
	# Map reticle to grid coordinate and place
	pos = dirt.local_to_map(reticleComp.getHitLocation())
	reticleComp.setReticleLocation(dirt.map_to_local(pos))
func _isLocation_Placeable() -> bool:
	var results: bool = false
	results = _isValid_Floor_Location()
	return results
func _isValid_Floor_Location() -> bool:
	if dirt:
		var tmp_pos
		var tmp_pos_id
		var hitLocation = reticleComp.getHitLocation()
		tmp_pos = dirt.local_to_map(hitLocation)
		tmp_pos_id = dirt.get_cell_atlas_coords(tmp_pos)
		return (tmp_pos_id[1] > -1)
	return false
func _get_Handle_Node(nd) -> Node:
	var tmp = get_tree().current_scene
	if tmp:
		return tmp.find_child(nd)
	else:
		return tmp
func _isValid_Hoed_Location() -> bool:
	if soil_hoed:
		return is_hit_location_valid_tml(soil_hoed,reticleComp.getHitLocation())
	return false
func _isValid_Hoed_Location_byValue(val:Vector2) -> bool:
	if soil_hoed:
		return is_hit_location_valid_tml(soil_hoed,val)
	return false
func _is_space_available() -> bool:
	if pos:
		#print(pos)
		#print(listPlantedLocations.has(dirt.map_to_local(pos)))
		var space_occupied = listPlantedLocations.has(dirt.map_to_local(pos))
		return !space_occupied
	else: return false
func _is_space_available_byValue(val) -> bool:
	if val:
		var space_occupied = listPlantedLocations.has(Vector2i(val))
		return !space_occupied
	else: return false
func set_Mode_to_Default():
	state = Enum.State.DEFAULT
func _loadAbility(abilName) -> Node:
	var scene = load("res://abilities/" + abilName + ".tscn")
	var sceneNode = scene.instantiate()
	add_child(sceneNode)
	return sceneNode

func plant_detected(area):
	if area:
		if area.is_in_group("harvestable"):
			current_crop = area
func plant_not_detected():
	current_crop = null
func plants_detected() -> int:
	if current_crop: return true
	else: return false




#func debug_place_seed(loc: Vector2):
	#seeding._place_crop(Enum.Seed.STRAWBERRY,loc)
func _attempt_exit_store():
	if state == Enum.State.SHOP:
		var gen_str = find_anywhere("general_store")
		gen_str.visible = false
		#UiManager.active_ui = null
		state = Enum.State.DEFAULT  # Return to game



func _on_hurtbox_area_entered(area: Area2D) -> void:
	if is_invincible:
		return
	
	CURRENT_HEALTH -= 1
	damage_component.entity_is_hit(area)
	#var enemy: CharacterBody2D = area.get_parent()
	var enemy: Node2D = area.get_parent()
	apply_knockback(enemy.global_position, 300)
	start_invincibility()
	
	Events.emit_signal("health_changed",CURRENT_HEALTH,MAX_HEALTH)

func apply_knockback(from_position: Vector2, force: float):
	var kb_direction = (global_position - from_position).normalized()
	knockback_velocity = kb_direction * force
func start_invincibility():
	is_invincible = true
	# Optional flash effect
	modulate.a = 0.5
	await get_tree().create_timer(invincibility_duration).timeout
	modulate.a = 1.0
	is_invincible = false





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


#func shoot_fireball():
	#var spawn_distance := 28.0
	#var fireball = ground_pulse_scene.instantiate()
	#get_tree().current_scene.add_child(fireball)
	#fireball.global_position = global_position + currentFacingDir.normalized() * spawn_distance
	#fireball.set_direction(currentFacingDir)
	#fireball.direction = currentFacingDir
	#fireball.rotation = currentFacingDir.angle()





# BOTTOM
