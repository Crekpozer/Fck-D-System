extends Node3D

@onready var crate : PackedScene = preload("res://Source/Scenes/Misc/Falling Crates/crate_rigid_body_3d.tscn")

@export var rechargeTime : float = 5
@export var destroyCrateTime : float
@export var respawnPoint : Marker3D

var hasCrates : bool = true
var activivationArea : Area3D


func _ready() -> void:
	%DispenserTimer.wait_time = rechargeTime

func _on_dispenser_timer_timeout() -> void:
	hasCrates = true

func _on_activation_area_3d_body_entered(body: Node3D) -> void:
		if body is Player:
			if hasCrates:
				hasCrates = false
				%DispenserTimer.start()
				%AudioStreamPlayer3D.play()
				var fallingCrate = crate.instantiate()
				fallingCrate.global_position = %Marker3D.global_position
				fallingCrate.respawnPoint = respawnPoint
				fallingCrate.FogoNaBomba(destroyCrateTime)
				get_parent().add_child(fallingCrate)
