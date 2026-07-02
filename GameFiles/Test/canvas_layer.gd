extends CanvasLayer

@onready var wave_label: Label = $MarginContainer/VBoxContainer/WaveLabel
@onready var enemy_label: Label = $MarginContainer/VBoxContainer/EnemyLabel
@onready var time_label: Label = $MarginContainer/VBoxContainer/TimeLabel
@onready var timer_bar: ProgressBar = $MarginContainer/VBoxContainer/WaveTimerBar

@onready var round_message: Label = $CenterContainer/RoundMessage



func set_wave(current:int, total:int) -> void:
	if wave_label:
		wave_label.text = "Wave %d / %d" % [current, total]


func set_enemy_count(count:int) -> void:
	if enemy_label:
		enemy_label.text = "Enemies Remaining: %d" % count


func set_time(seconds:float) -> void:
	if time_label:
		time_label.text = "Time: %d" % ceil(seconds)


func set_timer_percent(percent:float) -> void:
	if timer_bar:
		timer_bar.value = clamp(percent, 0, 100)


func show_round_message(text: String):

	round_message.text = text
	round_message.visible = true

	await get_tree().create_timer(2.0).timeout

	round_message.visible = false



# Bottom
