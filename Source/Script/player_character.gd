extends CharacterBody3D

# Define uma velocidade para o personagem
@export var moveSpeed : int = 50
# Velocidade do movimento no ar
@export var airMoveSpeed : float = 20
# Angulo de inclinação
@export var tiltAmount : float = 0.2
# Gravidade padrão
@export var gravity : float = 9.8
# Força do pulo
@export var jumpForce : float = 5.0

# Lida com a direção do pulo
var jumpDirection : Vector3 = Vector3.ZERO
# Indica se o jogador pulou quanto estava andando
var jumpFromMoving : bool = false
# Indica se o personagem pode dar o pulo duplo ou não
var canDoubleJump : bool = true

# Referencia ao nodo da camera
var cameraFollow : Node3D

# Função que dispara quando o personagem é carregado na cena
func _ready() -> void:
	# Preenche a varivel com a referencia do nodo da camera
	cameraFollow = get_parent().get_node("CameraFollow")

# Função que lida com a fisica do personagem
func _physics_process(delta: float) -> void:
	var direction = Vector3.ZERO # Direção zerada
	var tilt = 0.0 # Inclinação inicial
	
	# Aplica a gravidade
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
	
	# Faz o personagem pular
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jumpForce # Joga o personagem para cima
		# Verifica se o personagem está em movimento ou não e aplica a velocidade no eixo x adequada para a situação
		velocity.x = jumpDirection.x * moveSpeed if jumpFromMoving else jumpDirection.x * airMoveSpeed
	
	if Input.is_action_just_pressed("jump") and not is_on_floor() and canDoubleJump:
		velocity.y = jumpForce
		canDoubleJump = false
	
	# Permite movimentação reduzida no ar
	if not is_on_floor() and not jumpFromMoving:
		if Input.is_action_pressed("left"):
			velocity.x = -airMoveSpeed
		if Input.is_action_pressed("right"):
			velocity.x = airMoveSpeed
	
	# Altera a velocidade do personagem baseado na direção que ele está andando multiplicado pela velocidade padrão do personagem
	if is_on_floor():
		velocity.x = direction.x * moveSpeed
	
	move_and_slide() # Aplicao movimento no personagem
	
	# inclina levemente o personagem para dar a impressão de movimento
	rotation = rotation.lerp(Vector3(rotation.x, rotation.y, tilt), 1.0)
