extends Node2D

func _ready() -> void:
	$OptionsContainer/ButtonContainer/MusicButton.button_pressed = !AudioServer.is_bus_mute(0)
	$OptionsContainer/ButtonContainer/SoundButton.button_pressed = !AudioServer.is_bus_mute(1)
	$OptionsContainer/ButtonContainer/MusicButton.grab_focus()

func _on_music_button_toggled(toggled_on: bool) -> void:
	AudioServer.set_bus_mute(0, !toggled_on)
	print("Music mute toggled to: ", !toggled_on)

func _on_sound_button_toggled(toggled_on: bool) -> void:
	AudioServer.set_bus_mute(1, !toggled_on)
	print("Sound mute toggled to: ", !toggled_on)

func _on_return_to_menu_button_pressed() -> void:
	Events.go_to_menu.emit()
