extends Node2D

# This component is responsible for:
# - Showing particles when hit
# - Animate entity to show hit
# - show text popup with amount of damage applied


@export var damage = preload("res://components/popup_hit_text.tscn")
@onready var hit_particles = $hit_particles
@onready var txt_damage = $txtDamage
@onready var animation_player = $AnimationPlayer



func _take_damage(val):
	# From explosives
	makeHit(val)

func entity_is_hit(dam) -> void:
	animation_player.play("you_hurt_me")
	makeHit(dam)

func makeHit(dam) -> void:
	var newHit = damage.instantiate()
	newHit.position = txt_damage.global_position
	
	var dir = get_text_direction()
	var tween = get_tree().create_tween()
	tween.tween_property(newHit,"position",global_position - dir, 20)
	
	get_tree().current_scene.add_child(newHit)
	newHit.setValue(dam.damage)
	
	hit_particles.emitting = true

func get_text_direction() -> Vector2:
	#return Vector2(randf_range(-1,1),randf_range(-3,-2)) * 16
	return Vector2(randf_range(-1,1),randf_range(20,18)) * 16

func particle_knockback(source_position: Vector2) -> void:
	hit_particles.rotation = get_angle_to(source_position) + PI
