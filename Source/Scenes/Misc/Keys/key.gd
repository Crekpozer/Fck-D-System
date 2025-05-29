extends Node3D

@export var colorBlue : bool
@export var colorYellow : bool
@export var colorRed : bool

func _on_area_3d_body_entered(body: Node3D) -> void:
	
	if colorRed:
		if body is Player:
			print("O jogador pegou a chave vermelha")
			body.hasRedKey = true
			queue_free()
	elif colorYellow:
		print("O jogador pegou a chave amarela")
		if body is Player:
			body.hasYellowKey = true
			queue_free()
	else:
		print("O jogador pegou a chave azul")
		if body is Player:
			body.hasBlueKey = true
			queue_free()
