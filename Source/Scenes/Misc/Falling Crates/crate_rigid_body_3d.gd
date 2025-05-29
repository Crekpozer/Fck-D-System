class_name Crate
extends RigidBody3D

@onready var audioStreamPlayer : AudioStreamPlayer3D = %AudioStreamPlayer3D

var isMoving : bool
var canBeDestoyed : bool

func _physics_process(_delta: float) -> void:
	if linear_velocity.length() > 1:
		print(linear_velocity.length())
		isMoving = true
	else:
		isMoving = false
	
	if not isMoving and canBeDestoyed:
		queue_free()

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is Player:
		body.Death()

func Kabum() -> void:
	print("Kabum!")
	audioStreamPlayer.play()
	await audioStreamPlayer.finished
	canBeDestoyed = true

func FogoNaBomba(time : float) -> void:
	print("Fogo na bomba")
	var timerBomb : Timer = Timer.new()
	timerBomb.wait_time = time
	timerBomb.one_shot = true
	timerBomb.timeout.connect(Kabum)
	add_child(timerBomb)
	timerBomb.autostart = true
