extends StaticBody3D

@export var startPositionMarker : Marker3D
@export var endPositionMarker : Marker3D
@export var speed : float = 3

var startPosition : Vector3
var endPosition : Vector3
var goingToEnd : bool = true
var playerReference : Player
var moveTo : Vector3

func _ready() -> void:
	startPosition = startPositionMarker.global_position
	endPosition = endPositionMarker.global_position
	position = startPosition

func _physics_process(delta: float) -> void:
	if goingToEnd:
		moveTo = endPosition
	else:
		moveTo = startPosition
	
	position = position.move_toward(moveTo, speed * delta)
	
	if position.distance_to(moveTo) < 1:
		goingToEnd = not goingToEnd
	
	if playerReference:
		playerReference.position -= position - position.move_toward(moveTo, speed * delta)

func _on_area_3d_body_entered(body: Node3D) -> void:
	
	if body is Player:
		print("O jogador entrou")
		playerReference = body

func _on_area_3d_body_exited(body: Node3D) -> void:
	
	if body is Player:
		print("O jogador saiu")
		playerReference = null
