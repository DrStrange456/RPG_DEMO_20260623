extends Node

signal wave_started(current_wave, total_waves)
signal wave_completed(current_wave)
signal all_waves_completed

signal enemy_count_changed(count)
signal timer_updated(time_left, duration)
signal round_message(text)

@export var spawn_points_path: NodePath
@export var enemy_container_path: NodePath

@onready var spawn_points: Node = get_node(spawn_points_path)
@onready var enemy_container: Node = get_node(enemy_container_path)

@onready var spawn_timer: Timer = $SpawnTimer
@onready var wave_timer: Timer = $WaveTimer
@onready var next_wave_timer: Timer = $NextWaveTimer

@export var spawn_delay := 0.25

var spawn_queue: Array[PackedScene] = []

var current_wave := -1
var enemies_alive := 0

# STATE FLAGS (kept but now strictly controlled)
var wave_running := false
var wave_active := false


const WAVES = [
	{
		"time_limit": 5.0,
		"delay": 3.0,
		"enemies": [
			{"scene": preload("res://characters/bat/bat.tscn"), "count": 5},
		]
	},
	{
		"time_limit": 40.0,
		"delay": 3.0,
		"enemies": [
			{"scene": preload("res://characters/bat/bat.tscn"), "count": 8},
			{"scene": preload("res://characters/bat/bat.tscn"), "count": 2},
		]
	},
	{
		"time_limit": 50.0,
		"delay": 3.0,
		"enemies": [
			{"scene": preload("res://characters/bat/bat.tscn"), "count": 10},
			{"scene": preload("res://characters/bat/bat.tscn"), "count": 8},
			{"scene": preload("res://characters/bat/bat.tscn"), "count": 2},
		]
	},
]


func _ready():
	wave_timer.timeout.connect(_on_wave_timeout)
	next_wave_timer.timeout.connect(_start_next_wave)
	spawn_timer.timeout.connect(_spawn_next_enemy)
	start()


func start():
	current_wave = -1
	_start_next_wave()


# ------------------------
# START WAVE
# ------------------------
func _start_next_wave():

	current_wave += 1

	if current_wave >= WAVES.size():
		wave_running = false
		all_waves_completed.emit()
		return

	var wave = WAVES[current_wave]

	enemies_alive = 0

	# FIX: consistent state start
	wave_active = true
	wave_running = true

	wave_started.emit(current_wave + 1, WAVES.size())
	enemy_count_changed.emit(enemies_alive)
	round_message.emit("Wave %d" % (current_wave + 1))

	_spawn_wave(wave)

	wave_timer.start(wave.time_limit)


# ------------------------
# TIMER UPDATE
# ------------------------
func _process(_delta):

	if not wave_running:
		return

	timer_updated.emit(
		wave_timer.time_left,
		WAVES[current_wave].time_limit
	)


# ------------------------
# SPAWN SYSTEM
# ------------------------
func _spawn_wave(wave):

	spawn_queue.clear()

	for enemy_data in wave.enemies:
		for i in enemy_data.count:
			spawn_queue.append(enemy_data.scene)

	spawn_queue.shuffle()

	spawn_timer.wait_time = spawn_delay
	spawn_timer.start()


func _spawn_next_enemy():

	if not wave_active:
		return

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
	enemy_count_changed.emit(enemies_alive)

	if enemy.has_signal("died"):
		enemy.died.connect(enemy_died)


# ------------------------
# ENEMY DEATH
# ------------------------
func enemy_died():

	# HARD GUARD: prevents post-wave cleanup corruption
	if not wave_active:
		return

	enemies_alive -= 1
	enemies_alive = max(enemies_alive, 0)

	enemy_count_changed.emit(enemies_alive)

	if enemies_alive <= 0 and wave_active:
		_finish_wave(false)


# ------------------------
# WAVE END
# ------------------------
func _on_wave_timeout():
	_finish_wave(true) # failure


func _finish_wave(failed := false):

	if not wave_active:
		return

	# LOCK IMMEDIATELY to prevent late signals
	wave_active = false
	wave_running = false

	wave_timer.stop()
	spawn_timer.stop()

	if failed:
		_kill_all_enemies()
		enemies_alive = 0
		enemy_count_changed.emit(0)

	if failed:
		round_message.emit("Wave Failed")
	else:
		round_message.emit("Victory!")

	wave_completed.emit(current_wave + 1)

	next_wave_timer.start(WAVES[current_wave].delay)


# ------------------------
# CLEANUP
# ------------------------
func _kill_all_enemies():

	var enemies = enemy_container.get_children()

	for e in enemies:
		if is_instance_valid(e):
			if e.has_method("die"):
				e.die()
			else:
				e.queue_free()
