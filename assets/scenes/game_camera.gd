extends Camera3D

enum Rotation {
  NONE = 0,
  CLOCKWISE = -1,
  COUNTER_CLOCKWISE = 1
}

enum Tilt {
  NONE = 0,
  DOWN = -1,
  UP = 1
}

@export var target : Dog

const TILT_MAX: float = 20
const TILT_MIN: float = 12

var camera_offset: Vector3

func _ready() -> void:
  camera_offset = global_position
  Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(delta: float) -> void:
  var dogs = get_tree().get_nodes_in_group("dog") as Array[CharacterBody3D]
  if dogs.is_empty():
    return
  
  var average_pos = Vector3.ZERO
  for dog in dogs:
    average_pos += dog.global_position
  average_pos /= dogs.size()
  
  global_position = average_pos + camera_offset
  
  var rotate_direction = Rotation.NONE
  var tilt_direction = Tilt.NONE
  if Input.is_action_pressed("ui_camera_rotate_cw"):
    rotate_direction = Rotation.CLOCKWISE
  if Input.is_action_pressed("ui_camera_rotate_ccw"):
    rotate_direction = Rotation.COUNTER_CLOCKWISE
  if Input.is_action_pressed("ui_camera_tilt_up"):
    tilt_direction = Tilt.UP
  if Input.is_action_pressed("ui_camera_tilt_down"):
    tilt_direction = Tilt.DOWN
  
  if (rotate_direction != Rotation.NONE):
    camera_offset = camera_offset.rotated(Vector3.UP, delta * rotate_direction)
  if (tilt_direction != Tilt.NONE):
    tilt_camera(delta * tilt_direction)

  look_at(target.position)
  target.set_camera_rotation(rotation.y)

func _input(event):
  if event is InputEventMouseMotion:
    camera_offset = camera_offset.rotated(Vector3.UP, event.relative.x * -0.005)
    tilt_camera(event.relative.y * -0.001)

func tilt_camera(angle: float):
  var new_camera_offset = camera_offset.rotated(Vector3.LEFT, angle)

  if new_camera_offset.y > TILT_MIN && new_camera_offset.y < TILT_MAX:
   camera_offset = new_camera_offset
