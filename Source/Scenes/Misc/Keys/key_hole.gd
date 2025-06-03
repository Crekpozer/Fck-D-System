extends Node3D

var opened : bool = false
@export var startOpen : bool
@export var colorRed : bool
@export var colorYellow : bool
@export var colorBlue : bool

var isPlayerHere : bool
var progress : float = 0.0
var progressSpeed : float = 50

@export var progressBar : ProgressBar

var player : Player

func _ready() -> void:
	if startOpen:
		OpenDoor()

func _process(delta: float) -> void:
	if not opened:
		if isPlayerHere and PlayerHasKey():
			if Input.is_action_pressed("interact"):
				progress += progressSpeed * delta
				progressBar.value = progress
				print("progresso atual: ", progress)
			elif progress > 0:
				progress -= progressSpeed * delta
				progressBar.value = progress
				print("Progresso reduzindo: ", progress)
			
			if progress >= 100:
				OpenDoor()
				

func PlayerHasKey() -> bool:
	if not player:
		return false
	
	if colorRed and player.hasRedKey:
		return true
	elif colorYellow and player.hasYellowKey:
		return true
	elif colorBlue and player.hasBlueKey:
		return true
	
	return false

func OpenDoor() -> void:
	print("Abrindo portas!")
	opened = true
	progressBar.value = 100
	
	if colorRed:
		print("Abrindo porta vermelha")
		%KeyLogicAnimationPlayer.play("OpenRedDoor")
	elif colorYellow:
		print("Abrindo porta amarela")
		%KeyLogicAnimationPlayer.play("OpenYellowDoor")
	else:
		print("Abrindo por azul")
		%KeyLogicAnimationPlayer.play("OpenBlueDoors")


func _on_area_3d_body_entered(body: Node3D) -> void:
	if not opened and body is Player:
		print("O jogador está aqui")
		isPlayerHere = true
		player = body
		print("ele tem a chave? ", PlayerHasKey())

func _on_area_3d_body_exited(body: Node3D) -> void:
	if body is Player:
		print("O jogador não está mais aqui")
		isPlayerHere = false
		progress = 0
		progressBar.value = 0
		player = null
