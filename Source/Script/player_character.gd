extends CharacterBody3D

@export_category("Movement")
# Define uma velocidade para o personagem
@export var moveSpeed : int = 50
# Velocidade do movimento no ar
@export var airMoveSpeed : float = 20
# Angulo de inclinação
@export var tiltAmount : float = 0.2

@export_category("Jump")
# Gravidade padrão
@export var gravity : float = 9.8
# Força do pulo
@export var jumpForce : float = 5.0
# Direção do pulo
var jumpDirection : Vector3 = Vector3.ZERO
# Indica se o jogador pulou quanto estava andando
var jumpFromMoving : bool = false
# Indica se o personagem pode dar o pulo duplo ou não
var canDoubleJump : bool = true

@export_category("Wall Stick")
# Tempo que o personagem fica grudado na parede
@export var wallStickTime : float = 0.0
# Força do pulo na parede
@export var wallJumpForce : float = 5.0
# marca se o personagem está grudado na parede ou não
var isSticking : bool = false
# Tempo que o jogador pode grudar na parede de novo
var cooldownStickTime : float
# Tempo padrão que o jogador deve espera antes de poder grudar na parede denovo
var stickTimer : float = 0.2

# REFERECNIAS
# Referencia ao nodo da camera
var cameraFollow : Node3D
# Referencia ao RayCast3D
var rayCast : RayCast3D
# Referência à parede que o personagem está grudado
var collider : StaticBody3D

# Função que dispara quando o personagem é carregado na cena
func _ready() -> void:
	# Preenche a variavel com a referencia do nodo da Camera3D
	cameraFollow = get_parent().get_node("CameraFollow")
	# Preenche a variavel com a referencia do nodo do RayCast3D
	rayCast = %RayCast3D
	# Preenche a varivel com a referencia do nodo StickTimer


# Função que lida com a fisica do personagem
func _physics_process(delta: float) -> void:
	var direction = Vector3.ZERO # Direção zerada
	var tilt = 0.0 # Inclinação inicial
	
	if not isSticking and cooldownStickTime > 0:
		cooldownStickTime -= delta
	
	if rayCast.is_colliding() and cooldownStickTime <= 0:
		collider = rayCast.get_collider() # Pega o objeto com que o RayCast colidiu
		var collisionNormal = rayCast.get_collision_normal() # Obtem a normal da superficie
		
		if abs(collisionNormal.x) > 0.8: # Se a normal estiver mais horizontal, é uma parede
			velocity.y = 0
			isSticking = true
	
	# Se o personagem estiver grudado na parede, cancela a gravidade por um tempo
	if isSticking:
		# gravity = 0 # Cancela a gravidade
		if collider.wallSide:
			
			if Input.is_action_just_pressed("right"):
				cooldownStickTime = stickTimer
				velocity.x = airMoveSpeed
				isSticking = false
				transform.basis = Basis(Vector3(0, 1, 0), deg_to_rad(0))
			
			if Input.is_action_just_pressed("jump"):
				cooldownStickTime = stickTimer
				velocity.x = wallJumpForce
				transform.basis = Basis(Vector3(0, 1, 0), deg_to_rad(0))
				velocity.y = 10
				isSticking = false
		else:
			
			if Input.is_action_just_pressed("left"):
				cooldownStickTime = stickTimer
				velocity.x = -airMoveSpeed
				isSticking = false
				transform.basis = Basis(Vector3(0, 1, 0), deg_to_rad(180))
			
			if Input.is_action_just_pressed("jump"):
				cooldownStickTime = stickTimer
				velocity.x = -wallJumpForce
				transform.basis = Basis(Vector3(0, 1, 0), deg_to_rad(180))
				velocity.y = 10
				isSticking = false
	
	velocity.y -= gravity * delta
	
	# Se o personagem estiver no chão
	if is_on_floor():
		canDoubleJump = true
		# Detecta o input do jogador e adiciona o movimento
		if Input.is_action_pressed("left"):
			direction.x -= 1 # faz com que a direção do personagem seja -1 no eixo x
			tilt = -tiltAmount # Inclina o personagem na direção que o jogador está andando
			transform.basis = Basis(Vector3(0, 1, 0), deg_to_rad(180)) # Gira o personagem quando indo pra esquerda
			cameraFollow.global_position = global_position # Ajusta a camera em relação a rotação do personagem
		if Input.is_action_pressed("right"):
			direction.x += 1 # Faz com que a direção do personagem seja 1 no eixo x
			tilt = -tiltAmount # Inclina o personagem na direção que o jogador está se movimentando
			transform.basis = Basis(Vector3(0, 1, 0), deg_to_rad(0))
		
		# Atualizar direção do pulo SOMENTE quando estiver no chão
		if direction.x != 0:
			jumpDirection.x = direction.x * 0.1 # 
			jumpFromMoving = true
		else:
			jumpFromMoving = false
		
		# Define se o jogador estava em movimento antes do pulo
		jumpFromMoving = direction.x != 0
	
	# Faz o personagem pular se ele estiver no chão
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jumpForce # Joga o personagem para cima
		# Verifica se o personagem está em movimento ou não e aplica a velocidade no eixo x adequada para a situação
		velocity.x = jumpDirection.x * moveSpeed if jumpFromMoving else jumpDirection.x * airMoveSpeed
	
	# Faz o personagem dar um segundo pulo no ar
	if Input.is_action_just_pressed("jump") and not is_on_floor() and canDoubleJump:
		velocity.y = jumpForce
		canDoubleJump = false
	
	# Permite movimentação reduzida no ar
	if not is_on_floor() and not jumpFromMoving:
		if Input.is_action_pressed("left"):
			velocity.x = -airMoveSpeed
			transform.basis = Basis(Vector3(0, 1, 0), deg_to_rad(180))
		if Input.is_action_pressed("right"):
			velocity.x = airMoveSpeed
			transform.basis = Basis(Vector3(0, 1, 0), deg_to_rad(0))
	
	# Altera a velocidade do personagem baseado na direção que ele está andando multiplicado pela velocidade padrão do personagem
	if is_on_floor():
		velocity.x = direction.x * moveSpeed
	
	move_and_slide() # Aplicao movimento no personagem
	
	# inclina levemente o personagem para dar a impressão de movimento
	rotation = rotation.lerp(Vector3(rotation.x, rotation.y, tilt), 1.0)


#func _on_stick_timer_timeout() -> void:
	#print("Acabou o timer")
	#isSticking = false
	#if collider.wallSide:
		#velocity.x = wallJumpForce
	#else:
		#velocity.x = -wallJumpForce
