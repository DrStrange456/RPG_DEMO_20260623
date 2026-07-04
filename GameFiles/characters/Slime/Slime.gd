extends CharacterBody2D

signal enemy_death

const EnemyDeathEffect = preload("res://Entities/Common/enemy_death_effect.tscn")

@export_category("Custom Variables")
@export var ACCELERATION : int = 300
@export var MAX_SPEED : int = 75
@export var FRICTION : int = 400
@export var WANDER_TARGET_RANGE = 4
@export var KNOCKBACK_FORCE = 120


@onready var ScnMgr = cFuncs.get_CurrentScene_ScnMgr()
@onready var animationPlayer = $AnimationPlayer
@onready var animationTree = $AnimationTree
@onready var animationState = animationTree.get("parameters/playback")
@onready var playerDetectionZone = $PlayerDetectionZone
@onready var wanderController = $WanderController
@onready var softCollision = $SoftCollision
@onready var sprite = $Sprite2D
@onready var stats = $Stats
@onready var blink_anim_plyr = $BlinkAnimationPlayer
@onready var damage_component = $Damage_Component
@onready var audio_stream_player = $AudioStreamPlayer

@onready var plyr = get_tree().get_first_node_in_group("player")

@export var enemy_damage: int = 3

var state = entityState.CHASE
var knockback = Vector2.ZERO
var jump_chances : int = 1
var base_probability : int = 200

# Parameters for jump effect
@export var jump_distance: float = 40.0
@export var jump_duration: float = 0.6
@export var jump_height: float = 50.0

# State variables
var start_position: Vector2
var target_position: Vector2
var jump_progress: float = 0.0
var is_jumping: bool = false

enum entityState {
	IDLE,
	WANDER,
	CHASE,
	JUMP
}

func _ready():
	@warning_ignore("unused_signal")
	randomize()
	animationTree.active = true
	state = pick_random_state([entityState.IDLE, entityState.WANDER])
	connect("enemy_death", Callable(ScnMgr.enemy_killed))
	$ValSqr1.setDisabled()

func _process(delta):
	if is_jumping:
		_apply_jump(delta)

func _physics_process(delta):
	if ScnMgr != null:
		if ScnMgr.isGamePaused(): return
	
	knockback = knockback.move_toward(Vector2.ZERO, FRICTION * delta)
	if knockback != Vector2.ZERO:
		velocity = velocity.move_toward(knockback, (ACCELERATION * 5) * delta)
	move_and_slide()

	match state:
		entityState.IDLE:
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
			seek_player()

			if wanderController.get_time_left() == 0:
				update_wander()

		entityState.WANDER:
			seek_player()
			if wanderController.get_time_left() == 0:
				update_wander()

			accelerate_towards_point(wanderController.target_position, delta)

			if global_position.distance_to(wanderController.target_position) <= WANDER_TARGET_RANGE:
				update_wander()

		entityState.CHASE:
			var player = playerDetectionZone.player
			if player != null:
				
				# If distance to player is within 20, no chase
				var dist_to_plyr = global_position.distance_to(player.global_position)
				if dist_to_plyr <= 35:
					
					#Randomly have enemy jump at Player
					if dice_roll(jump_chances,base_probability):
						state = entityState.JUMP
					else:
						state = entityState.IDLE
				else:
					accelerate_towards_point(player.global_position, FRICTION * delta)
				
##				move_and_collide(player.global_position, delta)
				#
				##Randomly have enemy jump at Player
				#if dice_roll(jump_chances,base_probability):
					#print("slime jumping")
					##fast_move_towards_point(player.global_position, delta)
				##else:
					##accelerate_towards_point(player.global_position, delta)
					##
			else:
				state = entityState.IDLE

		entityState.JUMP:
			jump_to_position_behind_player(plyr.global_position)
			state = entityState.IDLE

	if softCollision.is_colliding():
		velocity += softCollision.get_push_vector() * delta * 400
	move_and_slide()

func jump_to_position_behind_player(player_pos: Vector2):
	# Calc direction from player to enemy
	var direction_to_enemy = (player_pos - global_position).normalized()
	var variable_jump_distance = randf_range(jump_distance/4,jump_distance)
	
	# Set target position a certain distance behind the player
	target_position = player_pos + direction_to_enemy * variable_jump_distance
	
	# Initialize jump parameters
	start_position = global_position
	jump_progress = 0.0
	is_jumping = true

# Function to handle the jump arc motion
func _apply_jump(delta):
	# Increment progress based on time
	jump_progress += delta / jump_duration
	
	# Calculate horizontal position using linear interpolation
	global_position = start_position.lerp(target_position, jump_progress)
	
	# Calculate vertical offset for the parabolic arc
	var vertical_offset = -sin(jump_progress * PI) * jump_height
	$Sprite2D.position.y = vertical_offset
	
	# End the jump once progress reaches 1 (100% Complete)
	if jump_progress >= 1.0:
		is_jumping = false
	$Sprite2D.position.y = 0







# *** ---------------- ***
# *** FUNCTIONS / SUBS ***
# *** ---------------- ***

func pick_random_state(state_list):
	state_list.shuffle()
	return state_list.pop_front()

func update_wander():
	state = pick_random_state([entityState.IDLE, entityState.WANDER])
	wanderController.start_wander_timer(randf_range(1,3))

func accelerate_towards_point(point, delta):
	var direction = global_position.direction_to(point)
#	print("direction "+str(direction))
	velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION * delta)
	sprite.flip_h = velocity.x < 0

func fast_move_towards_point(point, delta):
	var direction = global_position.direction_to(point)
	velocity = velocity.move_toward(direction * (MAX_SPEED*10), (ACCELERATION*50) * delta)
	sprite.flip_h = velocity.x < 0

func idle_state(_delta):
	animationState.travel("Idle")

func seek_player():
	if playerDetectionZone.can_see_player():
		state = entityState.CHASE

func dice_roll(target : int, out_of : int):
	#example: 1 out of 200
	if randi() % out_of <= target:
		return true
	else:
		return false





# *** -------------- ***
# *** SIGNAL METHODS ***
# *** -------------- ***      

func _on_stats_no_health():
	queue_free() 
	var enemyDeathEffect = EnemyDeathEffect.instantiate()
	get_parent().add_child(enemyDeathEffect)
	enemyDeathEffect.global_position = global_position
	#emit_signal("enemy_death", self)
	#enemy_death.emit()

func _on_hurtbox_area_entered(area):
	if is_instance_valid(self) && self.is_in_group("enemy"):
		stats.health -= area.damage
		knockback = (self.global_position - plyr.global_position).normalized() * KNOCKBACK_FORCE
		blink_anim_plyr.play("start")
		damage_component.entity_is_hit(area)

func _on_shield_contactbox_area_entered(_area):
	knockback = (self.global_position - plyr.global_position).normalized() * KNOCKBACK_FORCE
	makeSound("res://Audio/SFX/impactMetal_000.ogg")

func makeSound(snd_file_name):
	audio_stream_player.stream = load(snd_file_name)
	audio_stream_player.play()
	await audio_stream_player.finished
	audio_stream_player.stream = null
