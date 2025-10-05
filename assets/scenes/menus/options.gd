extends Control


func _ready() -> void:
    %MasterVolumeSlider.value = AudioServer.get_bus_volume_linear(AudioServer.get_bus_index("Master"))
    %MusicVolumeSlider.value = AudioServer.get_bus_volume_linear(AudioServer.get_bus_index("Music"))
    %SoundVolumeSlider.value = AudioServer.get_bus_volume_linear(AudioServer.get_bus_index("Sound"))
    %MasterVolumeSlider.grab_focus()

func _on_music_button_toggled(toggled_on: bool) -> void:
    AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db($Slider.value))
    print("Music mute toggled to: ", !toggled_on)

func _on_sound_button_toggled(toggled_on: bool) -> void:
    AudioServer.set_bus_mute(1, !toggled_on)
    print("Sound mute toggled to: ", !toggled_on)

func _on_master_volume_slider_value_changed(value: float) -> void:
    AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(value))

func _on_music_volume_slider_value_changed(value: float) -> void:
    print(value)
    AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(value))

func _on_sound_volume_slider_value_changed(value: float) -> void:
    AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Sound"), linear_to_db(value))

func _on_return_to_menu_button_pressed() -> void:
    Events.go_to_menu.emit()

func _on_invert_y_axis_toggled(toggled_on: bool) -> void:
    Global.yAxisInverted = !Global.yAxisInverted
