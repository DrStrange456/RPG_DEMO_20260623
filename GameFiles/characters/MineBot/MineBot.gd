extends CharacterBody2D

enum entityState {
	IDLE,
	MOVE,
	PICK
}

@export var routine_script: Script
@export var path_to_follow: PathFollow2D

@onready var ScnMgr = cFuncs.get_CurrentScene_ScnMgr()
@onready var animationPlayer = $AnimationPlayer
@onready var animationTree = $AnimationTree
@onready var animationState = animationTree.get("parameters/playback")
@onready var plyr = get_tree().get_first_node_in_group("player")

@onready var path_out = path_to_follow
@onready var currentFacingDir = Vector2.DOWN


var schedule_byDateTime: Dictionary = {
	"6:20 am" : { 0: 1 },  # Idle to Move
	"7:00 am" : { 2: 1 },  # Move to Pick
	"7:40 am" : { 0: 1 },  # Idle to Move
	"8:20 am" : { 2: 1 },  # Move to Pick
}
var schedule_byProgress: Dictionary = {
	"0.55" : { 1: 2 },
}

var state = entityState.IDLE
var speed: float = 0.1
var going_out: bool = true
var curr_position: Vector2
var next_position: Vector2
var routine

# State variables
var start_position: Vector2
var target_position: Vector2
var on_schedule: bool = false


func _ready():
	routine = routine_script.new()
	animationTree.active = true
	state = entityState.IDLE
	#cFuncs.sfx_play("door_opened",$SoundEffect)


func _physics_process(delta):
	match state:
		entityState.IDLE:
			idle_state(delta)
		entityState.MOVE:
			move_state(delta)
		entityState.PICK:
			picking_state(delta)

func _process(_delta):
	routine.sched_check(path_out, self)


### - STATES

func move_state(delta):
	if animationPlayer.is_playing():
		animationPlayer.stop()
	
	animationTree.set("parameters/MOVE/blend_position", currentFacingDir)
	animationState.travel("MOVE")
	
	# Determine facing direction
	if velocity.x > 0 and (velocity.y < 0.5 and velocity.y > -0.5):
		currentFacingDir = Vector2.RIGHT
	elif velocity.x < 0 and (velocity.y < 0.5 and velocity.y > -0.5):
		currentFacingDir = Vector2.LEFT
	elif velocity.y > 0 and (velocity.x < 0.5 and velocity.x > -0.5):
		currentFacingDir = Vector2.DOWN
	elif velocity.y < 0 and (velocity.x < 0.5 and velocity.x > -0.5):
		currentFacingDir = Vector2.UP
	
	move_and_slide()
	runSchedule(delta)

func idle_state(_delta):
	if animationPlayer.is_playing():
		animationPlayer.stop()
	
	animationTree.set("parameters/IDLE/blend_position", currentFacingDir)
	animationState.travel("IDLE")
	velocity = Vector2.ZERO

func picking_state(_delta):
	animationTree.set("parameters/PICK/blend_position", currentFacingDir)
	animationState.travel("PICK")
	velocity = Vector2.ZERO
	
	if !animationPlayer.is_playing():
		match currentFacingDir:
			Vector2.RIGHT:
				animationPlayer.play("pick_right")
			Vector2.LEFT:
				animationPlayer.play("pick_left")
			Vector2.DOWN:
				animationPlayer.play("pick_down")
			Vector2.UP:
				animationPlayer.play("pick_up")


# FUNCTIONS
func runSchedule(delta)->void:
	var increment_ratio = 0.01 # Define how far ahead (in normalized terms).
	var current_ratio = path_out.progress_ratio  # Store current progress ratio
	
	# Temporarily move forward
	curr_position = global_position
	path_out.progress_ratio = min(current_ratio + increment_ratio, 1.0) # Clamp to avoid exceeding the path
	next_position = global_position
	
	path_out.progress_ratio = current_ratio  # Restore the original progress_ratio
	
	if state == entityState.MOVE:
		# proceed along path
		if path_out.progress_ratio < 1: 
			path_out.progress_ratio += delta * speed
	
	velocity = -get_direction(next_position,curr_position).normalized()

func get_direction(ptA: Vector2, ptB: Vector2)->Vector2:
	return ptB-ptA

func Get_SoundPlayer():
	return $SoundEffect

func play_sfx_pickaxe():
	sfx_play("pick_clink_1", $SoundEffect)



# Attaching locally so sound is relative to node near player
func sfx_play(mfile,audio_plyr) -> void:
	if Settings.CONFIG_SOUND_SFX_ENABLED:
		if audio_plyr.is_playing(): audio_plyr.stop()
		audio_plyr.stream = load(Settings.get_SFX_File_Path(mfile))
		audio_plyr.volume_db = -30 + (40 * (Settings.CONFIG_SOUND_SFX) / 100)
		audio_plyr.play()
		await audio_plyr.finished
