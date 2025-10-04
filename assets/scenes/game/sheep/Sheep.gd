extends Node3D

class_name Sheep

@export var character_body: CharacterBody3D

enum State {
  Idle,
}

var state: State = State.Idle

func _process(delta: float) -> void:
  match state:
    State.Idle:
      character_body.velocity += Vector3.FORWARD * 10 * delta
  pass
