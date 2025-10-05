extends Node3D

const SheepScene = preload("uid://divjv3eaenwq7")

var total_sheep

var coralled_sheep: set = _set_coralled_sheep
@onready var level_timer: Timer = $LevelTimer

signal level_complete
signal level_failed

func _ready():
  add_child(level_timer)
  coralled_sheep = 0

  total_sheep = get_tree().get_nodes_in_group("sheep").size()
  Events.point_update.emit(0, total_sheep)
  Events.sheep_coralled.connect(_on_sheep_coralled)

  level_timer.start()

func _set_coralled_sheep(new_val: int):
  coralled_sheep = new_val
  Events.point_update.emit(coralled_sheep, total_sheep)

func _on_level_timer_timeout():
  print("Level timer timeout")
  level_failed.emit()
  level_timer.stop()

func _on_sheep_coralled():
  coralled_sheep = get_tree().get_nodes_in_group("coralled").size()
  if get_tree().get_nodes_in_group("sheep").size() == 0:
    level_complete.emit()
