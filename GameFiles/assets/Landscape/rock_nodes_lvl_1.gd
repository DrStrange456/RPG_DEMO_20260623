extends rock_base

@warning_ignore("unused_signal")
#signal enemy_death

#const EnemyDeathEffect = preload("res://Entities/Common/enemy_death_effect.tscn")

@onready var rock_type1 = preload("res://assets/Landscape/rock_gray.png")
@onready var rock_type2 = preload("res://Assets/Landscape/rock_gray2.png")

@onready var ScnMgr


func _ready():
	#ScnMgr = Global.find_anywhere("SceneMgr_WhisFalls")
	randomize()
	#connect("enemy_death", Callable(ScnMgr.enemy_killed))
	init_PickMyLook()
	#hitPoints = 1


func init_PickMyLook()->void:
	# Determine if rock type 1 or 2 and direction facing
	rock_texture_check()
	rock_flipped_check()

func rock_texture_check()->void:
	var chnc_type: int = randi_range(1,100)
	if chnc_type <= 50:
		$Sprite2D.texture = rock_type2

func rock_flipped_check()->void:
	var chnc_flipped: int = randi_range(1,100)
	if chnc_flipped <= 50:
		$Sprite2D.flip_h = true

func take_damage(val)->void:
	if is_player_looking_at_me():
		playSound_Rock_Plink()
		hitPoints -= val
		death_check()

func death_check()->void:
	if hitPoints <= 0: 
		rock_died()

func rock_died()->void:
	visible = false
	$CollisionShape2D.disabled = true
	$rock_PlayerDetectionZone.disable_raycasts()
	
	#Init death animation
	play_death_effect()
	
	#Drop Loot and play death sfx
	emit_signal("enemy_death", self)
	playSound_Rock_Crushed()

func play_death_effect()->void:
	#var enemyDeathEffect = EnemyDeathEffect.instantiate()
	#get_parent().add_child(enemyDeathEffect)
	#enemyDeathEffect.global_position = global_position
	pass

func playSound_Rock_Crushed()->void:
	#Cofuns.sfx_play("rock_crushed",$SoundEffect)
	#await $SoundEffect.finished
	queue_free()

func playSound_Rock_Plink()->void:
	#Cofuns.sfx_play("pick_clink_1",$SoundEffect)
	#await $SoundEffect.finished
	print("plink")


### - CONNECTED METHODS

func _on_rock_player_detection_zone_player_detected(body,detection_dir)->void:
	plyr = body
	side_detected_on = detection_dir
