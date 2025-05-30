extends Node3D

@onready var crate : PackedScene = preload("res://Source/Scenes/Misc/Falling Crates/crate_rigid_body_3d.tscn")

@export var rechargeTime : float = 5
@export var destroyCrateTime : float
var hasCrates : bool = true
var activivationArea : Area3D

func _ready() -> void:
	%DispenserTimer.wait_time = rechargeTime

func _on_dispenser_timer_timeout() -> void:
	hasCrates = true

func _on_activation_area_3d_body_entered(body: Node3D) -> void:
		if body is Player:
			if hasCrates:
				%AudioStreamPlayer3D.play()
				await %AudioStreamPlayer3D.finished
				var fallingCrate = crate.instantiate()
				fallingCrate.global_position = %Marker3D.global_position
				fallingCrate.FogoNaBomba(destroyCrateTime)
				hasCrates = false
				get_parent().add_child(fallingCrate)
				%DispenserTimer.start()
