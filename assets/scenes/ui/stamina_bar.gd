extends ProgressBar


# Called when the node enters the scene tree for the first time.
func _ready():
  Events.stamina_change.connect(_on_stamina_change)
  
func _on_stamina_change(new_value: float) -> void:
  value = new_value * 100
