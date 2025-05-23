extends CharacterBody3D

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
# Força do pulo na parede
@export var wallJumpForce : float = 5.0
# Marca se o personagem está grudado na parede ou não
var isSticking : bool = false
# Tempo que o jogador pode grudar na parede de novo
var cooldownStickTime : float
# Tempo padrão que o jogador deve esperar antes de poder grudar na parede novamente
var stickTimer : float = 0.2

# REFERÊNCIAS
# Referência ao nodo da câmera
var cameraFollow : Node3D
# Referência ao RayCast3D
var rayCast : RayCast3D
# Referência à parede que o personagem está grudado
var collider : StaticBody3D

func _ready() -> void:
	# Obtém a referência do nodo da CameraFollow
	cameraFollow = get_parent().get_node("CameraFollow")
	# Obtém a referência do RayCast3D (certifique-se de que o caminho está correto)
	rayCast = $RayCast3D
	# Obtém a referência do Timer para correção do wall jump
	wallJumpCorrectionTimer = %wallJumpCorrectionTimer
	wallJumpCorrectionTimer.wait_time = wallJumpCorrectionWindow
	wallJumpCorrectionTimer.one_shot = true

func _physics_process(delta: float) -> void:
	var direction = Vector3.ZERO
	var tilt = 0.0

	# Atualiza o cooldown quando não está grudado
	if not isSticking and cooldownStickTime > 0:
		cooldownStickTime -= delta

	# Detecta colisão com a parede usando o RayCast3D, se o cooldown permitir
	if rayCast.is_colliding() and cooldownStickTime <= 0:
		collider = rayCast.get_collider()
		var collisionNormal = rayCast.get_collision_normal()
		if abs(collisionNormal.x) > 0.8:
			velocity.y = 0
			isSticking = true

	# Apenas se o jogador pressionar o botão de pulo, sai do estado "sticking"
	if isSticking:
		if Input.is_action_just_pressed("jump"):
			cooldownStickTime = stickTimer
			# Se houver também input direcional, prioriza-o
			if Input.is_action_pressed("left"):
				velocity.x = -wallJumpForce
				transform.basis = Basis(Vector3(0, 1, 0), deg_to_rad(180))
			elif Input.is_action_pressed("right"):
				velocity.x = wallJumpForce
				transform.basis = Basis(Vector3(0, 1, 0), deg_to_rad(0))
			else:
				# Caso nenhum input direcional seja detectado, escolhe o impulso padrão
				if collider.wallSide:
					velocity.x = wallJumpForce
					transform.basis = Basis(Vector3(0, 1, 0), deg_to_rad(0))
				else:
					velocity.x = -wallJumpForce
					transform.basis = Basis(Vector3(0, 1, 0), deg_to_rad(180))
			# Impulso vertical para o wall jump
			velocity.y = 10
			isSticking = false
			recentlyWallJumped = true
			wallJumpCorrectionTimer.start()

	# Durante a janela de correção, permite apenas ajustes na velocidade horizontal
	if recentlyWallJumped and not wallJumpCorrectionTimer.is_stopped():
		if Input.is_action_pressed("left"):
			velocity.x = -airMoveSpeed
			transform.basis = Basis(Vector3(0, 1, 0), deg_to_rad(180))
		elif Input.is_action_pressed("right"):
			velocity.x = airMoveSpeed
			transform.basis = Basis(Vector3(0, 1, 0), deg_to_rad(0))
	# Ao final da janela de correção, reseta o estado
	if wallJumpCorrectionTimer.is_stopped():
		recentlyWallJumped = false

	# Aplica a gravidade
	velocity.y -= gravity * delta

	# Movimentação, inputs e ajustes no chão
	if is_on_floor():
		canDoubleJump = true
		if Input.is_action_pressed("left"):
			direction.x -= 1
			tilt = -tiltAmount
			transform.basis = Basis(Vector3(0, 1, 0), deg_to_rad(180))
			cameraFollow.global_position = global_position
		if Input.is_action_pressed("right"):
			direction.x += 1
			tilt = -tiltAmount
			transform.basis = Basis(Vector3(0, 1, 0), deg_to_rad(0))
		if direction.x != 0:
			jumpDirection.x = direction.x * 0.1
			jumpFromMoving = true
		else:
			jumpFromMoving = false
		jumpFromMoving = direction.x != 0

	# Pulo normal no chão
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jumpForce
		velocity.x = jumpDirection.x * moveSpeed if jumpFromMoving else jumpDirection.x * airMoveSpeed

	# Duplo pulo no ar
	if Input.is_action_just_pressed("jump") and not is_on_floor() and canDoubleJump:
		velocity.y = jumpForce
		canDoubleJump = false

	# Movimentação reduzida no ar (quando o pulo não é iniciado via movimento)
	if not is_on_floor() and not jumpFromMoving:
		if Input.is_action_pressed("left"):
			velocity.x = -airMoveSpeed
			transform.basis = Basis(Vector3(0, 1, 0), deg_to_rad(180))
		if Input.is_action_pressed("right"):
			velocity.x = airMoveSpeed
			transform.basis = Basis(Vector3(0, 1, 0), deg_to_rad(0))

	if is_on_floor():
		velocity.x = direction.x * moveSpeed

	move_and_slide()
	rotation = rotation.lerp(Vector3(rotation.x, rotation.y, tilt), 1.0)
