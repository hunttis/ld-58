class_name Dog
extends CharacterBody3D

@export var speed: float = 10
@onready var agent: NavigationAgent3D =  $NavigationAgent3D


func _physics_process(_delta: float) -> void:
  if agent.is_navigation_finished():
    return
  var target = agent.get_next_path_position() 
  var direction = global_position.direction_to(target)
  velocity = direction * speed
  look_at(Vector3(direction.x, global_position.y, direction.z))
  move_and_slide()


func _input(_event) -> void:
  if Input.is_action_just_pressed("LeftClick"):
    var camera := get_tree().get_nodes_in_group("Camera")[0] as Camera3D
    var click_pos := get_viewport().get_mouse_position()
    var ray_length := camera.far
    var origin := camera.project_ray_origin(click_pos)
    var direction := camera.project_ray_normal(click_pos)
    var end_position = origin + direction * ray_length

    var space := get_world_3d().direct_space_state
    var query := PhysicsRayQueryParameters3D.create(origin, end_position)
    var result = space.intersect_ray(query)

    print('Clicked', result)
    if not result.is_empty():
      agent.target_position = result.position
