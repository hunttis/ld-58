extends Node3D

class_name Sheep

enum State {
  Idle,
}

var state: State = State.Idle

func _process(delta: float) -> void:
  match state:
    State.Idle:
      pass
  pass