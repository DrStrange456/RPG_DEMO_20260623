extends Control

signal video_pressed
signal audio_pressed




func _on_btn_settings_video_pressed() -> void:
	video_pressed.emit()

func _on_btn_settings_audio_pressed() -> void:
	audio_pressed.emit()
