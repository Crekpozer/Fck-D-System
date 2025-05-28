class_name DeathArea
extends Area3D

func _ready() -> void:
	pass

func _on_body_entered(body: Node3D) -> void:
	if body is Player:
		body.Death()
