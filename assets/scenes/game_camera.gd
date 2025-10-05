extends Camera3D

enum Rotation {
  NONE = 0,
  CLOCKWISE = -1,
  COUNTER_CLOCKWISE = 1
}

@export var target : Node3D

var camera_offset: Vector3

func _ready() -> void:
  camera_offset = global_position

func _process(delta: float) -> void:
  var dogs = get_tree().get_nodes_in_group("dog") as Array[CharacterBody3D]
  if dogs.is_empty():
    return

  var rotate_angle = Rotation.NONE
  
  var average_pos = Vector3.ZERO
  for dog in dogs:
    average_pos += dog.global_position
  average_pos /= dogs.size()
  
  global_position = average_pos + camera_offset
  
  if Input.is_action_pressed("ui_camera_rotate_cw"):
      rotate_angle = Rotation.CLOCKWISE
  if Input.is_action_pressed("ui_camera_rotate_ccw"):
      rotate_angle = Rotation.COUNTER_CLOCKWISE
  
  if (rotate_angle != Rotation.NONE):
    camera_offset = camera_offset.rotated(Vector3.UP, delta * rotate_angle)
  
  look_at(target.position)
