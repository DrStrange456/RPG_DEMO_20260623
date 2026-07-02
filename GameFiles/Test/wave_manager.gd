extends Node

signal wave_started(wave_number)
signal wave_completed(wave_number)
signal all_waves_completed()

@export var spawn_points_path: NodePath
@export var enemy_container_path: NodePath

@onready var spawn_points: Node = get_node(spawn_points_path)
@onready var enemy_container: Node = get_node(enemy_container_path)
@onready var spawn_timer: Timer = $SpawnTimer

var spawn_queue: Array[PackedScene] = []

@export var spawn_delay := 0.25

@export var ui_path: NodePath
@onready var ui = get_node(ui_path)

const TOTAL_WAVES := 5


const WAVES = [
{
	"time_limit": 30.0,
	"delay": 3.0,
	"enemies":
	[
		{"scene": preload("res://characters/bat/bat.tscn"), "count": 5},
	]
},
{
	"time_limit": 40.0,
	"delay": 3.0,
	"enemies":
	[
		{"scene": preload("res://characters/bat/bat.tscn"), "count": 8},
		{"scene": preload("res://characters/bat/bat.tscn"), "count": 2},
	]
},
{
	"time_limit": 50.0,
	"delay": 3.0,
	"enemies":
	[
		{"scene": preload("res://characters/bat/bat.tscn"), "count": 10},
		 {"scene": preload("res://characters/bat/bat.tscn"), "count": 8},
		{"scene": preload("res://characters/bat/bat.tscn"), "count": 2},
	]
},
]


@onready var wave_timer: Timer = $WaveTimer
@onready var next_wave_timer: Timer = $NextWaveTimer

var current_wave := -1
var enemies_alive := 0
var wave_running := false

func _ready():

	wave_timer.timeout.connect(_on_wave_timeout)
	next_wave_timer.timeout.connect(_start_next_wave)
	spawn_timer.timeout.connect(_spawn_next_enemy)

	start()

func _process(_delta):

	if wave_running:

		ui.set_time(wave_timer.time_left)

		var wave_time = WAVES[current_wave].time_limit

		ui.set_timer_percent(
			(wave_timer.time_left / wave_time) * 100.0
		)

func start():

	current_wave = -1
	_start_next_wave()

func _start_next_wave():

	current_wave += 1

	if current_wave >= WAVES.size():
		wave_running = false
		all_waves_completed.emit()
		return

	var wave = WAVES[current_wave]

	enemies_alive = 0
	wave_running = true

	_spawn_wave(wave)

	wave_timer.start(wave.time_limit)

	wave_started.emit(current_wave + 1)
	
	ui.set_wave(current_wave + 1, WAVES.size())
	ui.set_enemy_count(enemies_alive)

func _spawn_wave(wave):

	spawn_queue.clear()

	for enemy_data in wave.enemies:

		for i in enemy_data.count:
			spawn_queue.append(enemy_data.scene)

	spawn_queue.shuffle()

	spawn_timer.wait_time = spawn_delay
	spawn_timer.start()

func _spawn_next_enemy():

	if spawn_queue.is_empty():

		spawn_timer.stop()
		return

	var scene = spawn_queue.pop_front()

	spawn_enemy(scene)

func spawn_enemy(enemy_scene: PackedScene):

	var enemy = enemy_scene.instantiate()

	var markers := spawn_points.get_children()

	if markers.is_empty():
		push_error("WaveManager: No spawn points found!")
		return

	var marker: Marker2D = markers.pick_random()

	enemy.global_position = marker.global_position

	enemy_container.add_child(enemy)

	enemies_alive += 1

	# Listen for the enemy's death signal
	if enemy.has_signal("died"):
		enemy.died.connect(enemy_died)
	
	ui.set_enemy_count(enemies_alive)

func enemy_died():

	if !wave_running:
		return

	enemies_alive -= 1

	if enemies_alive <= 0:
		_finish_wave()
	
	ui.set_enemy_count(enemies_alive)

func _on_wave_timeout():

	_finish_wave()

func _finish_wave():


	if !wave_running:
		return

	wave_running = false

	wave_timer.stop()

	wave_completed.emit(current_wave + 1)

	var delay = WAVES[current_wave].delay

	next_wave_timer.start(delay)
	
	ui.show_round_message("Victory!")
