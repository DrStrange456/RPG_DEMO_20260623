extends rock_base

const EnemyDeathEffect = preload("res://Entities/Common/enemy_death_effect.tscn")

@onready var lootTemplate = preload("res://Scene_Objects/Items/item_drop_collectable.tscn")
@onready var ScnMgr = SceneFuncs.get_CurrentScene_ScnMgr()
@onready var sound_effect = $SoundEffect

func _ready():
	hitPoints = 2

func _on_rock_player_detection_zone_player_detected(body,detection_dir):
	plyr = body
	side_detected_on = detection_dir

func take_damage(val):
	if is_player_looking_at_me():
		hitPoints -= val
		death_check()

func death_check():
	if hitPoints <= 0: 
		rock_died()
	else:
		#play clink sound
		var sfx_file = load("res://Audio/SFX/hoe.wav")
		sound_effect.volume_db = 1
		sound_effect.stream = sfx_file
		sound_effect.pitch_scale = randf_range(0.8, 1.2)
		if !sound_effect.playing: sound_effect.play()

func rock_died():
	visible = false
	$CollisionShape2D.disabled = true
	$rock_PlayerDetectionZone.disable_raycasts()
	
	#Play Death Effect
	var enemyDeathEffect = EnemyDeathEffect.instantiate()
	get_parent().add_child(enemyDeathEffect)
	enemyDeathEffect.global_position = global_position
	
	#Drop Loot
	var loot_chances = randf_range(0.0, 100)
	if loot_chances <= 12.5:
		var newObject = lootTemplate.instantiate()
		newObject.setTexture("res://Art_Assets/Items/" + "wood" + ".png")
		newObject.global_position = global_position
		get_parent().add_child(newObject)
	
	#Play explode sfx
	var sfx_file = load("res://Audio/SFX/hammer.wav")
	sound_effect.volume_db = 1
	sound_effect.stream = sfx_file
	sound_effect.pitch_scale = randf_range(0.8, 1.2)
	if !sound_effect.playing: sound_effect.play()
	await sound_effect.finished
	queue_free()
