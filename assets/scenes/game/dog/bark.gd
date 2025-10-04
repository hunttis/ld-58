extends Node3D
class_name Bark

@onready var barkArea: Area3D = $BarkThreatRange
@onready var barkAreaCollider: CollisionShape3D = $BarkThreatRange/CollisionShape3D
@onready var barkActiveTimer: Timer = $BarkActiveTimer
@onready var barkAudio: AudioStreamPlayer3D = $BarkAudio

@export var bark_threat_range = 15.0
@export var bark_active_time = 2

# Called when the node enters the scene tree for the first time.
func _ready():
  barkAudio.play()
  (barkAreaCollider.shape as SphereShape3D).radius = bark_threat_range
  barkActiveTimer.start(bark_active_time)
  barkActiveTimer.connect("timeout", queue_free)
