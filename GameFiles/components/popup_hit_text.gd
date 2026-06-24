extends Node2D

@onready var label = $Label

func setValue(val: int):
	if label:
		label.text = str(val)
