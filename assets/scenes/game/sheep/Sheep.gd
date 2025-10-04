extends CharacterBody3D

class_name Sheep

@export var sheep_dog = Vector3.ZERO

@export var neighbor_radius: float = 8.0
@export var max_neighbors: int = 10
@export var dog_fear_radius: float = 10.0

@export var max_idle_speed: float = 2
@export var separation_radius: float = 1.5

@export var look_ahead: float = 1.0

@export var weight_goal: float = 0.6
@export var weight_cohesion: float = 0.5
@export var weight_separation: float = 1.0
@export var weight_align: float = 0.4
@export var weight_dog: float = 2.0
@export var weight_wander: float = 0.15

@onready var agent: NavigationAgent3D = $NavigationAgent3D

var goal_point: Vector3 = Vector3.ZERO
var rnd := RandomNumberGenerator.new()

var _neighbors: Array[Node] = []
var _dogs: Array[Node] = []

func _ready() -> void:
  rnd.randomize()
  agent.velocity_computed.connect(_on_velocity_computed)

func _on_velocity_computed(safe_velocity: Vector3) -> void:
    # Apply the avoidance-adjusted velocity to the body
    velocity = safe_velocity
    var target_dir := position + velocity
    look_at(Vector3(target_dir.x, global_position.y, target_dir.z))
    move_and_slide()

func _physics_process(_delta: float) -> void:
  _neighbors = get_tree().get_nodes_in_group("sheep")

  var steer := Vector3.ZERO
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
      var desired_velocity := dir_to_corner.normalized() * max_idle_speed
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
    var f := Vector3.ZERO
    for d in dogs:
        var off: Vector3 = global_position - d.global_position
        var dist: float = off.length()
        if dist < dog_fear_radius and dist > 0.001:
            # Heavier inverse-square, scales up close to the dog
            f += off.normalized() * (1.0 / (dist * dist))
    return f
