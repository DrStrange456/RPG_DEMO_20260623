extends Node

#GLOBAL CONFIGURATION SETTINGS

#VIDEO
var CONFIG_VIDEO_VSYNC: bool = true
var CONFIG_VIDEO_WINDOWMODE = 1
var CONFIG_VIDEO_RESOLUTION = 2

#SOUND
var CONFIG_SOUND_SFX_ENABLED: bool = true
var CONFIG_SOUND_MUSIC_ENABLED: bool = false
var CONFIG_SOUND_SFX = 75
var CONFIG_SOUND_MUSIC = 75


func _ready():
	load_settings_from_config_file()
	#print("Settings ready at: ", Time.get_ticks_msec())

func load_settings_from_config_file() -> void:
	var config = ConfigFile.new()

	# Load data from a file.
	var err = config.load("user://settings.cfg")

	# If the file didn't load, ignore it.
	if err != OK:
		return

	# Iterate over all sections.
	for Sound in config.get_sections():
		# Fetch the data for each section.
		CONFIG_SOUND_SFX = config.get_value("Sound","FX_Volume", 50)
		CONFIG_SOUND_MUSIC = config.get_value("Sound","Music_Volume", 50)
	for Video in config.get_sections():
		# Fetch the data for each section.
		CONFIG_VIDEO_VSYNC = config.get_value("Video","VSync", 0)
		CONFIG_VIDEO_RESOLUTION = config.get_value("Video","Resolution", 1)
		CONFIG_VIDEO_WINDOWMODE = config.get_value("Video","Window_Mode", 1)

func is_SFX_Enabled() -> bool:
	return CONFIG_SOUND_SFX_ENABLED

func is_Music_Enabled() -> bool:
	return CONFIG_SOUND_MUSIC_ENABLED






# Bottom
