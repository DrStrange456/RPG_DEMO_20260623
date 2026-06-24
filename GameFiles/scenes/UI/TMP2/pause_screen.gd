extends Control

@onready var player_inventory_ui: Control = $PlayerInventoryUI
@onready var settings_ui: Control = $SettingsUI
@onready var video_ui: Control = $VideoUI
@onready var sound_ui: Control = $SoundUI

@onready var btn_inventory: Button = $btnINVENTORY
@onready var btn_settings: Button = $btnSETTINGS
@onready var btn_back: Button = $btnBACK
@onready var btn_settings_video: Button = $SettingsUI/btnSETTINGS_VIDEO
@onready var btn_settings_audio: Button = $SettingsUI/btnSETTINGS_AUDIO

@onready var btn_back_video: Button = $VideoUI/btnBACK_VIDEO
@onready var btn_back_sound: Button = $SoundUI/btnBACK_SOUND


@onready var music_sample: AudioStreamPlayer2D = $Sounds/Music_Sample
@onready var sfx_sample: AudioStreamPlayer2D = $Sounds/SFX_Sample



var is_vsync_enabled: bool = false
var prev_state

enum State {DEFAULT,INVENTORY,SETTINGS,VIDEO,AUDIO}
var ps_state 

func _ready() -> void:
	$SoundUI/sfx_volume.value = 50
	$SoundUI/music_volume.value = 50
	ps_state = State.DEFAULT

func _process(_delta: float) -> void:
	match ps_state:
		State.DEFAULT:
			default_state()
		State.INVENTORY:
			inventory_state()
		State.SETTINGS:
			settings_state()
		State.VIDEO:
			settings_video()
		State.AUDIO:
			settings_audio()


func default_state():
	btn_inventory.visible = true
	btn_settings.visible = true
	btn_back.visible = true
	
	player_inventory_ui.visible = false
	settings_ui.visible = false
	video_ui.visible = false
	sound_ui.visible = false
	
	btn_back_video.visible = false
	btn_back_sound.visible = false

func inventory_state():
	btn_inventory.visible = false
	btn_settings.visible = false
	btn_back.visible = true
	
	btn_back_video.visible = false
	btn_back_sound.visible = false
	
	player_inventory_ui.visible = true
	settings_ui.visible = false
	video_ui.visible = false
	sound_ui.visible = false

func settings_state():
	btn_inventory.visible = false
	btn_settings.visible = false
	btn_back.visible = true
	
	btn_back_video.visible = false
	btn_back_sound.visible = false
	
	player_inventory_ui.visible = false
	settings_ui.visible = true
	video_ui.visible = false
	sound_ui.visible = false

func settings_video():
	btn_inventory.visible = false
	btn_settings.visible = false
	btn_back.visible = false
	
	btn_back_video.visible = true
	btn_back_sound.visible = false
	
	player_inventory_ui.visible = false
	settings_ui.visible = false
	video_ui.visible = true
	sound_ui.visible = false

func settings_audio():
	btn_inventory.visible = false
	btn_settings.visible = false
	btn_back.visible = false
	
	btn_back_video.visible = false
	btn_back_sound.visible = true
	
	player_inventory_ui.visible = false
	settings_ui.visible = false
	video_ui.visible = false
	sound_ui.visible = true







func _on_btn_inventory_pressed() -> void:
	prev_state = ps_state
	ps_state = State.INVENTORY

func _on_btn_settings_pressed() -> void:
	prev_state = ps_state
	ps_state = State.SETTINGS

func _on_btn_settings_video_pressed() -> void:
	ps_state = State.VIDEO

func _on_btn_settings_audio_pressed() -> void:
	ps_state = State.AUDIO

func _on_btn_back_pressed() -> void:
	ps_state = prev_state
	if sfx_sample.playing: sfx_sample.stop()
	if music_sample.playing: music_sample.stop()

func _on_btn_back_video_pressed() -> void:
	ps_state = State.SETTINGS

func _on_btn_back_sound_pressed() -> void:
	ps_state = State.SETTINGS






### - Video Options
func _on_drop_window_mode_item_selected(index: int) -> void:
	print("Selected:", index)
	print(DisplayServer.window_get_mode())
	match index:
		0:
			apply_window_mode("windowed")
		1:
			apply_window_mode("borderless")
		2:
			apply_window_mode("fullscreen")

func _on_check_box_pressed() -> void:
	if is_vsync_enabled:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
		is_vsync_enabled = false
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
		is_vsync_enabled = true

func _on_dropdown_reso_item_selected(index: int) -> void:
	match index:
		0:  #480x270
			DisplayServer.window_set_size(Vector2i(480,270))
		1:  #640x360
			DisplayServer.window_set_size(Vector2i(640,360))
		2:  #1280x600
			DisplayServer.window_set_size(Vector2i(1280,600))
		3:  #1920x1080
			DisplayServer.window_set_size(Vector2i(1920,1080))

func apply_window_mode(mode: String):
	var was_paused = get_tree().paused
	get_tree().paused = false  # ensures OS updates apply

	match mode:
		"windowed":
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)

		"borderless":
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)

			# Make it fill the screen
			var screen_size = DisplayServer.screen_get_size()
			DisplayServer.window_set_size(screen_size)
			DisplayServer.window_set_position(Vector2i(0, 0))

		"fullscreen":
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

	await get_tree().process_frame
	get_tree().paused = was_paused




### - Sound Options
func _on_sfx_volume_value_changed(value: float) -> void:
	$SoundUI/sfx_volume/txtValue_SFX.text = str(value)
	apply_audio_sfx_settings()

func _on_music_volume_value_changed(value: float) -> void:
	$SoundUI/music_volume/txtValue_Music.text = str(value)
	apply_audio_music_settings()

func apply_audio_sfx_settings():
	if ps_state != State.AUDIO: return
	if music_sample.playing: music_sample.stop()
	
	if !sfx_sample.playing:
		sfx_sample.play()
	sfx_sample.volume_db = (40 * (float($SoundUI/sfx_volume/txtValue_SFX.text) / 100)) - 20

func apply_audio_music_settings():
	if ps_state != State.AUDIO: return
	if sfx_sample.playing: sfx_sample.stop()
	
	if !music_sample.playing:
		music_sample.play()
	music_sample.volume_db = (40 * (float($SoundUI/music_volume/txtValue_Music.text) / 100)) - 20
