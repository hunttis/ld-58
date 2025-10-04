extends Camera3D

var camera_offset: Vector3

func _ready() -> void:
  camera_offset = global_position

func _process(_delta: float) -> void:
  var dogs = get_tree().get_nodes_in_group("dog") as Array[CharacterBody3D]
  if dogs.is_empty():
    return
    
  var average_pos = Vector3.ZERO
  for dog in dogs:
    average_pos += dog.global_position
  average_pos /= dogs.size()
  
  global_position = average_pos + camera_offset
