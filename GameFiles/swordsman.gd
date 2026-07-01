extends CharacterBody2D

@export var move_speed: float = 150.0
@export var sprint_bonus: float = 150.0
@export var knockback_decay: float = 800.0

enum State {
	DEFAULT,
	SWORD
}

var state: State = State.DEFAULT
var previous_state: State = State.DEFAULT

var direction: Vector2 = Vector2.ZERO
var last_direction: Vector2 = Vector2.DOWN
var current_facing_dir: Vector2 = Vector2.DOWN

var knockback_velocity: Vector2 = Vector2.ZERO

var animation_player: AnimationPlayer
var animation_tree: AnimationTree
var animation_state

func _ready() -> void:
	animation_player = $AnimationPlayer
	animation_tree = $AnimationTree

	animation_tree.active = true
	animation_player.active = true

	animation_state = animation_tree.get("parameters/playback")


func _physics_process(delta: float) -> void:
	_handle_state_transition()

	match state:
		State.DEFAULT:
			_process_default_state(delta)

		State.SWORD:
			_process_sword_state(delta)

	move_and_slide()


# ----------------------------------------------------
# STATE HANDLING
# ----------------------------------------------------

func _handle_state_transition() -> void:
	if state != previous_state:
		_on_state_enter(previous_state, state)
		previous_state = state


func _on_state_enter(_old_state: State, new_state: State) -> void:
	match new_state:
		State.SWORD:
			# Lock facing direction at attack start
			if direction != Vector2.ZERO:
				current_facing_dir = direction
			else:
				current_facing_dir = last_direction

			_play_sword_animation()


# ----------------------------------------------------
# DEFAULT STATE
# ----------------------------------------------------

func _process_default_state(delta: float) -> void:
	get_input()
	_move(delta)
	_animate()


func get_input() -> void:
	direction = Input.get_vector(
		"mapped_move_left",
		"mapped_move_right",
		"mapped_move_up",
		"mapped_move_down"
	)

	if direction != Vector2.ZERO:
		last_direction = direction
		current_facing_dir = direction

	if Input.is_action_just_pressed("alt_attack"):
		_attempt_sword()


func _move(delta: float) -> void:
	var speed := move_speed

	if Input.is_action_pressed("sprinting"):
		speed += sprint_bonus

	var input_velocity = direction * speed

	knockback_velocity = knockback_velocity.move_toward(
		Vector2.ZERO,
		knockback_decay * delta
	)

	velocity = input_velocity + knockback_velocity


func _animate() -> void:
	animation_tree.set("parameters/Idle/blend_position", current_facing_dir)
	animation_tree.set("parameters/Walk/blend_position", current_facing_dir)
	animation_tree.set("parameters/Run/blend_position", current_facing_dir)
	animation_tree.set("parameters/Swing/blend_position", current_facing_dir)

	if direction == Vector2.ZERO:
		animation_state.travel("Idle")
	elif Input.is_action_pressed("sprinting"):
		animation_state.travel("Run")
	else:
		animation_state.travel("Walk")


# ----------------------------------------------------
# SWORD STATE
# ----------------------------------------------------

func _process_sword_state(_delta: float) -> void:
	# No movement input during attack (intentional lock)
	#velocity = Vector2.ZERO + knockback_velocity
	velocity = direction * move_speed + knockback_velocity

	# Only direction affects animation blending
	animation_tree.set("parameters/Swing/blend_position", current_facing_dir)
	animation_tree.set("parameters/RunningSwing/blend_position", current_facing_dir)


func _attempt_sword() -> void:
	if state == State.SWORD:
		return

	state = State.SWORD


func _play_sword_animation() -> void:
	if Input.is_action_pressed("sprinting"):
		animation_state.travel("RunningSwing")
	else:
		animation_state.travel("Swing")


# ----------------------------------------------------
# ANIMATION CALLBACK
# ----------------------------------------------------

func _attack_anim_done() -> void:
	state = State.DEFAULT
