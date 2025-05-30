extends StaticBody3D

@export var respawnPoint : Marker3D

@export var animation : bool
var animationPlayerReference : AnimationPlayer 

func _ready() -> void:
	animationPlayerReference = %AnimationPlayer
	
	if animation:
		animationPlayerReference.play("Default")
	else:
		animationPlayerReference.play("Default_2")


func _on_gas_area_3d_body_entered(body: Node3D) -> void:
	
	if body is Player:
		body.Death(respawnPoint)
