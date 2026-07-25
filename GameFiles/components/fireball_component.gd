extends Node2D
class_name GroundPulse_Component

@export var isEnabled := true
@export var projectile_scene: PackedScene
@export var cooldown := 0.5
@export var spawn_distance := 16   # distance from player
@export var disruption_power := 50

var can_cast := true

func cast(direction: Vector2):
	if !isEnabled:
		return
	
	if !can_cast:
		return

	can_cast = false

	var fireball = projectile_scene.instantiate()
	fireball.global_position = owner.global_position + direction * spawn_distance
	fireball.direction = direction.normalized()
	fireball.damage = disruption_power

	owner.get_tree().current_scene.add_child(fireball)

	await get_tree().create_timer(cooldown).timeout
	can_cast = true
