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

var speed := 150
var speed_bonus := 150


var knockback_velocity: Vector2
@export var knockback_decay := 800.0

@onready var damage_component = $Components/Damage_Component
@onready var harvest_receiver: Node = $Components/harvest_receiver
@onready var currentFacingDir = Vector2.DOWN
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var animationState = animation_tree.get("parameters/playback")


@onready var dirt = _get_Handle_Node("Plantable")
@onready var soil_hoed = _get_Handle_Node("hoed")


var hoe =        _loadAbility("hoe") as Hoe_Ability
var seeding =    _loadAbility("seeding") as Seed_Sowing_Ability

var crop_list_array = []
var listPlantedLocations: Array = crop_list_array

var state = Enum.State.DEFAULT

var direction: Vector2
var last_direction: Vector2
var can_move: bool = true
var current_interactable
var current_crop = null

var is_invincible := false
@export var invincibility_duration := 2.0

func _ready() -> void:
	animation_tree.active = true
	animation_player.active = true
	reticleComp.visible = true
	reticleComp.init_detectors_toFalse()
	
	print("Time to playable: ",
		Time.get_ticks_msec() - StartupTimer.launch_time,
		" ms")

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
	direction = Input.get_vector("mapped_move_left", "mapped_move_right", "mapped_move_up", "mapped_move_down")
	currentFacingDir = direction
	match direction:
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
	if Input.is_action_just_pressed("alt_attack"):
		_attempt_sword()
	if Input.is_action_just_released("button_cross"):
		if state == Enum.State.DEFAULT:
			if current_crop:
				harvest_receiver.receive_crop(current_crop)

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




func update_interaction_target():
	# This is for activating the E.  Not needed as it creates dependency.
	
	#if reticleComp.is_IA_colliding():
		#var collider = reticleComp.IA().get_collider()
#
		## If you hit the Area2D, go up to the parent (Market)
		#if collider is Area2D:
			#var interactable = collider.get_parent()
			#
			#if interactable.has_method("interact"):
				#current_interactable = interactable
				#interactable.interact_enabled(self)
				#return

	# fallback if nothing valid hit
	#current_interactable = null
	#Events.emit_signal("hide_shop_icon")
	pass

func _attempt_hoe():
	state = Enum.State.HOEING

func _attempt_seed():
	state = Enum.State.SEEDING

func _attempt_sword():
	state = Enum.State.SWORD



## - - - HOEING - - -
func hoe_state():
	velocity = Vector2.ZERO
	if _isValid_Floor_Location():
		hoe.hoe_tile(pos, soil_hoed, reticleComp)
	state = Enum.State.DEFAULT


## - - - SEEDING - - -
func seed_state(_delta):
	seeding._seed_sowing_single()
	state = Enum.State.DEFAULT


## - - - SWINGING - - -
func sword_state(delta):
	animation_tree.advance(delta * SWORD_SPEED_MULTIPLIER)
	velocity = Vector2.ZERO
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






### - Reticle
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
func _is_space_available() -> bool:
	if pos:
		var space_occupied = listPlantedLocations.has(dirt.map_to_local(pos))
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
	var enemy: CharacterBody2D = area.get_parent()
	apply_knockback(enemy.global_position, 300)
	start_invincibility()
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



# BOTTOM
