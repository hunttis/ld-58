class_name Corral
extends Node3D

@onready var target := $juomakaukalo

func _on_holding_area_body_entered(body: Node3D) -> void:
  if body is Sheep:
    body.collided_with_corral_entrance(target)
