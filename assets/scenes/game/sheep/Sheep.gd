extends CharacterBody3D

class_name Sheep

@export var sheep_dog = Vector3.ZERO

@export var dog_fear_radius: float = 10.0

@export var corral_speed: float = 2
@export var max_idle_speed: float = 2
@export var max_flee_speed: float = 5.0
@export var separation_radius: float = 1.5

@export var look_ahead: float = 1.0
@export var rotation_speed: float = 5.0

@export var weight_cohesion: float = 0.2
@export var weight_separation: float = 1.0
@export var weight_align: float = 0.2
@export var weight_dog: float = 2.0
@export var weight_wander: float = 0.5
@export var weight_bark: float = 20
@export var weight_goal: float = 20

enum State {
  IDLE,
  FLEE,
  IN_CORRAL
}

@onready var agent: NavigationAgent3D = $NavigationAgent3D


var goal_point: Vector3 = Vector3.ZERO
var rnd := RandomNumberGenerator.new()
var state: State = State.IDLE

var _neighbors: Array[Node] = []
var _dogs: Array[Node] = []
var _barks: Array[Node] = []

func _ready() -> void:
  rnd.randomize()
  agent.velocity_computed.connect(_on_velocity_computed)

func collided_with_dog(dog: Dog) -> void:
  _dogs.append(dog)

func collided_with_dog_exited(dog: Dog) -> void:
  _dogs.erase(dog)

func collided_with_dog_bark(bark: Node) -> void:
  if _barks.size() == 0 and state == State.IDLE:
    state = State.FLEE
  _barks.append(bark)

func collided_with_dog_bark_exited(bark: Node) -> void:
  _barks.erase(bark)
  if _barks.size() == 0 and state == State.FLEE:
    state = State.IDLE

func collided_with_corral_entrance(target: Node3D) -> void:
  # remove from group so not considered as neighbour for sheep movement
  remove_from_group("sheep")
  add_to_group("coralled")
  Events.sheep_coralled.emit()
  goal_point = target.global_position
  state = State.IN_CORRAL
  
func _on_velocity_computed(safe_velocity: Vector3) -> void:
    # Apply the avoidance-adjusted velocity to the body
    velocity = safe_velocity
    
    # Smoothly rotate towards movement direction
    if velocity.length() > 0.001:
        var target_dir := velocity.normalized()
        var target_transform := Transform3D()
        target_transform.origin = global_position
        target_transform = target_transform.looking_at(global_position + target_dir, Vector3.UP)
        
        # Slerp the basis for smooth rotation
        var delta := get_physics_process_delta_time()
        global_transform.basis = global_transform.basis.slerp(target_transform.basis, rotation_speed * delta)
    
    move_and_slide()

func _physics_process(_delta: float) -> void:
  _neighbors = get_tree().get_nodes_in_group("sheep")

  var steer := Vector3.ZERO
  if goal_point != Vector3.ZERO:
    steer += _towards(goal_point) * weight_goal

  if _neighbors.size() > 0:
    var centroid := _average_pos(_neighbors)
    steer += _towards(centroid) * weight_cohesion

  if _neighbors.size() > 0:
      var avg_vel := _average_vel(_neighbors)
      if avg_vel.length() > 0.001:
          steer += avg_vel.normalized() * weight_align

  # Separation (short-range)
  steer += _separation_force(_neighbors) * weight_separation

  # Dog repulsion
  steer += _dog_repulsion(_dogs) * weight_dog

  # Bark repulsion
  steer += _bark_repulsion(_barks) * weight_bark

  # Wander
  steer += _wander() * weight_wander

  var desired_dir := steer
  if desired_dir.length() < 0.001:
      desired_dir = - transform.basis.z # keep moving forward a bit
  desired_dir = desired_dir.normalized()

  # 2) Pick a short-range steer target and hand it to the agent
  var steer_target := global_position + ((desired_dir * look_ahead) * 2)
  agent.target_position = steer_target

  # 3) Use path corner to build desired velocity; let avoidance adjust it
  var next_corner := agent.get_next_path_position()
  var dir_to_corner := (next_corner - global_position)
  if dir_to_corner.length() > 0.001:
      var speed: float = 0
      match state:
        State.IDLE:
          speed = max_idle_speed
        State.FLEE:
          speed = max_flee_speed
        State.IN_CORRAL:
          speed = corral_speed
      var desired_velocity := dir_to_corner.normalized() * speed
      # Tell the agent what we *want*; it will emit a safe velocity
      agent.velocity = desired_velocity
  else:
      agent.velocity = Vector3.ZERO


# === Helper functions ===

func _separation_force(neighbors: Array) -> Vector3:
    var f := Vector3.ZERO
    for n in neighbors:
        var off: Vector3 = global_position - n.global_position
        var d: float = off.length()
        if d > 0.001 and d < separation_radius:
            # Inverse-square falloff
            f += off.normalized() * (1.0 / (d * d))
    return f

func _towards(target: Vector3) -> Vector3:
  return (target - global_position).normalized()

func _average_pos(arr: Array) -> Vector3:
    var sum := Vector3.ZERO
    for a in arr:
        sum += a.global_position
    return sum / float(max(1, arr.size()))

func _average_vel(arr: Array) -> Vector3:
    var sum := Vector3.ZERO
    for a in arr:
        sum += a.velocity
    return sum / float(max(1, arr.size()))

func _dog_repulsion(dogs: Array) -> Vector3:
  if state == State.IN_CORRAL:
    return Vector3.ZERO

  var f := Vector3.ZERO
  for d in dogs:
      var off: Vector3 = global_position - d.global_position
      var dist: float = off.length()
      if dist < dog_fear_radius and dist > 0.001:
          # Heavier inverse-square, scales up close to the dog
          f += off.normalized() * (1.0 / (dist * dist))
  return f

func _bark_repulsion(barks: Array) -> Vector3:

  if state == State.IN_CORRAL:
    return Vector3.ZERO
  var f := Vector3.ZERO
  for b in barks:
      var off: Vector3 = global_position - b.global_position
      var dist: float = off.length()
      if dist > 0.001:
        f += off.normalized() * (1.0 / (dist * dist))
  return f

func _wander() -> Vector3:
  # Small random nudge on the XZ plane
  var angle := rnd.randf_range(-PI, PI)
  var v := Vector3(cos(angle), 0.0, sin(angle))
  return v
