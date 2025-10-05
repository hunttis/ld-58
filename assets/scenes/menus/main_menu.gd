extends Control

var bus = AudioServer.get_bus_index("Music")

func _ready():
  $ScreenSizeContainer/VerticalContainer/MenuButtons/StartButton.grab_focus()
  AudioServer.remove_bus_effect(bus, 0)

func _on_start_button_pressed() -> void:
  Events.go_to_game.emit()

func _on_options_button_pressed() -> void:
  Events.go_to_options.emit()

func _on_quit_button_pressed() -> void:
  get_tree().quit()
