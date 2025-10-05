extends GPUParticles3D

func _ready():
  emitting = true

func _process(_delta):
  if !emitting:
    queue_free()
#
