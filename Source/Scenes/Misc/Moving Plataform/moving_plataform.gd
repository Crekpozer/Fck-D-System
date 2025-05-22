extends StaticBody3D


func _on_area_3d_body_entered(body: Node3D) -> void:
	print("O jogador entrou")
	reparent(body)


func _on_area_3d_body_exited(body: Node3D) -> void:
	body.reparent(get_tree().root)
