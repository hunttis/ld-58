extends Node3D

class_name Sheep

@export var character_body: CharacterBody3D
@export var speed: float = 10

enum State {
  Idle,
}

var state: State = State.Idle

func _process(delta: float) -> void:
  pass


func _physics_process(delta: float) -> void:
  match state:
    State.Idle:
      character_body.velocity += Vector3.FORWARD * speed * delta
  character_body.move_and_slide()
