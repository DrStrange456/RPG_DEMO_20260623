extends CharacterBody2D

const EnemyDeathEffect = preload("res://assets/characters/Common/enemy_death_effect.tscn")

@export_category("Custom Variables")
@export var ACCELERATION : int = 300
@export var MAX_SPEED : int = 50
@export var FRICTION : int = 200
@export var WANDER_TARGET_RANGE = 4
@export var KNOCKBACK_FORCE = 20

enum entityState {
	IDLE,
	WANDER,
	CHASE
}

@onready var plyr = GameManager.glPlayerRef
#@onready var blink_animation_player: AnimationPlayer = $BlinkAnimationPlayer

var knockback = Vector2.ZERO
var state = entityState.CHASE

@onready var sprite = $AnimatedSprite2D
@onready var stats = $Stats
@onready var playerDetectionZone = $PlayerDetectionZone
@onready var hurtbox = $Hurtbox
@onready var softCollision = $SoftCollision
@onready var wanderController = $WanderController
@onready var damage_component = $Damage_Component
@onready var hitbox: Area2D = $Hitbox


func _ready():
	randomize()
	state = pick_random_state([entityState.IDLE, entityState.WANDER])
	hitbox.visible = false

func _physics_process(delta):
	
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
				accelerate_towards_point(player.global_position, delta)

			else:
				state = entityState.IDLE

	if softCollision.is_colliding():
		velocity += softCollision.get_push_vector() * delta * 400
	move_and_slide()







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
	#animationState.travel("Idle")
	pass

func seek_player():
	if playerDetectionZone.can_see_player():
		state = entityState.CHASE

func dice_roll(target : int, out_of : int):
	#example: 1 out of 200
	if randi() % out_of <= target:
		return true
	else:
		return false


func _on_stats_no_health():
	queue_free() 
	var enemyDeathEffect = EnemyDeathEffect.instantiate()
	get_parent().add_child(enemyDeathEffect)
	enemyDeathEffect.global_position = global_position
	#emit_signal("enemy_death", self)

func _on_hurtbox_area_entered(area):
	if is_instance_valid(self) && self.is_in_group("enemy"):
		stats.health -= area.damage
		knockback = (self.global_position - plyr.global_position).normalized() * KNOCKBACK_FORCE
		damage_component.entity_is_hit(area)

#
#func apply_knockback(from_position: Vector2, force: float):
	#var kb_direction = (global_position - from_position).normalized()
	#knockback_velocity = kb_direction * force
