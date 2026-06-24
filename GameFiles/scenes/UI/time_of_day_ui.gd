extends Control


@onready var day_label_background: Label = %DayLabelBackground
@onready var day_label: Label = %DayLabel
@onready var time_label_background: Label = %TimeLabelBackground
@onready var time_label: Label = %TimeLabel



func set_daytime(day: int, hour: int, minute: int) -> void:
	day_label.text = "Day " + str(day + 1)
	day_label_background.text = day_label.text
	
	time_label.text = _amfm_hour(hour) + ":" + _minute(minute) + " " + _am_pm(hour)
	time_label_background.text = time_label.text
	
	# Update Global TIME/DATE variables
	GameManager.gl_TIME = time_label.text
	GameManager.gl_DATE = day_label.text

func _amfm_hour(hour:int) -> String:
	if hour == 0:
		return str(12)
	if hour > 12:
		return str(hour - 12)
	return str(hour)

func _minute(minute:int) -> String:
	if minute < 10:
		return "0" + str(minute)
	return str(minute)

func _am_pm(hour:int) -> String:
	if hour < 12:
		return "am"
	else:
		return "pm"

func _remap_rangef(input:float, minInput:float, maxInput:float, minOutput:float, maxOutput:float):
	return float(input - minInput) / float(maxInput - minInput) * float(maxOutput - minOutput) + minOutput
