extends Node2D



func _on_area_2d_2_body_entered(_body: Node2D) -> void:
	modulate.a = .2

func _on_area_2d_2_body_exited(_body: Node2D) -> void:
	modulate.a = 1.0

func _reset_modulation():
	modulate.a = 1.0
