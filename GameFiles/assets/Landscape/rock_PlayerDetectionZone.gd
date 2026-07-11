extends Node2D

@warning_ignore("unused_signal")
signal player_detected

var plyr
var plyr_direction: String

func _process(_delta):
	if $rc_LEFT.is_colliding():
		plyr = $rc_LEFT.get_collider()
		plyr_direction = "LEFT"
	elif $rc_RIGHT.is_colliding():
		plyr = $rc_RIGHT.get_collider()
		plyr_direction = "RIGHT"
	elif $rc_UP.is_colliding():
		plyr = $rc_UP.get_collider()
		plyr_direction = "DOWN"
	elif $rc_DOWN.is_colliding():
		plyr = $rc_DOWN.get_collider()
		plyr_direction = "UP"
	else:
		plyr = null
		plyr_direction = ""
	
	if plyr != null:
		emit_signal("player_detected", plyr, plyr_direction)
	else:
		emit_signal("player_detected", null, plyr_direction)

func disable_raycasts():
	$rc_DOWN.enabled = false
	$rc_LEFT.enabled = false
	$rc_RIGHT.enabled = false
	$rc_UP.enabled = false
	plyr = null
