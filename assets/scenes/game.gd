extends Node3D

const SheepScene = preload("uid://divjv3eaenwq7")
var heart_fx_scene = preload("res://assets/scenes/game/sheep/SheepHeartEffect.tscn")
var bark_fx_scene = preload("res://assets/scenes/game/dog/BarkEffect.tscn")

var total_sheep: int = 0
var coralled_sheep: set = _set_coralled_sheep

@onready var level_timer: Timer = $LevelTimer
@onready var global_bleat_timer = $GlobalBleatTimer

@export var global_bleat_timeout_max: float = 8.0
@export var global_bleat_timeout_min: float = 0.5

signal level_complete
signal level_failed

func _ready():
  var heart_fx = heart_fx_scene.instantiate()
  add_child(heart_fx)
  heart_fx.visible = false
  var bark_fx = bark_fx_scene.instantiate()
  add_child(bark_fx)
  bark_fx.visible = false
  
  add_child(level_timer)
  coralled_sheep = 0

  total_sheep = get_tree().get_nodes_in_group("sheep").size()
  Events.point_update.emit(0, total_sheep)
  Events.sheep_coralled.connect(_on_sheep_coralled)
  Events.sheep_bleating.connect(
    func():
      global_bleat_timer.start(randf_range(global_bleat_timeout_min, global_bleat_timeout_max))
      Events.global_bleat_cooldown_start.emit()
      )
  global_bleat_timer.timeout.connect(Events.global_bleat_cooldown_done.emit)

  level_timer.start()
  global_bleat_timer.start()

func _set_coralled_sheep(new_val: int):
  coralled_sheep = new_val
  Events.point_update.emit(coralled_sheep, total_sheep)

func _on_level_timer_timeout():
  print("Level timer timeout")
  Global.endScreenTitle = "Good job!"
  Global.endScreenText = "You rescued " + str(coralled_sheep) + " sheep!"
  var lowpass = AudioEffectLowPassFilter.new()
  lowpass.cutoff_hz = 500
  var bus = AudioServer.get_bus_index("Master")
  AudioServer.add_bus_effect(bus, lowpass, 0)
  level_failed.emit()
  level_timer.stop()

func _on_sheep_coralled():
  coralled_sheep = get_tree().get_nodes_in_group("coralled").size()
  if get_tree().get_nodes_in_group("sheep").size() == 0:
    Global.endScreenTitle = "Good job!"
    Global.endScreenText = "You rescued all the sheep!"
    Global.won = true
    level_complete.emit()
