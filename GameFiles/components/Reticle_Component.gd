#class_name Reticle_Component
extends Node2D

const LEFT: Vector2 = Vector2(-16,0)
const RIGHT: Vector2 = Vector2(16,0)
const UP: Vector2 = Vector2(0,-16)
const DOWN: Vector2 = Vector2(0,16)


# CROPS
@onready var ray_cast_pivot: Node2D = $RayCast_Pivot
@onready var rc_crop_det_1: RayCast2D = $RayCast_Pivot/rcCROP_DET1
@onready var rc_crop_det_2: RayCast2D = $RayCast_Pivot/rcCROP_DET2
@onready var rc_crop_det_3: RayCast2D = $RayCast_Pivot/rcCROP_DET3
@onready var rc_ia_det_4: RayCast2D = $RayCast_Pivot/rcIA_DET4
@onready var crops_detected_flag: bool = false
var rcDET_CROP = [rc_crop_det_1,rc_crop_det_2,rc_crop_det_3]

var isReticleVisible: bool = false



func _ready():
	setReticle_FacingDir("down")
	ray_cast_pivot.visible = true

func _physics_process(_delta: float) -> void:
	does_player_see_crops()



func init_detectors_toFalse():
	ray_cast_pivot.visible = false


## CROPS
func does_player_see_crops():
	rcDET_CROP = [rc_crop_det_1,rc_crop_det_2,rc_crop_det_3]
	crops_detected_flag = are_any_rays_colliding(rcDET_CROP)
			
func are_any_rays_colliding(rays: Array)->bool:
	for ray in rays:
		if ray is RayCast2D and ray.is_colliding():
			GameManager.glPlayerRef.plant_detected(ray.get_collider())
			return true
	if is_instance_valid(GameManager.glPlayerRef):
		if GameManager.glPlayerRef.plants_detected():
			GameManager.glPlayerRef.plant_not_detected()
	return false

## PICKUP ZONE



## IA ZONE
func is_IA_colliding():
	return rc_ia_det_4.is_colliding()

func IA():
	return rc_ia_det_4


func getHitLocation() -> Vector2:
	return $ReticleTracker.global_position + $ReticleTracker.offset

func getReticleOffset() -> Vector2:
	return $ReticleTracker.offset

func getReticle_Visibility() -> bool:
	return isReticleVisible

func getReticle() -> Node:
	return $Tool_Reticle


func setReticle_FacingDir(dir) -> void:
	match dir:
		"left":
			$ReticleTracker.offset = LEFT
			ray_cast_pivot.rotation_degrees = 180
			ray_cast_pivot.position.y = 0
			ray_cast_pivot.position.x = 0
		"right":
			$ReticleTracker.offset = RIGHT
			ray_cast_pivot.rotation_degrees = 0
			ray_cast_pivot.position.y = 0
			ray_cast_pivot.position.x = 0
		"up":
			$ReticleTracker.offset = UP
			ray_cast_pivot.rotation_degrees = -90
			ray_cast_pivot.position.y = 0
			ray_cast_pivot.position.x = 0
		"down":
			$ReticleTracker.offset = DOWN
			ray_cast_pivot.rotation_degrees = 90
			ray_cast_pivot.position.y = 0
			ray_cast_pivot.position.x = 0

func _setToolVisibility(val) -> void:
	isReticleVisible = !val
	if val:
		$Tool_Reticle.self_modulate.a = 1
	else:
		$Tool_Reticle.self_modulate.a = 0

func setReticleLocation(loc: Vector2) -> void:
	$Tool_Reticle.global_position = loc




# Bottom
