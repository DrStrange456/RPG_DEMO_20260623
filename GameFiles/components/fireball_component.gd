extends Node2D
class_name GroundPulse_Component

@export var projectile_scene: PackedScene
@export var cooldown := 0.5
@export var spawn_distance := 16   # distance from player

var can_cast := true

func cast(direction: Vector2):
	if !can_cast:
		return

	can_cast = false

	var fireball = projectile_scene.instantiate()
	fireball.global_position = owner.global_position + direction * spawn_distance
	fireball.direction = direction.normalized()

	owner.get_tree().current_scene.add_child(fireball)

	await get_tree().create_timer(cooldown).timeout
	can_cast = true
