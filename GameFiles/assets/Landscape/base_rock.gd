class_name rock_base
extends StaticBody2D

@export var hitPoints: int = 1
@onready var plyr_looking_at_me: bool =  false
@onready var side_detected_on: String = ""


var plyr
var plyr_is_facing_me: bool = false

func is_player_looking_at_me() -> bool:
	if plyr:
		print(GameManager.convDir_from_Vector(plyr.last_direction))
		return side_detected_on == GameManager.convDir_from_Vector(plyr.last_direction)
	else:
		return false
