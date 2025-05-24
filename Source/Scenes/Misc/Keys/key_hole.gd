extends Node3D

var opened : bool
@export var startOpen : bool
@export var colorRed : bool
@export var colorYellow : bool
@export var colorBlue : bool

func _ready() -> void:
	if startOpen:
		if colorRed:
			%RedKeyHoleAnimationPlayer.play("OpenDoors")
		elif colorYellow:
			%YellowKeyHoleAnimationPlayer.play("OpenDoors")
		else:
			%BlueKeyHoleAnimationPlayer.play("OpenDoors")

func _on_area_3d_body_entered(body: Node3D) -> void:
	if not opened:
		if colorRed:
			if body is Player:
				if body.hasRedKey:
					print("O jogador usou a chave vermelha")
					opened = true
					%RedKeyHoleAnimationPlayer.play("OpenDoors")
		elif colorYellow:
			print("Chave amarela")
			if body is Player:
				if body.hasYellowKey:
					print("O jogador usou a chave amarela")
					opened = true
					%YellowKeyHoleAnimationPlayer.play("OpenDoors")
		else:
			print("Chave azul")
			if body is Player:
				if body.hasBlueKey:
					print("O jogador usou a chave azul")
					opened = true
					%BlueKeyHoleAnimationPlayer.play("OpenDoors")
