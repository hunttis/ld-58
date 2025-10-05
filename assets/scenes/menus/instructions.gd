extends Control


func _on_return_to_menu_button_pressed() -> void:
  Events.go_to_menu.emit()
