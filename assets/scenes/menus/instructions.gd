extends Control

func _ready() -> void:
  %ReturnToMenuButton.grab_focus()

func _on_return_to_menu_button_pressed() -> void:
  Events.go_to_menu.emit()
