class_name Dog
extends CharacterBody3D

const bark_scene = preload("uid://ywcmei680bhq")

@onready var agent: NavigationAgent3D = $NavigationAgent3D
@onready var repulsionArea: Area3D = $MoveThreatRange
@onready var repulsionCollider: CollisionShape3D = $MoveThreatRange/CollisionShape3D
@onready var barkCooldown: Timer = $BarkCooldown

@export var sprint_threat_range = 3.5
@export var normal_threat_range = 7.0
@export var sprint_speed = 25.0
@export var normal_speed = 10.0
@export var dash_speed = 100.0
@export var dash_distance = 15.0
@export var bark_cooldown = 2.5

var speed: float
var dash_target: Vector3 = Vector3.ZERO

enum MOVE_STATE {
  NORMAL,
  SPRINT,
  DASH
}

var move_state: MOVE_STATE = MOVE_STATE.NORMAL

func _ready():
  speed = normal_speed
  add_to_group("dog")
  agent.connect("navigation_finished",
  func():
    if move_state == MOVE_STATE.DASH:
      move_state = MOVE_STATE.NORMAL
      speed = normal_speed
    )

func _physics_process(_delta: float) -> void:
  if move_state != MOVE_STATE.DASH:
    var move_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
    if move_dir.length() > 0:
      agent.target_position = global_position + Vector3(move_dir.x, 0, move_dir.y) * 10
    if agent.is_navigation_finished():
      return
    var target = agent.get_next_path_position()
    var direction = global_position.direction_to(target)
    velocity = direction * speed

    var look_target = position + velocity
    look_at(Vector3(look_target.x, global_position.y, look_target.z))
    move_and_slide()

  if move_state == MOVE_STATE.DASH:
    var dir = global_position.direction_to(dash_target)
    velocity = dir * dash_speed
    var collided = move_and_slide()
    if global_position.distance_to(dash_target) <= 1 || collided:
      move_state = MOVE_STATE.NORMAL
      agent.target_position = global_position

func _input(_event) -> void:
  if Input.is_action_just_pressed("LeftClick") && move_state != MOVE_STATE.DASH:
    var target = get_vector_to_cursor_pos()
    print('Clicked', target)
    agent.target_position = target


func _unhandled_input(event: InputEvent):
    if event.is_action_pressed("ability_q"):
      match move_state:
        MOVE_STATE.NORMAL:
          move_state = MOVE_STATE.SPRINT
          set_repulsion_range(sprint_threat_range)
          speed = sprint_speed
        MOVE_STATE.SPRINT:
          move_state = MOVE_STATE.NORMAL
          set_repulsion_range(normal_threat_range)
          speed = normal_speed

    if event.is_action_pressed("ability_w") && barkCooldown.is_stopped():
      _bark()
      barkCooldown.start(bark_cooldown)

    if event.is_action_pressed("ability_e") && move_state != MOVE_STATE.DASH:
      _dash()

func _bark():
  var bark_inst = bark_scene.instantiate() as Bark
  bark_inst.position = global_position
  get_tree().get_nodes_in_group("Game")[0].add_child(bark_inst)


func _dash():
  print("DASH BABY!")
  agent.target_position = global_position
  var dash_dir = global_position.direction_to(get_vector_to_cursor_pos())
  dash_dir.y = 0
  dash_target = global_position + (dash_dir * dash_distance)
  print("Dash target: ", dash_target)
  move_state = MOVE_STATE.DASH

func get_vector_to_cursor_pos() -> Vector3:
  var camera := get_tree().get_nodes_in_group("Camera")[0] as Camera3D
  var click_pos := get_viewport().get_mouse_position()
  var ray_length := camera.far
  var origin := camera.project_ray_origin(click_pos)
  var direction := camera.project_ray_normal(click_pos)
  var end_position = origin + direction * ray_length
  var space := get_world_3d().direct_space_state
  var query := PhysicsRayQueryParameters3D.create(origin, end_position)
  var result = space.intersect_ray(query)
  if result.is_empty():
    printerr("Cursor position returned empty!")
    return Vector3.ZERO

  return result.position

func set_repulsion_range(new_range: float) -> void:
  var shape = repulsionCollider.shape as SphereShape3D
  shape.radius = new_range


func _on_repulsion_area_body_entered(body: Node3D) -> void:
  if body is Sheep:
    body.collided_with_dog(self)


func _on_repulsion_area_body_exited(body: Node3D) -> void:
  if body is Sheep:
    body.collided_with_dog(self)
