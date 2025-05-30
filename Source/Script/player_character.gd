class_name Player
extends CharacterBody3D

# Vida
@export_category("Life")
# Vida total do personagem
@export var totalLife : float = 100
# Vida atual do personagem
@export var actualLife : float = 100

@export_category("Movement")
# Define uma velocidade para o personagem
@export var moveSpeed : int = 50
# Velocidade do movimento no ar
@export var airMoveSpeed : float = 20
# Ângulo de inclinação
@export var tiltAmount : float = 0.2

@export_category("AirMechanics")
# Gravidade padrão
@export var gravity : float = 9.8
# Força do pulo
@export var jumpForce : float = 5.0
# Direção do pulo
var jumpDirection : Vector3 = Vector3.ZERO
# Indica se o jogador pulou enquanto estava andando
var jumpFromMoving : bool = false
# Indica se o personagem pode dar o pulo duplo ou não
var canDoubleJump : bool = true
# Duração do tempo onde o jogador pode corrigir a sua posição no ar
@export var wallJumpCorrectionWindow : float = 0.2

@export_category("Wall Stick")
# Tempo que o personagem fica grudado na parede
@export var wallStickTime : float = 0.0
var recentlyWallJumped : bool = false
var wallJumpCorrectionTimer : Timer
# Força do pulo horizontal na parede
@export var wallHorizontalJumpForce : float = 5.0
# Força do pulo vertical na parede
@export var wallVerticalJumpForce : float = 10.0
# Marca se o personagem está grudado na parede ou não
var isSticking : bool = false
# Tempo que o jogador pode grudar na parede de novo
var cooldownStickTime : float
# Tempo padrão que o jogador deve esperar antes de poder grudar na parede novamente
var stickTimer : float = 0.2

# CHAVES
var hasBlueKey : bool
var hasYellowKey : bool
var hasRedKey : bool

# REFERÊNCIAS
# Referência ao nodo da câmera
var cameraFollow : Node3D
# Referência ao RayCast3D
var rayCast : RayCast3D
# Referência à parede que o personagem está grudado
var collider : StaticBody3D
# Referencia ao nodo de respawn do personagem
var spawn : Node3D

var playedSound = false

var levelScript

func _ready() -> void:
	# Obtém a referência do nodo da CameraFollow
	cameraFollow = get_parent().get_node("CameraFollow")
	# Obtém a referência do RayCast3D (certifique-se de que o caminho está correto)
	rayCast = $RayCast3D
	# Obtém a referência do Timer para correção do wall jump
	wallJumpCorrectionTimer = %wallJumpCorrectionTimer
	wallJumpCorrectionTimer.wait_time = wallJumpCorrectionWindow
	wallJumpCorrectionTimer.one_shot = true
	spawn = %PlayerStartLocation
	levelScript = get_parent()

func _process(_delta: float) -> void:
	if hasBlueKey:
		%ChipAzulPanel.visible = true
	
	if hasYellowKey:
		%ChipAmarelhoPanel.visible = true
	
	if hasRedKey:
		%ChipVermelhoPanel.visible = true


func _physics_process(delta: float) -> void:
	var direction = Vector3.ZERO
	var tilt = 0.0
	
	# Atualiza o cooldown quando não está grudado
	if not isSticking and cooldownStickTime > 0:
		cooldownStickTime -= delta
		playedSound = false

	# Detecta colisão com a parede usando o RayCast3D, se o cooldown permitir
	if rayCast.is_colliding() and cooldownStickTime <= 0:
		collider = rayCast.get_collider()
		var collisionNormal = rayCast.get_collision_normal()
		if abs(collisionNormal.x) > 0.8:
			velocity.y = 0
			isSticking = true

	# Apenas se o jogador pressionar o botão de pulo, sai do estado "sticking"
	if isSticking:
		if not playedSound:
			AudioManager.PlaySFX("grudar")
			playedSound = true
		
		if Input.is_action_just_pressed("jump"):
			cooldownStickTime = stickTimer
			# Se houver também input direcional, prioriza-o
			if Input.is_action_pressed("left"):
				velocity.x = -wallHorizontalJumpForce
				transform.basis = Basis(Vector3(0, 1, 0), deg_to_rad(180))
			elif Input.is_action_pressed("right"):
				velocity.x = wallHorizontalJumpForce
				transform.basis = Basis(Vector3(0, 1, 0), deg_to_rad(0))
			else:
				# Caso nenhum input direcional seja detectado, escolhe o impulso padrão
				if collider.wallSide:
					velocity.x = wallHorizontalJumpForce
					transform.basis = Basis(Vector3(0, 1, 0), deg_to_rad(0))
				else:
					velocity.x = -wallHorizontalJumpForce
					transform.basis = Basis(Vector3(0, 1, 0), deg_to_rad(180))
			# Impulso vertical para o wall jump
			velocity.y = wallVerticalJumpForce
			isSticking = false
			recentlyWallJumped = true
			wallJumpCorrectionTimer.start()
		
	else:
		playedSound = false
	
	# Durante a janela de correção, permite apenas ajustes na velocidade horizontal
	if recentlyWallJumped and not wallJumpCorrectionTimer.is_stopped():
		if Input.is_action_pressed("left"):
			velocity.x = -moveSpeed
			transform.basis = Basis(Vector3(0, 1, 0), deg_to_rad(180))
		elif Input.is_action_pressed("right"):
			velocity.x = moveSpeed
			transform.basis = Basis(Vector3(0, 1, 0), deg_to_rad(0))
	# Ao final da janela de correção, reseta o estado
	if wallJumpCorrectionTimer.is_stopped():
		recentlyWallJumped = false

	# Aplica a gravidade
	velocity.y -= gravity * delta

	# Movimentação, inputs e ajustes no chão
	if is_on_floor():
		if not levelScript.isGameOver:
			canDoubleJump = true
			if Input.is_action_pressed("left"):
				direction.x -= 1
				AudioManager.StartWalk()
				transform.basis = Basis(Vector3(0, 1, 0), deg_to_rad(180))
				cameraFollow.global_position = global_position
			
			if Input.is_action_pressed("right"):
				direction.x += 1
				transform.basis = Basis(Vector3(0, 1, 0), deg_to_rad(0))
				AudioManager.StartWalk()
			
	else:
		AudioManager.StopWalk()

	# Pulo normal no chão
	if not levelScript.isGameOver:
		if Input.is_action_just_pressed("jump") and is_on_floor():
			AudioManager.PlaySFX("pulo")
			velocity.y = jumpForce
			velocity.x = jumpDirection.x * moveSpeed # if jumpFromMoving else jumpDirection.x * airMoveSpeed

	# Duplo pulo no ar
	if Input.is_action_just_pressed("jump") and not is_on_floor() and canDoubleJump:
		velocity.y = jumpForce
		canDoubleJump = false

	# Movimentação reduzida no ar (quando o pulo não é iniciado via movimento)
	if not is_on_floor():
		if Input.is_action_pressed("left"):
			velocity.x = -moveSpeed
			transform.basis = Basis(Vector3(0, 1, 0), deg_to_rad(180))
		if Input.is_action_pressed("right"):
			velocity.x = moveSpeed
			transform.basis = Basis(Vector3(0, 1, 0), deg_to_rad(0))
	
	if Input.is_action_just_released("left") or Input.is_action_just_released("right"):
		AudioManager.StopWalk()
	
	if is_on_floor():
		velocity.x = direction.x * moveSpeed
	
	move_and_slide()

func Death(respawn : Marker3D) -> void:
	actualLife -= 15
	%TextureProgressBar.value = actualLife
	print("O jogador perdeu 15 de vida", actualLife)
	if not levelScript.isGameOver:
		ResetPosition(respawn)

func Damage() -> void:
	pass

func ResetPosition(respawn : Marker3D) -> void:
	global_position = respawn.global_position
