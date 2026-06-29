extends CharacterBody2D

@export var move_speed: float = 150.0
@export var knockback_decay := 800.0
@export var SWORD_SPEED_MULTIPLIER = 1.0


@onready var currentFacingDir = Vector2.DOWN
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var animationState = animation_tree.get("parameters/playback")


var state = Enum.State.DEFAULT
var direction: Vector2
var last_direction: Vector2
var can_move: bool = true

var speed := 150
var speed_bonus := 150
var knockback_velocity: Vector2




func _ready() -> void:
	animation_tree.active = true
	animation_player.active = true


func _physics_process(delta: float) -> void:
	match state:
		Enum.State.DEFAULT:
			if can_move:
				get_basic_input(delta)
				move_action(delta)
				animate()
		Enum.State.SWORD:
			animationState.travel('Swing')
			sword_state(delta)
	if direction:
		last_direction = direction



func move_action(delta):
	animation_tree.advance(delta * 0.25)
	direction = Input.get_vector("mapped_move_left", "mapped_move_right", "mapped_move_up", "mapped_move_down")
	currentFacingDir = direction
	
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

func _attempt_sword():
	state = Enum.State.SWORD

func _attack_anim_done()->void:
	# when animation frames advanced artificially, the player still waits for duration to end.
	#  this can be used to signal when the frames have completed.  
	#  Usage: has to be added as a method track in player.
	state = Enum.State.DEFAULT
