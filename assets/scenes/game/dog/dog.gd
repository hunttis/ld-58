class_name Dog
extends CharacterBody3D

const bark_scene = preload("uid://ywcmei680bhq")

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
var threat_range: float
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
      threat_range = sprint_threat_range

    Global.DOG_MOVE_STATE.NORMAL:
      move_state = Global.DOG_MOVE_STATE.NORMAL
      set_repulsion_range(normal_threat_range)
      speed = normal_speed
      threat_range = normal_threat_range


func _ready():
  cur_stamina = max_stamina
  move_state = Global.DOG_MOVE_STATE.NORMAL
  speed = normal_speed
  threat_range = normal_threat_range
  add_to_group("dog")
  repulsionArea.body_entered.connect(_on_repulsion_area_body_entered)
  repulsionArea.body_exited.connect(_on_repulsion_area_body_exited)

func _process(delta):
  if (move_state == Global.DOG_MOVE_STATE.NORMAL || velocity == Vector3.ZERO) && cur_stamina < max_stamina:
    cur_stamina = min(cur_stamina + stamina_regen * delta, max_stamina)

func _physics_process(delta: float) -> void:
  var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
  var move_dir = Vector3(input_dir.x, 0, input_dir.y)
  if move_state != Global.DOG_MOVE_STATE.DASH:
    if move_dir.length() > 0:
      velocity = move_dir * speed
    else:
      velocity = Vector3.ZERO
    
    if move_state == Global.DOG_MOVE_STATE.SPRINT:
      cur_stamina = max(cur_stamina - sprint_stamina_cost * delta, 0)
      if cur_stamina <= 0:
        move_state = Global.DOG_MOVE_STATE.NORMAL
    
    move_and_slide()

  if move_state == Global.DOG_MOVE_STATE.DASH:
    if dash_target == Vector3.ZERO:
      dash_target = global_position + (move_dir * dash_distance)
      
    velocity = global_position.direction_to(dash_target) * dash_speed
    var collided = move_and_slide()
    
    if global_position.distance_to(dash_target) <= 1 || collided:
      move_state = Global.DOG_MOVE_STATE.NORMAL
      velocity = Vector3.ZERO
      dash_target = Vector3.ZERO
  
  var look_target = position + velocity
  if look_target != position:
    look_at(Vector3(look_target.x, global_position.y, look_target.z))

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
  move_state = Global.DOG_MOVE_STATE.DASH

func set_repulsion_range(new_range: float) -> void:
  var shape = repulsionCollider.shape as SphereShape3D
  shape.radius = new_range


func _on_repulsion_area_body_entered(body: Node3D) -> void:
  if body is Sheep:
    body.collided_with_dog(self)


func _on_repulsion_area_body_exited(body: Node3D) -> void:
  if body is Sheep:
    body.collided_with_dog(self)
