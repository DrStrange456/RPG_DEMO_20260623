extends Node

signal wave_started(current_wave, total_waves)
signal wave_completed(current_wave)
signal all_waves_completed

signal enemy_count_changed(count)
signal timer_updated(time_left, duration)
signal round_message(text)

@export var spawn_areas_path: NodePath
@export var enemy_container_path: NodePath
@export var spawn_delay := 0.25

@onready var spawn_areas: Node = get_node(spawn_areas_path)
@onready var enemy_container: Node = get_node(enemy_container_path)

@onready var spawn_timer: Timer = $SpawnTimer
@onready var wave_timer: Timer = $WaveTimer
@onready var next_wave_timer: Timer = $NextWaveTimer


var spawn_queue: Array[PackedScene] = []

var current_wave := -1
var enemies_alive := 0

var wave_running := false
var wave_active := false


const WAVES = [
	{
		"time_limit":30.0,
		"delay": 3.0,
		"enemies": [
			#{"scene": preload("res://characters/bat/bat.tscn"), "count": 5},
			{"scene": preload("res://characters/mud_man/mud_man.tscn"), 
			"count": 5},
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


# ---------------------------------------------------
# WAVE START
# ---------------------------------------------------
func _start_next_wave():

	current_wave += 1

	if current_wave >= WAVES.size():
		wave_running = false
		wave_active = false
		all_waves_completed.emit()
		return

	var wave = WAVES[current_wave]

	enemies_alive = 0

	wave_active = true
	wave_running = true

	wave_started.emit(current_wave + 1, WAVES.size())
	enemy_count_changed.emit(enemies_alive)
	round_message.emit("Wave %d" % (current_wave + 1))

	_spawn_wave(wave)

	wave_timer.start(wave.time_limit)


# ---------------------------------------------------
# TIMER UI UPDATE
# ---------------------------------------------------
func _process(_delta):

	if not wave_running:
		return

	timer_updated.emit(
		wave_timer.time_left,
		WAVES[current_wave].time_limit
	)


# ---------------------------------------------------
# SPAWNING SYSTEM
# ---------------------------------------------------
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

	enemy.global_position = get_random_spawn_position()

	enemy_container.add_child(enemy)

	enemies_alive += 1
	enemy_count_changed.emit(enemies_alive)

	if enemy.has_signal("died"):
		enemy.died.connect(enemy_died)


# ---------------------------------------------------
# ENEMY DEATH
# ---------------------------------------------------
func enemy_died():

	if not wave_active:
		return

	enemies_alive -= 1
	enemies_alive = max(enemies_alive, 0)

	enemy_count_changed.emit(enemies_alive)

	if enemies_alive <= 0 and wave_active:
		_finish_wave(false)


# ---------------------------------------------------
# WAVE END
# ---------------------------------------------------
func _on_wave_timeout():
	_finish_wave(true)


func _finish_wave(failed := false):

	if not wave_active:
		return

	wave_active = false
	wave_running = false

	wave_timer.stop()
	spawn_timer.stop()

	if failed:
		_kill_all_enemies()
		enemies_alive = 0
		enemy_count_changed.emit(0)

	round_message.emit("Wave Failed" if failed else "Victory!")

	wave_completed.emit(current_wave + 1)

	next_wave_timer.start(WAVES[current_wave].delay)


# ---------------------------------------------------
# CLEANUP
# ---------------------------------------------------
func _kill_all_enemies():

	var enemies = enemy_container.get_children()

	for e in enemies:
		if is_instance_valid(e):
			if e.has_method("die"):
				e.die()
			else:
				e.queue_free()


# ---------------------------------------------------
# SPAWN AREA LOGIC
# ---------------------------------------------------
func get_random_spawn_position() -> Vector2:

	var areas = spawn_areas.get_children()

	if areas.is_empty():
		push_error("No spawn areas found!")
		return Vector2.ZERO

	var area: Area2D = areas.pick_random()

	var shape: CollisionShape2D = area.get_node("CollisionShape2D")

	if shape.shape is RectangleShape2D:

		var rect := shape.shape as RectangleShape2D
		var half := rect.size * 0.5

		var local_pos = Vector2(
			randf_range(-half.x, half.x),
			randf_range(-half.y, half.y)
		)

		return area.to_global(local_pos)

	elif shape.shape is CircleShape2D:

		var circle := shape.shape as CircleShape2D

		var angle = randf() * TAU
		var radius = sqrt(randf()) * circle.radius

		var local_pos = Vector2.RIGHT.rotated(angle) * radius

		return area.to_global(local_pos)

	return area.global_position
