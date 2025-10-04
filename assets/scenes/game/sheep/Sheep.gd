extends CharacterBody3D

class_name Sheep

@export var speed: float = 10

@onready var agent: NavigationAgent3D = $NavigationAgent3D

enum State {
  Idle,
}

var state: State = State.Idle

func _process(delta: float) -> void:
  agent.target_position = Vector3.ZERO


func _physics_process(delta: float) -> void:
  if agent.is_navigation_finished():
    velocity = Vector3.ZERO
  else:
    velocity = agent.get_next_path_position() - position
  move_and_slide()
