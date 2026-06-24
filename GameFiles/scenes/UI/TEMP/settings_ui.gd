extends Control

signal video_pressed
signal audio_pressed



func _on_btn_settings_video_pressed() -> void:
	#Events.emit_signal("settings_video_pressed")
	video_pressed.emit()

func _on_btn_settings_audio_pressed() -> void:
	audio_pressed.emit()



func _open_video_menu():
	var parent = get_parent()
	parent._on_btn_settings_video_pressed()

func _on_button_pressed() -> void:
	video_pressed.emit()
