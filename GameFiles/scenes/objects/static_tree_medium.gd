extends Node2D

@export var max_health: int = 3
var current_health: int


func _ready():
	current_health = max_health
	



func take_damage(amount: int, attacker_position: Vector2):
	current_health -= amount
	
	var dir: float = sign(global_position.x - attacker_position.x)
	sway_tree(dir)
	
	if current_health <= 0:
		destroy()

func destroy():
	print("Tree fell")
	queue_free()

func sway_tree(hit_direction: float = 1.0) -> void:
	var angle := deg_to_rad(8) * hit_direction

	var t := create_tween()
	t.set_trans(Tween.TRANS_SINE)

	t.tween_property(self, "rotation",  angle,        0.06)
	t.tween_property(self, "rotation", -angle * 0.6,  0.08)
	t.tween_property(self, "rotation",  angle * 0.35, 0.07)
	t.tween_property(self, "rotation", -angle * 0.15, 0.06)
	t.tween_property(self, "rotation", 0.0,           0.08)




func _on_area_2d_2_body_entered(_body: Node2D) -> void:
	modulate.a = .2

func _on_area_2d_2_body_exited(_body: Node2D) -> void:
	modulate.a = 1.0

func _reset_modulation():
	modulate.a = 1.0
