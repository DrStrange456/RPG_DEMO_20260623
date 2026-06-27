extends CharacterBody2D

@export var move_speed: float = 150.0

var input_direction: Vector2 = Vector2.ZERO
var facing_direction: Vector2 = Vector2.DOWN

func _physics_process(_delta: float) -> void:
	# Get movement input
	input_direction = Input.get_vector(
		"mapped_move_left",
		"mapped_move_right",
		"mapped_move_up",
		"mapped_move_down"
	)

	# Save the last direction moved for animations later
	if input_direction != Vector2.ZERO:
		facing_direction = input_direction.normalized()

	# Apply movement
	velocity = input_direction * move_speed
	move_and_slide()
