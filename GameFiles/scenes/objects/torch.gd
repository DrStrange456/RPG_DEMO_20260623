@tool
extends Node2D


@export var toggle_light: bool = true:
	set(value):
		toggle_light = value

		if is_node_ready():
			point_light_2d.enabled = value


@export_range(0.0, 5.0)
var energy: float = 1.0:
	set(value):
		energy = value

		if is_node_ready():
			target_energy = value


@export_range(0.0, 3.0)
var txtr_scale: float = 1.0:
	set(value):
		txtr_scale = value

		if is_node_ready():
			target_scale = value


@export_enum("add", "subtract", "mix")
var blend: String = "add"

@export var light_mask_value: int = 1:
	set(value):
		light_mask_value = value

		if is_node_ready():
			point_light_2d.light_mask = value


@export var cull_mask_value: int = 1:
	set(value):
		cull_mask_value = value

		if is_node_ready():
			point_light_2d.range_item_cull_mask = value


@export var flame_color: Color = Color.WHITE:
	set(value):
		flame_color = value

		if is_node_ready():
			point_light_2d.color = value


# ---------------------------------
# Flicker Settings
# ---------------------------------

@export var flicker_enabled: bool = true

# Percentage variation
# 0.15 = ±15%
@export_range(0.0, 1.0)
var energy_variation: float = 0.15

@export_range(0.0, 1.0)
var scale_variation: float = 0.05

@export_range(0.0, 20.0)
var flicker_speed: float = 10.0


@onready var point_light_2d: PointLight2D = $PointLight2D
@onready var flicker_timer: Timer = $FlickerTimer

var player_within_range: bool = false
var plyr

var target_energy: float
var target_scale: float


func _ready() -> void:
	randomize()

	point_light_2d.enabled = toggle_light
	point_light_2d.light_mask = light_mask_value
	point_light_2d.range_item_cull_mask = cull_mask_value
	point_light_2d.color = flame_color

	target_energy = energy
	target_scale = txtr_scale

	point_light_2d.energy = energy
	point_light_2d.texture_scale = txtr_scale

	if flicker_timer:
		# Each torch gets a slightly different speed
		flicker_timer.wait_time = randf_range(0.04, 0.08)

		# Start with a random delay
		await get_tree().create_timer(
			randf_range(0.0, 0.25)
		).timeout

		flicker_timer.start()


func _process(delta: float) -> void:
	if !toggle_light:
		return

	if flicker_enabled:
		point_light_2d.energy = lerpf(
			point_light_2d.energy,
			target_energy,
			flicker_speed * delta
		)

		point_light_2d.texture_scale = lerpf(
			point_light_2d.texture_scale,
			target_scale,
			flicker_speed * delta
		)
	else:
		point_light_2d.energy = energy
		point_light_2d.texture_scale = txtr_scale


func _on_flicker_timer_timeout() -> void:
	if !flicker_enabled:
		return

	# Energy varies around current Energy value
	var energy_min = energy * (1.0 - energy_variation)
	var energy_max = energy * (1.0 + energy_variation)

	target_energy = randf_range(
		energy_min,
		energy_max
	)

	# Radius varies around current Scale value
	var scale_min = txtr_scale * (1.0 - scale_variation)
	var scale_max = txtr_scale * (1.0 + scale_variation)

	target_scale = randf_range(
		scale_min,
		scale_max
	)


func _on_i_zone_body_entered(body):
	if body.is_in_group("player"):
		$Interact_Icon.visible = true
		player_within_range = true
		plyr = body


func _on_i_zone_body_exited(body):
	if body.is_in_group("player"):
		$Interact_Icon.visible = false
		player_within_range = false
		plyr = body
