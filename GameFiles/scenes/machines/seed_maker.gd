extends StaticBody2D

@export var id: int
@onready var interact_icon: Sprite2D = $imgIcon
var player_within_range: bool = false
var plyr

var output_object = preload("res://resources/seeds_carrot.tres")


enum State {
	IDLE,
	PROCESSING,
	FINISHED
}

var state = State.IDLE

var input_crop
var output_seed
var output_amount

@onready var timer = $Timer


func start_processing(crop):

	if state != State.IDLE:
		return
	
	input_crop = crop
	state = State.PROCESSING
	
	timer.start(2)

func _on_timer_timeout():
	#output_seed = recipes[input_crop.id].seed
	output_seed = output_object
	output_amount = randi_range(1,3)
	print("outputting seed pack: ", output_amount)
	
	state = State.FINISHED

func collect():
	print("collecting seed:")
	state = State.IDLE

func add_seeds():
	# Try to add seeds to inventory
	pass


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
