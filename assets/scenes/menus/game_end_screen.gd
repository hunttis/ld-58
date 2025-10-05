extends Node2D
@onready var winfare = $winfare
@onready var lossfare = $lossfare

func _ready():
  $MenuContainer/HBoxContainer/Content/VBoxContainer/RescueCountLabel.text = Global.endScreenText
  $MenuContainer/HBoxContainer/Content/VBoxContainer/GameoverLabel.text = Global.endScreenTitle
  Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
  if Global.won:
    winfare.play()
  else:
    lossfare.play()

func _on_back_to_menu_button_pressed() -> void:
  Events.go_to_menu.emit()
