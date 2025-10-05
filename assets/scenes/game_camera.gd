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
var tilt_axis: Vector3
var inverter: int

func _ready() -> void:
  camera_offset = global_position
  tilt_axis = Vector3.LEFT
  inverter = -1 if Global.yAxisInverted else 1
  Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _process(delta: float) -> void:
  global_position = target.global_position + camera_offset
  
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
    rotate_camera(delta * rotate_direction)
  if (tilt_direction != Tilt.NONE):
    tilt_camera(delta * tilt_direction / 2)

  look_at(target.position)
  target.set_camera_rotation(rotation.y)

func _input(event):
  if event is InputEventMouseMotion:
    rotate_camera(event.relative.x * -0.005)
    tilt_camera(event.relative.y * -0.001)

func rotate_camera(angle: float):
    camera_offset = camera_offset.rotated(Vector3.UP, angle)
    tilt_axis = tilt_axis.rotated(Vector3.UP, angle)

func tilt_camera(angle: float):
  var new_camera_offset = camera_offset.rotated(tilt_axis, angle * inverter)

  if new_camera_offset.y > TILT_MIN && new_camera_offset.y < TILT_MAX:
   camera_offset = new_camera_offset
