class_name Crate
extends RigidBody3D

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is Player:
		body.Death()

func Kabum() -> void:
	print("Kabum!")
	queue_free()

func FogoNaBomba(time : float) -> void:
	print("Fogo na bomba")
	var timerBomb : Timer = Timer.new()
	timerBomb.wait_time = time
	timerBomb.timeout.connect(Kabum)
	timerBomb.autostart = true
	add_child(timerBomb)
