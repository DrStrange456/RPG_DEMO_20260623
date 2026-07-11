extends StaticBody2D

@onready var pl = get_tree().get_first_node_in_group("player")


func _ready():
	init_PickMyLook()


func init_PickMyLook()->void:
		sprite_flipped_check()


func sprite_flipped_check()->void:
	var chnc_flipped: int = randi_range(1,100)
	if chnc_flipped <= 50:
		$Sprite2D.flip_h = true


func _take_damage(_val):
	queue_free()

func _on_hurtbox_area_entered(_area):
	queue_free()

func _on_player_detection_zone_body_entered(_body):
	var dir = to_local(pl.global_position).normalized()
	if dir.x <= 0:
		$AnimationPlayer.play("Rustle_Right")
	if dir.x > 0:
		$AnimationPlayer.play("Rustle_Left")
