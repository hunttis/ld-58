extends Camera3D

enum Rotation {
  NONE = 0,
  CLOCKWISE = -1,
  COUNTER_CLOCKWISE = 1
}

@export var target : Dog

var camera_offset: Vector3

func _ready() -> void:
  camera_offset = global_position
  Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(delta: float) -> void:
  var dogs = get_tree().get_nodes_in_group("dog") as Array[CharacterBody3D]
  if dogs.is_empty():
    return

  var rotate_direction = Rotation.NONE
  
  var average_pos = Vector3.ZERO
  for dog in dogs:
    average_pos += dog.global_position
  average_pos /= dogs.size()
  
  global_position = average_pos + camera_offset
  
  if Input.is_action_pressed("ui_camera_rotate_cw"):
      rotate_direction = Rotation.CLOCKWISE
  if Input.is_action_pressed("ui_camera_rotate_ccw"):
      rotate_direction = Rotation.COUNTER_CLOCKWISE
  
  if (rotate_direction != Rotation.NONE):
    camera_offset = camera_offset.rotated(Vector3.UP, delta * rotate_direction)

  look_at(target.position)
  target.set_camera_rotation(rotation.y)

func _input(event):
  if event is InputEventMouseMotion:
    camera_offset = camera_offset.rotated(Vector3.UP, event.relative.x * -0.005)
