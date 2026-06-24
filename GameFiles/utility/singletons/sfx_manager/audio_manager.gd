class_name Audio_Controller
extends Node


#func _ready():
	#print("Audio Manager ready at: ", Time.get_ticks_msec())


func play_music(val):
	var music_player: AudioStreamPlayer2D = $MUSIC/music_player
	var ac_path = Data.get_audio_source_by_name(val)
	music_player.stream = load(ac_path)
	music_player.play()

func play_sound(val):
	var sfx_player: AudioStreamPlayer2D = $SFX/sfx_player
	var ac_path = Data.get_audio_source_by_name(val)
	sfx_player.stream = load(ac_path)
	sfx_player.play()
