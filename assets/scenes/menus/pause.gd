extends Node2D

@onready var resume_btn = $"Pause/Resume btn"
@onready var exit_btn = $"Pause/exit btn"

# Called when the node enters the scene tree for the first time.
func _ready():
  Events.toggle_pause.connect(_on_pause_toggled)
  resume_btn.pressed.connect(_on_resume)
  exit_btn.pressed.connect(_on_return_to_menu)

func _on_pause_toggled():
  if is_visible_in_tree():
    _on_resume()
  else:
    _on_pause()

func _on_pause():
  Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
  show()
  get_tree().paused = true

func _on_resume():
  Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
  hide()
  get_tree().paused = false

func _on_return_to_menu():
  get_tree().paused = false
  Events.go_to_menu.emit()
  queue_free()
