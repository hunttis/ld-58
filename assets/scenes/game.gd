extends Node3D

const SheepScene = preload("uid://divjv3eaenwq7")

func _ready():
  for x in range(10):
    for z in range(10):
      var sheep = SheepScene.instantiate()
      sheep.position = Vector3(x * 10 - 50, 0, z * 10 - 50)
      sheep.add_to_group("sheep")
      add_child(sheep)