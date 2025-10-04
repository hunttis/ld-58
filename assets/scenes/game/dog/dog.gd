class_name Dog
extends CharacterBody3D

@onready var agent: NavigationAgent3D =  $NavigationAgent3D
@onready var repulsionArea: Area3D = $RepulsionArea
@onready var repulsionCollider: CollisionShape3D = $RepulsionArea/CollisionShape3D
@onready var barkCooldown: Timer = $BarkCooldown
@onready var barkAudio: AudioStreamPlayer3D = $BarkAudio

@export var sprint_threat_range = 3.5
@export var normal_threat_range = 7.0
@export var bark_threat_range = 15.0
@export var sprint_speed = 25.0
@export var normal_speed = 10.0
@export var bark_cooldown = 2.5

var speed: float

enum MOVE_STATE {
  NORMAL,
  SPRINT,
  DASH
}

var move_state: MOVE_STATE = MOVE_STATE.NORMAL

func _ready():
  speed = normal_speed

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
    
    if event.is_action_pressed("ability_e"):
      _dash()

func _bark():
  print("BARK!")
  barkAudio.play()

func _dash():
  print("DASH BABY!")

func set_repulsion_range(new_range: float) -> void:
  var shape = repulsionCollider.shape as SphereShape3D
  shape.radius = new_range
