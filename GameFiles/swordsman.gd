extends CharacterBody2D

@export var move_speed: float = 150.0

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var state_machine: AnimationNodeStateMachinePlayback = animation_tree["parameters/playback"]

var input_direction: Vector2 = Vector2.ZERO
var facing_direction: Vector2 = Vector2.DOWN


func _ready() -> void:
	animation_tree.active = true


func _physics_process(_delta: float) -> void:
	handle_input()
	handle_movement()
	update_animation()


func handle_input() -> void:
	input_direction = Input.get_vector(
		"mapped_move_left",
		"mapped_move_right",
		"mapped_move_up",
		"mapped_move_down"
	)

	if input_direction != Vector2.ZERO:
		facing_direction = input_direction.normalized()


func handle_movement() -> void:
	velocity = input_direction * move_speed
	move_and_slide()


func update_animation() -> void:
	var state: String = ""

	# Determine direction priority (horizontal vs vertical)
	if abs(facing_direction.x) > abs(facing_direction.y):
		if facing_direction.x > 0:
			state = "walk_right" if input_direction != Vector2.ZERO else "idle_right"
		else:
			state = "walk_left" if input_direction != Vector2.ZERO else "idle_left"
	else:
		if facing_direction.y > 0:
			state = "walk_down" if input_direction != Vector2.ZERO else "idle_down"
		else:
			state = "walk_up" if input_direction != Vector2.ZERO else "idle_up"

	# Only change state if needed
	if state_machine.get_current_node() != state:
		state_machine.travel(state)
