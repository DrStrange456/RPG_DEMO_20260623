extends Node

var launch_time := 0

func _init():
	launch_time = Time.get_ticks_msec()

func _ready() -> void:
	print("Autoloads started: ",
		Time.get_ticks_msec() - StartupTimer.launch_time,
		" ms")
