extends HBoxContainer

@onready var jog = $Jog
@onready var sprint = $Sprint
@onready var dash = $Dash

const jog_color = Color(0.0, 0.475, 0.765, 1.0)
const sprint_color = Color(0.157, 0.588, 0.286, 1.0)
const dash_color = Color(0.646, 0.455, 0.113, 1.0)

# Called when the node enters the scene tree for the first time.
func _ready():
  jog.show()
  jog.color = jog_color
  sprint.hide()
  dash.hide()
  dash.color = dash_color
  Events.dog_move_state_change.connect(on_move_state_changed)
  
func on_move_state_changed(moveState: Global.DOG_MOVE_STATE):
  match moveState:
    Global.DOG_MOVE_STATE.NORMAL:
      jog.color = jog_color
      sprint.hide()
      dash.hide()
      pass
    Global.DOG_MOVE_STATE.SPRINT:
      jog.color = sprint_color
      sprint.color = sprint_color
      sprint.show()
      dash.hide()
      pass
    Global.DOG_MOVE_STATE.DASH:
      jog.color = dash_color
      sprint.color = dash_color
      sprint.show()
      dash.show()
      pass
  pass
