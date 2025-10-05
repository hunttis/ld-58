extends Control

@export var level_timer: Timer

@onready var _timer_label: Label = $MarginContainer/Time

func _process(_delta: float):
  if level_timer.time_left > 0:
    _timer_label.text = "%ss" % str(int(level_timer.time_left))
  else:
    _timer_label.text = "-"

func on_level_timer_timeout():
  on_game_over()

func on_game_over():
  $GameOverLabel.visible = true

func on_level_complete():
  $LevelCompleteLabel.visible = true
