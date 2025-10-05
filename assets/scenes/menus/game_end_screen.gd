extends Node2D

func _ready():
  $MenuContainer/HBoxContainer/Content/VBoxContainer/RescueCountLabel.text = "You rescued " + str(Global.rescuedSheepCount) + " sheep!"
  Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_back_to_menu_button_pressed() -> void:
  Events.go_to_menu.emit()
