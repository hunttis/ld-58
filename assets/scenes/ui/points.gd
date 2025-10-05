extends Label

@onready var pointsLabel: Label = $"."

var pointString = "Sheep coralled: %d / %d"

# Called when the node enters the scene tree for the first time.
func _ready():
  Events.point_update.connect(_on_point_update)

func _on_point_update(points: int, total: int):
  pointsLabel.text = pointString % [points, total]
