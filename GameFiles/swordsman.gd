extends CharacterBody2D

@export var move_speed: float = 150.0
@export var knockback_decay := 800.0
@export var SWORD_SPEED_MULTIPLIER := 1.0

@onready var currentFacingDir = Vector2.DOWN
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var animationState = animation_tree.get("parameters/playback")

var state = Enum.State.DEFAULT

var direction: Vector2
var last_direction: Vector2
var can_move := true

var speed := 150
var speed_bonus := 0

var knockback_velocity: Vector2


func _ready() -> void:
	animation_tree.active = true
	animation_player.active = true


func _physics_process(delta: float) -> void:

	if can_move:
		get_basic_input()
		move_action(delta)

	match state:
		Enum.State.DEFAULT:
			animate()

		Enum.State.SWORD:
			sword_state(delta)

	if direction != Vector2.ZERO:
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
		currentFacingDir = direction

	if Input.is_action_pressed("sprinting"):
		speed_bonus = 150
	else:
		speed_bonus = 0

	velocity = direction * (speed + speed_bonus)

	knockback_velocity = knockback_velocity.move_toward(
		Vector2.ZERO,
		knockback_decay * delta
	)

	velocity += knockback_velocity

	move_and_slide()


func get_basic_input():

	if Input.is_action_just_pressed("alt_attack"):
		_attempt_sword()


func animate():

	animation_tree.set("parameters/Idle/blend_position", currentFacingDir)
	animation_tree.set("parameters/Walk/blend_position", currentFacingDir)
	animation_tree.set("parameters/Run/blend_position", currentFacingDir)
	animation_tree.set("parameters/Swing/blend_position", currentFacingDir)

	if direction == Vector2.ZERO:
		animationState.travel("Idle")
	elif Input.is_action_pressed("sprinting"):
		animationState.travel("Run")
	else:
		animationState.travel("Walk")


#----------------------------------------------------
# Sword
#----------------------------------------------------

func sword_state(delta):

	animation_tree.advance(delta * SWORD_SPEED_MULTIPLIER)

	animation_tree.set(
		"parameters/Swing/blend_position",
		currentFacingDir
	)

	animationState.travel("Swing")


func _attempt_sword():

	if state == Enum.State.SWORD:
		return

	state = Enum.State.SWORD

	_init_attack_anim()


func _init_attack_anim() -> void:

	match currentFacingDir:
		Vector2.UP:
			pass
		Vector2.LEFT:
			pass
		Vector2.DOWN:
			pass
		Vector2.RIGHT:
			pass


func _attack_anim_done():

	state = Enum.State.DEFAULT
