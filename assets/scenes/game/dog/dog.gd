class_name Dog
extends CharacterBody3D

const bark_scene = preload("uid://ywcmei680bhq")

@onready var agent: NavigationAgent3D = $NavigationAgent3D
@onready var repulsionArea: Area3D = $MoveThreatRange
@onready var repulsionCollider: CollisionShape3D = $MoveThreatRange/CollisionShape3D
@onready var barkCooldown: Timer = $BarkCooldown

@export_category("Threat range")
@export var sprint_threat_range = 3.5
@export var normal_threat_range = 7.0
@export_category("Speed")
@export var sprint_speed = 25.0
@export var normal_speed = 10.0
@export var dash_speed = 100.0
@export var dash_distance = 15.0

@export_category("Abilities")
@export var bark_cooldown = 2.5
@export var bark_stamina_cost = 30.0
@export var dash_cooldown = 1.5
@export var dash_stamina_cost = 25.0
@export var sprint_stamina_cost = 20.0

@export_category("Stamina")
@export var max_stamina = 100
@export var stamina_regen = 20

var speed: float
var dash_target: Vector3 = Vector3.ZERO
var cur_stamina: set = set_cur_stamina
var move_state: set = _set_move_state

func set_cur_stamina(new_val: float):
  cur_stamina = new_val
  Events.stamina_change.emit(new_val / max_stamina)


func _set_move_state(new_state: Global.DOG_MOVE_STATE) -> void:
  move_state = new_state
  Events.dog_move_state_change.emit(new_state)
  match new_state:
    Global.DOG_MOVE_STATE.SPRINT:
      move_state = Global.DOG_MOVE_STATE.SPRINT
      set_repulsion_range(sprint_threat_range)
      speed = sprint_speed
      
    Global.DOG_MOVE_STATE.NORMAL:
      move_state = Global.DOG_MOVE_STATE.NORMAL
      set_repulsion_range(normal_threat_range)
      speed = normal_speed
  

func _ready():
  cur_stamina = max_stamina
  move_state = Global.DOG_MOVE_STATE.NORMAL
  speed = normal_speed
  add_to_group("dog")

func _process(delta):
  if (move_state == Global.DOG_MOVE_STATE.NORMAL || velocity == Vector3.ZERO) && cur_stamina < max_stamina:
    cur_stamina = min(cur_stamina + stamina_regen * delta, max_stamina)

func _physics_process(delta: float) -> void:
  if move_state != Global.DOG_MOVE_STATE.DASH:
    var move_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
    if move_dir.length() > 0:
      agent.target_position = global_position + Vector3(move_dir.x, 0, move_dir.y) * 10
    if agent.is_navigation_finished():
      velocity = Vector3.ZERO
      return
    var target = agent.get_next_path_position()
    var direction = global_position.direction_to(target)
    velocity = direction * speed

    var look_target = position + velocity
    look_at(Vector3(look_target.x, global_position.y, look_target.z))
    move_and_slide()
    
    if move_state == Global.DOG_MOVE_STATE.SPRINT:
      cur_stamina = max(cur_stamina - sprint_stamina_cost * delta, 0)
      if cur_stamina <= 0:
        move_state = Global.DOG_MOVE_STATE.NORMAL

  if move_state == Global.DOG_MOVE_STATE.DASH:
    var dir = global_position.direction_to(dash_target)
    velocity = dir * dash_speed
    var collided = move_and_slide()
    if global_position.distance_to(dash_target) <= 1 || collided:
      move_state = Global.DOG_MOVE_STATE.NORMAL
      agent.target_position = global_position
      velocity = Vector3.ZERO

func _input(_event) -> void:
  if Input.is_action_just_pressed("LeftClick") && move_state != Global.DOG_MOVE_STATE.DASH:
    var target = get_vector_to_cursor_pos()
    print('Clicked', target)
    agent.target_position = target


func _unhandled_input(event: InputEvent):
    if event.is_action_pressed("ability_sprint"):
      match move_state:
        Global.DOG_MOVE_STATE.NORMAL:
          move_state = Global.DOG_MOVE_STATE.SPRINT

        Global.DOG_MOVE_STATE.SPRINT:
          move_state = Global.DOG_MOVE_STATE.NORMAL

    if event.is_action_pressed("ability_bark") && barkCooldown.is_stopped():
      _bark()
      barkCooldown.start(bark_cooldown)

    if event.is_action_pressed("ability_dash") && move_state != Global.DOG_MOVE_STATE.DASH:
      _dash()

func _bark():
  if cur_stamina < bark_stamina_cost:
    return
    
  cur_stamina -= bark_stamina_cost
  var bark_inst = bark_scene.instantiate() as Bark
  bark_inst.position = global_position
  get_tree().get_nodes_in_group("Game")[0].add_child(bark_inst)


func _dash():
  if cur_stamina < dash_stamina_cost:
    # some indicator for insufficient stamina
    return
    
  cur_stamina -= dash_stamina_cost
  agent.target_position = global_position
  var dash_dir = global_position.direction_to(get_vector_to_cursor_pos())
  dash_dir.y = 0
  dash_target = global_position + (dash_dir * dash_distance)
  print("Dash target: ", dash_target)
  move_state = Global.DOG_MOVE_STATE.DASH

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
