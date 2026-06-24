extends Control


@onready var player_inventory_ui: Control = $PlayerInventoryUI
@onready var settings_ui: Control = $SettingsUI
@onready var video_ui: Control = $VideoUI
@onready var sound_ui: Control = $SoundUI

@onready var character_ui: Control = $CharacterUI
@onready var btn_character: Button = $btnCHARACTER

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

enum State {DEFAULT,INVENTORY,SETTINGS,VIDEO,AUDIO,CHARACTER}
var ps_state 

func _ready() -> void:
	load_audio_from_config_file()
	load_video_from_config_file()
	apply_global()
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
		State.CHARACTER:
			character_state()


func default_state():
	btn_inventory.visible = true
	btn_settings.visible = true
	btn_back.visible = true
	btn_character.visible = true
	
	player_inventory_ui.visible = false
	settings_ui.visible = false
	video_ui.visible = false
	sound_ui.visible = false
	character_ui.visible = false
	
	btn_back_video.visible = false
	btn_back_sound.visible = false

func inventory_state():
	_setup_ui_vis([btn_back,player_inventory_ui])


func settings_state():
	#_setup_ui_vis([btn_back,settings_ui])
	btn_inventory.visible = false
	btn_settings.visible = false
	btn_back.visible = true
	btn_character.visible = false
	
	btn_back_video.visible = false
	btn_back_sound.visible = false
	
	player_inventory_ui.visible = false
	settings_ui.visible = true
	video_ui.visible = false
	sound_ui.visible = false
	character_ui.visible = false

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

func character_state():
	#_setup_ui_vis([btn_back,character_ui])
	btn_inventory.visible = false
	btn_settings.visible = false
	btn_back.visible = true
	
	btn_back_video.visible = false
	btn_back_sound.visible = false
	
	player_inventory_ui.visible = false
	settings_ui.visible = false
	video_ui.visible = false
	sound_ui.visible = false
	character_ui.visible = true



func _quick_load_default():
	ps_state = State.DEFAULT

func _quick_load_inventory():
	ps_state = State.INVENTORY


func _on_btn_inventory_pressed() -> void:
	prev_state = ps_state
	ps_state = State.INVENTORY
	player_inventory_ui._refresh_inventory_items()

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

func _on_btn_character_pressed() -> void:
	prev_state = ps_state
	ps_state = State.CHARACTER




### - Video Options
func _on_drop_window_mode_item_selected(index: int) -> void:
	#print("Selected:", index)
	#print(DisplayServer.window_get_mode())
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


func _setup_ui_vis(nodes_to_remain_visible: Array):
	_hide_all_ui()
	if nodes_to_remain_visible.size() > 0:
		for N in nodes_to_remain_visible:
			N.visible = true

func _hide_all_ui():
	btn_inventory.visible = false
	btn_settings.visible = false
	btn_character.visible = false
	player_inventory_ui.visible = false
	settings_ui.visible = false
	video_ui.visible = false
	sound_ui.visible = false
	btn_back_video.visible = false
	btn_back_sound.visible = false
	character_ui.visible = false




func apply_global():
	# SOUND
	if Settings.CONFIG_SOUND_SFX or Settings.CONFIG_SOUND_SFX == 0:
		$SoundUI/sfx_volume.value = Settings.CONFIG_SOUND_SFX
	if Settings.CONFIG_SOUND_MUSIC or Settings.CONFIG_SOUND_MUSIC == 0:
		$SoundUI/music_volume.value = Settings.CONFIG_SOUND_MUSIC
	
	# VIDEO
	if Settings.CONFIG_VIDEO_VSYNC:
		$VideoUI/CheckBox.button_pressed = Settings.CONFIG_VIDEO_VSYNC
	if Settings.CONFIG_VIDEO_WINDOWMODE or Settings.CONFIG_VIDEO_WINDOWMODE == 0:
		$VideoUI/dropWINDOW_MODE.select(Settings.CONFIG_VIDEO_WINDOWMODE)
	if Settings.CONFIG_VIDEO_RESOLUTION or Settings.CONFIG_VIDEO_RESOLUTION == 0:
		$VideoUI/dropdownReso.select(Settings.CONFIG_VIDEO_RESOLUTION)
	
	#print("Config Loaded Globally")

func update_global():
	Settings.CONFIG_SOUND_MUSIC = $SoundUI/music_volume.value
	Settings.CONFIG_SOUND_SFX = $SoundUI/sfx_volume.value
	
	Settings.CONFIG_VIDEO_VSYNC = $VideoUI/CheckBox.button_pressed
	Settings.CONFIG_VIDEO_RESOLUTION = $VideoUI/dropdownReso.get_selected_id()
	Settings.CONFIG_VIDEO_WINDOWMODE = $VideoUI/dropWINDOW_MODE.get_selected_id()



func load_video_from_config_file():
	var config = ConfigFile.new()

	# Load data from a file.
	var err = config.load("user://settings.cfg")

	# If the file didn't load, ignore it.
	if err != OK:
		return

	# Iterate over all sections.
	for Video in config.get_sections():
		# Fetch the data for each section.
		Settings.CONFIG_VIDEO_VSYNC = config.get_value("Video","VSync", 0)
		Settings.CONFIG_VIDEO_RESOLUTION = config.get_value("Video","Resolution", 1)
		Settings.CONFIG_VIDEO_WINDOWMODE = config.get_value("Video","Window_Mode", 1)
	apply_global()

func load_audio_from_config_file():
	var config = ConfigFile.new()

	# Load data from a file.
	var err = config.load("user://settings.cfg")

	# If the file didn't load, ignore it.
	if err != OK:
		return

	# Iterate over all sections.
	for Sound in config.get_sections():
		# Fetch the data for each section.
		Settings.CONFIG_SOUND_SFX = config.get_value("Sound","FX_Volume", 50)
		Settings.CONFIG_SOUND_MUSIC = config.get_value("Sound","Music_Volume", 50)
	apply_global()

func save_configs_to_file():
	#Create new config file object
	var config = ConfigFile.new()
	
	# VIDEO
	#Store some values
	config.set_value("Video","VSync",Settings.CONFIG_VIDEO_VSYNC)
	config.set_value("Video","Resolution",Settings.CONFIG_VIDEO_RESOLUTION)
	config.set_value("Video","Window_Mode",Settings.CONFIG_VIDEO_WINDOWMODE)
	
	# AUDIO
	config.set_value("Sound","FX_Volume",Settings.CONFIG_SOUND_SFX)
	config.set_value("Sound","Music_Volume",Settings.CONFIG_SOUND_MUSIC)
	
	#Saving it to a file (overwrite if file exists)
	config.save("user://settings.cfg")




func _on_btn_settings_audio_apply_pressed() -> void:
	update_global()
	save_configs_to_file()

func _on_btn_settings_video_apply_pressed() -> void:
	update_global()
	save_configs_to_file()



func _on_visibility_changed() -> void:
	if self.visible:
		Events.emit_signal("hide_buttons_and_tod")
		#if get_tree():
			#var root_scene = get_tree().current_scene
			#root_scene.hide_TOD_UI()
			#root_scene.hide_buttons()
	else:
		Events.emit_signal("show_buttons_and_tod")
		#if get_tree():
			#var root_scene = get_tree().current_scene
			#root_scene.show_TOD_UI()
			#root_scene.show_buttons()







# Bottom
