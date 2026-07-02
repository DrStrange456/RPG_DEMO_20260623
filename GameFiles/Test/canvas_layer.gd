extends CanvasLayer

@onready var wave_label: Label = $MarginContainer/VBoxContainer/WaveLabel
@onready var enemy_label: Label = $MarginContainer/VBoxContainer/EnemyLabel
@onready var time_label: Label = $MarginContainer/VBoxContainer/TimeLabel
@onready var timer_bar: ProgressBar = $MarginContainer/VBoxContainer/WaveTimerBar
@onready var round_message: Label = $CenterContainer/RoundMessage

@onready var wave_manager = get_node("../WaveManager")


func _ready():

	# Connect signals from WaveManager
	wave_manager.wave_started.connect(_on_wave_started)
	wave_manager.enemy_count_changed.connect(_on_enemy_count_changed)
	wave_manager.timer_updated.connect(_on_timer_updated)
	wave_manager.round_message.connect(_on_round_message)


# -------------------------
# SIGNAL HANDLERS
# -------------------------

func _on_wave_started(current: int, total: int) -> void:
	wave_label.text = "Wave %d / %d" % [current, total]


func _on_enemy_count_changed(count: int) -> void:
	enemy_label.text = "Enemies Remaining: %d" % count


func _on_timer_updated(time_left: float, duration: float) -> void:

	time_label.text = "Time: %d" % ceil(time_left)

	if duration > 0:
		timer_bar.value = (time_left / duration) * 100.0


func _on_round_message(text: String) -> void:

	round_message.text = text
	round_message.visible = true

	await get_tree().create_timer(2.0).timeout
	round_message.visible = false
