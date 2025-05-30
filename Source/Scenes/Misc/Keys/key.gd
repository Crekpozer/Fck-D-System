extends Node3D

@export var colorBlue : bool
@export var colorYellow : bool
@export var colorRed : bool

func _on_area_3d_body_entered(body: Node3D) -> void:
	%KeyTakenStreamPlayer3D.play()
	if colorRed:
		if body is Player:
			print("O jogador pegou a chave vermelha")
			body.hasRedKey = true
			%CollisionShape3D.visible = false
	elif colorYellow:
		print("O jogador pegou a chave amarela")
		if body is Player:
			body.hasYellowKey = true
			%CollisionShape3D.visible = false
	else:
		print("O jogador pegou a chave azul")
		if body is Player:
			body.hasBlueKey = true
			%CollisionShape3D.visible = false
	
	await %KeyTakenStreamPlayer3D.finished
	queue_free()
