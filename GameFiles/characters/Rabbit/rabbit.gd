class_name rabbit_character extends CharacterBody2D

@export_category("Custom Variables")
@export var ACCELERATION : int = 300
@export var MAX_SPEED : int = 50
@export var FRICTION : int = 200
@export var WANDER_TARGET_RANGE = 20

@onready var wanderController = $WanderController
@onready var plyr = get_tree().get_first_node_in_group("player")
@onready var sprite = $Sprite2D
@onready var playerDetectionZone = $PlayerDetectionZone

@onready var txt_dir = $txtDIR
@onready var txt_state = $txtSTATE

var tmpTarget_Point
var home_base

enum entityState {
	IDLE,
	WANDER,
	#RETREAT,
	HIDE
}

var state = entityState.WANDER



func _ready():
	randomize()
	state = pick_random_state([entityState.IDLE, entityState.WANDER])

func _process(_delta):
	txt_dir.text = str(global_position)
	#txt_state.text = str(home_base.global_position)

func _physics_process(delta):
	match state:
		entityState.IDLE:
			idle_state(delta)
		entityState.WANDER:
			wander_state(delta)
		#entityState.RETREAT:
			#retreat_state(delta)
		entityState.HIDE:
			hide_state()
	move_and_slide()


# *** ------ ***
# *** STATES ***
# *** ------ ***

func idle_state(delta)->void:
	velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	seek_player()
	if wanderController.get_time_left() == 0:
		update_wander()

func wander_state(delta)->void:
	seek_player()
	if wanderController.get_time_left() == 0:
		update_wander()
	accelerate_towards_point(wanderController.target_position, delta)
	if global_position.distance_to(wanderController.target_position) <= WANDER_TARGET_RANGE:
		update_wander()

#func retreat_state(delta)->void:
	#if home_base:
		#accelerate_towards_point_fast(home_base.global_position, delta)
	#var tmp = global_position.distance_to(home_base.global_position)
	#if tmp < 10:
		#state = entityState.HIDE
		
func hide_state()->void:
	visible = false



# *** ---------------- ***
# *** FUNCTIONS / SUBS ***
# *** ---------------- ***

func pick_random_state(state_list):
	state_list.shuffle()
	return state_list.pop_front()

func update_wander():
	state = pick_random_state([entityState.IDLE, entityState.WANDER])
	wanderController.start_wander_timer(randf_range(3,6))

func accelerate_towards_point(point, delta):
	var direction = global_position.direction_to(point)
	velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION * delta)
	sprite.flip_h = velocity.x < 0

func accelerate_towards_point_fast(point, delta):
	var direction = global_position.direction_to(point)
	velocity = velocity.move_toward(direction * (MAX_SPEED * 2), ACCELERATION * delta)
	sprite.flip_h = velocity.x < 0

func seek_player():
	pass
	#if playerDetectionZone.can_see_player():
		#state = entityState.RETREAT

func set_home(val)->void:
	home_base = val
