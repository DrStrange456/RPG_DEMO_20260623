extends Control

@onready var music_sample: AudioStreamPlayer2D = $PAUSEUI/Panel/Sounds/Music_Sample
@onready var sfx_sample: AudioStreamPlayer2D = $PAUSEUI/Panel/Sounds/SFX_Sample

enum State {DEFAULT,INVENTORY,SETTINGS,VIDEO,AUDIO,CHARACTER}
var ps_state 


func _ready() -> void:
	load_audio_from_config_file()
	#load_video_from_config_file()
	apply_global()
	ps_state = State.AUDIO


### - Sound Options

func _on_sfx_volume_value_changed(value: float) -> void:
	$PAUSEUI/Panel/SFX/sfx_volume/txtValue_SFX.text = str(value)
	apply_audio_sfx_settings()

func _on_music_volume_value_changed(value: float) -> void:
	$PAUSEUI/Panel/MUSIC/music_volume/txtValue_Music.text = str(value)
	apply_audio_music_settings()

func apply_audio_sfx_settings():
	if ps_state != State.AUDIO: return
	if music_sample.playing: music_sample.stop()
	
	if !sfx_sample.playing:
		sfx_sample.play()
	sfx_sample.volume_db = (40 * (float($PAUSEUI/Panel/SFX/sfx_volume/txtValue_SFX.text) / 100)) - 20

func apply_audio_music_settings():
	if ps_state != State.AUDIO: return
	if sfx_sample.playing: sfx_sample.stop()
	
	if !music_sample.playing:
		music_sample.play()
	music_sample.volume_db = (40 * (float($PAUSEUI/Panel/MUSIC/music_volume/txtValue_Music.text) / 100)) - 20



func apply_global():
	# SOUND
	if Settings.CONFIG_SOUND_SFX or Settings.CONFIG_SOUND_SFX == 0:
		$PAUSEUI/Panel/SFX/sfx_volume.value = Settings.CONFIG_SOUND_SFX
	if Settings.CONFIG_SOUND_MUSIC or Settings.CONFIG_SOUND_MUSIC == 0:
		$PAUSEUI/Panel/MUSIC/music_volume.value = Settings.CONFIG_SOUND_MUSIC

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





# Bottom
