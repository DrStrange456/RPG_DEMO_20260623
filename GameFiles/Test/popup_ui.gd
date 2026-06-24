class_name popup_ui
extends Control

@export var toggle_action := "toggle_popup"

# Opening animation
@export var pop_in_duration := 0.16
@export var settle_duration := 0.08

# Closing animation
@export var anticipation_duration := 0.05
@export var pop_out_duration := 0.12

# Idle animation
@export var idle_float_amount := 3.0
@export var idle_scale_amount := 1.03
@export var idle_duration := 0.75

@onready var popup: Control = $PopupRoot

var is_open := false

var active_tween: Tween
var idle_tween: Tween

var base_position: Vector2
var base_scale := Vector2.ONE


func _ready() -> void:
	# Wait one frame so PopupRoot has its final size
	await get_tree().process_frame

	# Scale from the center of the inventory window
	popup.pivot_offset = popup.size * 0.5

	base_position = popup.position

	visible = false

	popup.position = base_position
	popup.scale = Vector2.ZERO
	popup.modulate.a = 0.0
	
	var method_name := "initialize"
	
	if has_method(method_name):
		call(method_name)


func _unhandled_input(event: InputEvent) -> void:
	if toggle_action == "": return
	if event.is_action_pressed(toggle_action):
		toggle_popup()


func toggle_popup() -> void:
	if is_open:
		close_popup()
	else:
		open_popup()


func open_popup() -> void:
	is_open = true

	kill_tweens()

	visible = true

	# Start slightly tall and narrow
	popup.position = base_position
	popup.scale = Vector2(0.8, 1.2)
	popup.modulate.a = 0.0

	active_tween = create_tween()

	#
	# POP
	#
	active_tween.set_parallel()

	active_tween.tween_property(
		popup,
		"scale",
		Vector2(1.10, 0.95),
		pop_in_duration
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	active_tween.tween_property(
		popup,
		"modulate:a",
		1.0,
		pop_in_duration
	)

	#
	# SETTLE
	#
	active_tween.chain()

	active_tween.tween_property(
		popup,
		"scale",
		base_scale,
		settle_duration
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	await active_tween.finished

	if is_open:
		start_idle()


func close_popup() -> void:
	is_open = false

	kill_tweens()

	active_tween = create_tween()

	#
	# ANTICIPATION
	#
	active_tween.tween_property(
		popup,
		"scale",
		Vector2(1.08, 0.92),
		anticipation_duration
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	#
	# POP AWAY
	#
	active_tween.chain()
	active_tween.set_parallel()

	active_tween.tween_property(
		popup,
		"scale",
		Vector2(1.20, 0.0),
		pop_out_duration
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)

	active_tween.tween_property(
		popup,
		"modulate:a",
		0.0,
		pop_out_duration
	)

	await active_tween.finished

	if !is_open:
		visible = false

		popup.position = base_position
		popup.scale = Vector2.ZERO
		popup.modulate.a = 0.0


func start_idle() -> void:
	idle_tween = create_tween()
	idle_tween.set_loops()

	#
	# FLOAT UP / GROW
	#
	idle_tween.set_parallel()

	idle_tween.tween_property(
		popup,
		"position:y",
		base_position.y - idle_float_amount,
		idle_duration
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	idle_tween.tween_property(
		popup,
		"scale",
		base_scale * idle_scale_amount,
		idle_duration
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	#
	# FLOAT DOWN / SHRINK
	#
	idle_tween.chain()
	idle_tween.set_parallel()

	idle_tween.tween_property(
		popup,
		"position:y",
		base_position.y,
		idle_duration
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	idle_tween.tween_property(
		popup,
		"scale",
		base_scale,
		idle_duration
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func kill_tweens() -> void:
	if active_tween:
		active_tween.kill()
		active_tween = null

	if idle_tween:
		idle_tween.kill()
		idle_tween = null
