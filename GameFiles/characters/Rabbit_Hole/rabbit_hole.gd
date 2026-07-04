class_name rabbit_hole extends Node2D

@onready var rabbit = $rabbit as rabbit_character
@onready var bush = $bush


func _ready():
	rabbit.home_base = bush
