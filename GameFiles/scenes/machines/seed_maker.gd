extends StaticBody2D

signal processing_started
signal seed_produced
signal processing_finished
signal seeds_collected
signal state_changed

@export var id: int
@export var process_time := 3.0

@onready var interact_icon: Sprite2D = $imgIcon
@onready var timer: Timer = $Timer

var player_within_range := false
var plyr


enum State {
	IDLE,
	PROCESSING
}

var state: State = State.IDLE

var input_crop = null
var output_seed = null

# Number of crops still waiting to process.
var crops_remaining := 0

# Number of finished seed packs waiting to be collected.
var seeds_ready := 0


func start_processing(crop, amount: int) -> void:

	if amount <= 0:
		return

	# Already processing
	if state == State.PROCESSING:

		# Allow adding more of the same crop.
		if crop == input_crop:
			crops_remaining += amount
			print("Added ", amount, " more crops.")
			emit_signal("state_changed")
			return

		print("Machine is already processing another crop.")
		return

	input_crop = crop
	output_seed = crop.to_seed

	crops_remaining = amount
	seeds_ready = 0

	state = State.PROCESSING

	timer.start(process_time)

	emit_signal("processing_started")
	emit_signal("state_changed")


func _on_timer_timeout() -> void:

	if crops_remaining <= 0:
		return

	# Consume one crop.
	crops_remaining -= 1

	# Produce one seed pack.
	seeds_ready += 1

	print("Seed pack produced.")
	print("Remaining crops: ", crops_remaining)
	print("Seeds waiting: ", seeds_ready)

	emit_signal("seed_produced")
	emit_signal("state_changed")

	# Continue if more crops remain.
	if crops_remaining > 0:
		timer.start(process_time)
	else:
		print("Processing complete.")
		input_crop = null
		emit_signal("processing_finished")


func collect() -> void:

	if seeds_ready == 0:
		print("Nothing to collect.")
		return

	# TODO: should only pickup if can fit all into storage.
	#var left_over: int = StorageManager.try_add_item_to_inventory(GmMgr.PLAYER_INVENTORY_TEST_LARGE, output_seed.name, seeds_ready)
	
	# FIXME: Add to inventory not working quite right
	#var left_over: int = InvCore._add_item_to_inventory(InvCore.DATA, output_seed.name, seeds_ready)

	print("Collected ", seeds_ready, " seed packs.")

	seeds_ready = 0

	emit_signal("seeds_collected")
	emit_signal("state_changed")

	update_machine_state()


func update_machine_state() -> void:

	# Machine becomes idle only after:
	# 1. Every crop has been processed.
	# 2. Every produced seed pack has been collected.
	if crops_remaining == 0 and seeds_ready == 0:

		timer.stop()

		input_crop = null
		output_seed = null

		state = State.IDLE

		print("Seed Maker is idle.")

		emit_signal("state_changed")



func _ready():
	interact_icon.visible = false

func _input(_event: InputEvent) -> void:
	if plyr and player_within_range:
		if Input.is_action_just_pressed("activate"):
			UiManager.active_ui = self
			Events.emit_signal("try_interact_seed_maker")
			get_viewport().set_input_as_handled()  # Mark event as handled

func _on_interaction_collider_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		interact_icon.visible = true
		player_within_range = true
		plyr = body

func _on_interaction_collider_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		interact_icon.visible = false
		player_within_range = false
		plyr = body




#@export var ui_scene: PackedScene

#var ui_instance
#
#func interact():
	#if ui_instance == null:
		#ui_instance = ui_scene.instantiate()
		#get_tree().current_scene.add_child(ui_instance)
#
	#ui_instance.open(self)


# Bottom
