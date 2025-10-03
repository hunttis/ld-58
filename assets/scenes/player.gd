extends Sprite2D

@export var acceleration: float = 100
@export var deceleration: float = 10
@export var max_speed: Vector2 = Vector2(5, 5)
var speed: Vector2 = Vector2.ZERO

func _process(delta: float) -> void:

	if Input.is_action_pressed("ui_up"):
		speed = speed + Vector2.UP * delta * acceleration
	elif Input.is_action_pressed("ui_down"):
		speed = speed + Vector2.DOWN * delta * acceleration

	if Input.is_action_pressed("ui_left"):
		speed = speed + Vector2.LEFT * delta * acceleration
	if Input.is_action_pressed("ui_right"):
		speed = speed + Vector2.RIGHT * delta * acceleration

	print("Speed: ", speed, " - Delta: ", delta)

	speed.x = clamp(speed.x, -max_speed.x, max_speed.x)
	speed.y = clamp(speed.y, -max_speed.y, max_speed.y)

	position = position + speed
	speed = speed.move_toward(Vector2.ZERO, deceleration * delta)

	if position.x < 8 || position.x > get_window().size.x - 8:
		speed.x = 0

	if position.y < 8 || position.y > get_window().size.y - 8:
		speed.y = 0
