extends Node2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	#play_popup()
	pass

func setup(texture: Texture2D):
	sprite.texture = texture

func play_popup():
	animation_player.play("float")
	await animation_player.animation_finished
	queue_free()
