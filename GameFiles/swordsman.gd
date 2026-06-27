extends CharacterBody2D

@export var move_speed: float = 150.0
@export var knockback_decay := 800.0


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
	pass

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
