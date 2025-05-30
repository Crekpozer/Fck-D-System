class_name DeathArea
extends Area3D

@onready var respawnPoint : Marker3D = $RespawnPoint

func _ready() -> void:
	pass

func _on_body_entered(body: Node3D) -> void:
	if body is Player:
		body.Death(respawnPoint)
